import 'dart:async';

import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/utils/log_util.dart';

class BackgroundTaskCancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void throwIfCancelled() {
    if (_cancelled) throw const BackgroundTaskCancelled();
  }
}

class BackgroundTaskCancelled implements Exception {
  const BackgroundTaskCancelled();
}

class BackgroundTaskScheduler {
  final Map<String, _RunningBackgroundTask> _running = {};

  Future<void> run({
    required String name,
    String? dedupeKey,
    required Future<void> Function(BackgroundTaskCancellationToken token) task,
  }) {
    final key = dedupeKey == null ? name : '$name:$dedupeKey';
    final existing = _running[key];
    PerfLog.coalescing('background.$name', hit: existing != null);
    if (existing != null) return existing.future;

    final token = BackgroundTaskCancellationToken();
    final stopwatch = Stopwatch()..start();
    var failed = false;
    late final Future<void> future;
    future = Future.sync(() => task(token))
        .catchError((Object error, StackTrace stackTrace) {
          if (error is BackgroundTaskCancelled) return;
          failed = true;
          PerfLog.backgroundTask(
            name,
            elapsedUs: stopwatch.elapsedMicroseconds,
            success: false,
          );
          LogUtil.errorE('[BackgroundTask] $name failed', error, stackTrace);
        })
        .whenComplete(() {
          stopwatch.stop();
          if (!token.isCancelled && !failed) {
            PerfLog.backgroundTask(
              name,
              elapsedUs: stopwatch.elapsedMicroseconds,
              success: true,
            );
          }
          final current = _running[key];
          if (current != null && identical(current.future, future)) {
            _running.remove(key);
          }
        });
    _running[key] = _RunningBackgroundTask(token, future);
    return future;
  }

  Future<void> cancel(String name) async {
    final cancelled = <Future<void>>[];
    for (final entry in _running.entries) {
      if (entry.key == name || entry.key.startsWith('$name:')) {
        entry.value.token._cancelled = true;
        cancelled.add(entry.value.future);
      }
    }
    await Future.wait(cancelled);
  }

  Future<void> cancelAll() async {
    final cancelled = <Future<void>>[];
    for (final task in _running.values) {
      task.token._cancelled = true;
      cancelled.add(task.future);
    }
    await Future.wait(cancelled);
  }
}

class _RunningBackgroundTask {
  const _RunningBackgroundTask(this.token, this.future);

  final BackgroundTaskCancellationToken token;
  final Future<void> future;
}
