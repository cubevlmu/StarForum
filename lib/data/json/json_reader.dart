import 'package:flutter/foundation.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap asJsonMap(Object? value) {
  if (value is JsonMap) return value;
  if (value is Map) return value.cast<String, Object?>();
  return <String, Object?>{};
}

List<Object?> asJsonList(Object? value) {
  if (value is List<Object?>) return value;
  if (value is List) return value.cast<Object?>();
  return const <Object?>[];
}

class JsonValue {
  static String asString(Object? value, [String fallback = '']) {
    if (value == null) return fallback;
    return value is String ? value : value.toString();
  }

  static int asInt(Object? value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool asBool(Object? value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return switch (value.toLowerCase()) {
        'true' || '1' => true,
        'false' || '0' => false,
        _ => fallback,
      };
    }
    return fallback;
  }

  static DateTime asDateTime(Object? value, [DateTime? fallback]) {
    final defaultValue = fallback ?? DateTime.utc(1980);
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

@immutable
class JsonReader {
  const JsonReader(this.json);

  final JsonMap json;

  Object? operator [](String key) => json[key];
  bool contains(String key) => json.containsKey(key);
  String string(String key, [String fallback = '']) =>
      JsonValue.asString(json[key], fallback);
  int integer(String key, [int fallback = 0]) =>
      JsonValue.asInt(json[key], fallback);
  bool boolean(String key, [bool fallback = false]) =>
      JsonValue.asBool(json[key], fallback);
  DateTime dateTime(String key, [DateTime? fallback]) =>
      JsonValue.asDateTime(json[key], fallback);
  JsonMap map(String key) => asJsonMap(json[key]);
  List<Object?> list(String key) => asJsonList(json[key]);
}
