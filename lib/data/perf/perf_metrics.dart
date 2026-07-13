import 'package:flutter/foundation.dart';

@immutable
class PerfDurationStats {
  const PerfDurationStats({
    required this.count,
    required this.totalUs,
    required this.maxUs,
  });

  final int count;
  final int totalUs;
  final int maxUs;

  double get averageUs => count == 0 ? 0 : totalUs / count;
}

@immutable
class PerfSnapshot {
  const PerfSnapshot({required this.durations, required this.counters});

  final Map<String, PerfDurationStats> durations;
  final Map<String, int> counters;

  double ratio(String numerator, String denominator) {
    final total = counters[denominator] ?? 0;
    return total == 0 ? 0 : (counters[numerator] ?? 0) / total;
  }

  double cacheHitRate(String name) =>
      ratio('cache.$name.hits', 'cache.$name.requests');

  double coalescingHitRate(String name) =>
      ratio('coalescing.$name.hits', 'coalescing.$name.requests');
}

class PerfMetrics {
  PerfMetrics._();

  static final Map<String, _MutableDurationStats> _durations = {};
  static final Map<String, int> _counters = {};

  static void recordDuration(String name, int elapsedUs) {
    (_durations[name] ??= _MutableDurationStats()).add(elapsedUs);
  }

  static void increment(String name, [int count = 1]) {
    _counters.update(name, (value) => value + count, ifAbsent: () => count);
  }

  static void setGauge(String name, int value) {
    _counters[name] = value;
  }

  static PerfSnapshot snapshot() => PerfSnapshot(
    durations: Map.unmodifiable(
      _durations.map((key, value) => MapEntry(key, value.snapshot)),
    ),
    counters: Map.unmodifiable(_counters),
  );

  @visibleForTesting
  static void reset() {
    _durations.clear();
    _counters.clear();
  }
}

class _MutableDurationStats {
  int count = 0;
  int totalUs = 0;
  int maxUs = 0;

  void add(int elapsedUs) {
    count++;
    totalUs += elapsedUs;
    if (elapsedUs > maxUs) maxUs = elapsedUs;
  }

  PerfDurationStats get snapshot =>
      PerfDurationStats(count: count, totalUs: totalUs, maxUs: maxUs);
}
