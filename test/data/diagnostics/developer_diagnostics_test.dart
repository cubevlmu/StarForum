import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/diagnostics/developer_diagnostics.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/storage_utils.dart';

void main() {
  late Directory root;
  late Directory support;
  late Directory temporary;
  late AppDatabase database;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('star_forum_diagnostics_');
    support = Directory(p.join(root.path, 'support'));
    temporary = Directory(p.join(root.path, 'temp'));
    await support.create(recursive: true);
    await temporary.create(recursive: true);
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  DeveloperDiagnosticsService createService() {
    return DeveloperDiagnosticsService(
      database,
      supportDirectory: () async => support,
      temporaryDirectory: () async => temporary,
      packageInfo: () async => PackageInfo(
        appName: 'StarForum',
        packageName: 'dev.starforum.test',
        version: '2.0.0',
        buildNumber: '12',
      ),
      settings: () => <dynamic, dynamic>{
        'themeMode': 2,
        'lastChanged': DateTime.utc(2026, 7, 14),
        'accessToken': 'must-not-be-exported',
        SettingsStorageKeys.forumInfoCache: 'cached forum payload',
      },
    );
  }

  test('exports a consistent SQLite database snapshot', () async {
    await database.customSelect('SELECT 1').get();

    final file = await createService().exportDatabase();

    expect(await file.exists(), isTrue);
    final header = await file
        .openRead(0, 16)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    expect(utf8.decode(header), 'SQLite format 3\u0000');
  });

  test(
    'settings export is JSON safe and excludes cached or secret data',
    () async {
      final file = await createService().exportSettings();
      final payload =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final settings = payload['settings'] as Map<String, dynamic>;

      expect(settings['themeMode'], 2);
      expect(settings['lastChanged'], '2026-07-14T00:00:00.000Z');
      expect(settings, isNot(contains('accessToken')));
      expect(settings, isNot(contains(SettingsStorageKeys.forumInfoCache)));
    },
  );

  test(
    'reports database, support and image-cache storage separately',
    () async {
      await File(
        p.join(support.path, AppDatabase.fileName),
      ).writeAsBytes(List<int>.filled(10, 1));
      await File(
        p.join(support.path, 'hive', 'settings.hive'),
      ).create(recursive: true);
      await File(
        p.join(support.path, 'hive', 'settings.hive'),
      ).writeAsBytes(List<int>.filled(5, 1));
      final cache = Directory(p.join(temporary.path, CacheUtils.contentImage));
      await cache.create(recursive: true);
      await File(
        p.join(cache.path, 'image'),
      ).writeAsBytes(List<int>.filled(7, 1));
      await File(
        p.join(support.path, 'unrelated-app-data.bin'),
      ).writeAsBytes(List<int>.filled(100, 1));
      await File(
        p.join(temporary.path, 'unrelated-temp-data.bin'),
      ).writeAsBytes(List<int>.filled(100, 1));

      final snapshot = await createService().load();

      expect(snapshot.databaseBytes, 10);
      expect(snapshot.supportBytes, 15);
      expect(snapshot.cacheBytes, 7);
      expect(snapshot.totalBytes, 22);
      expect(snapshot.settingsCount, 2);
    },
  );
}
