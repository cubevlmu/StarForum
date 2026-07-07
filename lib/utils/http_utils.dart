/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/widgets.dart';
import 'package:star_forum/data/api/api_constants.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

String? _proxyFromEnvironment() {
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
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

String? _extractWindowsProxyServer(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }
  if (!value.contains('=')) {
    return value;
  }

  final entries = value.split(';');
  for (final scheme in const ['https', 'http']) {
    for (final entry in entries) {
      final idx = entry.indexOf('=');
      if (idx <= 0) continue;
      final key = entry.substring(0, idx).trim().toLowerCase();
      final proxy = entry.substring(idx + 1).trim();
      if (key == scheme && proxy.isNotEmpty) {
        return proxy;
      }
    }
  }

  for (final entry in entries) {
    final idx = entry.indexOf('=');
    if (idx <= 0) continue;
    final proxy = entry.substring(idx + 1).trim();
    if (proxy.isNotEmpty) {
      return proxy;
    }
  }
  return null;
}

String? _queryWindowsProxy() {
  if (!Platform.isWindows) {
    return null;
  }

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

  final proxy = Process.runSync('reg', ['query', keyPath, '/v', 'ProxyServer']);
  if (proxy.exitCode != 0) {
    return null;
  }

  final lines = proxy.stdout.toString().split(RegExp(r'[\r\n]+'));
  for (final line in lines) {
    if (!line.contains('ProxyServer')) continue;
    final parts = line.trim().split(RegExp(r'\s{2,}'));
    if (parts.length < 3) continue;
    return _extractWindowsProxyServer(parts.last);
  }
  return null;
}

String? _normalizeProxyHostPort(String value) {
  final proxy = value.trim();
  if (proxy.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(proxy);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.host}$port';
  }
  return proxy;
}

String? _resolveSystemProxy() {
  final proxy = _proxyFromEnvironment() ?? _queryWindowsProxy();
  return proxy == null ? null : _normalizeProxyHostPort(proxy);
}

class HttpUtils {
  static final HttpUtils _instance = HttpUtils._internal();
  factory HttpUtils() => _instance;
  static late final Dio dio;
  CancelToken _cancelToken = CancelToken();

  static void setToken(String token) {
    if (token.isEmpty) {
      HttpUtils.dio.options.headers.remove("Authorization");
      return;
    }
    HttpUtils.dio.options.headers.addAll({"Authorization": token});
  }

  Future<Response> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  Dio getInstance() {
    return dio;
  }

  HttpUtils._internal() {
    BaseOptions options = BaseOptions(
      headers: {
        'keep-alive': true,
        'user-agent': ApiConstants.userAgent,
        'Accept-Encoding': 'gzip',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      persistentConnection: true,
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();
    final proxy = _resolveSystemProxy();
    if (proxy != null) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.idleTimeout = const Duration(seconds: 15);
          client.maxConnectionsPerHost = 6;
          client.findProxy = (uri) => 'PROXY $proxy';
          return client;
        },
      );
      LogUtil.info('[Http] System proxy enabled: $proxy');
    }

    dio.interceptors.add(ErrorInterceptor());
  }

  Future<void> init() async {}

  void cancelRequests({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
    _cancelToken = token;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }
}

class ErrorInterceptor extends Interceptor {
  Future<bool> isConnected() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      return connectivityResult != ConnectivityResult.none;
    } catch (e, s) {
      LogUtil.errorE(
        "[Http] Failed to fetch system connectivity status.",
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    switch (err.type) {
      case DioExceptionType.unknown:
        if (!await isConnected()) {
          AppLocalizations? l10n;
          try {
            l10n = lookupAppLocalizations(
              WidgetsBinding.instance.platformDispatcher.locale,
            );
          } catch (_) {}
          SnackbarUtils.showMessage(
            title: l10n?.networkNotConnectedTitle ?? 'Network disconnected',
            msg:
                l10n?.networkNotConnectedMsg ??
                'Please check your network connection',
          );
          handler.reject(err);
        }
        break;
      default:
    }

    return super.onError(err, handler);
  }
}
