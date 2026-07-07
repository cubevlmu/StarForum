/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:typed_data';

import 'package:star_forum/data/api/extensions/fof_upload_api.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class UploadInputFile {
  const UploadInputFile({required this.fileName, this.path, this.bytes});

  final String fileName;
  final String? path;
  final Uint8List? bytes;

  FofUploadFile toApiFile() {
    return FofUploadFile(fileName: fileName, path: path, bytes: bytes);
  }
}

class UploadRepository {
  UploadRepository(this.uploadApi);

  final FoFUploadApi uploadApi;

  Future<PagedRepoResult<UploadFileInfo>> getUploads({
    required int userId,
    int offset = 0,
    int limit = 15,
    String? url,
  }) async {
    try {
      final data = await uploadApi.list(
        userId: userId,
        offset: offset,
        limit: limit,
        nextUrl: url,
      );
      if (data == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      return PagedRepoResult.success(
        data.items,
        nextUrl: data.nextUrl,
        hasMoreOverride: data.hasMore,
      );
    } on FlarumTransportError catch (error) {
      if (error.isExtensionMissing) _disableUploadFeature();
      return PagedRepoResult.failure(
        RepoError.fromTransport(error, extensionEndpoint: true),
      );
    }
  }

  Future<RepoResult<List<UploadFileInfo>>> uploadFiles(
    List<UploadInputFile> files,
  ) async {
    try {
      final data = await uploadApi.upload(
        files.map((file) => file.toApiFile()).toList(),
      );
      return data == null
          ? const RepoResult.failure(RepoError.empty)
          : RepoResult.success(data);
    } on FlarumTransportError catch (error) {
      if (error.isExtensionMissing) _disableUploadFeature();
      return RepoResult.failure(
        RepoError.fromTransport(error, extensionEndpoint: true),
      );
    }
  }

  Future<RepoResult<void>> deleteUploadFile(String uuid) async {
    try {
      final ok = await uploadApi.delete(uuid);
      return ok
          ? const RepoResult.success(null)
          : const RepoResult.failure(RepoError.operationFailed);
    } on FlarumTransportError catch (error) {
      if (error.isExtensionMissing) _disableUploadFeature();
      return RepoResult.failure(
        RepoError.fromTransport(error, extensionEndpoint: true),
      );
    }
  }

  void _disableUploadFeature() {
    uploadApi.client.setEnvironment(
      uploadApi.client.environment.copyWith(
        features: uploadApi.client.environment.features.copyWith(
          hasFoFUpload: false,
        ),
      ),
    );
  }
}
