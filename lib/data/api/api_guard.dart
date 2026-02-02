/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:dio/dio.dart';
import 'package:forum/data/api/api_log.dart';

class ApiGuard {
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
      } else if (status == 422) {
        ApiLog.fail(
          name,
          "[$method] cost=${sw.elapsedMilliseconds}ms {$extra}",
          e.response?.statusMessage ?? "",
        );
        return (fallback, true);
      } else {
        ApiLog.fail(
          name,
          "[$method] cost=${sw.elapsedMilliseconds}ms {$extra}",
          "network error.",
        );
        return (fallback, true);
      }
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
