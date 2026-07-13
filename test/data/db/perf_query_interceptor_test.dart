import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/perf_query_interceptor.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/data/perf/perf_metrics.dart';

void main() {
  test('records Drift query and write timings', () async {
    PerfConfig.enabled = true;
    PerfMetrics.reset();
    final directory = await Directory.systemTemp.createTemp('perf_db_test_');
    final file = File('${directory.path}${Platform.pathSeparator}forum.db');
    final executor = NativeDatabase.createInBackground(
      file,
    ).interceptWith(PerfQueryInterceptor(file));
    final database = AppDatabase.forTesting(executor);

    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
      PerfMetrics.reset();
      PerfConfig.reset();
    });

    await database.customSelect('SELECT 1').get();
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS perf_probe (id INTEGER)',
    );

    final metrics = PerfLog.snapshot().durations;
    expect(metrics.keys.any((key) => key.startsWith('database.query')), isTrue);
    expect(
      metrics.keys.any((key) => key.startsWith('database.custom')),
      isTrue,
    );
  });
}
