/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LogUtil {
  static late Logger _logger;
  static late File _logFile;
  static late Directory _logDir;

  static const int _maxKeepDays = 30;

  // Logger external apis
  static void info(String str) => _logger.i(str);
  static void debug(String str) => _logger.d(str);
  static void warn(String str) => _logger.w(str);
  static void error(String str) => _logger.e(str);
  static void trace(String str) => _logger.t(str);

  static void warnE(String str, Object? e, StackTrace? t) =>
      _logger.w(str, error: e, stackTrace: t);

  static void errorE(String str, Object? e, StackTrace? t) =>
      _logger.e(str, error: e, stackTrace: t);

  static void traceE(String str, Object? e, StackTrace? t) =>
      _logger.t(str, error: e, stackTrace: t);

  // Logger init function
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logDir = Directory('${dir.path}/logs');

    if (!_logDir.existsSync()) {
      _logDir.createSync(recursive: true);
    }

    _cleanOldLogs();

    _logFile = File('${_logDir.path}/${_todayFileName()}');
    _logger = Logger(
      printer: FileLogPrinter(),
      output: MultiOutput([ConsoleOutput(), FileOutput(_logFile)]),
    );

    _logger.i('Logger initialized');
    _logFile.writeAsStringSync(
      '\n\n'
      '========== APP START ==========\n'
      'Time: ${DateTime.now().toIso8601String()}\n'
      '================================\n',
      mode: FileMode.append,
    );
  }

  // Share util
  static void shareLog({DateTime? day}) {
    final file = day == null
        ? _logFile
        : File('${_logDir.path}/${_fileNameByDate(day)}');

    if (!file.existsSync()) return;

    Share.shareXFiles([XFile(file.path)], text: 'AppLogs');
  }

  static File get logFile => _logFile;

  // Build log file's name.
  static String _todayFileName() {
    return _fileNameByDate(DateTime.now());
  }

  static String _fileNameByDate(DateTime date) {
    return 'log_${date.year}-${_two(date.month)}-${_two(date.day)}.txt';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  // Auto clear old logs (More than 30 days).
  static void _cleanOldLogs() {
    final now = DateTime.now();

    for (final entity in _logDir.listSync()) {
      if (entity is! File) continue;

      final name = entity.uri.pathSegments.last;
      final date = _parseDateFromFileName(name);
      if (date == null) continue;

      final diff = now.difference(date).inDays;
      if (diff > _maxKeepDays) {
        try {
          entity.deleteSync();
        } catch (_) {}
      }
    }
  }

  // Parse log file from name : log_2026-01-30.txt
  static DateTime? _parseDateFromFileName(String name) {
    final match = RegExp(r'log_(\d{4})-(\d{2})-(\d{2})\.txt').firstMatch(name);

    if (match == null) return null;

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}

class FileOutput extends LogOutput {
  final File file;

  FileOutput(this.file);

  @override
  void output(OutputEvent event) {
    final text = event.lines.join('\n');
    file.writeAsStringSync('$text\n', mode: FileMode.append, flush: true);
  }
}

class FileLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.name.toUpperCase();
    final msg = event.message;

    final buffer = StringBuffer()..write('[$time] [$level] $msg');

    if (event.error != null) {
      buffer.write('\nERROR: ${event.error}');
    }
    if (event.stackTrace != null) {
      buffer.write('\nSTACK:\n${event.stackTrace}');
    }

    return [buffer.toString()];
  }
}
