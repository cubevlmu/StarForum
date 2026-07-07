/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/forum/forum_user_avatar.dart';

class ForumUserTile extends StatelessWidget {
  const ForumUserTile({
    super.key,
    required this.name,
    this.subtitle,
    this.avatar,
    this.role,
    this.online = false,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final String name;
  final String? subtitle;
  final ImageProvider? avatar;
  final String? role;
  final bool online;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FUISurface(
      onTap: onTap,
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Row(
        children: [
          ForumUserAvatar(name: name, image: avatar, online: online),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (role != null && role!.isNotEmpty) ...[
            const SizedBox(width: FUITokens.gap8),
            FUITag(label: role!, variant: FUITagVariant.neutral),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: FUITokens.gap8),
            FUIButton(
              label: actionLabel!,
              onPressed: onAction,
              small: true,
              variant: FUIButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
