/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';

class ForumPostEventTile extends StatelessWidget {
  const ForumPostEventTile({
    super.key,
    required this.icon,
    required this.label,
    this.meta = const [],
  });

  final IconData icon;
  final String label;
  final List<ForumMetaItem> meta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FUISurface(
      padding: const EdgeInsets.symmetric(
        horizontal: FUITokens.gap12,
        vertical: FUITokens.gap10,
      ),
      borderRadius: FUITokens.radiusLg,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(FUITokens.radiusMd),
            ),
            child: Icon(icon, size: 17, color: colors.primary),
          ),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ForumMetaRow(items: meta),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
