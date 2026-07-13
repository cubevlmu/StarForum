import 'package:flutter/material.dart';
import 'package:star_forum/data/perf/perf_log.dart';

class PerfInteractiveBoundary extends StatefulWidget {
  const PerfInteractiveBoundary({
    super.key,
    required this.name,
    required this.active,
    required this.child,
  });

  final String name;
  final bool active;
  final Widget child;

  @override
  State<PerfInteractiveBoundary> createState() =>
      _PerfInteractiveBoundaryState();
}

class _PerfInteractiveBoundaryState extends State<PerfInteractiveBoundary> {
  Stopwatch? _stopwatch;

  @override
  void initState() {
    super.initState();
    if (widget.active) _scheduleMeasurement();
  }

  @override
  void didUpdateWidget(covariant PerfInteractiveBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _scheduleMeasurement();
  }

  void _scheduleMeasurement() {
    final stopwatch = Stopwatch()..start();
    _stopwatch = stopwatch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_stopwatch, stopwatch)) return;
      stopwatch.stop();
      PerfLog.pageInteractive(
        widget.name,
        elapsedUs: stopwatch.elapsedMicroseconds,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
