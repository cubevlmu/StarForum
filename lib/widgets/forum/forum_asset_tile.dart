/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';

class ForumAssetTile extends StatelessWidget {
  const ForumAssetTile({
    super.key,
    required this.name,
    this.subtitle,
    this.thumbnail,
    this.selected = false,
    this.onTap,
  });

  final String name;
  final String? subtitle;
  final ImageProvider? thumbnail;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(FUITokens.radiusLg),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FUITokens.gap8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                      image: thumbnail == null
                          ? null
                          : DecorationImage(
                              image: thumbnail!,
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: thumbnail == null
                        ? Center(
                            child: Icon(
                              ForumIcons.image,
                              color: colors.textTertiary,
                              size: 26,
                            ),
                          )
                        : const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: FUITokens.gap8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textTertiary, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
