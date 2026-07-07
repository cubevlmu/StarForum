import 'package:star_forum/data/api/flarum_transport_error.dart';

enum RepoErrorType {
  empty,
  network,
  tokenExpired,
  validation,
  forbidden,
  notFound,
  extensionUnavailable,
  cancelled,
  operationFailed,
  unknown,
}

class RepoError {
  const RepoError({
    required this.type,
    required this.message,
    this.cause,
    this.stackTrace,
    this.statusCode,
    this.code,
    this.detail,
    this.sourcePointer,
    this.validationErrors = const {},
  });

  final RepoErrorType type;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final int? statusCode;
  final String? code;
  final String? detail;
  final String? sourcePointer;
  final Map<String, String> validationErrors;

  static const empty = RepoError(
    type: RepoErrorType.empty,
    message: 'Response data is empty.',
  );

  static const tokenExpired = RepoError(
    type: RepoErrorType.tokenExpired,
    message: 'Login token is expired.',
  );

  static const operationFailed = RepoError(
    type: RepoErrorType.operationFailed,
    message: 'Operation failed.',
  );

  static RepoError unknown(Object error, StackTrace stackTrace) {
    return RepoError(
      type: RepoErrorType.unknown,
      message: error.toString(),
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static RepoError fromTransport(
    FlarumTransportError error, {
    bool extensionEndpoint = false,
  }) {
    final status = error.statusCode;
    final code = error.apiError?.code;
    final detail = error.apiError?.detail ?? error.message;
    final type = error.cancelled
        ? RepoErrorType.cancelled
        : error.network
        ? RepoErrorType.network
        : error.isAuthExpired
        ? RepoErrorType.tokenExpired
        : (extensionEndpoint || error.isExtensionMissing) &&
              (status == 403 || status == 404)
        ? RepoErrorType.extensionUnavailable
        : status == 403
        ? RepoErrorType.forbidden
        : status == 404
        ? RepoErrorType.notFound
        : status == 422
        ? RepoErrorType.validation
        : RepoErrorType.unknown;
    return RepoError(
      type: type,
      message: detail,
      cause: error.cause,
      statusCode: status,
      code: code,
      detail: detail,
      sourcePointer: error.apiError?.sourcePointer,
      validationErrors: error.validationErrors,
    );
  }
}

class RepoResult<T> {
  const RepoResult._({
    this.data,
    this.error,
    this.latencyMs,
    this.fromCache = false,
  });

  const RepoResult.success(T data, {int? latencyMs, bool fromCache = false})
    : this._(data: data, latencyMs: latencyMs, fromCache: fromCache);

  const RepoResult.failure(
    RepoError error, {
    int? latencyMs,
    bool fromCache = false,
  }) : this._(error: error, latencyMs: latencyMs, fromCache: fromCache);

  final T? data;
  final RepoError? error;
  final int? latencyMs;
  final bool fromCache;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
  bool get isTokenExpired => error?.type == RepoErrorType.tokenExpired;

  static RepoResult<T> fromNullable<T>(T? data) {
    if (data == null) {
      return const RepoResult.failure(RepoError.empty);
    }
    return RepoResult.success(data);
  }

  static RepoResult<T> fromTokenTuple<T>((T?, bool) result) {
    final (data, tokenOk) = result;
    if (!tokenOk) {
      return const RepoResult.failure(RepoError.tokenExpired);
    }
    return RepoResult.fromNullable(data);
  }

  static Future<RepoResult<T>> guard<T>(Future<T?> Function() call) async {
    try {
      return RepoResult.fromNullable(await call());
    } on FlarumTransportError catch (e) {
      return RepoResult.failure(RepoError.fromTransport(e));
    } catch (e, s) {
      return RepoResult.failure(RepoError.unknown(e, s));
    }
  }

  static Future<RepoResult<void>> guardBool(
    Future<bool> Function() call,
  ) async {
    try {
      final ok = await call();
      return ok
          ? const RepoResult.success(null)
          : const RepoResult.failure(RepoError.operationFailed);
    } on FlarumTransportError catch (e) {
      return RepoResult.failure(RepoError.fromTransport(e));
    } catch (e, s) {
      return RepoResult.failure(RepoError.unknown(e, s));
    }
  }
}

class PagedRepoResult<T> extends RepoResult<List<T>> {
  const PagedRepoResult.success(
    List<T> data, {
    this.nextUrl,
    this.hasMoreOverride,
    super.latencyMs,
    super.fromCache = false,
  }) : super._(data: data);

  const PagedRepoResult.failure(
    RepoError error, {
    super.latencyMs,
    super.fromCache = false,
  }) : nextUrl = null,
       hasMoreOverride = false,
       super._(error: error);

  final String? nextUrl;
  final bool? hasMoreOverride;

  bool get hasMore =>
      hasMoreOverride ?? (nextUrl != null && nextUrl!.isNotEmpty);
}

class RepoRequestCoalescer {
  final Map<String, Future<Object?>> _pending = <String, Future<Object?>>{};

  Future<T> run<T>(String key, Future<T> Function() call) async {
    final pending = _pending[key];
    if (pending != null) {
      return await pending as T;
    }

    final future = call();
    _pending[key] = future;
    try {
      return await future;
    } finally {
      if (identical(_pending[key], future)) {
        _pending.remove(key);
      }
    }
  }
}
