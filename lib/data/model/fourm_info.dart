/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'base.dart';

class ForumInfo {
  final String title;
  final String description;
  final String welcomeTitle;
  final String welcomeMessage;
  final String logoUrl;

  static ForumInfo empty = ForumInfo(title: "", description: "", welcomeTitle: "", welcomeMessage: "", logoUrl: "");
  ForumInfo({required this.title, required this.description, required this.welcomeTitle, required this.welcomeMessage, required this.logoUrl});

  factory ForumInfo.formJson(String data) {
    var base = BaseBean.formJson(data);
    return ForumInfo.formBase(base);
  }

  factory ForumInfo.formBase(BaseBean base) {
    if (base.data.type == "forums") {
      Map info = base.data.attributes;
      return ForumInfo(
        title: info["title"],
        description: info["description"],
        welcomeTitle: info["welcomeTitle"],
        welcomeMessage: info["welcomeMessage"],
        logoUrl: info["logoUrl"]
      );
    }
    return empty;
  }
}
