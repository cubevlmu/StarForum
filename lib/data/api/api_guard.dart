/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:star_forum/data/api/api_log.dart';
import 'package:star_forum/data/perf/perf_log.dart';

class ApiRequestCachePolicy {
  const ApiRequestCachePolicy({
    required this.key,
    required this.ttl,
    this.dedupeInFlight = true,
  });

  final String key;
  final Duration ttl;
  final bool dedupeInFlight;
}

class _ApiRequestCacheEntry {
  const _ApiRequestCacheEntry({required this.value, required this.expiresAt});

  final Object? value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class _ApiPhasedMetrics {
  int? prepareMs;
  int? requestMs;
  int? parseMs;
  int? responseBytes;
  int? responseItems;
  int totalMs = 0;

  String buildDetails({String? cacheState}) {
    final parts = <String>[];
    if (cacheState != null) {
      parts.add('cache=$cacheState');
    }
    if (prepareMs != null) {
      parts.add('prepare=${prepareMs}ms');
    }
    if (requestMs != null) {
      parts.add('request=${requestMs}ms');
    }
    if (parseMs != null) {
      parts.add('parse=${parseMs}ms');
    }
    if (responseBytes != null) {
      parts.add('bytes=$responseBytes');
    }
    if (responseItems != null) {
      parts.add('items=$responseItems');
    }
    parts.add('total=${totalMs}ms');
    return parts.join(' ');
  }
}

class ApiGuard {
  static final Map<String, _ApiRequestCacheEntry> _memoryCache =
      <String, _ApiRequestCacheEntry>{};
  static final Map<String, Future<Object?>> _pendingRequests =
      <String, Future<Object?>>{};

  static void clearRequestCache() {
    _memoryCache.clear();
  }

  static void invalidateRequestCache(bool Function(String key) predicate) {
    final keys = _memoryCache.keys.where(predicate).toList(growable: false);
    for (final key in keys) {
      _memoryCache.remove(key);
    }
  }

  static T? _readCache<T>(ApiRequestCachePolicy policy) {
    final entry = _memoryCache[policy.key];
    if (entry == null) {
      return null;
    }
    if (entry.isExpired) {
      _memoryCache.remove(policy.key);
      return null;
    }
    return entry.value as T;
  }

  static void _writeCache<T>(ApiRequestCachePolicy policy, T value) {
    _memoryCache[policy.key] = _ApiRequestCacheEntry(
      value: value,
      expiresAt: DateTime.now().add(policy.ttl),
    );
  }

  static String _dioErrorDetails(DioException e) {
    final response = e.response;
    final status = response?.statusCode;
    final statusMessage = response?.statusMessage;
    final type = e.type.name;
    final body = response?.data;
    final bodyText = body == null ? '' : body.toString();
    final shortBody = bodyText.length > 320
        ? '${bodyText.substring(0, 320)}...'
        : bodyText;
    final parts = <String>[
      'type=$type',
      if (status != null) 'status=$status',
      if (statusMessage != null && statusMessage.isNotEmpty)
        'message=$statusMessage',
      if (shortBody.isNotEmpty) 'body=$shortBody',
    ];
    return parts.join(' ');
  }

  static bool _isAuthExpired(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) return true;
    if (status == 403) {
      final body = e.response?.data.toString().toLowerCase() ?? '';
      return body.contains('csrf') || body.contains('token');
    }
    return false;
  }

  static int? _responsePayloadBytes(Object? raw) {
    if (raw is Response) {
      final contentLength = raw.headers.value(Headers.contentLengthHeader);
      final parsed = contentLength == null ? null : int.tryParse(contentLength);
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
      return _bodyPayloadBytes(raw.data);
    }
    return _bodyPayloadBytes(raw);
  }

  static int? _responsePayloadItems(Object? raw) {
    final data = raw is Response ? raw.data : raw;
    if (data is! Map) {
      return null;
    }

    var count = 0;
    final dataNode = data['data'];
    if (dataNode is List) {
      count += dataNode.length;
    } else if (dataNode != null) {
      count += 1;
    }

    final included = data['included'];
    if (included is List) {
      count += included.length;
    }
    return count;
  }

  static int? _bodyPayloadBytes(Object? data) {
    if (data == null) {
      return 0;
    }
    if (data is String) {
      return data.length;
    }
    if (data is List<int>) {
      return data.length;
    }
    return null;
  }

  static Future<T> _executePhased<T, TPrepared, TRaw>({
    required String name,
    required String method,
    required Future<TPrepared> Function() prepare,
    required Future<TRaw> Function(TPrepared prepared) request,
    required Future<T> Function(TRaw raw, TPrepared prepared) parse,
    String? extra,
    void Function(
      int totalMs,
      int prepareMs,
      int requestMs,
      int parseMs,
      T result,
    )?
    onFinished,
  }) async {
    final metrics = _ApiPhasedMetrics();
    final totalSw = Stopwatch()..start();
    final prepareSw = Stopwatch()..start();

    final prepared = await prepare();
    prepareSw.stop();
    metrics.prepareMs = prepareSw.elapsedMilliseconds;

    final requestSw = Stopwatch()..start();
    final raw = await request(prepared);
    requestSw.stop();
    metrics.requestMs = requestSw.elapsedMilliseconds;
    metrics.responseBytes = _responsePayloadBytes(raw);
    metrics.responseItems = _responsePayloadItems(raw);

    final parseSw = Stopwatch()..start();
    final result = await parse(raw, prepared);
    parseSw.stop();
    metrics.parseMs = parseSw.elapsedMilliseconds;

    totalSw.stop();
    metrics.totalMs = totalSw.elapsedMilliseconds;

    ApiLog.ok(name, "[$method] ${metrics.buildDetails()}", extra);
    PerfLog.request(
      '$method $name',
      requestMs: metrics.requestMs ?? 0,
      parseMs: metrics.parseMs,
      totalMs: metrics.totalMs,
      details: extra,
    );
    onFinished?.call(
      metrics.totalMs,
      metrics.prepareMs ?? 0,
      metrics.requestMs ?? 0,
      metrics.parseMs ?? 0,
      result,
    );
    return result;
  }

  static Future<T> _runPhasedCached<T, TPrepared, TRaw>({
    required String name,
    required String method,
    required Future<TPrepared> Function() prepare,
    required Future<TRaw> Function(TPrepared prepared) request,
    required Future<T> Function(TRaw raw, TPrepared prepared) parse,
    String? extra,
    required T fallback,
    ApiRequestCachePolicy? cachePolicy,
    void Function(
      int totalMs,
      int prepareMs,
      int requestMs,
      int parseMs,
      T result,
    )?
    onFinished,
  }) async {
    if (cachePolicy != null) {
      final cached = _readCache<T>(cachePolicy);
      if (cached != null) {
        ApiLog.ok(name, "[$method] cache=hit total=0ms", extra);
        return cached;
      }

      if (cachePolicy.dedupeInFlight) {
        final pending = _pendingRequests[cachePolicy.key];
        if (pending != null) {
          ApiLog.ok(name, "[$method] cache=join total=0ms", extra);
          return await pending as T;
        }
      }
    }

    Future<T> future() async {
      try {
        final result = await _executePhased<T, TPrepared, TRaw>(
          name: name,
          method: method,
          prepare: prepare,
          request: request,
          parse: parse,
          extra: extra,
          onFinished: onFinished,
        );
        if (cachePolicy != null) {
          _writeCache(cachePolicy, result);
        }
        return result;
      } catch (e, s) {
        ApiLog.exception(name, "[$method] total=0ms", e, s);
        return fallback;
      }
    }

    if (cachePolicy == null || !cachePolicy.dedupeInFlight) {
      return future();
    }

    final pendingFuture = future();
    _pendingRequests[cachePolicy.key] = pendingFuture;
    try {
      return await pendingFuture;
    } finally {
      if (identical(_pendingRequests[cachePolicy.key], pendingFuture)) {
        _pendingRequests.remove(cachePolicy.key);
      }
    }
  }

  static Future<T> runPhased<T, TPrepared, TRaw>({
    required String name,
    required String method,
    required Future<TPrepared> Function() prepare,
    required Future<TRaw> Function(TPrepared prepared) request,
    required Future<T> Function(TRaw raw, TPrepared prepared) parse,
    String? extra,
    required T fallback,
    ApiRequestCachePolicy? cachePolicy,
    void Function(
      int totalMs,
      int prepareMs,
      int requestMs,
      int parseMs,
      T result,
    )?
    onFinished,
  }) {
    return _runPhasedCached<T, TPrepared, TRaw>(
      name: name,
      method: method,
      prepare: prepare,
      request: request,
      parse: parse,
      extra: extra,
      fallback: fallback,
      cachePolicy: cachePolicy,
      onFinished: onFinished,
    );
  }

  static Future<(T, bool)> runPhasedWithToken<T, TPrepared, TRaw>({
    required String name,
    required String method,
    required Future<TPrepared> Function() prepare,
    required Future<TRaw> Function(TPrepared prepared) request,
    required Future<T> Function(TRaw raw, TPrepared prepared) parse,
    String? extra,
    required T fallback,
    void Function(
      int totalMs,
      int prepareMs,
      int requestMs,
      int parseMs,
      T result,
    )?
    onFinished,
  }) async {
    try {
      final result = await _executePhased<T, TPrepared, TRaw>(
        name: name,
        method: method,
        prepare: prepare,
        request: request,
        parse: parse,
        extra: extra,
        onFinished: onFinished,
      );
      return (result, true);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final details = _dioErrorDetails(e);
      if (_isAuthExpired(e)) {
        ApiLog.fail(name, "[$method] token", "token expired. $details");
        return (fallback, false);
      }
      if (status == 422) {
        ApiLog.fail(name, "[$method] token", details);
        return (fallback, true);
      }
      ApiLog.fail(name, "[$method] token", details);
      return (fallback, true);
    } catch (e, s) {
      ApiLog.exception(name, "[$method] total=0ms", e, s);
      return (fallback, true);
    }
  }

  static Future<T> run<T>({
    required String name,
    required String method,
    required Future<T> Function() call,
    String? extra,
    required T fallback,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final result = await call();
      sw.stop();
      ApiLog.ok(name, "[$method] cost=${sw.elapsedMilliseconds}ms", extra);
      return result;
    } catch (e, s) {
      sw.stop();
      ApiLog.exception(
        name,
        "[$method] cost=${sw.elapsedMilliseconds}ms",
        e,
        s,
      );
      return fallback;
    }
  }

  static Future<T> runExtra<T>({
    required String name,
    required String method,
    required Future<T> Function() call,
    String? extra,
    required T fallback,
    Function(int, T)? onFinished,
    Function(int, DioException)? onFailed,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final result = await call();
      sw.stop();
      onFinished?.call(sw.elapsedMilliseconds, result);
      ApiLog.ok(name, "[$method] cost=${sw.elapsedMilliseconds}ms", extra);
      return result;
    } on DioException catch (e) {
      sw.stop();
      onFailed?.call(sw.elapsedMilliseconds, e);
      rethrow;
    } catch (e, s) {
      sw.stop();
      ApiLog.exception(
        name,
        "[$method] cost=${sw.elapsedMilliseconds}ms",
        e,
        s,
      );
      return fallback;
    }
  }

  static Future<(T, bool)> runWithToken<T>({
    required String name,
    required String method,
    required Future<T> Function() call,
    String? extra,
    required T fallback,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final result = await call();
      sw.stop();
      ApiLog.ok(name, "[$method] cost=${sw.elapsedMilliseconds}ms", extra);
      return (result, true);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        ApiLog.fail(
          name,
          "[$method] cost=${sw.elapsedMilliseconds}ms {$extra}",
          "token expired.",
        );
        return (fallback, false);
      }
      if (status == 422) {
        ApiLog.fail(
          name,
          "[$method] cost=${sw.elapsedMilliseconds}ms {$extra}",
          e.response?.statusMessage ?? "",
        );
        return (fallback, true);
      }
      ApiLog.fail(
        name,
        "[$method] cost=${sw.elapsedMilliseconds}ms {$extra}",
        "network error.",
      );
      return (fallback, true);
    } catch (e, s) {
      sw.stop();
      ApiLog.exception(
        name,
        "[$method] cost=${sw.elapsedMilliseconds}ms",
        e,
        s,
      );
      return (fallback, true);
    }
  }
}
