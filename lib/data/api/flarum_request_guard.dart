import 'api_guard.dart';

typedef FlarumRequestCachePolicy = ApiRequestCachePolicy;

class FlarumRequestGuard {
  static void clearCache() => ApiGuard.clearRequestCache();

  static void invalidate(bool Function(String key) predicate) {
    ApiGuard.invalidateRequestCache(predicate);
  }

  static Future<T> run<T>({
    required String name,
    required String method,
    required Future<T> Function() call,
    required T fallback,
  }) {
    return ApiGuard.run(
      name: name,
      method: method,
      call: call,
      fallback: fallback,
    );
  }
}
