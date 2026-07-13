import 'package:flutter/foundation.dart';

@immutable
class ContentHashKey {
  const ContentHashKey._(this.length, this.primary, this.secondary);

  factory ContentHashKey.fromString(String value) {
    var primary = 0x811c9dc5;
    var secondary = 0x9e3779b9;
    for (final codeUnit in value.codeUnits) {
      primary = ((primary ^ codeUnit) * 0x01000193) & _mask32;
      secondary = ((secondary ^ (codeUnit + 0x9e37)) * 0x01000193) & _mask32;
    }
    return ContentHashKey._(value.length, primary, secondary);
  }

  static const int _mask32 = 0xffffffff;

  final int length;
  final int primary;
  final int secondary;

  @override
  bool operator ==(Object other) =>
      other is ContentHashKey &&
      length == other.length &&
      primary == other.primary &&
      secondary == other.secondary;

  @override
  int get hashCode => Object.hash(length, primary, secondary);
}
