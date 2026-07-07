import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/mappers/discussion_mapper.dart';
import 'package:star_forum/data/api/mappers/badge_mapper.dart';
import 'package:star_forum/data/api/mappers/forum_mapper.dart';
import 'package:star_forum/data/api/mappers/notification_mapper.dart';
import 'package:star_forum/data/api/mappers/post_mapper.dart';
import 'package:star_forum/data/api/mappers/user_mapper.dart';
import 'package:star_forum/data/api/mappers/tag_mapper.dart';
import 'package:star_forum/data/api/mappers/upload_mapper.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/model/users.dart';

JsonApiDocument documentOf(Object? raw) => JsonApiDocument.from(raw);

ForumInfo parseForum(Object? raw) =>
    const ForumMapper().document(documentOf(raw)) ?? ForumInfo.empty;

Tags parseTags(Object? raw) => const TagMapper().documentList(documentOf(raw));

DiscussionInfo? parseDiscussion(Object? raw) =>
    const DiscussionMapper().document(documentOf(raw));

Discussions parseDiscussions(Object? raw) =>
    const DiscussionMapper().documentList(documentOf(raw));

Posts parsePosts(Object? raw) =>
    const PostMapper().documentList(documentOf(raw));

PostInfo? parsePost(Object? raw) =>
    const PostMapper().document(documentOf(raw));

UserInfo? parseUser(Object? raw) =>
    const UserMapper().document(documentOf(raw));

NotificationInfoList parseNotifications(Object? raw) =>
    const NotificationMapper().documentList(documentOf(raw));

NotificationsInfo parseNotification(Object? raw) =>
    const NotificationMapper().document(documentOf(raw)) ??
    NotificationsInfo(
      id: -1,
      contentType: '',
      createdAt: DateTime.utc(1980),
      isRead: false,
    );

UploadFileList parseUploads(Object? raw) =>
    const UploadMapper().documentList(documentOf(raw));

BadgeCategories parseBadges(Object? raw) =>
    const BadgeMapper().documentList(documentOf(raw));
