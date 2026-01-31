/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

class SharedDialog {
  static void showDialog2(
    BuildContext context,
    String title,
    String content,
    String aText,
    Function() aAction,
    String bText,
    Function() bAction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(onPressed: aAction, child: Text(aText)),
          TextButton(onPressed: bAction, child: Text(bText)),
        ],
      ),
    );
  }

  static void showNumberDialog(
    BuildContext context,
    String title,
    String content,
    String aText,
    VoidCallback aAction,
    String bText,
    Function(int) bAction,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '请输入数字'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              aAction();
            },
            child: Text(aText),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null) return; // 可以加 toast
              Navigator.pop(context);
              bAction(value);
            },
            child: Text(bText),
          ),
        ],
      ),
    );
  }
}
