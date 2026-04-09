/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/widgets.dart';

import 'base.dart';

@immutable
class ForumInfo {
  final String url;
  final String title;
  final String description;
  final String welcomeTitle;
  final String welcomeMessage;
  final String logoUrl;

  static ForumInfo empty = ForumInfo(
    url: "",
    title: "",
    description: "",
    welcomeTitle: "",
    welcomeMessage: "",
    logoUrl: "",
  );
  
  const ForumInfo({
    required this.url,
    required this.title,
    required this.description,
    required this.welcomeTitle,
    required this.welcomeMessage,
    required this.logoUrl,
  });

  factory ForumInfo.fromMap(Map map) {
    return ForumInfo.fromBase(BaseBean.fromMap(map));
  }

  factory ForumInfo.fromBase(BaseBean base) {
    if (base.data.type == "forums") {
      Map info = base.data.attributes;
      return ForumInfo(
        title: info["title"] ?? "",
        url: info["baseUrl"],
        description: info["description"] ?? "",
        welcomeTitle: info["welcomeTitle"] ?? "",
        welcomeMessage: info["welcomeMessage"] ?? "",
        logoUrl: info["logoUrl"] ?? "",
      );
    }
    return empty;
  }
}
