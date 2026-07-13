import 'dart:math';

import 'package:dio/dio.dart';
import 'package:star_forum/data/api/api_constants.dart';
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/utils/string_util.dart';

import 'flarum_api_environment.dart';
import 'flarum_auth.dart';
import 'flarum_transport_error.dart';
import 'json_api/json_api_document.dart';

class FlarumApiClient {
  FlarumApiClient(this._dio)
    : _environment = const FlarumApiEnvironment(baseUrl: '') {
    _dio.options.headers.addAll({
      'Accept': 'application/vnd.api+json, application/json',
      'Content-Type': 'application/vnd.api+json',
      'Accept-Encoding': 'gzip',
      'User-Agent': ApiConstants.userAgent,
    });
  }

  final Dio _dio;
  FlarumApiEnvironment _environment;
  FlarumAuthToken _auth = const FlarumAuthToken.none();
  final Map<String, Future<Response<dynamic>>> _pending = {};
  final Random _random = Random();

  FlarumApiEnvironment get environment => _environment;
  String get baseUrl => _environment.baseUrl;
  FlarumAuthToken get auth => _auth;

  void setEnvironment(FlarumApiEnvironment env) {
    if (_environment.baseUrl != env.baseUrl) {
      _pending.clear();
    }
    _environment = env.copyWith(
      baseUrl: StringUtil.normalizeSiteUrl(env.baseUrl) ?? '',
    );
  }

  void setAuth(FlarumAuthToken token) {
    if (_auth.kind != token.kind || _auth.token != token.token) {
      _pending.clear();
    }
    _auth = token;
    final header = token.toAuthorizationHeader();
    if (header == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = header;
    }
  }

  void clearAuth() => setAuth(const FlarumAuthToken.none());

  String resolveUrl(String path) {
    final uri = Uri.parse(path);
    if (uri.hasScheme) {
      final base = Uri.parse(baseUrl);
      if (uri.scheme != base.scheme ||
          uri.host != base.host ||
          uri.port != base.port) {
        throw const FlarumTransportError(
          message: 'Cross-origin pagination URL was rejected.',
          path: '',
        );
      }
      return uri.toString();
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalized';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    final url = resolveUrl(path);
    if (cancelToken != null || options != null) {
      return _request(
        path,
        'GET',
        () => _dio.get<T>(
          url,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        ),
      );
    }
    final key = _requestKey<T>(url, query);
    final pending = _pending[key];
    PerfLog.coalescing('http', hit: pending != null);
    if (pending != null) return pending.then((value) => value as Response<T>);

    return _fetch<T>(
      path: path,
      method: 'GET',
      url: url,
      key: key,
      query: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> _fetch<T>({
    required String path,
    required String method,
    required String url,
    required String key,
    required Map<String, dynamic>? query,
    required Options? options,
    required CancelToken? cancelToken,
  }) {
    final request = _request(
      path,
      method,
      () => _dio.get<T>(
        url,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
    );
    _pending[key] = request;
    return request.whenComplete(() {
      if (identical(_pending[key], request)) _pending.remove(key);
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => _writeRequest(
    path,
    'POST',
    () => _dio.post<T>(
      resolveUrl(path),
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => _writeRequest(
    path,
    'PATCH',
    () => _dio.patch<T>(
      resolveUrl(path),
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => _writeRequest(
    path,
    'DELETE',
    () => _dio.delete<T>(
      resolveUrl(path),
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> _writeRequest<T>(
    String path,
    String method,
    Future<Response<T>> Function() call,
  ) async {
    return _request(path, method, call);
  }

  String _requestKey<T>(String url, Map<String, dynamic>? query) {
    final normalizedQuery = query == null
        ? null
        : <String, String>{
            for (final key in query.keys.toList(growable: false)..sort())
              key: query[key].toString(),
          };
    final uri = Uri.parse(url).replace(queryParameters: normalizedQuery);
    return 'GET<$T> ${uri.toString()}';
  }

  Future<Response<T>> _request<T>(
    String path,
    String method,
    Future<Response<T>> Function() call,
  ) async {
    final watch = Stopwatch()..start();
    var requestMs = 0;
    var attempt = 0;
    while (true) {
      attempt += 1;
      final attemptWatch = Stopwatch()..start();
      try {
        final header = _auth.toAuthorizationHeader();
        if (header != null) {
          _dio.options.headers['Authorization'] = header;
        }
        final response = await call();
        attemptWatch.stop();
        requestMs += attemptWatch.elapsedMilliseconds;
        watch.stop();
        PerfLog.request(
          '$method ${Uri.parse(resolveUrl(path)).path}',
          requestMs: requestMs,
          totalMs: watch.elapsedMilliseconds,
          details: _responseDetails(response, attempt),
        );
        return response;
      } on DioException catch (error) {
        attemptWatch.stop();
        requestMs += attemptWatch.elapsedMilliseconds;
        if (_shouldRetry(method, error, attempt)) {
          await Future<void>.delayed(_retryDelay(attempt, error));
          continue;
        }
        watch.stop();
        PerfLog.request(
          '$method ${Uri.parse(resolveUrl(path)).path}',
          requestMs: requestMs,
          totalMs: watch.elapsedMilliseconds,
          details:
              'status=${error.response?.statusCode ?? 'network-error'} attempts=$attempt',
        );
        final document = JsonApiDocument.from(error.response?.data);
        final apiError = document.errors.isEmpty ? null : document.errors.first;
        throw FlarumTransportError(
          message: apiError?.detail ?? error.message ?? 'Request failed.',
          path: Uri.parse(resolveUrl(path)).path,
          statusCode: error.response?.statusCode,
          errors: document.errors,
          cause: error,
          cancelled: CancelToken.isCancel(error),
          network:
              error.response == null &&
              error.type != DioExceptionType.badResponse,
          kind: _transportErrorKind(error),
        );
      }
    }
  }

  FlarumTransportErrorKind _transportErrorKind(DioException error) {
    if (CancelToken.isCancel(error)) {
      return FlarumTransportErrorKind.cancelled;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return FlarumTransportErrorKind.timeout;
    }
    final status = error.response?.statusCode;
    if (status != null) {
      return status >= 500
          ? FlarumTransportErrorKind.server
          : FlarumTransportErrorKind.client;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return FlarumTransportErrorKind.networkUnavailable;
    }
    return FlarumTransportErrorKind.unknown;
  }

  String _responseDetails(Response<dynamic> response, int attempts) {
    final contentLength = response.headers.value(Headers.contentLengthHeader);
    final encoding = response.headers.value(Headers.contentEncodingHeader);
    final httpVersion = response.extra[HttpClientAdapter.extraKeyHttpVersion]
        ?.toString();
    return [
      'status=${response.statusCode}',
      'attempts=$attempts',
      if (contentLength != null) 'bytes=$contentLength',
      if (encoding != null) 'encoding=$encoding',
      if (httpVersion != null) 'http=$httpVersion',
    ].join(' ');
  }

  bool _shouldRetry(String method, DioException error, int attempt) {
    if (method != 'GET' || attempt >= 3 || CancelToken.isCancel(error)) {
      return false;
    }
    final status = error.response?.statusCode;
    if (status != null) {
      return status == 408 || status == 429 || status >= 500;
    }
    return error.type != DioExceptionType.badCertificate &&
        error.type != DioExceptionType.badResponse;
  }

  Duration _retryDelay(int attempt, DioException error) {
    final retryAfter = int.tryParse(
      error.response?.headers.value('retry-after') ?? '',
    );
    if (retryAfter != null && retryAfter >= 0) {
      return Duration(seconds: retryAfter.clamp(0, 30));
    }
    final exponentialMs = 250 * (1 << (attempt - 1));
    return Duration(milliseconds: exponentialMs + _random.nextInt(151));
  }
}
