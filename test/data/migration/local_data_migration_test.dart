import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:star_forum/data/migration/local_data_migration.dart';

void main() {
  late Directory root;
  late Directory support;
  late Directory temporary;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('star_forum_migration_');
    support = Directory(p.join(root.path, 'support'));
    temporary = Directory(p.join(root.path, 'temp'));
    await support.create(recursive: true);
    await temporary.create(recursive: true);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  LocalDataMigration createMigration({int targetVersion = 1}) {
    return LocalDataMigration(
      supportDirectory: support,
      targetVersion: targetVersion,
    );
  }

  test(
    'first data-version run deletes only SQLite files and writes marker',
    () async {
      for (final suffix in const ['', '-wal', '-shm', '-journal']) {
        await File(
          p.join(support.path, 'forum.db$suffix'),
        ).writeAsString('old database');
      }
      final settingsFile = File(p.join(support.path, 'settings.hive'));
      await settingsFile.writeAsString('settings');
      final cacheDirectory = Directory(p.join(temporary.path, 'image-cache'));
      await cacheDirectory.create();
      final cachedImage = File(p.join(cacheDirectory.path, 'avatar.png'));
      await cachedImage.writeAsBytes([1, 2]);

      expect(await createMigration().run(), isTrue);

      for (final suffix in const ['', '-wal', '-shm', '-journal']) {
        expect(
          await File(p.join(support.path, 'forum.db$suffix')).exists(),
          isFalse,
        );
      }
      expect(await settingsFile.readAsString(), 'settings');
      expect(await cachedImage.readAsBytes(), [1, 2]);
      expect(
        await File(
          p.join(support.path, LocalDataMigration.markerFileName),
        ).readAsString(),
        '1\n',
      );
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
  });

  test('higher target data version runs the migration again', () async {
    await File(
      p.join(support.path, LocalDataMigration.markerFileName),
    ).writeAsString('1\n');
    await File(p.join(support.path, 'forum.db')).writeAsString('old database');
    final settings = File(p.join(support.path, 'settings.hive'));
    await settings.writeAsString('keep');

    expect(await createMigration(targetVersion: 2).run(), isTrue);

    expect(
      await File(
        p.join(support.path, LocalDataMigration.markerFileName),
      ).readAsString(),
      '2\n',
    );
    expect(await settings.readAsString(), 'keep');
  });
}
