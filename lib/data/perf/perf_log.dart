import 'package:flutter/foundation.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/perf/perf_metrics.dart';

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
    PerfMetrics.recordDuration(
      'network.${_normalizedRequestName(name)}',
      requestMs * 1000,
    );
    _write('request', name, <String, Object?>{
      'requestMs': requestMs,
      'parseMs': parseMs,
      'totalMs': totalMs,
      'details': details,
    });
  }

  static void repository(
    String name, {
    required int elapsedUs,
    required bool success,
    bool? fromCache,
  }) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.recordDuration('repository.$name', elapsedUs);
    PerfMetrics.increment(
      'repository.$name.${success ? 'success' : 'failure'}',
    );
    if (fromCache != null) cache('repository.$name', hit: fromCache);
  }

  static void database(String name, {int? dbMs, int? dbUs, String? details}) {
    if (!PerfConfig.enabled || !PerfConfig.databaseMetrics) return;
    final elapsedUs = dbUs ?? (dbMs ?? 0) * 1000;
    PerfMetrics.recordDuration('database.$name', elapsedUs);
    if (elapsedUs >= 16000) {
      _write('database', name, <String, Object?>{
        'dbMs': dbMs,
        'dbUs': dbUs,
        'details': details,
      });
    }
  }

  static void parsing(String name, {required int parseUs}) {
    if (!PerfConfig.enabled || !PerfConfig.requestMetrics) return;
    PerfMetrics.recordDuration('parse.$name', parseUs);
    _write('parse', name, <String, Object?>{'parseUs': parseUs});
  }

  static void cache(String name, {required bool hit}) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.increment('cache.$name.requests');
    if (hit) PerfMetrics.increment('cache.$name.hits');
  }

  static void coalescing(String name, {required bool hit}) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.increment('coalescing.$name.requests');
    if (hit) PerfMetrics.increment('coalescing.$name.hits');
  }

  static void hydration(String name, {required int requested, int? hydrated}) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.increment('hydration.$name.requested', requested);
    if (hydrated != null) {
      PerfMetrics.increment('hydration.$name.completed', hydrated);
    }
  }

  static void htmlParse(
    String name, {
    required bool cacheHit,
    int? elapsedUs,
    required int inputBytes,
    bool isolated = false,
  }) {
    if (!PerfConfig.enabled) return;
    cache('html.$name', hit: cacheHit);
    if (!cacheHit) {
      PerfMetrics.increment('html.$name.parseCount');
      PerfMetrics.increment('html.$name.inputBytes', inputBytes);
      if (isolated) PerfMetrics.increment('html.$name.isolatedCount');
      if (elapsedUs != null) {
        PerfMetrics.recordDuration('html.$name', elapsedUs);
      }
    }
  }

  static void htmlParseBatch(
    String name, {
    required int count,
    required int elapsedUs,
    required int inputBytes,
    bool isolated = false,
  }) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.increment('html.$name.parseCount', count);
    PerfMetrics.increment('html.$name.inputBytes', inputBytes);
    if (isolated) PerfMetrics.increment('html.$name.isolatedCount', count);
    PerfMetrics.recordDuration('html.$name.batch', elapsedUs);
  }

  static void pageInteractive(String name, {required int elapsedUs}) {
    if (!PerfConfig.enabled || !PerfConfig.renderHints) return;
    PerfMetrics.recordDuration('page.$name.firstInteractive', elapsedUs);
    _write('page', name, <String, Object?>{'interactiveUs': elapsedUs});
  }

  static void frame({required int buildUs, required int rasterUs}) {
    if (!PerfConfig.enabled || !PerfConfig.renderHints) return;
    PerfMetrics.recordDuration('frame.build', buildUs);
    PerfMetrics.recordDuration('frame.raster', rasterUs);
    PerfMetrics.increment('frame.slow');
  }

  static void backgroundTask(
    String name, {
    required int elapsedUs,
    required bool success,
  }) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.recordDuration('background.$name', elapsedUs);
    PerfMetrics.increment(
      'background.$name.${success ? 'success' : 'failure'}',
    );
  }

  static void gauge(String name, int value) {
    if (!PerfConfig.enabled) return;
    PerfMetrics.setGauge(name, value);
  }

  static PerfSnapshot snapshot() => PerfMetrics.snapshot();

  static void printSnapshot() {
    if (!PerfConfig.enabled) return;
    final current = snapshot();
    for (final entry in current.durations.entries) {
      final value = entry.value;
      _write('summary', entry.key, <String, Object?>{
        'count': value.count,
        'avgUs': value.averageUs.round(),
        'maxUs': value.maxUs,
        'totalUs': value.totalUs,
      });
    }
    for (final entry in current.counters.entries) {
      _write('summary', entry.key, <String, Object?>{'value': entry.value});
    }
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

  static String _normalizedRequestName(String name) {
    return name
        .replaceAll(RegExp(r'/\d+(?=/|$)'), '/:id')
        .replaceAll(
          RegExp(r'/[0-9a-f]{16,}(?=/|$)', caseSensitive: false),
          '/:id',
        );
  }
}
