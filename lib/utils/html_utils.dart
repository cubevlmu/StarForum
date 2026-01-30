/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:html/parser.dart' as html_parser;

String htmlToPlainText(String html) {
  final document = html_parser.parse(html);
  final text = document.body?.text ?? '';
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}