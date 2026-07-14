/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/utils/content_hash_key.dart';
import 'package:star_forum/utils/weighted_lru_cache.dart';

final WeightedLruCache<ContentHashKey, String> _plainTextCache =
    WeightedLruCache(maxEntries: 600, maxWeight: 4 * 1024 * 1024);
const _plainTextParserVersion = 2;
final RegExp _whitespace = RegExp(r'\s+');
const _nonContentSelector = 'script, style, noscript, template';
const _textBoundaryElements = <String>{
  'address',
  'article',
  'aside',
  'blockquote',
  'div',
  'footer',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'li',
  'main',
  'nav',
  'ol',
  'p',
  'pre',
  'section',
  'table',
  'td',
  'th',
  'tr',
  'ul',
};

void removeNonContentHtmlElements(dom.Document document) {
  for (final element in document.querySelectorAll(_nonContentSelector)) {
    element.remove();
  }
}

String htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  final key = ContentHashKey.fromString('$_plainTextParserVersion:$html');
  final cached = _plainTextCache.get(key);
  if (cached != null) {
    PerfLog.htmlParse('plainText', cacheHit: true, inputBytes: html.length * 2);
    return cached;
  }

  final stopwatch = Stopwatch()..start();
  final document = html_parser.parse(html);
  removeNonContentHtmlElements(document);
  final buffer = StringBuffer();
  final body = document.body;
  if (body != null) _appendVisibleText(body, buffer);
  final text = buffer.toString();
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

void _appendVisibleText(dom.Node node, StringBuffer buffer) {
  if (node is dom.Text) {
    buffer.write(node.data);
    return;
  }
  if (node is! dom.Element) return;

  if (node.localName == 'br') buffer.write(' ');
  for (final child in node.nodes) {
    _appendVisibleText(child, buffer);
  }
  if (_textBoundaryElements.contains(node.localName)) buffer.write(' ');
}
