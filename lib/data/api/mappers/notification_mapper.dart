import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/model/posts.dart';

import 'mapper_support.dart';
import 'post_mapper.dart';
import 'user_mapper.dart';

class NotificationMapper {
  const NotificationMapper({
    this.userMapper = const UserMapper(),
    this.postMapper = const PostMapper(),
  });

  final UserMapper userMapper;
  final PostMapper postMapper;

  NotificationInfoList documentList(JsonApiDocument document) {
    return NotificationInfoList(
      [
        for (final resource in documentResources(document))
          if (resource.type == 'notifications')
            resourceItem(resource, document),
      ],
      Links(
        first: linkValue(document, 'first') ?? '',
        prev: linkValue(document, 'prev') ?? '',
        next: linkValue(document, 'next') ?? '',
      ),
    );
  }

  NotificationsInfo? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'notifications') return null;
    return resourceItem(resource, document);
  }

  NotificationsInfo resourceItem(
    JsonApiResource resource,
    JsonApiDocument document,
  ) {
    final attrs = JsonReader(resource.attributes);
    final notification = NotificationsInfo(
      id: resource.intId,
      contentType: attrs.string('contentType'),
      createdAt: attrs.dateTime('createdAt'),
      isRead: attrs.boolean('isRead'),
      content: resource.attributes['content'] is Map
          ? asJsonMap(resource.attributes['content'])
          : null,
    );

    final fromUser = document.includedOne(resource, 'fromUser');
    if (fromUser != null && fromUser.type == 'users') {
      notification.fromUser = userMapper.resourceItem(
        fromUser,
        document: document,
      );
    }

    final identifiers = resource.relationshipIdentifiers('subject');
    if (identifiers.isEmpty) return notification;
    final identifier = identifiers.first;
    final subject = document.index.find(identifier.type, identifier.id);
    final subjectId = int.tryParse(identifier.id) ?? -1;

    notification.subject = switch (identifier.type) {
      'posts' => PostSubject(
        subject == null
            ? PostInfo(subjectId, '', '', '', -1, -1, -1, -1)
            : postMapper.resourceItem(subject),
      ),
      'discussions' => DiscussionSubject(
        DiscussionNotificationInfo(
          id: subjectId,
          title: JsonReader(subject?.attributes ?? const {}).string('title'),
        ),
      ),
      'users' => UserSubject(
        NotificationUserInfo(
          id: subjectId,
          displayName: JsonReader(
            subject?.attributes ?? const {},
          ).string('displayName'),
          avatarUrl: JsonReader(
            subject?.attributes ?? const {},
          ).string('avatarUrl'),
        ),
      ),
      'quest-infos' => QuestSubject(
        QuestInfo(
          id: subjectId,
          name: JsonReader(subject?.attributes ?? const {}).string('name'),
          description: JsonReader(
            subject?.attributes ?? const {},
          ).string('description'),
        ),
      ),
      'levels' => LevelSubject(
        LevelInfo(
          id: subjectId,
          name: JsonReader(subject?.attributes ?? const {}).string('name'),
          minExpRequired: JsonReader(
            subject?.attributes ?? const {},
          ).integer('min_exp_required'),
        ),
      ),
      _ => null,
    };
    return notification;
  }
}
