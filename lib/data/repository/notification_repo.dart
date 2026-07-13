/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/notification_api.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class NotificationRepository {
  NotificationRepository(
    this.notificationApi,
    this.resourceCacheDao,
    this.collectionDao,
  );

  final NotificationApi notificationApi;
  final ResourceCacheDao resourceCacheDao;
  final CacheCollectionDao collectionDao;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  static const collectionKey = 'notification:all';

  Future<List<NotificationsInfo>> getCachedNotifications({
    int limit = 20,
  }) async {
    final cached = await resourceCacheDao.getNotifications(limit: limit);
    return cached.map((row) => row.toNotificationInfo()).toList();
  }

  Future<PagedRepoResult<NotificationsInfo>> getNotifications({String? url}) {
    return _requests.run(
      'notifications:${url ?? 'first'}',
      () => _getNotifications(url: url),
    );
  }

  Future<PagedRepoResult<NotificationsInfo>> _getNotifications({
    required String? url,
  }) async {
    try {
      final data = await notificationApi.list(nextUrl: url);
      if (data == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      final syncTime = DateTime.now();
      final offset = url == null ? 0 : await collectionDao.count(collectionKey);
      await resourceCacheDao.upsertNotifications(
        data.items
            .map((notification) => notification.toDbNotification(syncTime))
            .toList(growable: false),
      );
      await collectionDao.replaceWindowAndMarkSynced(
        collectionKey: collectionKey,
        resourceType: CacheResourceType.notification,
        offset: offset,
        windowLimit: data.items.length,
        items: [
          for (var index = 0; index < data.items.length; index += 1)
            DbCacheCollectionItemsCompanion.insert(
              collectionKey: collectionKey,
              resourceType: CacheResourceType.notification,
              resourceId: data.items[index].id.toString(),
              sortIndex: offset + index,
              fingerprint: data.items[index].fingerprint,
              seenAt: syncTime,
              syncedAt: syncTime,
            ),
        ],
        keepLimit: 300,
        nextUrl: data.nextUrl,
        syncedAt: syncTime,
        ttlSeconds: 10,
      );
      return PagedRepoResult.success(
        data.items,
        nextUrl: data.nextUrl,
        hasMoreOverride: data.hasMore,
      );
    } on FlarumTransportError catch (error) {
      if (url == null) {
        final cached = await resourceCacheDao.getNotifications(limit: 20);
        if (cached.isNotEmpty) {
          return PagedRepoResult.success(
            cached.map((row) => row.toNotificationInfo()).toList(),
            hasMoreOverride: false,
            fromCache: true,
          );
        }
      }
      return PagedRepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<RepoResult<NotificationsInfo>> markRead(String id) async {
    final result = await RepoResult.guard(
      () => notificationApi.markRead(id),
      name: 'notification.markRead',
    );
    final parsedId = int.tryParse(id);
    if (parsedId != null && result.isSuccess) {
      await resourceCacheDao.markNotificationRead(parsedId);
    }
    final data = result.data;
    if (data != null) {
      await resourceCacheDao.upsertNotifications([
        data.toDbNotification(DateTime.now()),
      ]);
    }
    return result;
  }

  Future<RepoResult<void>> readAll() async {
    final result = await RepoResult.guardBool(
      notificationApi.readAll,
      name: 'notification.readAll',
    );
    if (result.isSuccess) {
      await resourceCacheDao.markAllNotificationsRead();
    }
    return result;
  }

  Future<RepoResult<void>> clearAll() {
    return _clearAll();
  }

  Future<RepoResult<void>> _clearAll() async {
    try {
      final ok = await notificationApi.clearAll();
      if (ok) {
        await resourceCacheDao.markAllNotificationsDeleted();
        await collectionDao.replaceWindow(
          collectionKey: collectionKey,
          resourceType: CacheResourceType.notification,
          offset: 0,
          windowLimit: 300,
          items: const [],
        );
      }
      return ok
          ? const RepoResult.success(null)
          : const RepoResult.failure(RepoError.operationFailed);
    } on FlarumTransportError catch (error) {
      if (error.statusCode == 403 || error.statusCode == 404) {
        return const RepoResult.failure(RepoError.operationFailed);
      }
      return RepoResult.failure(RepoError.fromTransport(error));
    }
  }
}

extension on NotificationsInfo {
  String get fingerprint {
    return [
      id,
      contentType,
      isRead,
      createdAt.toUtc().toIso8601String(),
    ].join('|');
  }

  DbNotificationsCompanion toDbNotification(DateTime syncTime) {
    final subjectValue = subject;
    return DbNotificationsCompanion.insert(
      id: Value(id),
      type: contentType,
      isRead: Value(isRead),
      createdAt: createdAt,
      fromUserId: Value(fromUser?.id),
      subjectType: Value(subjectValue?.type),
      subjectId: Value(subjectValue?.id.toString()),
      contentJson: Value(content == null ? null : jsonEncode(content)),
      cachedTitle: Value(cachedTitle),
      cachedDesc: Value(cachedDesc),
      fingerprint: Value(fingerprint),
      syncedAt: syncTime,
      deletedAt: const Value(null),
    );
  }
}

extension on DbNotification {
  NotificationsInfo toNotificationInfo() {
    return NotificationsInfo(
      id: id,
      contentType: type,
      createdAt: createdAt,
      isRead: isRead,
      cachedTitle: cachedTitle,
      cachedDesc: cachedDesc,
    );
  }
}
