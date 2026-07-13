import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/background/background_task_scheduler.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/perf/perf_metrics.dart';

void main() {
  setUp(() {
    PerfConfig.enabled = true;
    PerfMetrics.reset();
  });

  tearDown(() {
    PerfMetrics.reset();
    PerfConfig.reset();
  });

  test('deduplicates tasks with the same key', () async {
    final scheduler = BackgroundTaskScheduler();
    final release = Completer<void>();
    var starts = 0;

    final first = scheduler.run(
      name: 'hydrate',
      dedupeKey: '1',
      task: (_) async {
        starts++;
        await release.future;
      },
    );
    final second = scheduler.run(
      name: 'hydrate',
      dedupeKey: '1',
      task: (_) async => starts++,
    );

    expect(identical(first, second), isTrue);
    release.complete();
    await Future.wait([first, second]);
    expect(starts, 1);
  });

  test('cooperatively cancels a running task', () async {
    final scheduler = BackgroundTaskScheduler();
    final release = Completer<void>();
    var reachedEnd = false;

    final future = scheduler.run(
      name: 'hydrate',
      task: (token) async {
        await release.future;
        token.throwIfCancelled();
        reachedEnd = true;
      },
    );
    final cancellation = scheduler.cancel('hydrate');
    release.complete();

    await Future.wait([future, cancellation]);
    expect(reachedEnd, isFalse);
  });
}
