import 'dart:collection';

import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/tags.dart';

import 'mapper_support.dart';

class TagMapper {
  const TagMapper();

  Tags documentList(JsonApiDocument document) {
    final all = <int, TagInfo>{};
    final miniTags = <int, TagInfo>{};
    final resources = <JsonApiResource>[
      ...documentResources(document),
      ...document.index.ofType('tags'),
    ];
    final seen = <String>{};
    for (final resource in resources) {
      if (resource.type != 'tags' || !seen.add(resource.id)) continue;
      final tag = resourceItem(resource);
      if (tag.position == null) {
        tag.children = null;
        miniTags[tag.id] = tag;
      } else {
        all[tag.id] = tag;
      }
    }
    final roots = SplayTreeMap<int, TagInfo>();
    for (final tag in all.values) {
      if (tag.isChild && tag.parentId != null) {
        final parent = all[tag.parentId!];
        parent?.children ??= SplayTreeMap<int, TagInfo>();
        parent?.children?[tag.position ?? 0] = tag;
      } else {
        roots[tag.position ?? 0] = tag;
      }
    }
    return Tags(all, roots, miniTags);
  }

  TagInfo resourceItem(JsonApiResource resource) {
    final attrs = JsonReader(resource.attributes);
    final parentId = int.tryParse(resource.relatedId('parent') ?? '');
    final rawPosition = attrs['position'];
    final position = rawPosition == null
        ? null
        : JsonValue.asInt(rawPosition, -1);
    return TagInfo(
      attrs.string('name'),
      resource.intId,
      attrs.string('description'),
      attrs.string('slug'),
      attrs.integer('discussionCount'),
      position,
      attrs.string('lastPostedAt'),
      null,
      -1,
      attrs.boolean('isChild', parentId != null),
      parentId,
      attrs.boolean('canStartDiscussion', true),
      canAddToDiscussion: attrs.boolean('canAddToDiscussion', true),
      icon: attrs.string('icon'),
      color: attrs.string('color'),
      backgroundUrl: attrs.string('backgroundUrl'),
      backgroundMode: attrs.string('backgroundMode'),
    );
  }
}
