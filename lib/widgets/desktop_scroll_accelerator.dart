import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Adds bounded acceleration to consecutive desktop mouse-wheel events.
///
/// The underlying scrollable still handles the base wheel delta. This widget
/// only adds the accelerated portion, so existing physics and refresh behavior
/// remain unchanged.
class DesktopScrollAccelerator extends StatefulWidget {
  const DesktopScrollAccelerator({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<DesktopScrollAccelerator> createState() =>
      _DesktopScrollAcceleratorState();
}

class _DesktopScrollAcceleratorState extends State<DesktopScrollAccelerator> {
  static const int _accelerationWindowMicros = 180000;
  static const int _maxStreak = 8;
  static const double _trackpadDeltaThreshold = 18;
  static const double _maxExtraDelta = 360;

  final Stopwatch _clock = Stopwatch()..start();
  int? _lastEventMicros;
  int _streak = 0;
  double _lastDirection = 0;

  bool get _isDesktop {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!_isDesktop || event is! PointerScrollEvent) return;

    final delta = event.scrollDelta.dy;
    if (delta == 0 || delta.abs() < _trackpadDeltaThreshold) {
      _resetAcceleration();
      return;
    }

    final now = _clock.elapsedMicroseconds;
    final elapsed = _lastEventMicros == null ? null : now - _lastEventMicros!;
    final continues =
        elapsed != null &&
        elapsed <= _accelerationWindowMicros &&
        delta.sign == _lastDirection;

    _streak = continues ? math.min(_streak + 1, _maxStreak) : 0;
    _lastEventMicros = now;
    _lastDirection = delta.sign;

    if (_streak == 0) return;

    // A quadratic curve keeps short wheel movements precise while allowing a
    // sustained scroll to traverse long discussions quickly.
    final boost = math.min((_streak * _streak) / 32, 2.0);
    final extraDelta = (delta * boost)
        .clamp(-_maxExtraDelta, _maxExtraDelta)
        .toDouble();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.controller.positions.length != 1) return;
      final position = widget.controller.position;
      final target = (position.pixels + extraDelta)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      if (target != position.pixels) widget.controller.jumpTo(target);
    });
  }

  void _resetAcceleration() {
    _streak = 0;
    _lastEventMicros = null;
    _lastDirection = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerSignal: _handlePointerSignal, child: widget.child);
  }
}
