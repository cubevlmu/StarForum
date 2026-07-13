import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:star_forum/data/perf/perf_log.dart';

class PerfQueryInterceptor extends QueryInterceptor {
  PerfQueryInterceptor(this.databaseFile);

  final File databaseFile;
  DateTime _lastSizeSample = DateTime.fromMillisecondsSinceEpoch(0);
  static final RegExp _tablePattern = RegExp(
    r'(?:FROM|INTO|UPDATE|TABLE)\s+["`\[]?([\w]+)',
    caseSensitive: false,
  );

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _measure('query', statement, () => executor.runSelect(statement, args));

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _write('insert', statement, () => executor.runInsert(statement, args));

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _write('update', statement, () => executor.runUpdate(statement, args));

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _write('delete', statement, () => executor.runDelete(statement, args));

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _write('custom', statement, () => executor.runCustom(statement, args));

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) => _write(
    'batch',
    '',
    () => executor.runBatched(statements),
    details: 'statements=${statements.statements.length}',
  );

  Future<T> _write<T>(
    String operation,
    String statement,
    Future<T> Function() call, {
    String? details,
  }) async {
    try {
      return await _measure(operation, statement, call, details: details);
    } finally {
      _sampleFileSize();
    }
  }

  Future<T> _measure<T>(
    String operation,
    String statement,
    Future<T> Function() call, {
    String? details,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await call();
    } finally {
      stopwatch.stop();
      final table = _tableName(statement);
      PerfLog.database(
        table == null ? operation : '$operation.$table',
        dbUs: stopwatch.elapsedMicroseconds,
        details: details,
      );
    }
  }

  void _sampleFileSize() {
    final now = DateTime.now();
    if (now.difference(_lastSizeSample) < const Duration(seconds: 30)) return;
    _lastSizeSample = now;
    unawaited(
      databaseFile.length().then(
        (bytes) => PerfLog.gauge('storage.sqlite.bytes', bytes),
        onError: (_) {},
      ),
    );
  }

  String? _tableName(String statement) {
    final match = _tablePattern.firstMatch(statement);
    return match?.group(1);
  }
}
