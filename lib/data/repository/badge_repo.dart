/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:star_forum/data/api/extensions/badge_api.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class BadgeRepository {
  BadgeRepository(this.badgeApi);

  final BadgeApi badgeApi;

  Future<RepoResult<BadgeCategories>> getBadgeCategories() async {
    try {
      return RepoResult.fromNullable(await badgeApi.listCategories());
    } on FlarumTransportError catch (error) {
      if (error.isExtensionMissing) {
        badgeApi.client.setEnvironment(
          badgeApi.client.environment.copyWith(
            features: badgeApi.client.environment.features.copyWith(
              hasBadge: false,
            ),
          ),
        );
      }
      return RepoResult.failure(
        RepoError.fromTransport(error, extensionEndpoint: true),
      );
    }
  }
}
