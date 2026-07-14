import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/widgets.dart';

class ForumDiscussionTags extends StatelessWidget {
  const ForumDiscussionTags({super.key, required this.tags, this.maxTags = 3});

  final List<String> tags;
  final int maxTags;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .take(maxTags)
        .toList(growable: false);
    if (visibleTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: FUITokens.gap6,
      runSpacing: FUITokens.gap4,
      children: [
        for (var index = 0; index < visibleTags.length; index++)
          FUITag(
            label: visibleTags[index],
            variant: index == 0 ? FUITagVariant.primary : FUITagVariant.neutral,
          ),
      ],
    );
  }
}
