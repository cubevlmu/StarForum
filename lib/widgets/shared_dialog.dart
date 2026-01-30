/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

class SharedDialog {
  static void showDialog2(BuildContext context, String aText, Function() aAction, String bText, Function() bAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('登出'),
        content: const Text('要登出账户嘛'),
        actions: <Widget>[
          TextButton(
            onPressed: aAction,
            child: Text(aText),
          ),
          TextButton(
            onPressed: bAction,
            child: Text(bText),
          ),
        ],
      ),
    );
  }
}
