/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';

class ForumMetaRow extends StatelessWidget {
  const ForumMetaRow({
    super.key,
    required this.items,
    this.iconSize = 14,
    this.textSize = 11,
  });

  final List<ForumMetaItem> items;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (i != 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FUITokens.gap6),
            child: Text(
              '·',
              style: TextStyle(color: colors.textTertiary, fontSize: textSize),
            ),
          ),
        );
      }
      children.add(
        _MetaItemView(item: item, iconSize: iconSize, textSize: textSize),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class ForumMetaItem {
  const ForumMetaItem({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

class _MetaItemView extends StatelessWidget {
  const _MetaItemView({
    required this.item,
    required this.iconSize,
    required this.textSize,
  });

  final ForumMetaItem item;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: iconSize, color: colors.textTertiary),
          const SizedBox(width: 4),
        ],
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
