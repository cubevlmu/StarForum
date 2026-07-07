import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/badge.dart';

import 'mapper_support.dart';

class BadgeMapper {
  const BadgeMapper();

  BadgeCategories documentList(JsonApiDocument document) {
    final badges = <int, Badge>{};
    for (final resource in document.index.ofType('badges')) {
      final badge = badgeItem(resource);
      badges[badge.id] = badge;
    }
    final categories = <BadgeCategory>[];
    for (final resource in documentResources(document)) {
      if (resource.type != 'badgeCategories') continue;
      final attrs = JsonReader(resource.attributes);
      categories.add(
        BadgeCategory(
          resource.intId,
          attrs.string('name'),
          attrs.string('description'),
          [
            for (final id in resource.relatedIds('badges'))
              if (badges[int.tryParse(id)] != null) badges[int.parse(id)]!,
          ],
        ),
      );
    }
    return BadgeCategories(
      list: categories,
      links: Links.fromMap(document.links),
    );
  }

  Badge badgeItem(JsonApiResource resource) {
    final attrs = JsonReader(resource.attributes);
    return Badge(
      resource.intId,
      attrs.string('name'),
      attrs.string('icon'),
      attrs.string('description'),
      attrs.integer('earnedAmount'),
    );
  }

  List<UserBadge> userBadgeList(JsonApiDocument document) {
    final categories = <int, BadgeCategory>{};
    for (final resource in document.index.ofType('badgeCategories')) {
      final attrs = JsonReader(resource.attributes);
      categories[resource.intId] = BadgeCategory(
        resource.intId,
        attrs.string('name'),
        attrs.string('description'),
        const <Badge>[],
      );
    }

    final badges = <int, Badge>{};
    final badgeCategories = <int, BadgeCategory?>{};
    for (final resource in document.index.ofType('badges')) {
      final badge = badgeItem(resource);
      badges[badge.id] = badge;
      final categoryId = int.tryParse(resource.relatedId('category') ?? '');
      badgeCategories[badge.id] = categories[categoryId];
    }

    final owner = documentResource(document);
    final ids = owner?.relatedIds('userBadges') ?? const <String>[];
    return [
      for (final id in ids)
        if (document.index.find('userBadges', id) != null)
          _userBadgeItem(
            document.index.find('userBadges', id)!,
            badges,
            badgeCategories,
          ),
    ].whereType<UserBadge>().toList(growable: false);
  }

  UserBadge? _userBadgeItem(
    JsonApiResource resource,
    Map<int, Badge> badges,
    Map<int, BadgeCategory?> categories,
  ) {
    final badgeId = int.tryParse(resource.relatedId('badge') ?? '');
    final badge = badges[badgeId];
    if (badge == null) return null;
    final attrs = JsonReader(resource.attributes);
    return UserBadge(
      id: resource.intId,
      badge: badge,
      category: categories[badge.id],
      description: attrs.string('description'),
      assignedAt: attrs.dateTime('assignedAt'),
      isPrimary: attrs.boolean('isPrimary'),
      inUserCard: attrs.boolean('inUserCard'),
    );
  }
}
