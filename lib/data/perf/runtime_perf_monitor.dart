import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/perf/perf_log.dart';

class RuntimePerfMonitor {
  RuntimePerfMonitor._();

  static const int _frameBudgetUs = 16667;
  static Timer? _resourceTimer;
  static bool _started = false;

  static void start() {
    if (_started || !PerfConfig.enabled) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_recordFrames);
    _sampleImageCache();
    _resourceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sampleImageCache(),
    );
  }

  static void stop() {
    if (!_started) return;
    SchedulerBinding.instance.removeTimingsCallback(_recordFrames);
    _resourceTimer?.cancel();
    _resourceTimer = null;
    _started = false;
  }

  static void _recordFrames(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildUs = timing.buildDuration.inMicroseconds;
      final rasterUs = timing.rasterDuration.inMicroseconds;
      if (buildUs > _frameBudgetUs || rasterUs > _frameBudgetUs) {
        PerfLog.frame(buildUs: buildUs, rasterUs: rasterUs);
      }
    }
  }

  static void _sampleImageCache() {
    final cache = PaintingBinding.instance.imageCache;
    PerfLog.gauge('imageCache.bytes', cache.currentSizeBytes);
    PerfLog.gauge('imageCache.entries', cache.currentSize);
    PerfLog.gauge('imageCache.liveEntries', cache.liveImageCount);
  }
}
