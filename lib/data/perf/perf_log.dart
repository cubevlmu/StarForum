import 'package:flutter/foundation.dart';
import 'package:star_forum/data/perf/perf_config.dart';

/// Lightweight structured performance output for development builds.
class PerfLog {
  PerfLog._();

  static void request(
    String name, {
    required int requestMs,
    int? parseMs,
    int? totalMs,
    String? details,
  }) {
    if (!PerfConfig.enabled || !PerfConfig.requestMetrics) return;
    _write('request', name, <String, Object?>{
      'requestMs': requestMs,
      'parseMs': parseMs,
      'totalMs': totalMs,
      'details': details,
    });
  }

  static void database(String name, {required int dbMs, String? details}) {
    if (!PerfConfig.enabled || !PerfConfig.databaseMetrics) return;
    _write('database', name, <String, Object?>{
      'dbMs': dbMs,
      'details': details,
    });
  }

  static void renderHint(String name, {String? details}) {
    if (!PerfConfig.enabled || !PerfConfig.renderHints) return;
    _write('render', name, <String, Object?>{'details': details});
  }

  static void _write(
    String category,
    String name,
    Map<String, Object?> values,
  ) {
    final fields = values.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
    debugPrint('[PERF][$category] $name${fields.isEmpty ? '' : ' $fields'}');
  }
}
