import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:star_forum/data/db/app_database.dart';

class LocalDataMigration {
  LocalDataMigration({
    required this.supportDirectory,
    this.databaseFileName = AppDatabase.fileName,
    this.targetVersion = currentDataVersion,
  });

  static const int currentDataVersion = 1;
  static const String markerFileName = '.local_data_version';

  final Directory supportDirectory;
  final String databaseFileName;
  final int targetVersion;

  static Future<bool> runBeforeBootstrap() async {
    return LocalDataMigration(
      supportDirectory: await getApplicationSupportDirectory(),
    ).run();
  }

  Future<bool> run() async {
    final installedVersion = await _readInstalledVersion();
    if (installedVersion != null && installedVersion >= targetVersion) {
      return false;
    }

    await _deleteDatabaseFiles();
    await _writeInstalledVersion();
    return true;
  }

  File get _markerFile => File(p.join(supportDirectory.path, markerFileName));

  Future<int?> _readInstalledVersion() async {
    final marker = _markerFile;
    if (!await marker.exists()) return null;
    return int.tryParse((await marker.readAsString()).trim());
  }

  Future<void> _deleteDatabaseFiles() async {
    for (final suffix in const ['', '-wal', '-shm', '-journal']) {
      final file = File(
        p.join(supportDirectory.path, '$databaseFileName$suffix'),
      );
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> _writeInstalledVersion() async {
    await supportDirectory.create(recursive: true);
    await _markerFile.writeAsString('$targetVersion\n', flush: true);
  }
}
