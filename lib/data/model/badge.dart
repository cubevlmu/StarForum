/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/api/flarum_links.dart';

class Badge {
  final int id;
  final String name;
  final String icon;
  final String description;
  final int earnedAmount;

  Badge(this.id, this.name, this.icon, this.description, this.earnedAmount);
}

class BadgeCategory {
  final int id;
  final String name;
  final String description;
  final List<Badge> badges;

  BadgeCategory(this.id, this.name, this.description, this.badges);
}

class BadgeCategories {
  final List<BadgeCategory> list;
  final Links links;

  BadgeCategories({required this.list, required this.links});
}

class UserBadge {
  final int id;
  final Badge badge;
  final BadgeCategory? category;
  final String description;
  final DateTime assignedAt;
  final bool isPrimary;
  final bool inUserCard;

  const UserBadge({
    required this.id,
    required this.badge,
    required this.category,
    required this.description,
    required this.assignedAt,
    required this.isPrimary,
    required this.inUserCard,
  });
}
