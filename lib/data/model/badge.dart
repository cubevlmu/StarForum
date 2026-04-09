/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/model/base.dart';

class Badge {
  final int id;
  final String name;
  final String icon;
  final String description;
  final int earnedAmount;

  Badge(
    this.id,
    this.name,
    this.icon,
    this.description,
    this.earnedAmount,
  );

  factory Badge.fromBaseData(BaseData data) {
    final info = JsonReader(asJsonMap(data.attributes));
    return Badge(
      data.id,
      info.string("name"),
      info.string("icon"),
      info.string("description"),
      info.integer("earnedAmount"),
    );
  }
}

class BadgeCategory {
  final int id;
  final String name;
  final String description;
  final List<Badge> badges;

  BadgeCategory(
    this.id,
    this.name,
    this.description,
    this.badges,
  );

  factory BadgeCategory.fromMapAndId(Map m, int id) {
    final info = JsonReader(asJsonMap(m));
    return BadgeCategory(
      id,
      info.string("name"),
      info.string("description"),
      [],
    );
  }
}

class BadgeCategories {
  final List<BadgeCategory> list;
  final Links links;

  BadgeCategories({
    required this.list,
    required this.links,
  });

  factory BadgeCategories.fromMap(Map map) {
    return BadgeCategories.fromBase(BaseListBean.fromMap(map));
  }

  factory BadgeCategories.fromBase(BaseListBean base) {
    final List<BadgeCategory> list = [];
    final Map<int, Badge> badges = {};

    for (final data in base.included.data) {
      if (data.type == "badges") {
        final badge = Badge.fromBaseData(data);
        badges[badge.id] = badge;
      }
    }

    for (final data in base.data.list) {
      if (data.type != "badgeCategories") continue;

      final category = BadgeCategory.fromMapAndId(
        data.attributes,
        data.id,
      );

      for (final badgeId in data.relatedIds("badges")) {
        final badge = badges[badgeId];
        if (badge != null) {
          category.badges.add(badge);
        }
      }

      list.add(category);
    }

    return BadgeCategories(
      list: list,
      links: base.links,
    );
  }
}