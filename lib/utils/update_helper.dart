/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:star_forum/utils/http_utils.dart';
import 'package:dio/dio.dart';

const String kGithubUpdateOwner = 'cubevlmu';
const String kGithubUpdateRepo = 'StarForum';
const String kGithubLatestReleaseUrl =
    'https://github.com/$kGithubUpdateOwner/$kGithubUpdateRepo/releases/latest';
const String kAppVersion = '1.2.0';

String _normalizeVersion(String input) {
  return input.trim();
}

List<int> _parseVersionParts(String version) {
  final normalized = _normalizeVersion(version);
  final match = RegExp(r'^\d+\.\d+\.\d+$').firstMatch(normalized);
  if (match == null) {
    return const <int>[];
  }
  return normalized
      .split('.')
      .map((segment) => int.tryParse(segment) ?? 0)
      .toList(growable: false);
}

@immutable
class GithubReleaseInfo {
  const GithubReleaseInfo({
    required this.title,
    required this.description,
    required this.version,
  });

  final String title;
  final String description;
  final String version;

  factory GithubReleaseInfo.fromMap(Map<String, dynamic> json) {
    return GithubReleaseInfo(
      title: (json['name'] ?? '').toString().trim(),
      description: (json['body'] ?? '').toString(),
      version: _normalizeVersion((json['tag_name'] ?? '').toString()),
    );
  }
}

@immutable
class UpdateCheckResult {
  const UpdateCheckResult({required this.release, required this.hasUpdate});

  final GithubReleaseInfo release;
  final bool hasUpdate;
}

class UpdateHelper {
  static final HttpUtils _http = HttpUtils();

  static Future<GithubReleaseInfo?> fetchLatestGithubRelease({
    required String owner,
    required String repo,
  }) async {
    final response = await _http.get(
      'https://api.github.com/repos/$owner/$repo/releases/latest',
      options: Options(
        headers: {
          'Authorization': null,
          'Accept': 'application/vnd.github+json',
        },
      ),
    );

    final data = response.data;
    if (data is! Map) {
      return null;
    }

    final mapped = Map<String, dynamic>.from(data);
    final info = GithubReleaseInfo.fromMap(mapped);
    if (info.version.isEmpty) {
      return null;
    }
    return info;
  }

  static Future<bool> isNewerThanAppVersion({
    required GithubReleaseInfo release,
    required String appVersion,
  }) async {
    final releaseParts = _parseVersionParts(release.version);
    final appParts = _parseVersionParts(_normalizeVersion(appVersion));
    final maxLength = releaseParts.length > appParts.length
        ? releaseParts.length
        : appParts.length;

    for (var i = 0; i < maxLength; i++) {
      final releaseValue = i < releaseParts.length ? releaseParts[i] : 0;
      final appValue = i < appParts.length ? appParts[i] : 0;
      if (releaseValue > appValue) {
        return true;
      }
      if (releaseValue < appValue) {
        return false;
      }
    }

    return false;
  }

  static Future<UpdateCheckResult?> checkGithubUpdate({
    required String owner,
    required String repo,
    required String appVersion,
  }) async {
    final release = await fetchLatestGithubRelease(owner: owner, repo: repo);
    if (release == null) {
      return null;
    }

    final hasUpdate = await isNewerThanAppVersion(
      release: release,
      appVersion: appVersion,
    );
    return UpdateCheckResult(release: release, hasUpdate: hasUpdate);
  }
}
