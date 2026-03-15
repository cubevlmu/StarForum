import 'package:flutter/material.dart';

class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1450),
    this.highlightStrength = 0.18,
  });

  final Widget Function(BuildContext context, SkeletonPalette palette) builder;
  final Duration duration;
  final double highlightStrength;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RepaintBoundary(
          child: widget.builder(
            context,
            SkeletonPalette(
              progress: _controller.value,
              baseColor: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.18 : 0.09,
              ),
              highlightColor: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.34 : 0.19,
              ),
              highlightStrength: widget.highlightStrength,
            ),
          ),
        );
      },
    );
  }
}

class SkeletonPalette {
  const SkeletonPalette({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
    required this.highlightStrength,
  });

  final double progress;
  final Color baseColor;
  final Color highlightColor;
  final double highlightStrength;

  BoxDecoration line({double radius = 999}) =>
      _buildDecoration(radius: radius, isCircle: false);

  BoxDecoration block({double radius = 16}) =>
      _buildDecoration(radius: radius, isCircle: false);

  BoxDecoration circle() => _buildDecoration(radius: 999, isCircle: true);

  BoxDecoration _buildDecoration({
    required double radius,
    required bool isCircle,
  }) {
    final pulse = Curves.easeInOut.transform(1 - ((progress - 0.5).abs() * 2));
    final baseTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 0.22 * pulse).clamp(0.0, 0.12),
    )!;
    final sweepProgress = Curves.easeInOut.transform(progress);
    final highlightTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 1.15).clamp(0.12, 0.42),
    )!;
    final alignment = Alignment(-1.35 + (sweepProgress * 2.7), 0);
    return BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: alignment,
        end: Alignment(alignment.x + 0.9, 0),
        colors: [baseTone, baseTone, highlightTone, baseTone, baseTone],
        stops: const [0.0, 0.34, 0.5, 0.66, 1.0],
      ),
    );
  }
}

class SkeletonBar extends StatelessWidget {
  const SkeletonBar({
    super.key,
    required this.decoration,
    required this.widthFactor,
    required this.height,
  });

  final Decoration decoration;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(height: height, decoration: decoration),
    );
  }
}
