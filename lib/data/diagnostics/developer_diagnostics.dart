import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/diagnostics/app_storage_usage.dart';
import 'package:star_forum/data/migration/local_data_migration.dart';
import 'package:star_forum/utils/app_info.dart';
import 'package:star_forum/utils/storage_utils.dart';

@immutable
class DeveloperDiagnosticsSnapshot {
  const DeveloperDiagnosticsSnapshot({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildMode,
    required this.operatingSystem,
    required this.operatingSystemVersion,
    required this.localeName,
    required this.processorCount,
    required this.dartVersion,
    required this.databaseSchemaVersion,
    required this.dataVersion,
    required this.settingsCount,
    required this.databaseBytes,
    required this.supportBytes,
    required this.cacheBytes,
    required this.totalBytes,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildMode;
  final String operatingSystem;
  final String operatingSystemVersion;
  final String localeName;
  final int processorCount;
  final String dartVersion;
  final int databaseSchemaVersion;
  final int dataVersion;
  final int settingsCount;
  final int databaseBytes;
  final int supportBytes;
  final int cacheBytes;
  final int totalBytes;

  String get versionLabel =>
      buildNumber.isEmpty ? version : '$version+$buildNumber';
}

class DeveloperDiagnosticsService {
  DeveloperDiagnosticsService(
    this.database, {
    Future<Directory> Function()? supportDirectory,
    Future<Directory> Function()? temporaryDirectory,
    Future<PackageInfo> Function()? packageInfo,
    Map<dynamic, dynamic> Function()? settings,
  }) : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _packageInfo = packageInfo ?? AppInfo.load,
       _settings = settings ?? (() => StorageUtils.settings.toMap());

  final AppDatabase database;
  final Future<Directory> Function() _supportDirectory;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<PackageInfo> Function() _packageInfo;
  final Map<dynamic, dynamic> Function() _settings;

  Future<DeveloperDiagnosticsSnapshot> load() async {
    final results = await Future.wait<Object>([
      _packageInfo(),
      AppStorageUsageService(
        supportDirectory: _supportDirectory,
        temporaryDirectory: _temporaryDirectory,
      ).load(),
    ]);
    final info = results[0] as PackageInfo;
    final storage = results[1] as AppStorageUsageSnapshot;
    final exportedSettings = _exportableSettings();

    return DeveloperDiagnosticsSnapshot(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildMode: kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
      operatingSystem: Platform.operatingSystem,
      operatingSystemVersion: Platform.operatingSystemVersion,
      localeName: Platform.localeName,
      processorCount: Platform.numberOfProcessors,
      dartVersion: Platform.version.split(' ').first,
      databaseSchemaVersion: database.schemaVersion,
      dataVersion: LocalDataMigration.currentDataVersion,
      settingsCount: exportedSettings.length,
      databaseBytes: storage.databaseBytes,
      supportBytes: storage.supportBytes,
      cacheBytes: storage.cacheBytes,
      totalBytes: storage.totalBytes,
    );
  }

  Future<File> exportDatabase() async {
    final directory = await _exportDirectory();
    final file = File(
      p.join(directory.path, 'star_forum_${_timestamp()}.sqlite'),
    );
    return database.exportSnapshot(file);
  }

  Future<File> exportSettings() async {
    final info = await _packageInfo();
    final payload = <String, Object?>{
      'exportVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'client': <String, Object?>{
        'appName': info.appName,
        'packageName': info.packageName,
        'version': info.version,
        'buildNumber': info.buildNumber,
        'databaseSchemaVersion': database.schemaVersion,
        'dataVersion': LocalDataMigration.currentDataVersion,
      },
      'settings': jsonSafe(_exportableSettings()),
    };
    final directory = await _exportDirectory();
    final file = File(
      p.join(directory.path, 'star_forum_settings_${_timestamp()}.json'),
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file;
  }

  Map<String, Object?> _exportableSettings() {
    return <String, Object?>{
      for (final entry in _settings().entries)
        if (_isExportableSettingKey(entry.key.toString()))
          entry.key.toString(): entry.value,
    };
  }

  bool _isExportableSettingKey(String key) {
    if (key == SettingsStorageKeys.forumInfoCache) return false;
    final normalized = key.toLowerCase();
    return !const [
      'token',
      'password',
      'secret',
      'authorization',
      'cookie',
      'credential',
    ].any(normalized.contains);
  }

  Future<Directory> _exportDirectory() async {
    final temporary = await _temporaryDirectory();
    final directory = Directory(p.join(temporary.path, 'star_forum_exports'));
    await directory.create(recursive: true);
    return directory;
  }

  static Object? jsonSafe(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Duration) return value.inMicroseconds;
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): jsonSafe(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(jsonSafe).toList(growable: false);
    }
    return value.toString();
  }

  String _timestamp() {
    final now = DateTime.now().toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}
