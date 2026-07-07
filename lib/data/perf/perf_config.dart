import 'package:flutter/foundation.dart';

/// Runtime switches for lightweight performance diagnostics.
///
/// Performance logging is enabled by default only in debug builds. Individual
/// categories can be disabled when a focused trace is needed.
class PerfConfig {
  PerfConfig._();

  static bool enabled = kDebugMode;
  static bool requestMetrics = true;
  static bool databaseMetrics = true;
  static bool renderHints = true;

  static void configure({
    bool? enabled,
    bool? requestMetrics,
    bool? databaseMetrics,
    bool? renderHints,
  }) {
    if (enabled != null) PerfConfig.enabled = enabled;
    if (requestMetrics != null) {
      PerfConfig.requestMetrics = requestMetrics;
    }
    if (databaseMetrics != null) {
      PerfConfig.databaseMetrics = databaseMetrics;
    }
    if (renderHints != null) PerfConfig.renderHints = renderHints;
  }

  static void reset() {
    enabled = kDebugMode;
    requestMetrics = true;
    databaseMetrics = true;
    renderHints = true;
  }
}
