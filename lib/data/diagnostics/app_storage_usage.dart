import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/migration/local_data_migration.dart';
import 'package:star_forum/utils/cache_utils.dart';

@immutable
class AppStorageUsageSnapshot {
  const AppStorageUsageSnapshot({
    required this.databaseBytes,
    required this.settingsBytes,
    required this.logBytes,
    required this.exportBytes,
    required this.imageCacheBytes,
  });

  final int databaseBytes;
  final int settingsBytes;
  final int logBytes;
  final int exportBytes;
  final Map<String, int> imageCacheBytes;

  int get imageBytes => imageCacheBytes.values.fold(0, (sum, v) => sum + v);
  int get supportBytes => databaseBytes + settingsBytes + logBytes;
  int get cacheBytes => imageBytes + exportBytes;
  int get totalBytes => supportBytes + cacheBytes;

  int imageBytesFor(String key) => imageCacheBytes[key] ?? 0;
}

class AppStorageUsageService {
  AppStorageUsageService({
    Future<Directory> Function()? supportDirectory,
    Future<Directory> Function()? temporaryDirectory,
  }) : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _supportDirectory;
  final Future<Directory> Function() _temporaryDirectory;

  Future<AppStorageUsageSnapshot> load() async {
    final directories = await Future.wait<Directory>([
      _supportDirectory(),
      _temporaryDirectory(),
    ]);
    final support = directories[0];
    final temporary = directories[1];
    final imageSizes = await Future.wait<int>([
      for (final key in CacheUtils.cacheKeys)
        _imageCacheSize(support, temporary, key),
    ]);
    final sizes = await Future.wait<int>([
      _databaseSize(support),
      _settingsSize(support),
      directorySize(Directory(p.join(support.path, 'logs'))),
      directorySize(Directory(p.join(temporary.path, 'star_forum_exports'))),
    ]);

    return AppStorageUsageSnapshot(
      databaseBytes: sizes[0],
      settingsBytes: sizes[1],
      logBytes: sizes[2],
      exportBytes: sizes[3],
      imageCacheBytes: Map.unmodifiable({
        for (var i = 0; i < CacheUtils.cacheKeys.length; i++)
          CacheUtils.cacheKeys[i]: imageSizes[i],
      }),
    );
  }

  Future<void> clearExports() async {
    final temporary = await _temporaryDirectory();
    final directory = Directory(p.join(temporary.path, 'star_forum_exports'));
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<int> _databaseSize(Directory support) async {
    return _filesSize([
      for (final suffix in const ['', '-wal', '-shm', '-journal'])
        File(p.join(support.path, '${AppDatabase.fileName}$suffix')),
    ]);
  }

  Future<int> _settingsSize(Directory support) async {
    final hiveBytes = await directorySize(
      Directory(p.join(support.path, 'hive')),
    );
    final markerBytes = await _filesSize([
      File(p.join(support.path, LocalDataMigration.markerFileName)),
    ]);
    return hiveBytes + markerBytes;
  }

  Future<int> _imageCacheSize(
    Directory support,
    Directory temporary,
    String key,
  ) async {
    final fileBytes = await Future.wait<int>([
      directorySize(Directory(p.join(temporary.path, key))),
      directorySize(
        Directory(p.join(temporary.path, 'libCachedImageData', key)),
      ),
    ]);
    final metadataBytes = await _filesSize([
      for (final extension in const ['db', 'json'])
        for (final suffix in const ['', '-wal', '-shm', '-journal'])
          File(p.join(support.path, '$key.$extension$suffix')),
    ]);
    return fileBytes.fold(0, (sum, size) => sum + size) + metadataBytes;
  }

  static Future<int> _filesSize(Iterable<File> files) async {
    var total = 0;
    for (final file in files) {
      try {
        if (await file.exists()) total += await file.length();
      } catch (_) {}
    }
    return total;
  }

  static Future<int> directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      try {
        total += await entity.length();
      } catch (_) {}
    }
    return total;
  }
}
