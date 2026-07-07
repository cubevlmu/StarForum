import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/excerpt_dao.dart';
import 'package:star_forum/data/db/dao/first_posts_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';

enum LocalCacheCategory {
  discussions,
  posts,
  users,
  tags,
  notifications,
  collections,
}

class LocalCacheSummary {
  const LocalCacheSummary({required this.category, required this.count});

  final LocalCacheCategory category;
  final int count;
}

class LocalCacheRepository {
  LocalCacheRepository(
    this.discussionsDao,
    this.resourceCacheDao,
    this.collectionDao,
    this.firstPostsDao,
    this.excerptDao,
  );

  final DiscussionsDao discussionsDao;
  final ResourceCacheDao resourceCacheDao;
  final CacheCollectionDao collectionDao;
  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;

  Future<List<LocalCacheSummary>> summaries() async {
    final values = await Future.wait<int>([
      discussionsDao.countResources(),
      resourceCacheDao.countPosts(),
      resourceCacheDao.countUsers(),
      resourceCacheDao.countTags(),
      resourceCacheDao.countNotifications(),
      collectionDao.countAllItems(),
    ]);
    return [
      LocalCacheSummary(
        category: LocalCacheCategory.discussions,
        count: values[0],
      ),
      LocalCacheSummary(category: LocalCacheCategory.posts, count: values[1]),
      LocalCacheSummary(category: LocalCacheCategory.users, count: values[2]),
      LocalCacheSummary(category: LocalCacheCategory.tags, count: values[3]),
      LocalCacheSummary(
        category: LocalCacheCategory.notifications,
        count: values[4],
      ),
      LocalCacheSummary(
        category: LocalCacheCategory.collections,
        count: values[5],
      ),
    ];
  }

  Future<void> clear(LocalCacheCategory category) async {
    switch (category) {
      case LocalCacheCategory.discussions:
        await collectionDao.clearResourceType(CacheResourceType.discussion);
        await discussionsDao.clearAll();
        await firstPostsDao.clearAll();
        await excerptDao.clearAll();
        return;
      case LocalCacheCategory.posts:
        await collectionDao.clearResourceType(CacheResourceType.post);
        await resourceCacheDao.clearPosts();
        await firstPostsDao.clearAll();
        await excerptDao.clearAll();
        return;
      case LocalCacheCategory.users:
        await collectionDao.clearResourceType(CacheResourceType.user);
        await resourceCacheDao.clearUsers();
        return;
      case LocalCacheCategory.tags:
        await collectionDao.clearResourceType(CacheResourceType.tag);
        await resourceCacheDao.clearTags();
        return;
      case LocalCacheCategory.notifications:
        await collectionDao.clearResourceType(CacheResourceType.notification);
        await resourceCacheDao.clearNotifications();
        return;
      case LocalCacheCategory.collections:
        await collectionDao.clearAll();
        return;
    }
  }

  Future<void> clearAll() async {
    await collectionDao.clearAll();
    await discussionsDao.clearAll();
    await firstPostsDao.clearAll();
    await excerptDao.clearAll();
    await resourceCacheDao.clearAll();
  }
}
