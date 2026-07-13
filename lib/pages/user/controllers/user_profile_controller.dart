import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart' as cached_image;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/string_util.dart';

class UserProfileController {
  UserProfileController({required this.userId});

  final int userId;
  final UserRepo repository = getIt<UserRepo>();
  final cacheManager = CacheUtils.avatarCacheManager;
  final Rxn<UserInfo> profile = Rxn<UserInfo>();
  final RxBool isProfileLoading = false.obs;
  final RxBool isAvatarUploading = false.obs;
  final RxBool isBioUpdating = false.obs;
  final RxBool isNicknameUpdating = false.obs;
  final RxBool detailsExpanded = false.obs;
  final CancelToken _cancelToken = CancelToken();
  Future<void>? _loadingTask;
  Timer? _refreshTimer;
  DateTime? _lastRemoteLoadAt;
  bool _initialized = false;
  bool _expAnimationPlayed = false;

  static const refreshInterval = Duration(minutes: 15);

  void _ensurePeriodicRefresh() {
    _refreshTimer ??= Timer.periodic(refreshInterval, (_) {
      unawaited(load(force: true));
    });
  }

  UserInfo? get info => profile.value;
  set info(UserInfo? value) => profile.value = value;
  bool get initialized => _initialized;
  bool get hasExpData => info?.expInfo != null;
  RxBool get isLoading => isProfileLoading;

  Future<void> load({bool force = false}) async {
    _ensurePeriodicRefresh();
    final lastRemoteLoadAt = _lastRemoteLoadAt;
    if (!force &&
        info != null &&
        lastRemoteLoadAt != null &&
        DateTime.now().difference(lastRemoteLoadAt) < refreshInterval) {
      isProfileLoading.value = false;
      return;
    }
    final activeTask = _loadingTask;
    if (activeTask != null) return activeTask;

    final task = _loadInternal();
    _loadingTask = task;
    await task;
  }

  Future<void> _loadInternal() async {
    if (userId <= 0) {
      LogUtil.warn('[UserProfileController] invalid user id: $userId');
      isProfileLoading.value = false;
      return;
    }
    if (info == null) isProfileLoading.value = true;
    try {
      final cached = await repository.getCachedUserInfoByNameOrId(
        userId.toString(),
      );
      if (cached != null && info == null) {
        info = cached;
        _initialized = true;
        isProfileLoading.value = false;
      }
      final result = await repository.getUserInfoByNameOrId(
        userId.toString(),
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return;
      final remote = result.data;
      if (remote == null) {
        LogUtil.error('[UserProfileController] empty user response: $userId');
        return;
      }
      info = info?.mergedWith(remote) ?? remote;
      _lastRemoteLoadAt = DateTime.now();
      if (info?.expInfo == null) _expAnimationPlayed = true;
      _initialized = true;
    } catch (error, stackTrace) {
      LogUtil.errorE('[UserProfileController] load failed', error, stackTrace);
    } finally {
      _loadingTask = null;
      isProfileLoading.value = false;
    }
  }

  bool isMe() {
    return info != null &&
        repository.isLogin &&
        info?.id == repository.user?.id;
  }

  String getLastSeenAt() {
    if (info == null) return '';
    if (isMe()) return AppLocalizations.of(Get.context!)!.userOnline;
    try {
      final date = info?.lastSeenAt ?? fallbackTime;
      return StringUtil.timeStampToAgoDate(date.millisecondsSinceEpoch ~/ 1000);
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserProfileController] parse last seen failed',
        error,
        stackTrace,
      );
      return '';
    }
  }

  String getRegisterAt() {
    if (info == null) return '';
    try {
      final date = info?.joinTime ?? fallbackTime;
      return StringUtil.timeStampToAgoDate(date.millisecondsSinceEpoch ~/ 1000);
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserProfileController] parse join time failed',
        error,
        stackTrace,
      );
      return '';
    }
  }

  String buildExpString() {
    final expInfo = info?.expInfo;
    if (expInfo == null) return '';
    return '${expInfo.expLevel} 路 ${expInfo.expTotal} / '
        '${expInfo.expTotal + expInfo.expNextNeed}';
  }

  double getExpPercent() => (info?.expInfo?.expPercent ?? 0) / 100;

  bool shouldAnimateExp() {
    return !_expAnimationPlayed && info?.expInfo != null;
  }

  void markExpAnimationPlayed() => _expAnimationPlayed = true;

  void toggleDetailsExpanded() {
    detailsExpanded.value = !detailsExpanded.value;
  }

  List<String> getGroupNames() {
    return info?.groups?.list
            .map((group) => group.name.trim())
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];
  }

  String getProfileBio() {
    final value = info?.bio.trim() ?? '';
    return value.isEmpty
        ? AppLocalizations.of(Get.context!)!.userBioEmpty
        : value;
  }

  String getUsernameLabel() {
    final value = info?.username.trim() ?? '';
    return value.isEmpty ? '--' : '@$value';
  }

  String getEmailLabel() {
    final value = info?.email.trim() ?? '';
    return value.isEmpty
        ? AppLocalizations.of(Get.context!)!.userFieldHidden
        : value;
  }

  String getUserIdLabel() {
    final value = info?.id;
    return value == null || value < 0 ? '--' : value.toString();
  }

  Future<bool> uploadAvatarBytes({
    required Uint8List fileData,
    required String fileName,
  }) async {
    if (!isMe()) return false;
    final currentAvatarUrl =
        info?.avatarUrl ?? repository.user?.avatarUrl ?? '';
    isAvatarUploading.value = true;
    try {
      final result = await repository.uploadAvatar(
        userId: repository.userId,
        fileData: fileData,
        fileName: fileName,
      );
      if (result.isFailure) return false;
      if (currentAvatarUrl.isNotEmpty) {
        await cached_image.CachedNetworkImage.evictFromCache(
          currentAvatarUrl,
          cacheKey: currentAvatarUrl,
          cacheManager: cacheManager,
        );
      }
      cacheManager.store.emptyMemoryCache();
      await _refreshAfterMutation();
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserProfileController] upload avatar failed',
        error,
        stackTrace,
      );
      return false;
    } finally {
      isAvatarUploading.value = false;
    }
  }

  Future<bool> updateBioText(String bio) async {
    if (!isMe()) return false;
    final value = bio.trim();
    isBioUpdating.value = true;
    try {
      final result = await repository.updateBio(repository.userId, value);
      if (result.isFailure) return false;
      if (!await _refreshAfterMutation() && info != null) {
        info = info!.copyWith(bio: value);
      }
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserProfileController] update bio failed',
        error,
        stackTrace,
      );
      return false;
    } finally {
      isBioUpdating.value = false;
    }
  }

  Future<bool> updateNicknameText(String nickname) async {
    if (!isMe()) return false;
    final username = info?.username.trim() ?? repository.user?.username.trim();
    if (username == null || username.isEmpty) return false;
    final value = nickname.trim();
    isNicknameUpdating.value = true;
    try {
      final result = await repository.updateNickname(
        userId: repository.userId,
        username: username,
        nickname: value,
      );
      if (result.isFailure) return false;
      if (!await _refreshAfterMutation() && info != null) {
        info = info!.copyWith(displayName: value);
      }
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserProfileController] update nickname failed',
        error,
        stackTrace,
      );
      return false;
    } finally {
      isNicknameUpdating.value = false;
    }
  }

  Future<bool> _refreshAfterMutation() async {
    final refreshed = await repository.refreshCurrentUser();
    if (refreshed && repository.user != null) {
      info = repository.user;
      _initialized = true;
      return true;
    }
    return false;
  }

  void dispose() {
    _refreshTimer?.cancel();
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('User profile closed.');
    }
  }
}
