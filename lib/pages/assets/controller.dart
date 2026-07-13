import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/repository/upload_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';

class AssetsController extends GetxController {
  final UserRepo userRepo = getIt<UserRepo>();
  final SessionState sessionState = getIt<SessionState>();
  final UploadRepository uploadRepo = getIt<UploadRepository>();
  final RxList<UploadFileInfo> files = <UploadFileInfo>[].obs;
  final Rxn<UploadFileInfo> selectedFile = Rxn<UploadFileInfo>();
  final RxBool isInitialLoading = true.obs;
  final RxBool isUploading = false.obs;
  final RxBool canUpload = false.obs;
  final RxSet<int> deletingIds = <int>{}.obs;

  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  static const int _pageSize = 15;
  String? _nextUrl;
  bool _hasMore = true;
  bool _loading = false;

  @override
  void onInit() {
    super.onInit();
    sessionState.state.addListener(_handleSessionChanged);
    _handleSessionChanged();
    onRefresh();
  }

  void _handleSessionChanged() {
    canUpload.value = sessionState.current.canUpload;
  }

  void selectFile(UploadFileInfo file) {
    selectedFile.value = selectedFile.value?.id == file.id ? null : file;
  }

  Future<bool?> pickAndUpload() async {
    if (isUploading.value || !canUpload.value) {
      return false;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final uploadFiles = <UploadInputFile>[];
    for (final file in result.files) {
      uploadFiles.add(
        UploadInputFile(
          fileName: file.name,
          path: file.path,
          bytes: file.bytes,
        ),
      );
    }

    isUploading.value = true;
    try {
      final result = await uploadRepo.uploadFiles(uploadFiles);
      final uploaded = result.data;
      if (result.isFailure || uploaded == null) {
        return false;
      }

      if (uploaded.isNotEmpty) {
        files.insertAll(0, uploaded);
        selectedFile.value = uploaded.first;
      } else {
        await onRefresh();
      }
      return true;
    } catch (e, s) {
      LogUtil.errorE('[AssetsPage] upload failed', e, s);
      return false;
    } finally {
      isUploading.value = false;
      isInitialLoading.value = false;
    }
  }

  Future<bool> deleteFile(UploadFileInfo file) async {
    if (file.uuid.isEmpty || deletingIds.contains(file.id)) {
      return false;
    }

    deletingIds.add(file.id);
    try {
      final result = await uploadRepo.deleteUploadFile(file.uuid);
      if (result.isFailure) {
        return false;
      }

      files.removeWhere((item) => item.id == file.id);
      if (selectedFile.value?.id == file.id) {
        selectedFile.value = null;
      }
      return true;
    } catch (e, s) {
      LogUtil.errorE('[AssetsPage] delete failed', e, s);
      return false;
    } finally {
      deletingIds.remove(file.id);
    }
  }

  Future<void> onRefresh() async {
    if (_loading) {
      _finishRefreshSafe(IndicatorResult.fail);
      return;
    }

    _loading = true;
    try {
      _nextUrl = null;
      _hasMore = true;
      selectedFile.value = null;

      if (!userRepo.isLogin || userRepo.userId <= 0) {
        files.clear();
        _hasMore = false;
        _finishRefreshSafe(IndicatorResult.success);
        _finishLoadSafe(IndicatorResult.noMore);
        return;
      }

      final result = await uploadRepo.getUploads(
        userId: userRepo.userId,
        offset: 0,
        limit: _pageSize,
      );
      if (result.isFailure) {
        _finishRefreshSafe(IndicatorResult.fail);
        return;
      }

      final list = result.data ?? const <UploadFileInfo>[];
      files.assignAll(list);
      _nextUrl = result.nextUrl;
      _hasMore = result.hasMore;

      _finishRefreshSafe(IndicatorResult.success);
      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[AssetsPage] refresh failed', e, s);
      _finishRefreshSafe(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> onLoad() async {
    if (_loading) {
      _finishLoadSafe(IndicatorResult.fail);
      return;
    }
    if (!_hasMore || _nextUrl == null || _nextUrl!.isEmpty) {
      _finishLoadSafe(IndicatorResult.noMore);
      return;
    }

    _loading = true;
    try {
      final result = await uploadRepo.getUploads(
        userId: userRepo.userId,
        url: _nextUrl,
      );
      if (result.isFailure) {
        _finishLoadSafe(IndicatorResult.fail);
        return;
      }

      final next = result.data ?? const <UploadFileInfo>[];
      if (next.isNotEmpty) {
        files.addAll(next);
      }
      _nextUrl = result.nextUrl;
      _hasMore = result.hasMore;

      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[AssetsPage] load failed', e, s);
      _finishLoadSafe(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  void _finishRefreshSafe(IndicatorResult result) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        refreshController.finishRefresh(result);
      }
    });
  }

  void _finishLoadSafe(IndicatorResult result) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        refreshController.finishLoad(result);
      }
    });
  }

  @override
  void onClose() {
    sessionState.state.removeListener(_handleSessionChanged);
    scrollController.dispose();
    refreshController.dispose();
    CacheUtils.assetThumbCacheManager.store.emptyMemoryCache();
    super.onClose();
  }
}
