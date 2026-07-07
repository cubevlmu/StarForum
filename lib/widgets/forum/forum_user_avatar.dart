/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';

class ForumUserAvatar extends StatelessWidget {
  const ForumUserAvatar({
    super.key,
    this.name,
    this.avatarUrl,
    this.image,
    this.size = 36,
    this.online = false,
  });

  final String? name;
  final String? avatarUrl;
  final ImageProvider? image;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = size / 2;
    final url = avatarUrl?.trim() ?? '';
    final hasImage = url.isNotEmpty || image != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: colors.border),
            image: url.isNotEmpty || image == null
                ? null
                : DecorationImage(image: image!, fit: BoxFit.cover),
          ),
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  cacheManager: CacheUtils.avatarCacheManager,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  cacheWidth: (MediaQuery.devicePixelRatioOf(context) * size)
                      .round(),
                  cacheHeight: (MediaQuery.devicePixelRatioOf(context) * size)
                      .round(),
                  placeholder: () => const SizedBox.expand(),
                )
              : !hasImage
              ? Text(
                  _initials(name),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        if (online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: colors.success,
                borderRadius: BorderRadius.circular(FUITokens.radiusFull),
                border: Border.all(color: colors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  static String _initials(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return '?';
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return value.substring(0, 1).toUpperCase();
  }
}
