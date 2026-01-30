/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/data/db/app_database.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupInjector() {
  // Database
  // getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Dao
  // getIt.registerLazySingleton<DiscussionsDao>(() => DiscussionsDao(getIt<AppDatabase>()));

  // Api
  // getIt.registerLazySingleton<SyncApi>(() => SyncApi());

  // Repository（这一行必须存在）
  // getIt.registerLazySingleton<DiscussionsRepository>(() => DiscussionsRepository(getIt<SyncApi>(), getIt<DiscussionsDao>()));

  getIt.registerSingleton<AppDatabase>(AppDatabase());

  getIt.registerLazySingleton(
    () => DiscussionRepository(
      getIt<AppDatabase>().discussionsDao,
      getIt<AppDatabase>().firstPostsDao,
      getIt<AppDatabase>().excerptDao,
    ),
  );
  // getIt.registerLazySingleton<DiscussionDetailRepository>(() => DiscussionDetailRepository());
  getIt.registerLazySingleton<UserRepo>(() => UserRepo());

}
