import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_api_environment.dart';
import 'package:star_forum/data/api/forum_http_transport.dart';
import 'package:star_forum/data/perf/perf_config.dart';

const int _iterations = int.fromEnvironment(
  'BENCH_ITERATIONS',
  defaultValue: 100,
);
const int _idleProbeSeconds = int.fromEnvironment(
  'BENCH_IDLE_SECONDS',
  defaultValue: 4,
);

void main() {
  test('network layer benchmark', () async {
    PerfConfig.configure(enabled: false);
    addTearDown(PerfConfig.reset);
    final payload = _buildPayload();
    final encodedPayload = jsonEncode(payload);
    final remotePorts = <int>{};
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.autoCompress = true;
    server.listen((request) async {
      final remotePort = request.connectionInfo?.remotePort;
      if (remotePort != null) remotePorts.add(remotePort);
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        request.uri.path == '/payload'
            ? encodedPayload
            : '{"data":{"type":"benchmark","id":"1"}}',
      );
      await request.response.close();
    });
    addTearDown(() => server.close(force: true));

    final baseUrl = 'http://${server.address.address}:${server.port}';
    _writeEvent('BENCH_CONFIG', {
      'iterations': _iterations,
      'payloadBytes': utf8.encode(encodedPayload).length,
      'idleProbeSeconds': _idleProbeSeconds,
      'dartVersion': Platform.version,
      'operatingSystem': Platform.operatingSystemVersion,
    });

    final backgroundDio = Dio(
      BaseOptions(
        headers: {'Accept-Encoding': 'gzip'},
        responseType: ResponseType.json,
        persistentConnection: true,
      ),
    )..transformer = BackgroundTransformer();
    await _measure(
      'http_background_json_decode',
      iterations: _iterations,
      operation: (iteration) =>
          backgroundDio.get<Object?>('$baseUrl/payload?iteration=$iteration'),
    );
    backgroundDio.close(force: true);

    final optimizedDio = ForumHttpTransport.create(useSystemProxy: false);
    addTearDown(() => optimizedDio.close(force: true));
    await _measure(
      'http_fused_json_decode',
      iterations: _iterations,
      operation: (iteration) =>
          optimizedDio.get<Object?>('$baseUrl/payload?iteration=$iteration'),
    );

    remotePorts.clear();
    await optimizedDio.get<Object?>('$baseUrl/keep-alive');
    await Future<void>.delayed(Duration(seconds: _idleProbeSeconds));
    await optimizedDio.get<Object?>('$baseUrl/keep-alive?second=true');
    expect(remotePorts, hasLength(1));
    _writeEvent('BENCH_CHECK', {
      'name': 'connection_reused_after_idle',
      'idleSeconds': _idleProbeSeconds,
      'tcpConnections': remotePorts.length,
    });

    final countingAdapter = _CountingAdapter();
    final coalescingDio = Dio()..httpClientAdapter = countingAdapter;
    addTearDown(() => coalescingDio.close(force: true));
    final apiClient = FlarumApiClient(coalescingDio)
      ..setEnvironment(
        const FlarumApiEnvironment(baseUrl: 'https://benchmark.invalid'),
      );
    final responses = await Future.wait([
      for (var index = 0; index < 100; index += 1)
        apiClient.get<Object?>('/slow'),
    ]);
    expect(responses, hasLength(100));
    expect(countingAdapter.requestCount, 1);
    _writeEvent('BENCH_CHECK', {
      'name': 'get_request_coalescing_100',
      'serverRequests': countingAdapter.requestCount,
    });

    countingAdapter.requestCount = 0;
    await Future.wait([
      apiClient.get<Object?>('/cancel-aware', cancelToken: CancelToken()),
      apiClient.get<Object?>('/cancel-aware', cancelToken: CancelToken()),
    ]);
    expect(countingAdapter.requestCount, 2);

    countingAdapter.requestCount = 0;
    await Future.wait([
      apiClient.get<Object?>(
        '/custom-options',
        options: Options(headers: {'X-Benchmark-Variant': 'a'}),
      ),
      apiClient.get<Object?>(
        '/custom-options',
        options: Options(headers: {'X-Benchmark-Variant': 'b'}),
      ),
    ]);
    expect(countingAdapter.requestCount, 2);
    _writeEvent('BENCH_CHECK', {
      'name': 'get_coalescing_respects_request_semantics',
      'cancelTokenRequests': 2,
      'customOptionsRequests': 2,
    });
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<void> _measure(
  String name, {
  required int iterations,
  required Future<Object?> Function(int iteration) operation,
}) async {
  for (var iteration = 0; iteration < min(10, iterations); iteration += 1) {
    await operation(iteration);
  }

  final samples = <int>[];
  final rssBefore = ProcessInfo.currentRss;
  final total = Stopwatch()..start();
  for (var iteration = 0; iteration < iterations; iteration += 1) {
    final watch = Stopwatch()..start();
    await operation(iteration);
    watch.stop();
    samples.add(watch.elapsedMicroseconds);
  }
  total.stop();
  samples.sort();
  final totalUs = total.elapsedMicroseconds;
  _writeEvent('BENCH_RESULT', {
    'name': name,
    'iterations': iterations,
    'totalMs': totalUs / 1000,
    'meanUs': totalUs / iterations,
    'p50Us': _percentile(samples, 0.50),
    'p95Us': _percentile(samples, 0.95),
    'opsPerSecond': iterations * Duration.microsecondsPerSecond / totalUs,
    'rssDeltaKb': (ProcessInfo.currentRss - rssBefore) / 1024,
  });
}

Map<String, Object?> _buildPayload() {
  return <String, Object?>{
    'data': [
      for (var index = 0; index < 500; index += 1)
        <String, Object?>{
          'type': 'benchmark',
          'id': '$index',
          'attributes': <String, Object?>{
            'title': 'Network benchmark item $index',
            'content': '${'payload-$index ' * 12}end',
            'count': index,
          },
        },
    ],
  };
}

int _percentile(List<int> sortedSamples, double percentile) {
  final index = ((sortedSamples.length - 1) * percentile).round();
  return sortedSamples[index];
}

void _writeEvent(String type, Map<String, Object?> values) {
  stdout.writeln('$type ${jsonEncode(values)}');
}

class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return ResponseBody.fromString(
      '{"data":{"type":"benchmark","id":"1"}}',
      HttpStatus.ok,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
