import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:star_forum/data/migration/local_data_migration.dart';
import 'package:star_forum/utils/cache_utils.dart';

void main() {
  late Directory root;
  late Directory support;
  late Directory temporary;
  late int secureClearCount;
  late int fileCacheClearCount;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('star_forum_migration_');
    support = Directory(p.join(root.path, 'support'));
    temporary = Directory(p.join(root.path, 'temp'));
    await support.create(recursive: true);
    await temporary.create(recursive: true);
    secureClearCount = 0;
    fileCacheClearCount = 0;
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  LocalDataMigration createMigration({int targetVersion = 1}) {
    return LocalDataMigration(
      supportDirectory: support,
      temporaryDirectory: temporary,
      targetVersion: targetVersion,
      clearSecureStorage: () async => secureClearCount++,
      clearFileCaches: () async => fileCacheClearCount++,
    );
  }

  test(
    'first data-version run clears old local data and writes marker',
    () async {
      await File(
        p.join(support.path, 'forum.db'),
      ).writeAsString('old database');
      await Directory(p.join(support.path, 'hive')).create();
      final cacheDirectory = Directory(
        p.join(temporary.path, CacheUtils.userAvatar),
      );
      await cacheDirectory.create();
      await File(
        p.join(cacheDirectory.path, 'avatar.png'),
      ).writeAsBytes([1, 2]);

      expect(await createMigration().run(), isTrue);

      expect(await File(p.join(support.path, 'forum.db')).exists(), isFalse);
      expect(await Directory(p.join(support.path, 'hive')).exists(), isFalse);
      expect(await cacheDirectory.exists(), isFalse);
      expect(
        await File(
          p.join(support.path, LocalDataMigration.markerFileName),
        ).readAsString(),
        '1\n',
      );
      expect(secureClearCount, 1);
      expect(fileCacheClearCount, 1);
    },
  );

  test('current data version leaves local data untouched', () async {
    await File(
      p.join(support.path, LocalDataMigration.markerFileName),
    ).writeAsString('1\n');
    final database = File(p.join(support.path, 'forum.db'));
    await database.writeAsString('current database');

    expect(await createMigration().run(), isFalse);

    expect(await database.readAsString(), 'current database');
    expect(secureClearCount, 0);
    expect(fileCacheClearCount, 0);
  });

  test('higher target data version runs the migration again', () async {
    await File(
      p.join(support.path, LocalDataMigration.markerFileName),
    ).writeAsString('1\n');
    await File(p.join(support.path, 'forum.db')).writeAsString('old database');

    expect(await createMigration(targetVersion: 2).run(), isTrue);

    expect(
      await File(
        p.join(support.path, LocalDataMigration.markerFileName),
      ).readAsString(),
      '2\n',
    );
    expect(secureClearCount, 1);
    expect(fileCacheClearCount, 1);
  });
}
