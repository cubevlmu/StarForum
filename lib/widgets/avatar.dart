/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.radius,
    this.onPressed,
    this.cacheWidthHeight,
    this.placeholder = "",
    this.width,
    this.height,
  });

  final double? width;
  final double? height;
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
        width: width ?? radius * 2,
        height: height ?? radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: avatarUrl.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      alignment: Alignment.center,
                      child: placeholder.isEmpty
                          ? Icon(
                              Icons.person_outline_rounded,
                              size: radius,
                            )
                          : Text(
                              placeholder[0],
                              style: TextStyle(
                                fontSize: radius * 0.95,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                height: 1,
                              ),
                            ),
                    )
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      cacheWidth:
                          (cacheWidthHeight ??
                          (MediaQuery.of(context).devicePixelRatio * radius * 2)
                              .toInt()),
                      cacheHeight:
                          (cacheWidthHeight ??
                          (MediaQuery.of(context).devicePixelRatio * radius * 2)
                              .toInt()),
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
