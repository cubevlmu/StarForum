/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/widgets.dart';

@immutable
class ForumInfo {
  final String url;
  final String title;
  final String description;
  final String welcomeTitle;
  final String welcomeMessage;
  final String logoUrl;
  final bool canUpload;

  static ForumInfo empty = ForumInfo(
    url: "",
    title: "",
    description: "",
    welcomeTitle: "",
    welcomeMessage: "",
    logoUrl: "",
    canUpload: false,
  );

  const ForumInfo({
    required this.url,
    required this.title,
    required this.description,
    required this.welcomeTitle,
    required this.welcomeMessage,
    required this.logoUrl,
    required this.canUpload,
  });

  Map<String, Object?> toCacheMap() => {
    'url': url,
    'title': title,
    'description': description,
    'welcomeTitle': welcomeTitle,
    'welcomeMessage': welcomeMessage,
    'logoUrl': logoUrl,
    'canUpload': canUpload,
  };

  factory ForumInfo.fromCacheMap(Map<Object?, Object?> map) {
    return ForumInfo(
      url: map['url']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      welcomeTitle: map['welcomeTitle']?.toString() ?? '',
      welcomeMessage: map['welcomeMessage']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString() ?? '',
      canUpload: map['canUpload'] == true,
    );
  }
}
