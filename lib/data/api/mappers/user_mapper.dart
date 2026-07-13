import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/group_info.dart';
import 'package:star_forum/data/model/users.dart';

import 'mapper_support.dart';

class UserMapper {
  const UserMapper();

  UserInfo? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'users') return null;
    return resourceItem(resource, document: document);
  }

  List<UserInfo> documentList(JsonApiDocument document) {
    return [
      for (final resource in documentResources(document))
        if (resource.type == 'users')
          resourceItem(resource, document: document),
    ];
  }

  UserInfo resourceItem(JsonApiResource resource, {JsonApiDocument? document}) {
    final attrs = JsonReader(resource.attributes);
    final groups = document == null
        ? const <GroupInfo>[]
        : [
            for (final group in document.includedMany(resource, 'groups'))
              groupItem(group),
          ];
    return UserInfo(
      resource.intId,
      attrs.string('username'),
      attrs.string('displayName', attrs.string('username')),
      attrs.string('avatarUrl'),
      attrs.dateTime(
        attrs.contains('joinedAt') ? 'joinedAt' : 'joinTime',
        DateTime.utc(1980),
      ),
      attrs.integer('discussionCount'),
      attrs.integer('commentCount'),
      attrs.dateTime('lastSeenAt', DateTime.utc(1980)),
      attrs.string('email'),
      groups.isEmpty ? null : Groups(list: groups),
      attrs.string('bio'),
      avatarSrcset: attrs.string('avatarSrcset'),
      expInfo: attrs.contains('expLevel')
          ? ExpInfo(
              attrs.string('expLevel'),
              attrs.integer('expTotal'),
              attrs.integer('expPercent'),
              attrs.string('expNext'),
              attrs.integer('expNextNeed'),
            )
          : null,
    );
  }

  GroupInfo groupItem(JsonApiResource resource) {
    final attrs = JsonReader(resource.attributes);
    return GroupInfo(
      id: resource.intId,
      name: attrs.string('namePlural', attrs.string('nameSingular')),
      color: attrs.string('color', '#FFFFFF'),
      icon: attrs.string('icon'),
    );
  }
}
