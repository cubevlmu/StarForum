import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:star_forum/data/api/api_constants.dart';

abstract final class ForumHttpTransport {
  static const idleTimeout = Duration(seconds: 30);
  static const maxConnectionsPerHost = 6;
  static const jsonIsolateThreshold = 256 * 1024;
  static final String? _systemProxy = _resolveSystemProxy();

  static Dio create({String? proxy, bool useSystemProxy = true}) {
    final resolvedProxy = proxy ?? (useSystemProxy ? _systemProxy : null);
    final dio = Dio(
      BaseOptions(
        headers: {
          'user-agent': ApiConstants.userAgent,
          'Accept-Encoding': 'gzip',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        persistentConnection: true,
      ),
    );
    dio.transformer = FusedTransformer(
      contentLengthIsolateThreshold: jsonIsolateThreshold,
    );
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient()
          ..idleTimeout = idleTimeout
          ..maxConnectionsPerHost = maxConnectionsPerHost;
        if (resolvedProxy != null && resolvedProxy.isNotEmpty) {
          client.findProxy = (_) => 'PROXY $resolvedProxy';
        }
        return client;
      },
    );
    return dio;
  }

  static String? _resolveSystemProxy() {
    final proxy = _proxyFromEnvironment() ?? _queryWindowsProxy();
    return proxy == null ? null : _normalizeProxyHostPort(proxy);
  }

  static String? _proxyFromEnvironment() {
    final env = Platform.environment;
    for (final key in const [
      'HTTPS_PROXY',
      'https_proxy',
      'HTTP_PROXY',
      'http_proxy',
      'ALL_PROXY',
      'all_proxy',
    ]) {
      final value = env[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _queryWindowsProxy() {
    if (!Platform.isWindows) return null;

    const keyPath =
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings';
    final enabled = Process.runSync('reg', [
      'query',
      keyPath,
      '/v',
      'ProxyEnable',
    ]);
    if (enabled.exitCode != 0 || !enabled.stdout.toString().contains('0x1')) {
      return null;
    }

    final proxy = Process.runSync('reg', [
      'query',
      keyPath,
      '/v',
      'ProxyServer',
    ]);
    if (proxy.exitCode != 0) return null;

    for (final line in proxy.stdout.toString().split(RegExp(r'[\r\n]+'))) {
      if (!line.contains('ProxyServer')) continue;
      final parts = line.trim().split(RegExp(r'\s{2,}'));
      if (parts.length >= 3) return _extractWindowsProxyServer(parts.last);
    }
    return null;
  }

  static String? _extractWindowsProxyServer(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (!value.contains('=')) return value;

    final entries = value.split(';');
    for (final scheme in const ['https', 'http']) {
      for (final entry in entries) {
        final separator = entry.indexOf('=');
        if (separator <= 0) continue;
        final key = entry.substring(0, separator).trim().toLowerCase();
        final proxy = entry.substring(separator + 1).trim();
        if (key == scheme && proxy.isNotEmpty) return proxy;
      }
    }
    for (final entry in entries) {
      final separator = entry.indexOf('=');
      if (separator <= 0) continue;
      final proxy = entry.substring(separator + 1).trim();
      if (proxy.isNotEmpty) return proxy;
    }
    return null;
  }

  static String? _normalizeProxyHostPort(String value) {
    final proxy = value.trim();
    if (proxy.isEmpty) return null;
    final uri = Uri.tryParse(proxy);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return '${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    }
    return proxy;
  }
}
