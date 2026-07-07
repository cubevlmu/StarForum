import 'json_api/json_api_error.dart';

class FlarumTransportError implements Exception {
  const FlarumTransportError({
    required this.message,
    required this.path,
    this.statusCode,
    this.errors = const [],
    this.cause,
    this.cancelled = false,
    this.network = false,
  });

  final String message;
  final String path;
  final int? statusCode;
  final List<JsonApiError> errors;
  final Object? cause;
  final bool cancelled;
  final bool network;

  JsonApiError? get apiError => errors.isEmpty ? null : errors.first;

  Map<String, String> get validationErrors {
    final result = <String, String>{};
    for (final error in errors) {
      final key =
          error.sourceParameter ?? _fieldFromPointer(error.sourcePointer);
      final detail = error.detail;
      if (key != null &&
          key.isNotEmpty &&
          detail != null &&
          detail.isNotEmpty) {
        result[key] = detail;
      }
    }
    return result;
  }

  bool get isAuthExpired {
    if (statusCode == 401) return true;
    if (statusCode != 403) return false;
    final text = errors
        .map((error) => '${error.code ?? ''} ${error.detail ?? ''}')
        .join(' ')
        .toLowerCase();
    return const [
      'token',
      'session',
      'authentication',
      'unauthenticated',
      'csrf',
    ].any(text.contains);
  }

  bool get isExtensionMissing =>
      (statusCode == 403 || statusCode == 404) &&
      (path.startsWith('/api/fof/') ||
          path.startsWith('/api/badge_') ||
          path.startsWith('/api/badges'));

  static String? _fieldFromPointer(String? pointer) {
    if (pointer == null || pointer.isEmpty) return null;
    final segments = pointer.split('/').where((part) => part.isNotEmpty);
    return segments.isEmpty ? null : segments.last;
  }

  @override
  String toString() => message;
}
