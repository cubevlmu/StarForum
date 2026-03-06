/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:collection';

import 'package:html/parser.dart' as html_parser;

final LinkedHashMap<String, String> _plainTextCache =
    LinkedHashMap<String, String>();
const int _maxPlainTextCacheSize = 600;

String htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  final cached = _plainTextCache[html];
  if (cached != null) return cached;

  final document = html_parser.parse(html);
  final text = document.body?.text ?? '';
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (_plainTextCache.length >= _maxPlainTextCacheSize) {
    _plainTextCache.remove(_plainTextCache.keys.first);
  }
  _plainTextCache[html] = normalized;
  return normalized;
}
