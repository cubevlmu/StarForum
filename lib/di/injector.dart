/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/background/background_task_scheduler.dart';
import 'package:star_forum/data/api/extensions/badge_api.dart';
import 'package:star_forum/data/api/extensions/fof_upload_api.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/forum_http_transport.dart';
import 'package:star_forum/data/api/services/auth_api.dart';
import 'package:star_forum/data/api/services/discussion_api.dart';
import 'package:star_forum/data/api/services/forum_api.dart';
import 'package:star_forum/data/api/services/notification_api.dart';
import 'package:star_forum/data/api/services/post_api.dart';
import 'package:star_forum/data/api/services/tag_api.dart';
import 'package:star_forum/data/api/services/user_api.dart';
import 'package:star_forum/data/repository/badge_repo.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/discussion/discussion_cache_writer.dart';
import 'package:star_forum/data/repository/discussion/discussion_detail_repository.dart';
import 'package:star_forum/data/repository/discussion/discussion_excerpt_hydrator.dart';
import 'package:star_forum/data/repository/discussion/discussion_feed_repository.dart';
import 'package:star_forum/data/repository/discussion/discussion_mutation_service.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/data/repository/local_cache_repo.dart';
import 'package:star_forum/data/repository/notification_repo.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/data/repository/upload_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/repository/user/forum_permission_service.dart';
import 'package:star_forum/data/repository/user/session_repository.dart';
import 'package:star_forum/data/repository/user/user_directory_repository.dart';
import 'package:star_forum/data/repository/user/user_profile_mutation_service.dart';
import 'package:star_forum/data/repository/user/user_repository.dart';
import 'package:star_forum/data/sync/sync_status.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupInjector() {
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<SyncStatusService>(SyncStatusService());
  getIt.registerSingleton<SessionState>(SessionState());
  getIt.registerSingleton<BackgroundTaskScheduler>(BackgroundTaskScheduler());
  getIt.registerLazySingleton<FlarumApiClient>(
    () => FlarumApiClient(ForumHttpTransport.create()),
  );
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<FlarumApiClient>()));
  getIt.registerLazySingleton<ForumApi>(
    () => ForumApi(getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<DiscussionApi>(
    () => DiscussionApi(getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<PostApi>(() => PostApi(getIt<FlarumApiClient>()));
  getIt.registerLazySingleton<UserApi>(() => UserApi(getIt<FlarumApiClient>()));
  getIt.registerLazySingleton<TagApi>(() => TagApi(getIt<FlarumApiClient>()));
  getIt.registerLazySingleton<NotificationApi>(
    () => NotificationApi(getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<FoFUploadApi>(
    () => FoFUploadApi(getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<BadgeApi>(
    () => BadgeApi(getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<BadgeRepository>(
    () => BadgeRepository(getIt<BadgeApi>()),
  );
  getIt.registerLazySingleton<ForumRepository>(
    () => ForumRepository(getIt<ForumApi>(), getIt<FlarumApiClient>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(
      getIt<NotificationApi>(),
      getIt<AppDatabase>().resourceCacheDao,
      getIt<AppDatabase>().cacheCollectionDao,
    ),
  );
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepository(
      getIt<PostApi>(),
      getIt<AppDatabase>().resourceCacheDao,
      getIt<AppDatabase>().cacheCollectionDao,
      getIt<AppDatabase>().discussionsDao,
    ),
  );
  getIt.registerLazySingleton<UploadRepository>(
    () => UploadRepository(getIt<FoFUploadApi>()),
  );

  getIt.registerLazySingleton<DiscussionCacheWriter>(
    () => DiscussionCacheWriter(
      getIt<AppDatabase>().discussionsDao,
      getIt<AppDatabase>().firstPostsDao,
      getIt<AppDatabase>().excerptDao,
      getIt<AppDatabase>().cacheCollectionDao,
      getIt<AppDatabase>().resourceCacheDao,
    ),
  );
  getIt.registerLazySingleton<DiscussionExcerptHydrator>(
    () => DiscussionExcerptHydrator(
      getIt<AppDatabase>().firstPostsDao,
      getIt<AppDatabase>().excerptDao,
      getIt<PostRepository>(),
    ),
  );
  getIt.registerLazySingleton<DiscussionFeedRepository>(
    () => DiscussionFeedRepository(
      getIt<AppDatabase>().discussionsDao,
      getIt<AppDatabase>().cacheCollectionDao,
      getIt<SyncStatusService>(),
      getIt<DiscussionApi>(),
      getIt<DiscussionCacheWriter>(),
      getIt<DiscussionExcerptHydrator>(),
      getIt<BackgroundTaskScheduler>(),
    ),
  );
  getIt.registerLazySingleton<DiscussionDetailRepository>(
    () => DiscussionDetailRepository(
      getIt<AppDatabase>().discussionsDao,
      getIt<AppDatabase>().cacheCollectionDao,
      getIt<DiscussionApi>(),
      getIt<DiscussionCacheWriter>(),
      getIt<DiscussionExcerptHydrator>(),
      getIt<BackgroundTaskScheduler>(),
    ),
  );
  getIt.registerLazySingleton<DiscussionMutationService>(
    () => DiscussionMutationService(
      getIt<DiscussionApi>(),
      getIt<DiscussionCacheWriter>(),
    ),
  );
  getIt.registerLazySingleton(
    () => DiscussionRepository(
      getIt<DiscussionFeedRepository>(),
      getIt<DiscussionDetailRepository>(),
      getIt<DiscussionMutationService>(),
      getIt<DiscussionCacheWriter>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () =>
        UserRepository(getIt<UserApi>(), getIt<AppDatabase>().resourceCacheDao),
  );
  getIt.registerLazySingleton<UserDirectoryRepository>(
    () => UserDirectoryRepository(
      getIt<UserApi>(),
      getIt<FlarumApiClient>(),
      getIt<AppDatabase>().resourceCacheDao,
      getIt<AppDatabase>().cacheCollectionDao,
    ),
  );
  getIt.registerLazySingleton<UserProfileMutationService>(
    () => UserProfileMutationService(getIt<UserApi>()),
  );
  getIt.registerLazySingleton<ForumPermissionService>(
    () => ForumPermissionService(getIt<ForumRepository>()),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepository(
      getIt<AuthApi>(),
      getIt<FlarumApiClient>(),
      getIt<UserRepository>(),
      getIt<ForumPermissionService>(),
      getIt<SessionState>(),
    ),
  );
  getIt.registerLazySingleton<UserRepo>(
    () => UserRepo(
      getIt<SessionRepository>(),
      getIt<UserRepository>(),
      getIt<UserDirectoryRepository>(),
      getIt<UserProfileMutationService>(),
    ),
  );
  getIt.registerLazySingleton<TagRepo>(
    () => TagRepo(getIt<TagApi>(), getIt<AppDatabase>().resourceCacheDao),
  );
  getIt.registerLazySingleton<LocalCacheRepository>(
    () => LocalCacheRepository(
      getIt<AppDatabase>().discussionsDao,
      getIt<AppDatabase>().resourceCacheDao,
      getIt<AppDatabase>().cacheCollectionDao,
      getIt<AppDatabase>().firstPostsDao,
      getIt<AppDatabase>().excerptDao,
    ),
  );
}
