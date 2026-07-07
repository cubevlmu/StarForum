import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/uploads.dart';

import '../services/api_parsing.dart';

class FofUploadFile {
  const FofUploadFile({required this.fileName, this.path, this.bytes});

  final String fileName;
  final String? path;
  final Uint8List? bytes;

  Future<MultipartFile> toMultipartFile() {
    if (path != null && path!.isNotEmpty) {
      return MultipartFile.fromFile(path!, filename: fileName);
    }
    final data = bytes;
    if (data == null || data.isEmpty) {
      throw StateError('Upload file data is empty: $fileName');
    }
    return Future.value(MultipartFile.fromBytes(data, filename: fileName));
  }
}

class FoFUploadApi {
  FoFUploadApi(this.client);

  final FlarumApiClient client;

  Future<FlarumPage<UploadFileInfo>?> list({
    required int userId,
    int offset = 0,
    int limit = 15,
    String? nextUrl,
  }) async {
    final response = await client.get<Object?>(
      nextUrl ?? '/api/fof/uploads',
      query: nextUrl == null
          ? (FlarumQuery()
                  ..filter('user', userId.toString())
                  ..page(offset: offset, limit: limit))
                .build()
          : null,
    );
    final parsed = parseUploads(response.data);
    return FlarumPage(
      items: parsed.list,
      nextUrl: parsed.links.next.isEmpty ? null : parsed.links.next,
      prevUrl: parsed.links.prev.isEmpty ? null : parsed.links.prev,
    );
  }

  Future<List<UploadFileInfo>?> upload(List<FofUploadFile> files) async {
    if (files.isEmpty) return const [];
    final form = FormData();
    for (final file in files) {
      form.files.add(MapEntry('files[]', await file.toMultipartFile()));
    }
    final response = await client.post<Object?>(
      '/api/fof/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return parseUploads(response.data).list;
  }

  Future<bool> delete(String uuid) async {
    final response = await client.post<Object?>(
      '/api/fof/upload/delete/$uuid',
      options: Options(headers: {'X-HTTP-Method-Override': 'DELETE'}),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
