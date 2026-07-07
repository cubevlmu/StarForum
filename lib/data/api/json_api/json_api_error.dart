import 'package:star_forum/data/json/json_reader.dart';

class JsonApiError {
  const JsonApiError({
    this.status,
    this.code,
    this.detail,
    this.sourcePointer,
    this.sourceParameter,
  });

  final String? status;
  final String? code;
  final String? detail;
  final String? sourcePointer;
  final String? sourceParameter;

  factory JsonApiError.from(Object? raw) {
    final json = asJsonMap(raw);
    final source = asJsonMap(json['source']);
    return JsonApiError(
      status: json['status']?.toString(),
      code: json['code']?.toString(),
      detail: json['detail']?.toString(),
      sourcePointer: source['pointer']?.toString(),
      sourceParameter: source['parameter']?.toString(),
    );
  }
}
