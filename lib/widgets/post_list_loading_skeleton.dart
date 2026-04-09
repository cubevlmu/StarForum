import 'package:flutter/material.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';

class PostListLoadingSkeleton extends StatelessWidget {
  const PostListLoadingSkeleton({super.key, this.minItems, this.maxItems});

  final int? minItems;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    const itemExtent = 150.0;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final count = (viewportHeight / itemExtent).ceil().clamp(
      minItems ?? 4,
      maxItems ?? 12,
    );

    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1450),
      highlightStrength: 0.18,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            count,
            (index) => _PostListLoadingRow(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _PostListLoadingRow extends StatelessWidget {
  const _PostListLoadingRow({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: circleDecoration,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.52,
                            height: 15,
                          ),
                          const SizedBox(height: 6),
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.34,
                            height: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Column(
                    children: [
                      SkeletonBar(
                        decoration: pillDecoration,
                        widthFactor: 0.92,
                        height: 12,
                      ),
                      const SizedBox(height: 8),
                      SkeletonBar(
                        decoration: pillDecoration,
                        widthFactor: 0.76,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 70,
                      height: 18,
                      decoration: pillDecoration,
                    ),
                    Container(
                      width: 78,
                      height: 18,
                      decoration: pillDecoration,
                    ),
                    Container(
                      width: 62,
                      height: 18,
                      decoration: pillDecoration,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
