import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/background/background_task_scheduler.dart';
import 'package:star_forum/data/db/dao/excerpt_dao.dart';
import 'package:star_forum/data/db/dao/first_posts_dao.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/setting_util.dart';

@immutable
class DiscussionExcerptTask {
  const DiscussionExcerptTask({
    required this.discussionId,
    required this.contentHtml,
    required this.sourceUpdatedAt,
  });

  final String discussionId;
  final String contentHtml;
  final DateTime sourceUpdatedAt;
}

@immutable
class DiscussionExcerptResult {
  const DiscussionExcerptResult({
    required this.discussionId,
    required this.excerpt,
    required this.sourceUpdatedAt,
  });

  final String discussionId;
  final String excerpt;
  final DateTime sourceUpdatedAt;
}

List<DiscussionExcerptResult> buildDiscussionExcerptResults(
  List<DiscussionExcerptTask> tasks,
) {
  return tasks
      .map((task) {
        var excerpt = htmlToPlainText(task.contentHtml);
        if (excerpt.length > 80) excerpt = excerpt.substring(0, 80);
        return DiscussionExcerptResult(
          discussionId: task.discussionId,
          excerpt: excerpt,
          sourceUpdatedAt: task.sourceUpdatedAt,
        );
      })
      .where((result) {
        final value = result.excerpt.trim();
        return value.isNotEmpty && value != '...';
      })
      .toList(growable: false);
}

class DiscussionExcerptHydrator {
  DiscussionExcerptHydrator(this.firstPostsDao, this.excerptDao, this.postRepo);

  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;
  final PostRepository postRepo;

  Future<List<DiscussionDetail>> withCachedFirstPosts(
    List<DiscussionDetail> discussions,
  ) async {
    if (!SettingsUtil.showDiscussionExcerpt || discussions.isEmpty) {
      return discussions;
    }
    final cached = await firstPostsDao.getByDiscussionIds(
      discussions.map((discussion) => discussion.id).toList(growable: false),
    );
    return [
      for (final discussion in discussions)
        if (cached[discussion.id] case final row?
            when discussion.firstPost == null)
          discussion.copyWith(
            firstPost: PostInfo(
              discussion.firstPostId,
              row.updatedAt.toIso8601String(),
              row.content,
              row.updatedAt.toIso8601String(),
              discussion.user?.id ?? -1,
              -1,
              int.tryParse(discussion.id) ?? -1,
              row.likeCount,
              user: discussion.user,
            ),
          )
        else
          discussion,
    ];
  }

  Future<List<DiscussionDetail>> targets(
    List<DiscussionDetail> pageItems,
    List<DiscussionDetail> changed,
  ) async {
    if (!SettingsUtil.showDiscussionExcerpt || pageItems.isEmpty) {
      return const <DiscussionDetail>[];
    }
    final missingIds = await excerptDao.findMissingOrInvalid(
      pageItems.map((discussion) => discussion.id),
    );
    if (changed.isEmpty && missingIds.isEmpty) {
      return const <DiscussionDetail>[];
    }
    final byId = <String, DiscussionDetail>{
      for (final item in pageItems) item.id: item,
      for (final item in changed) item.id: item,
    };
    return [
      for (final id in {
        ...changed.map((discussion) => discussion.id),
        ...missingIds,
      })
        if (byId[id] != null) byId[id]!,
    ];
  }

  Future<void> hydrate(
    List<DiscussionDetail> discussions, {
    BackgroundTaskCancellationToken? cancellationToken,
  }) async {
    cancellationToken?.throwIfCancelled();
    final tasks = <DiscussionExcerptTask>[];
    final missingFirstPostIds = <int>{};
    final discussionIdByPostId = <int, String>{};
    final firstPostRows = <DbFirstPostsCompanion>[];
    final cacheThreshold = DateTime.now().subtract(const Duration(days: 7));
    final discussionsWithoutPost = <DiscussionDetail>[];

    for (final discussion in discussions) {
      final post = discussion.firstPost;
      if (post != null && _hasSource(post.contentHtml)) {
        tasks.add(_taskFromPost(discussion.id, post));
        firstPostRows.add(_firstPostCompanion(discussion.id, post));
      } else {
        discussionsWithoutPost.add(discussion);
      }
    }

    final cachedPosts = await firstPostsDao.getByDiscussionIds(
      discussionsWithoutPost
          .map((discussion) => discussion.id)
          .toList(growable: false),
    );
    cancellationToken?.throwIfCancelled();
    for (final discussion in discussionsWithoutPost) {
      final cached = cachedPosts[discussion.id];
      final remoteFirstPost = discussion.firstPost;
      final remoteUpdatedAt = remoteFirstPost == null
          ? null
          : _updatedAt(remoteFirstPost);
      final cacheMatchesRemote =
          cached != null &&
          (remoteUpdatedAt == null ||
              !cached.updatedAt.isBefore(remoteUpdatedAt));
      if (cached != null &&
          _hasSource(cached.content) &&
          !cached.updatedAt.isBefore(cacheThreshold) &&
          cacheMatchesRemote) {
        tasks.add(
          DiscussionExcerptTask(
            discussionId: discussion.id,
            contentHtml: cached.content,
            sourceUpdatedAt: cached.updatedAt,
          ),
        );
      } else if (discussion.firstPostId >= 0) {
        missingFirstPostIds.add(discussion.firstPostId);
        discussionIdByPostId[discussion.firstPostId] = discussion.id;
      }
    }

    if (missingFirstPostIds.isNotEmpty) {
      PerfLog.hydration('firstPost', requested: missingFirstPostIds.length);
      final posts = await postRepo.getPostsById(
        missingFirstPostIds.toList(),
        forceRemote: true,
      );
      cancellationToken?.throwIfCancelled();
      var hydrated = 0;
      for (final post in posts.data?.posts.values ?? const <PostInfo>[]) {
        final discussionId = discussionIdByPostId[post.id];
        if (discussionId == null || !_hasSource(post.contentHtml)) continue;
        tasks.add(_taskFromPost(discussionId, post));
        firstPostRows.add(_firstPostCompanion(discussionId, post));
        hydrated++;
      }
      PerfLog.hydration('firstPost', requested: 0, hydrated: hydrated);
    }

    cancellationToken?.throwIfCancelled();
    await firstPostsDao.upsertAll(firstPostRows);
    if (tasks.isEmpty) return;
    late final List<DiscussionExcerptResult> results;
    if (tasks.length < 4) {
      results = buildDiscussionExcerptResults(tasks);
    } else {
      final stopwatch = Stopwatch()..start();
      results = await compute(buildDiscussionExcerptResults, tasks);
      stopwatch.stop();
      PerfLog.htmlParseBatch(
        'excerptWorker',
        count: tasks.length,
        elapsedUs: stopwatch.elapsedMicroseconds,
        inputBytes: tasks.fold(
          0,
          (total, task) => total + task.contentHtml.length * 2,
        ),
        isolated: true,
      );
    }
    cancellationToken?.throwIfCancelled();
    final generatedAt = DateTime.now();
    await excerptDao.upsertAll([
      for (final item in results)
        DbDiscussionExcerptCacheCompanion(
          discussionId: Value(item.discussionId),
          excerpt: Value(item.excerpt),
          sourceUpdatedAt: Value(item.sourceUpdatedAt),
          generatedAt: Value(generatedAt),
        ),
    ]);
  }

  DiscussionExcerptTask _taskFromPost(String discussionId, PostInfo post) {
    return DiscussionExcerptTask(
      discussionId: discussionId,
      contentHtml: post.contentHtml,
      sourceUpdatedAt: _updatedAt(post),
    );
  }

  DbFirstPostsCompanion _firstPostCompanion(
    String discussionId,
    PostInfo post,
  ) {
    return DbFirstPostsCompanion(
      discussionId: Value(discussionId),
      content: Value(post.contentHtml),
      updatedAt: Value(_updatedAt(post)),
      likeCount: Value(post.likes),
    );
  }

  DateTime _updatedAt(PostInfo post) {
    final raw = post.editedAt.isNotEmpty ? post.editedAt : post.createdAt;
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  bool _hasSource(String html) {
    final value = html.trim();
    return value.isNotEmpty && value != '...';
  }
}
