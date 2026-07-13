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
import 'package:star_forum/data/perf/perf_log.dart';

JsonApiDocument documentOf(Object? raw) => JsonApiDocument.from(raw);

ForumInfo parseForum(Object? raw) => _measureParse(
  'forum',
  () => const ForumMapper().document(documentOf(raw)) ?? ForumInfo.empty,
);

ForumInfo parseForumDocument(JsonApiDocument document) => _measureParse(
  'forum',
  () => const ForumMapper().document(document) ?? ForumInfo.empty,
);

Tags parseTags(Object? raw) => _measureParse(
  'tags',
  () => const TagMapper().documentList(documentOf(raw)),
);

DiscussionDetail? parseDiscussion(Object? raw) => _measureParse(
  'discussion',
  () => const DiscussionMapper().document(documentOf(raw)),
);

List<DiscussionDetail> parseDiscussions(Object? raw) => _measureParse(
  'discussions',
  () => const DiscussionMapper().documentList(documentOf(raw)),
);

List<DiscussionDetail> parseDiscussionsDocument(JsonApiDocument document) =>
    _measureParse(
      'discussions',
      () => const DiscussionMapper().documentList(document),
    );

Posts parsePosts(Object? raw) => _measureParse(
  'posts',
  () => const PostMapper().documentList(documentOf(raw)),
);

Posts parsePostsDocument(JsonApiDocument document) =>
    _measureParse('posts', () => const PostMapper().documentList(document));

PostInfo? parsePost(Object? raw) =>
    _measureParse('post', () => const PostMapper().document(documentOf(raw)));

UserInfo? parseUser(Object? raw) =>
    _measureParse('user', () => const UserMapper().document(documentOf(raw)));

NotificationInfoList parseNotifications(Object? raw) => _measureParse(
  'notifications',
  () => const NotificationMapper().documentList(documentOf(raw)),
);

NotificationsInfo parseNotification(Object? raw) => _measureParse(
  'notification',
  () =>
      const NotificationMapper().document(documentOf(raw)) ??
      NotificationsInfo(
        id: -1,
        contentType: '',
        createdAt: DateTime.utc(1980),
        isRead: false,
      ),
);

UploadFileList parseUploads(Object? raw) => _measureParse(
  'uploads',
  () => const UploadMapper().documentList(documentOf(raw)),
);

BadgeCategories parseBadges(Object? raw) => _measureParse(
  'badges',
  () => const BadgeMapper().documentList(documentOf(raw)),
);

T _measureParse<T>(String name, T Function() parse) {
  final watch = Stopwatch()..start();
  final result = parse();
  watch.stop();
  PerfLog.parsing(name, parseUs: watch.elapsedMicroseconds);
  return result;
}
