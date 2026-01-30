/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' as image;

class CachedNetworkImage extends image.CachedNetworkImage {
  CachedNetworkImage({
    super.key,
    required String imageUrl,
    super.cacheManager,
    final Map<String, String>? headers,
    super.width,
    super.height,
    super.fit,
    super.filterQuality,
    Widget Function()? placeholder,
    Widget Function()? errorWidget,
    int? cacheWidth,
    int? cacheHeight,
    super.scale,
  }) : super(
         imageUrl: imageUrl.startsWith('http://')
             ? imageUrl.replaceFirst('http://', 'https://')
             : imageUrl,
         httpHeaders: headers,
         placeholder: placeholder == null
             ? (_, _) => _defaultPlaceholder()
             : (_, _) => placeholder(),
         errorWidget: errorWidget == null
             ? (_, _, _) => _defaultPlaceholder()
             : (_, _, _) => errorWidget(),
         memCacheWidth: cacheWidth,
         memCacheHeight: cacheHeight,
         fadeInDuration: const Duration(milliseconds: 200),
         fadeOutDuration: const Duration(milliseconds: 200),
         cacheKey: imageUrl,
       );

  static Widget _defaultPlaceholder() {
    return Padding(
      padding: EdgeInsetsGeometry.all(40),
      child: Center(child: Icon(Icons.image_not_supported_outlined, size: 28)),
    );
  }
}
