/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';

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
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      persistentConnection: true,
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();

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
          SnackbarUtils.showMessage(title: '网络未连接 ', msg: '请检查网络状态');
          handler.reject(err);
        }
        break;
      default:
    }

    return super.onError(err, handler);
  }
}
