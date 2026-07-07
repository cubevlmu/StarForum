/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';

class ForumBadgeCard extends StatelessWidget {
  const ForumBadgeCard({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.progressLabel,
    this.icon,
    this.earned = false,
  });

  final String title;
  final String? subtitle;
  final double? progress;
  final String? progressLabel;
  final IconData? icon;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FUISurface(
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: earned ? colors.primarySoft : colors.surfaceAlt,
              borderRadius: BorderRadius.circular(FUITokens.radiusMd),
            ),
            child: Icon(
              icon ?? ForumIcons.badge,
              color: earned ? colors.primary : colors.textTertiary,
            ),
          ),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: FUITokens.gap4),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: FUITokens.gap10),
                  Row(
                    children: [
                      Expanded(
                        child: FUIProgressBar(
                          value: progress!.clamp(0.0, 1.0).toDouble(),
                        ),
                      ),
                      if (progressLabel != null) ...[
                        const SizedBox(width: FUITokens.gap8),
                        Text(
                          progressLabel!,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
