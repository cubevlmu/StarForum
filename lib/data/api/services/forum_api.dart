/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_api_environment.dart';
import 'package:star_forum/data/api/flarum_auth.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/utils/string_util.dart';

import 'api_parsing.dart';

class ForumProbeResult {
  const ForumProbeResult({required this.environment, required this.latencyMs});

  final FlarumApiEnvironment environment;
  final int latencyMs;
}

class ForumApi {
  ForumApi(this.client);

  final FlarumApiClient client;
  ForumProbeResult? _cached;
  Future<ForumProbeResult?>? _pendingProbe;
  String? _pendingBaseUrl;

  Future<ForumInfo?> getForumInfo(String baseUrl, {bool force = false}) async {
    return (await probe(baseUrl, force: force))?.environment.forumInfo;
  }

  Future<ForumProbeResult?> probe(String baseUrl, {bool force = false}) async {
    final normalized = StringUtil.normalizeSiteUrl(baseUrl);
    if (normalized == null || normalized.isEmpty) return null;
    if (!force && _cached?.environment.baseUrl == normalized) return _cached;

    final pending = _pendingProbe;
    if (pending != null && _pendingBaseUrl == normalized) return pending;

    final task = _probe(normalized);
    _pendingProbe = task;
    _pendingBaseUrl = normalized;
    try {
      return await task;
    } finally {
      if (identical(_pendingProbe, task)) {
        _pendingProbe = null;
        _pendingBaseUrl = null;
      }
    }
  }

  Future<ForumProbeResult?> _probe(String normalized) async {
    final previous = client.environment;
    final previousAuth = client.auth;
    final switchingSite =
        previous.baseUrl.isNotEmpty && previous.baseUrl != normalized;
    if (switchingSite) {
      client.clearAuth();
    }
    client.setEnvironment(FlarumApiEnvironment(baseUrl: normalized));
    final watch = Stopwatch()..start();
    try {
      final response = await client.get<Object?>('/api');
      final document = documentOf(response.data);
      final forum = parseForumDocument(document);
      final data = asJsonMap(document.data);
      final attrs = asJsonMap(data['attributes']);
      final versionText = [
        attrs['version'],
        attrs['flarumVersion'],
        attrs['apiVersion'],
      ].whereType<Object>().map((value) => value.toString()).join(' ');
      final major = RegExp(r'(^|\D)2\.').hasMatch(versionText)
          ? FlarumApiMajor.v2
          : RegExp(r'(^|\D)1\.').hasMatch(versionText)
          ? FlarumApiMajor.v1
          : FlarumApiMajor.unknown;
      final features = FlarumApiFeatures(
        hasFoFUpload:
            attrs.containsKey('fof-upload.canUpload') ||
            attrs.keys.any((key) => key.startsWith('fof-upload.')),
        hasBadge: attrs.keys.any((key) => key.toLowerCase().contains('badge')),
        supportsAvatarSrcset:
            attrs.containsKey('avatarSrcset') ||
            document.included.any(
              (resource) => resource.attributes.containsKey('avatarSrcset'),
            ),
        supportsPostLogout: true,
        supportsDiscussionShowPosts: false,
        supportsUserDirectory: true,
      );
      final environment = FlarumApiEnvironment(
        baseUrl: normalized,
        apiMajor: major,
        forumInfo: forum,
        features: features,
      );
      client.setEnvironment(environment);
      watch.stop();
      return _cached = ForumProbeResult(
        environment: environment,
        latencyMs: watch.elapsedMilliseconds,
      );
    } catch (_) {
      client.setEnvironment(previous);
      if (switchingSite &&
          previousAuth.kind != FlarumAuthKind.none &&
          previousAuth.token.isNotEmpty) {
        client.setAuth(previousAuth);
      }
      return null;
    }
  }
}
