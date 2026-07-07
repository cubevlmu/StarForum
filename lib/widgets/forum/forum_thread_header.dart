/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';

class ForumThreadHeader extends StatelessWidget {
  const ForumThreadHeader({
    super.key,
    required this.title,
    this.tags = const [],
    this.meta = const [],
    this.trailing,
  });

  final String title;
  final List<String> tags;
  final List<ForumMetaItem> meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FUISurface(
      borderRadius: FUITokens.radiusXl,
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: FUITokens.gap6,
              runSpacing: FUITokens.gap6,
              children: [
                for (final tag in tags)
                  FUITag(
                    label: tag,
                    variant: tag == tags.first
                        ? FUITagVariant.primary
                        : FUITagVariant.neutral,
                  ),
              ],
            ),
            const SizedBox(height: FUITokens.gap8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 21,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: FUITokens.gap12),
                trailing!,
              ],
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap10),
            ForumMetaRow(items: meta, textSize: 12),
          ],
        ],
      ),
    );
  }
}
