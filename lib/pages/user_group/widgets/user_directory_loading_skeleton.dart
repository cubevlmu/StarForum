import 'package:flutter/material.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/two_column_loading_skeleton.dart';

class UserDirectoryLoadingSkeleton extends StatelessWidget {
  const UserDirectoryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return TwoColumnLoadingSkeleton(
      cardHeight: 96,
      itemBuilder: (context, palette) => _UserDirectorySkeletonCard(
        lineDecoration: palette.line(radius: 8),
        circleDecoration: palette.circle(),
      ),
    );
  }
}

class _UserDirectorySkeletonCard extends StatelessWidget {
  const _UserDirectorySkeletonCard({
    required this.lineDecoration,
    required this.circleDecoration,
  });

  final Decoration lineDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: 0.02),
            colorScheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            Colors.white.withValues(alpha: 0.55),
            colorScheme.surfaceContainerLowest,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.32,
          ),
        ),
      ),
      child: SizedBox(
        height: 96,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: circleDecoration,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBar(
                          decoration: lineDecoration,
                          widthFactor: 0.58,
                          height: 14,
                        ),
                        const SizedBox(height: 6),
                        SkeletonBar(
                          decoration: lineDecoration,
                          widthFactor: 0.42,
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SkeletonBar(
                decoration: lineDecoration,
                widthFactor: 0.68,
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
