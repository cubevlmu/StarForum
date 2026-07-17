import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/excerpt_dao.dart';
import 'package:star_forum/data/db/dao/first_posts_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/db/mappers/user_cache_mapper.dart';
import 'package:star_forum/data/db/mappers/discussion_cache_mapper.dart';
import 'package:star_forum/data/db/mappers/tag_cache_mapper.dart';
import 'package:drift/drift.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/setting_util.dart';

class DiscussionCacheWriter {
  DiscussionCacheWriter(
    this.discussionsDao,
    this.firstPostsDao,
    this.excerptDao,
    this.collectionDao,
    this.resourceCacheDao,
  );

  final DiscussionsDao discussionsDao;
  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;
  final CacheCollectionDao collectionDao;
  final ResourceCacheDao resourceCacheDao;

  Future<List<DiscussionDetail>> saveCollectionPage({
    required String collectionKey,
    required List<DiscussionDetail> remote,
    required int offset,
    required int limit,
    required String? nextUrl,
    required int ttlSeconds,
  }) async {
    final syncTime = DateTime.now();
    final remoteIds = remote
        .map((discussion) => int.tryParse(discussion.id))
        .whereType<int>()
        .toList(growable: false);
    final cachedById = await discussionsDao.getByIds(remoteIds);
    final normalizedRemote = [
      for (final discussion in remote)
        _normalizeDiscussion(
          discussion,
          cachedById[int.tryParse(discussion.id)],
        ),
    ];
    final localWindow = await collectionDao.getWindow(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      limit: limit,
    );
    final localFingerprints = {
      for (final item in localWindow) item.resourceId: item.fingerprint,
    };
    final changed = <DiscussionDetail>[];
    final collectionItems = <DbCacheCollectionItemsCompanion>[];
    final discussionRows = <DbDiscussionsCompanion>[];
    final userRows = <DbUsersCompanion>[];
    final missingAuthorIds = localWindow.isEmpty
        ? const <String>{}
        : await discussionsDao.findIdsWithMissingAuthor(
            normalizedRemote.map((discussion) => discussion.id),
          );

    for (var index = 0; index < normalizedRemote.length; index += 1) {
      final discussion = normalizedRemote[index];
      final fingerprint = discussion.fingerprint;
      if (localFingerprints[discussion.id] != fingerprint ||
          missingAuthorIds.contains(discussion.id)) {
        changed.add(discussion);
        discussionRows.add(
          discussion.toDbDiscussion(
            syncTime: syncTime,
            fingerprint: fingerprint,
          ),
        );
      }
      final user = discussion.user;
      if (user != null && user.hasCacheableIdentity) {
        userRows.add(user.toDbUser());
      }
      collectionItems.add(
        DbCacheCollectionItemsCompanion.insert(
          collectionKey: collectionKey,
          resourceType: CacheResourceType.discussion,
          resourceId: discussion.id,
          sortIndex: offset + index,
          fingerprint: fingerprint,
          seenAt: syncTime,
          syncedAt: syncTime,
        ),
      );
    }

    await Future.wait([
      discussionsDao.upsertAll(discussionRows),
      resourceCacheDao.upsertUsers(userRows),
    ]);
    await _saveDiscussionTags(normalizedRemote, syncTime: syncTime);
    await collectionDao.replaceWindowAndMarkSynced(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      windowLimit: limit,
      items: collectionItems,
      keepLimit: 600,
      nextUrl: nextUrl,
      syncedAt: syncTime,
      ttlSeconds: ttlSeconds,
    );
    return changed;
  }

  DiscussionDetail _normalizeDiscussion(
    DiscussionDetail remote,
    DiscussionDetail? cached,
  ) {
    final firstPostCreatedAt = DateTime.tryParse(
      remote.firstPost?.createdAt ?? '',
    );
    final createdAt = _validDate(remote.createdAt)
        ? remote.createdAt
        : cached != null && _validDate(cached.createdAt)
        ? cached.createdAt
        : firstPostCreatedAt != null && _validDate(firstPostCreatedAt)
        ? firstPostCreatedAt
        : DateTime.utc(1980);
    final lastPostedAt = _validDate(remote.lastPostedAt)
        ? remote.lastPostedAt
        : cached != null && _validDate(cached.lastPostedAt)
        ? cached.lastPostedAt
        : createdAt;
    final commentCount = remote.commentCount > 0
        ? remote.commentCount
        : cached != null && cached.commentCount > 0
        ? cached.commentCount
        : 1;
    final cachedViews = cached?.views ?? -1;
    final views = remote.views >= 0
        ? remote.views > cachedViews
              ? remote.views
              : cachedViews
        : cachedViews > 0
        ? cachedViews
        : -1;

    return remote.copyWith(
      title: remote.title.trim().isNotEmpty
          ? remote.title
          : cached?.title ?? '',
      createdAt: createdAt,
      lastPostedAt: lastPostedAt,
      commentCount: commentCount,
      participantCount: remote.participantCount > 0
          ? remote.participantCount
          : cached?.participantCount ?? 0,
      views: views,
      lastPostNumber: remote.lastPostNumber > 0
          ? remote.lastPostNumber
          : cached != null && cached.lastPostNumber > 0
          ? cached.lastPostNumber
          : commentCount,
      firstPostId: remote.firstPostId >= 0
          ? remote.firstPostId
          : cached?.firstPostId ?? -1,
    );
  }

  bool _validDate(DateTime value) => value.isAfter(DateTime.utc(1981));

  Future<void> manuallyInsert(DiscussionDetail discussion) async {
    final fingerprint = discussion.fingerprint;
    await discussionsDao.upsert(
      discussion.toDbDiscussion(
        syncTime: DateTime.now(),
        fingerprint: fingerprint,
      ),
    );
    await _saveDiscussionTags([discussion], syncTime: DateTime.now());
    await collectionDao.prependItem(
      collectionKey: DiscussionCollectionKey.feed(),
      resourceType: CacheResourceType.discussion,
      resourceId: discussion.id,
      fingerprint: fingerprint,
    );

    if (!SettingsUtil.showDiscussionExcerpt) return;
    var excerpt = htmlToPlainText(discussion.firstPost?.contentHtml ?? '');
    if (excerpt.length > 80) excerpt = excerpt.substring(0, 80);
    await excerptDao.upsert(
      discussionId: discussion.id,
      excerpt: excerpt,
      sourceUpdatedAt: DateTime.now(),
    );
  }

  Future<void> cleanupDeletedDiscussions() async {
    final threshold = DateTime.now().subtract(const Duration(days: 10));
    final deleted = await discussionsDao.deleteNotSeenSince(threshold);
    LogUtil.info('[DiscussionCacheWriter] Deleted $deleted discussions');
  }

  Future<void> clearAll() async {
    await discussionsDao.clearAll();
    await firstPostsDao.clearAll();
    await excerptDao.clearAll();
    await collectionDao.clearAll();
    await resourceCacheDao.clearAll();
  }

  Future<void> updateSubscriptionIfExists({
    required String discussionId,
    required int subscription,
  }) {
    return discussionsDao.updateSubscriptionIfExists(
      discussionId,
      subscription,
    );
  }

  Future<void> _saveDiscussionTags(
    List<DiscussionDetail> discussions, {
    required DateTime syncTime,
  }) async {
    if (discussions.isEmpty) return;
    final tagsById = <int, TagInfo>{};
    final relations = <DbDiscussionTagsCompanion>[];
    for (final discussion in discussions) {
      for (var index = 0; index < discussion.tags.length; index++) {
        final tag = discussion.tags[index];
        tagsById[tag.id] = tag;
        relations.add(
          DbDiscussionTagsCompanion.insert(
            discussionId: discussion.id,
            tagId: tag.id,
            sortIndex: Value(index),
          ),
        );
      }
    }
    await resourceCacheDao.upsertTags([
      for (final tag in tagsById.values) tag.toDbTag(syncedAt: syncTime),
    ]);
    await resourceCacheDao.replaceDiscussionTagSets(
      discussionIds: discussions.map((item) => item.id).toList(growable: false),
      tags: relations,
    );
  }
}
