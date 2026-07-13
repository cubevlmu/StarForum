import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:star_forum/data/auth/app_secure_storage.dart';
import 'package:star_forum/utils/cache_utils.dart';

class LocalDataMigration {
  LocalDataMigration({
    required this.supportDirectory,
    required this.temporaryDirectory,
    required this.clearSecureStorage,
    Future<void> Function()? clearFileCaches,
    this.targetVersion = currentDataVersion,
  }) : _clearFileCaches = clearFileCaches ?? CacheUtils.deleteAllCacheImage;

  static const int currentDataVersion = 1;
  static const String markerFileName = '.local_data_version';

  final Directory supportDirectory;
  final Directory temporaryDirectory;
  final int targetVersion;
  final Future<void> Function() clearSecureStorage;
  final Future<void> Function() _clearFileCaches;

  static Future<bool> runBeforeBootstrap() async {
    final secureStorage = createAppSecureStorage();
    return LocalDataMigration(
      supportDirectory: await getApplicationSupportDirectory(),
      temporaryDirectory: await getTemporaryDirectory(),
      clearSecureStorage: secureStorage.deleteAll,
    ).run();
  }

  Future<bool> run() async {
    final installedVersion = await _readInstalledVersion();
    if (installedVersion != null && installedVersion >= targetVersion) {
      return false;
    }

    await clearSecureStorage();
    await _deleteSupportData();
    await _deleteTemporaryCaches();
    await _clearFileCaches();
    await _writeInstalledVersion();
    return true;
  }

  File get _markerFile => File(p.join(supportDirectory.path, markerFileName));

  Future<int?> _readInstalledVersion() async {
    final marker = _markerFile;
    if (!await marker.exists()) return null;
    return int.tryParse((await marker.readAsString()).trim());
  }

  Future<void> _deleteSupportData() async {
    if (!await supportDirectory.exists()) return;
    await for (final entity in supportDirectory.list(followLinks: false)) {
      await entity.delete(recursive: true);
    }
  }

  Future<void> _deleteTemporaryCaches() async {
    for (final cacheKey in CacheUtils.cacheKeys) {
      final path = p.join(temporaryDirectory.path, cacheKey);
      final type = await FileSystemEntity.type(path, followLinks: false);
      switch (type) {
        case FileSystemEntityType.directory:
          await Directory(path).delete(recursive: true);
        case FileSystemEntityType.file:
        case FileSystemEntityType.link:
          await File(path).delete();
        case FileSystemEntityType.notFound:
          break;
        case FileSystemEntityType.pipe:
        case FileSystemEntityType.unixDomainSock:
          await File(path).delete();
      }
    }
  }

  Future<void> _writeInstalledVersion() async {
    await supportDirectory.create(recursive: true);
    await _markerFile.writeAsString('$targetVersion\n', flush: true);
  }
}
