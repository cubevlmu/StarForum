import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';

class UserBadgesController {
  UserBadgesController({required this.userId});

  final int userId;
  final UserRepo repository = getIt<UserRepo>();
  final RxList<UserBadge> items = <UserBadge>[].obs;
  final RxBool isLoading = false.obs;
  final CancelToken _cancelToken = CancelToken();
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> load() async {
    if (_initialized || isLoading.value || userId <= 0) return;
    isLoading.value = true;
    try {
      final result = await repository.getUserBadges(
        userId,
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return;
      items.assignAll(result.data ?? const <UserBadge>[]);
      _initialized = true;
    } catch (error, stackTrace) {
      LogUtil.errorE('[UserBadgesController] load failed', error, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('User badges closed.');
    }
  }
}
