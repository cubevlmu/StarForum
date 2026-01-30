/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/widgets/cached_network_image.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.radius,
    this.onPressed,
    this.cacheWidthHeight,
    this.placeholder = "U",
  });
  final String avatarUrl;
  final String placeholder;
  final double radius;
  final Function()? onPressed;
  final int? cacheWidthHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: avatarUrl.isEmpty ? CircleAvatar(child: Text(placeholder[0])) : CachedNetworkImage(
                fit: BoxFit.cover,
                cacheWidth:
                    cacheWidthHeight ??
                    (MediaQuery.of(context).devicePixelRatio * radius * 2)
                        .toInt(),
                cacheHeight:
                    cacheWidthHeight ??
                    (MediaQuery.of(context).devicePixelRatio * radius * 2)
                        .toInt(),
                placeholder: () => Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                imageUrl: avatarUrl,
                cacheManager: CacheUtils.avatarCacheManager,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
