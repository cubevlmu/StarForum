import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';

class AssetsController extends GetxController {
  final UserRepo userRepo = getIt<UserRepo>();
  final RxList<UploadFileInfo> files = <UploadFileInfo>[].obs;
  final Rxn<UploadFileInfo> selectedFile = Rxn<UploadFileInfo>();
  final RxBool isInitialLoading = true.obs;
  final RxBool isUploading = false.obs;
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
    onRefresh();
  }

  void selectFile(UploadFileInfo file) {
    selectedFile.value = selectedFile.value?.id == file.id ? null : file;
  }

  Future<bool?> pickAndUpload() async {
    if (isUploading.value || !userRepo.canUpload.value) {
      return false;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final uploadFiles = <ApiUploadFile>[];
    for (final file in result.files) {
      uploadFiles.add(
        ApiUploadFile(fileName: file.name, path: file.path, bytes: file.bytes),
      );
    }

    isUploading.value = true;
    try {
      final (uploaded, ok) = await Api.uploadFiles(uploadFiles);
      if (!ok || uploaded == null) {
        return false;
      }

      if (uploaded.list.isNotEmpty) {
        files.insertAll(0, uploaded.list);
        selectedFile.value = uploaded.list.first;
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
      final (ok, tokenOk) = await Api.deleteUploadFile(file.uuid);
      if (!tokenOk || !ok) {
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

      final (result, ok) = await Api.getUploads(
        userId: userRepo.userId,
        offset: 0,
        limit: _pageSize,
      );
      if (!ok) {
        _finishRefreshSafe(IndicatorResult.fail);
        return;
      }

      final list = result?.list ?? const <UploadFileInfo>[];
      files.assignAll(list);
      _nextUrl = result?.links.next;
      _hasMore = _nextUrl != null && _nextUrl!.isNotEmpty;

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
      final (result, ok) = await Api.getUploads(
        userId: userRepo.userId,
        url: _nextUrl,
      );
      if (!ok) {
        _finishLoadSafe(IndicatorResult.fail);
        return;
      }

      final next = result?.list ?? const <UploadFileInfo>[];
      if (next.isNotEmpty) {
        files.addAll(next);
      }
      _nextUrl = result?.links.next;
      _hasMore = _nextUrl != null && _nextUrl!.isNotEmpty;

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
    scrollController.dispose();
    refreshController.dispose();
    CacheUtils.assetThumbCacheManager.store.emptyMemoryCache();
    super.onClose();
  }
}
