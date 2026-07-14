import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/users.dart';

extension DbDiscussionCacheMapper on DbDiscussion {
  DiscussionDetail toDiscussionDetail() {
    final author = posterId == null
        ? null
        : UserInfo(
            posterId!,
            '',
            authorName,
            authorAvatar,
            createdAt,
            0,
            0,
            DateTime.utc(1980),
            '',
            null,
            '',
          );
    return DiscussionDetail(
      id,
      title,
      commentCount,
      participantCount,
      viewCount,
      createdAt,
      lastPostedAt ?? createdAt,
      lastPostNumber,
      firstPostId,
      author,
      null,
      null,
      firstPostId >= 0 ? [firstPostId] : const <int>[],
      const {},
      posterId == null || author == null ? const {} : {posterId!: author},
      const [],
      subscription,
      isSticky: isSticky,
      authorRelationshipLoaded: authorResolved,
    );
  }
}

extension DiscussionDetailCacheMapper on DiscussionDetail {
  String get fingerprint {
    final firstPostStamp = firstPost == null
        ? ''
        : [
            firstPost!.editedAt,
            firstPost!.createdAt,
            firstPost!.likes,
            firstPost!.isLiked,
          ].join(':');
    return [
      id,
      title,
      lastPostedAt.toUtc().toIso8601String(),
      lastPostNumber,
      commentCount,
      views,
      subscription,
      isSticky,
      firstPostId,
      firstPostStamp,
    ].join('|');
  }

  DbDiscussionsCompanion toDbDiscussion({
    required DateTime syncTime,
    required String fingerprint,
  }) {
    final author = user;
    final authorId = author != null && author.id > 0 ? author.id : null;
    final hasAuthorIdentity =
        author != null &&
        (author.username.trim().isNotEmpty ||
            author.displayName.trim().isNotEmpty ||
            author.avatarUrl.trim().isNotEmpty);
    return DbDiscussionsCompanion.insert(
      id: id,
      title: title,
      slug: '',
      commentCount: commentCount,
      participantCount: participantCount,
      viewCount: Value(views),
      authorName: hasAuthorIdentity
          ? Value(UserInfo.displayLabel(author, fallbackId: authorId))
          : const Value.absent(),
      authorAvatar: hasAuthorIdentity
          ? Value(author.avatarUrl)
          : const Value.absent(),
      authorResolved: authorRelationshipLoaded
          ? const Value(true)
          : const Value.absent(),
      createdAt: createdAt,
      lastPostedAt: Value(lastPostedAt),
      lastPostNumber: lastPostNumber,
      firstPostId: Value(firstPostId),
      likeCount: Value(firstPost?.likes ?? -1),
      posterId: authorRelationshipLoaded
          ? Value(authorId)
          : const Value.absent(),
      lastSeenAt: syncTime,
      syncedAt: Value(syncTime),
      deletedAt: const Value(null),
      subscription: subscription,
      isSticky: Value(isSticky),
      fingerprint: Value(fingerprint),
    );
  }
}
