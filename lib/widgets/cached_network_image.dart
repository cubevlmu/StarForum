/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' as image;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:star_forum/utils/restricted_http_client.dart';

class CachedNetworkImage extends StatelessWidget {
  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.cacheManager,
    this.headers,
    this.width,
    this.height,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
    this.scale = 1,
    this.badCertificateHost,
  });

  final String imageUrl;
  final BaseCacheManager? cacheManager;
  final Map<String, String>? headers;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final Widget Function()? placeholder;
  final Widget Function()? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;
  final double scale;
  final String? badCertificateHost;

  static final Map<String, http.Client> _certificateClients = {};
  static final Map<String, CacheManager> _certificateCacheManagers = {};

  @override
  Widget build(BuildContext context) {
    final url = _normalizedUrl(imageUrl);
    final restrictedHost = _restrictedHostFor(url, badCertificateHost);
    final restrictedClient = restrictedHost == null
        ? null
        : _clientFor(restrictedHost);
    if (_isLikelySvgUrl(url)) {
      return SvgPicture.network(
        url,
        headers: headers,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_, _, _) => _errorWidget(),
        httpClient: restrictedClient,
      );
    }

    return image.CachedNetworkImage(
      imageUrl: url,
      cacheManager: restrictedHost == null
          ? cacheManager
          : _cacheManagerFor(restrictedHost),
      httpHeaders: headers,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      placeholder: (_, _) => _placeholder(),
      errorWidget: (_, _, _) => _errorWidget(),
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      scale: scale,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      cacheKey: imageUrl,
    );
  }

  Widget _placeholder() => placeholder?.call() ?? _defaultPlaceholder();

  Widget _errorWidget() => errorWidget?.call() ?? _defaultPlaceholder();

  static BaseCacheManager cacheManagerFor({
    required String url,
    required BaseCacheManager fallback,
    String? badCertificateHost,
  }) {
    final restrictedHost = _restrictedHostFor(url, badCertificateHost);
    return restrictedHost == null ? fallback : _cacheManagerFor(restrictedHost);
  }

  static String? _restrictedHostFor(String url, String? badCertificateHost) {
    final allowed = badCertificateHost?.trim().toLowerCase();
    if (allowed == null || allowed.isEmpty) return null;
    final host = Uri.tryParse(url)?.host.toLowerCase();
    return host == allowed ? allowed : null;
  }

  static http.Client _clientFor(String host) {
    return _certificateClients.putIfAbsent(
      host,
      () => createRestrictedCertificateClient(host),
    );
  }

  static CacheManager _cacheManagerFor(String host) {
    return _certificateCacheManagers.putIfAbsent(
      host,
      () => CacheManager(
        Config(
          'forumMedia-${host.hashCode}',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
          fileService: HttpFileService(httpClient: _clientFor(host)),
        ),
      ),
    );
  }

  static String _normalizedUrl(String url) {
    if (url.startsWith('//')) return 'https:$url';
    return url;
  }

  static bool _isLikelySvgUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    final format = uri.queryParameters['format']?.toLowerCase();
    return path.endsWith('.svg') ||
        path.endsWith('.svgz') ||
        format == 'svg' ||
        uri.host.toLowerCase() == 'img.shields.io';
  }

  static Widget _defaultPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(child: Icon(Icons.image_not_supported_outlined, size: 28)),
    );
  }
}
