/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:star_forum/data/api/api_constants.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_api_environment.dart';
import 'package:star_forum/data/api/services/forum_api.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/string_util.dart';

class ForumRepository {
  ForumRepository(this.forumApi, this.client);

  final ForumApi forumApi;
  final FlarumApiClient client;

  String get baseUrl => client.baseUrl;

  bool get hasFixedBaseUrl => ApiConstants.hasFixedApi;

  ForumInfo? get cachedForumInfo {
    final raw = StorageUtils.networkData.get(
      SettingsStorageKeys.forumInfoCache,
    );
    if (raw is! Map) return null;
    final cached = ForumInfo.fromCacheMap(raw);
    if (cached.title.isEmpty ||
        (cached.url.isNotEmpty && cached.url != client.baseUrl)) {
      return null;
    }
    return cached;
  }

  Future<RepoResult<void>> setup() async {
    final configured = ApiConstants.hasFixedApi
        ? ApiConstants.fixedApi
        : StorageUtils.networkData
              .get(SettingsStorageKeys.apiBaseUrl)
              ?.toString();
    if (configured == null || configured.isEmpty) {
      return const RepoResult.failure(RepoError.empty);
    }
    final normalized = StringUtil.normalizeSiteUrl(configured);
    if (normalized == null || normalized.isEmpty) {
      return const RepoResult.failure(RepoError.empty);
    }
    client.setEnvironment(FlarumApiEnvironment(baseUrl: normalized));
    return const RepoResult.success(null);
  }

  Future<RepoResult<ForumInfo>> refreshEnvironment({bool force = false}) async {
    return getForumInfo(baseUrl, force: force);
  }

  void setUrl(String url) {
    final selected = ApiConstants.hasFixedApi ? ApiConstants.fixedApi : url;
    final normalized = StringUtil.normalizeSiteUrl(selected);
    if (normalized == null || normalized.isEmpty) return;
    if (client.baseUrl.isNotEmpty && client.baseUrl != normalized) {
      client.clearAuth();
      StorageUtils.networkData.delete(SettingsStorageKeys.forumInfoCache);
    }
    client.setEnvironment(FlarumApiEnvironment(baseUrl: normalized));
    StorageUtils.networkData.put(SettingsStorageKeys.apiBaseUrl, normalized);
  }

  Future<RepoResult<ForumInfo>> getForumInfo(
    String url, {
    bool force = false,
  }) async {
    final result = await forumApi.probe(url, force: force);
    if (result == null) return const RepoResult.failure(RepoError.empty);
    await StorageUtils.networkData.put(
      SettingsStorageKeys.forumInfoCache,
      result.environment.forumInfo!.toCacheMap(),
    );
    return RepoResult.success(
      result.environment.forumInfo!,
      latencyMs: result.latencyMs,
    );
  }

  String discussionUrl(String discussionId) {
    return "$baseUrl/d/$discussionId";
  }
}
