/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:html/parser.dart' as html_parser;
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/utils/content_hash_key.dart';
import 'package:star_forum/utils/weighted_lru_cache.dart';

final WeightedLruCache<ContentHashKey, String> _plainTextCache =
    WeightedLruCache(maxEntries: 600, maxWeight: 4 * 1024 * 1024);
final RegExp _whitespace = RegExp(r'\s+');

String htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  final key = ContentHashKey.fromString(html);
  final cached = _plainTextCache.get(key);
  if (cached != null) {
    PerfLog.htmlParse('plainText', cacheHit: true, inputBytes: html.length * 2);
    return cached;
  }

  final stopwatch = Stopwatch()..start();
  final document = html_parser.parse(html);
  final text = document.body?.text ?? '';
  final normalized = text.replaceAll(_whitespace, ' ').trim();
  stopwatch.stop();

  _plainTextCache.put(
    key,
    normalized,
    weight: (html.length + normalized.length) * 2 + 64,
  );
  PerfLog.htmlParse(
    'plainText',
    cacheHit: false,
    elapsedUs: stopwatch.elapsedMicroseconds,
    inputBytes: html.length * 2,
  );
  return normalized;
}
