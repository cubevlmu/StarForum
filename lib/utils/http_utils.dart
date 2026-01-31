/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/data/auth/auth_storage.dart';
import 'package:forum/utils/log_util.dart';
import 'package:path_provider/path_provider.dart';

class HttpUtils {
  static final HttpUtils _instance = HttpUtils._internal();
  factory HttpUtils() => _instance;
  static late final Dio dio;
  static late final CookieManager cookieManager;
  CancelToken _cancelToken = CancelToken();

  static void setToken(String token) {
    if (token.isEmpty) {
      HttpUtils.dio.options.headers.remove("Authorization");
      cookieManager.cookieJar.deleteAll();
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

    // dio.interceptors.add(AuthInterceptor()); // ⭐ 新增
    // dio.interceptors.add(ErrorInterceptor());
  }

  Future<void> init() async {
    if (kIsWeb) {
      cookieManager = CookieManager(CookieJar());
    } else {
      //设置cookie存放的位置，保存cookie
      var cookiePath =
          "${(await getApplicationSupportDirectory()).path}/.cookies/";
      cookieManager = CookieManager(
        PersistCookieJar(storage: FileStorage(cookiePath)),
      );
    }
    dio.interceptors.add(cookieManager);
    if ((await cookieManager.cookieJar.loadForRequest(
      Uri.parse(ApiConstants.apiBase),
    )).isEmpty) {
      try {
        await dio.get(ApiConstants.apiBase);
      } catch (e, s) {
        LogUtil.errorE("utils/my_dio", e, s);
      }
    }
  }

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

// class ErrorInterceptor extends Interceptor {
//   Future<bool> isConnected() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     return connectivityResult != ConnectivityResult.none;
//   }

//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     switch (err.type) {
//       case DioExceptionType.unknown:
//         if (!await isConnected()) {
//           Get.rawSnackbar(title: '网络未连接 ', message: '请检查网络状态');
//           handler.reject(err);
//         }
//         break;
//       default:
//     }

//     return super.onError(err, handler);
//   }
// }

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Token $token';
    }

    handler.next(options);
  }
}
