import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';

class TwoColumnLoadingSkeleton extends StatelessWidget {
  const TwoColumnLoadingSkeleton({
    super.key,
    required this.cardHeight,
    required this.itemBuilder,
    this.spacing = 10,
    this.padding = const EdgeInsets.all(12),
    this.minRows = 3,
    this.maxRows = 6,
    this.reservedHeight = 180,
  });

  final double cardHeight;
  final Widget Function(BuildContext context, SkeletonPalette palette)
  itemBuilder;
  final double spacing;
  final EdgeInsets padding;
  final int minRows;
  final int maxRows;
  final double reservedHeight;

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height - reservedHeight;
    final availableHeight = math.max(0.0, viewportHeight - padding.vertical);
    final resolvedMin = math.max(1, minRows);
    final resolvedMax = math.max(resolvedMin, maxRows);
    final rowCount = ((availableHeight + spacing) / (cardHeight + spacing))
        .ceil()
        .clamp(resolvedMin, resolvedMax);

    return SkeletonShimmer(
      builder: (context, palette) {
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rowCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == rowCount - 1 ? 0 : spacing,
                ),
                child: Row(
                  children: [
                    Expanded(child: itemBuilder(context, palette)),
                    SizedBox(width: spacing),
                    Expanded(child: itemBuilder(context, palette)),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
