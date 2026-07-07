import 'dart:async';

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
  final Map<
    String,
    ({Response<dynamic> response, DateTime freshUntil, DateTime staleUntil})
  >
  _cache = {};
  final Map<String, Future<Response<dynamic>>> _pending = {};

  FlarumApiEnvironment get environment => _environment;
  String get baseUrl => _environment.baseUrl;
  FlarumAuthToken get auth => _auth;

  void setEnvironment(FlarumApiEnvironment env) {
    if (_environment.baseUrl != env.baseUrl) {
      _cache.clear();
      _pending.clear();
    }
    _environment = env.copyWith(
      baseUrl: StringUtil.normalizeSiteUrl(env.baseUrl) ?? '',
    );
  }

  void setAuth(FlarumAuthToken token) {
    if (_auth.kind != token.kind || _auth.token != token.token) {
      _cache.clear();
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
    bool bypassCache = false,
  }) {
    final url = resolveUrl(path);
    final key = _requestKey(url, query);
    final cached = bypassCache ? null : _cache[key];
    final now = DateTime.now();
    if (cached != null && now.isBefore(cached.freshUntil)) {
      return Future.value(cached.response as Response<T>);
    }
    if (cached != null && now.isBefore(cached.staleUntil)) {
      if (!_pending.containsKey(key)) {
        unawaited(
          _fetchAndCache<T>(
            path: path,
            method: 'GET',
            url: url,
            key: key,
            query: query,
            options: options,
            cancelToken: null,
          ).catchError((_) => cached.response as Response<T>),
        );
      }
      return Future.value(cached.response as Response<T>);
    }
    _cache.remove(key);
    final pending = bypassCache ? null : _pending[key];
    if (pending != null) return pending.then((value) => value as Response<T>);

    return _fetchAndCache<T>(
      path: path,
      method: 'GET',
      url: url,
      key: key,
      query: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> _fetchAndCache<T>({
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
    return request
        .then((response) {
          final policy = _cachePolicy(url, query);
          final now = DateTime.now();
          _cache[key] = (
            response: response,
            freshUntil: now.add(policy.fresh),
            staleUntil: now.add(policy.stale),
          );
          return response;
        })
        .whenComplete(() {
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
    final response = await _request(path, method, call);
    _invalidateForPath(path);
    return response;
  }

  String _requestKey(String url, Map<String, dynamic>? query) {
    final uri = Uri.parse(url).replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    return 'GET ${uri.toString()}';
  }

  ({Duration fresh, Duration stale}) _cachePolicy(
    String url,
    Map<String, dynamic>? query,
  ) {
    final path = Uri.parse(url).path;
    final offset = int.tryParse(query?['page[offset]']?.toString() ?? '') ?? 0;
    if (path == '/api') {
      return (
        fresh: const Duration(minutes: 5),
        stale: const Duration(days: 1),
      );
    }
    if (path == '/api/tags') {
      return (
        fresh: const Duration(minutes: 10),
        stale: const Duration(days: 1),
      );
    }
    if (path.contains('/notifications')) {
      return (
        fresh: const Duration(seconds: 8),
        stale: const Duration(minutes: 2),
      );
    }
    if (path.contains('/posts')) {
      return (
        fresh: const Duration(seconds: 30),
        stale: const Duration(minutes: 30),
      );
    }
    if (path.contains('/users/')) {
      return (
        fresh: const Duration(minutes: 2),
        stale: const Duration(days: 1),
      );
    }
    if (path == '/api/users') {
      return (
        fresh: const Duration(minutes: 2),
        stale: const Duration(minutes: 30),
      );
    }
    if (path == '/api/discussions') {
      return offset == 0
          ? (
              fresh: const Duration(seconds: 20),
              stale: const Duration(minutes: 10),
            )
          : (
              fresh: const Duration(minutes: 1),
              stale: const Duration(minutes: 30),
            );
    }
    if (path.startsWith('/api/discussions/')) {
      return (
        fresh: const Duration(seconds: 30),
        stale: const Duration(minutes: 30),
      );
    }
    return (
      fresh: const Duration(seconds: 20),
      stale: const Duration(minutes: 5),
    );
  }

  void _invalidateForPath(String path) {
    final uriPath = Uri.parse(resolveUrl(path)).path;
    final targets = <String>{uriPath};
    if (uriPath.contains('/posts') || uriPath.contains('/discussions')) {
      targets.addAll({'/api/posts', '/api/discussions'});
    }
    if (uriPath.contains('/notifications')) {
      targets.add('/api/notifications');
    }
    if (uriPath.contains('/users')) targets.add('/api/users');
    _cache.removeWhere(
      (key, _) => targets.any((target) => key.contains(target)),
    );
  }

  Future<Response<T>> _request<T>(
    String path,
    String method,
    Future<Response<T>> Function() call,
  ) async {
    final watch = Stopwatch()..start();
    try {
      final header = _auth.toAuthorizationHeader();
      if (header != null) {
        _dio.options.headers['Authorization'] = header;
      }
      final response = await call();
      watch.stop();
      PerfLog.request(
        '$method ${Uri.parse(resolveUrl(path)).path}',
        requestMs: watch.elapsedMilliseconds,
        totalMs: watch.elapsedMilliseconds,
        details: 'status=${response.statusCode}',
      );
      return response;
    } on DioException catch (error) {
      watch.stop();
      PerfLog.request(
        '$method ${Uri.parse(resolveUrl(path)).path}',
        requestMs: watch.elapsedMilliseconds,
        totalMs: watch.elapsedMilliseconds,
        details: 'status=${error.response?.statusCode ?? 'network-error'}',
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
      );
    }
  }
}
