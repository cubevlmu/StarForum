import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1350),
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
    final baseSurface = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHigh;
    final highlightSurface = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.14),
            colorScheme.surfaceBright,
          )
        : Color.alphaBlend(
            Colors.white.withValues(alpha: 0.72),
            colorScheme.surfaceContainerLow,
          );
    final baseTone = Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.11),
      baseSurface,
    );
    final highlightTone = Color.alphaBlend(
      (isDark ? Colors.white : Colors.black).withValues(
        alpha: isDark ? 0.05 : 0.045,
      ),
      highlightSurface,
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RepaintBoundary(
          child: widget.builder(
            context,
            SkeletonPalette(
              progress: _controller.value,
              baseColor: baseTone,
              highlightColor: highlightTone,
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
    final sweep = Curves.easeInOut.transform(progress);
    final baseTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 0.16).clamp(0.03, 0.08),
    )!;
    final shimmerTone = Color.lerp(
      baseColor,
      highlightColor,
      (highlightStrength * 1.2).clamp(0.22, 0.42),
    )!;
    final startX = -1.2 + (sweep * 2.4);
    final endX = startX + 0.85;
    return BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment(startX, 0),
        end: Alignment(endX, 0),
        colors: [baseTone, baseTone, shimmerTone, baseTone],
        stops: const [0.0, 0.38, 0.52, 1.0],
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
    final resolvedWidthFactor = widthFactor.clamp(0.1, 1.0);
    return Align(
      alignment: Alignment.centerLeft,
      child: _SkeletonBarBox(
        widthFactor: resolvedWidthFactor,
        fallbackWidth: MediaQuery.sizeOf(context).width,
        height: height,
        child: DecoratedBox(decoration: decoration),
      ),
    );
  }
}

class _SkeletonBarBox extends SingleChildRenderObjectWidget {
  const _SkeletonBarBox({
    required this.widthFactor,
    required this.fallbackWidth,
    required this.height,
    required super.child,
  });

  final double widthFactor;
  final double fallbackWidth;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSkeletonBarBox(widthFactor, fallbackWidth, height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSkeletonBarBox renderObject,
  ) {
    renderObject
      ..widthFactor = widthFactor
      ..fallbackWidth = fallbackWidth
      ..height = height;
  }
}

class _RenderSkeletonBarBox extends RenderProxyBox {
  _RenderSkeletonBarBox(this._widthFactor, this._fallbackWidth, this._height);

  double _widthFactor;
  double _fallbackWidth;
  double _height;

  set widthFactor(double value) {
    if (_widthFactor == value) return;
    _widthFactor = value;
    markNeedsLayout();
  }

  set fallbackWidth(double value) {
    if (_fallbackWidth == value) return;
    _fallbackWidth = value;
    markNeedsLayout();
  }

  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  Size _resolvedSize(BoxConstraints constraints) {
    final availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : _fallbackWidth;
    return constraints.constrain(Size(availableWidth * _widthFactor, _height));
  }

  @override
  void performLayout() {
    size = _resolvedSize(constraints);
    child?.layout(BoxConstraints.tight(size));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _resolvedSize(constraints);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _fallbackWidth * _widthFactor;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _fallbackWidth * _widthFactor;

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;
}
