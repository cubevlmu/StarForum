import 'package:star_forum/data/model/forum_info.dart';

enum FlarumApiMajor { unknown, v1, v2 }

class FlarumApiFeatures {
  const FlarumApiFeatures({
    this.hasFoFUpload = false,
    this.hasBadge = false,
    this.supportsAvatarSrcset = false,
    this.supportsPostLogout = false,
    this.supportsDiscussionShowPosts = false,
    this.supportsUserDirectory = true,
  });

  final bool hasFoFUpload;
  final bool hasBadge;
  final bool supportsAvatarSrcset;
  final bool supportsPostLogout;
  final bool supportsDiscussionShowPosts;
  final bool supportsUserDirectory;

  FlarumApiFeatures copyWith({
    bool? hasFoFUpload,
    bool? hasBadge,
    bool? supportsAvatarSrcset,
    bool? supportsPostLogout,
    bool? supportsDiscussionShowPosts,
    bool? supportsUserDirectory,
  }) {
    return FlarumApiFeatures(
      hasFoFUpload: hasFoFUpload ?? this.hasFoFUpload,
      hasBadge: hasBadge ?? this.hasBadge,
      supportsAvatarSrcset: supportsAvatarSrcset ?? this.supportsAvatarSrcset,
      supportsPostLogout: supportsPostLogout ?? this.supportsPostLogout,
      supportsDiscussionShowPosts:
          supportsDiscussionShowPosts ?? this.supportsDiscussionShowPosts,
      supportsUserDirectory:
          supportsUserDirectory ?? this.supportsUserDirectory,
    );
  }
}

class FlarumApiEnvironment {
  const FlarumApiEnvironment({
    required this.baseUrl,
    this.apiMajor = FlarumApiMajor.unknown,
    this.forumInfo,
    this.features = const FlarumApiFeatures(),
  });

  final String baseUrl;
  final FlarumApiMajor apiMajor;
  final ForumInfo? forumInfo;
  final FlarumApiFeatures features;

  FlarumApiEnvironment copyWith({
    String? baseUrl,
    FlarumApiMajor? apiMajor,
    ForumInfo? forumInfo,
    FlarumApiFeatures? features,
  }) {
    return FlarumApiEnvironment(
      baseUrl: baseUrl ?? this.baseUrl,
      apiMajor: apiMajor ?? this.apiMajor,
      forumInfo: forumInfo ?? this.forumInfo,
      features: features ?? this.features,
    );
  }
}
