/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/snackbar_utils.dart';

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
      builder: (context) => _SimpleDialog(
        title: title,
        content: content,
        aText: aText,
        aAction: aAction,
        bText: bText,
        bAction: bAction,
      ),
    );
  }

  static void showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _LogoutDialog());
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
    showDialog(
      context: context,
      builder: (context) => _NumberDialog(
        title: title,
        content: content,
        aText: aText,
        aAction: aAction,
        bText: bText,
        bAction: bAction,
      ),
    );
  }

  static void showInputDialog(
    BuildContext context,
    String title,
    String content,
    String aText,
    VoidCallback aAction,
    String bText,
    Function(String) bAction,
  ) {
    showDialog(
      context: context,
      builder: (context) => _InputDialog(
        title: title,
        content: content,
        aText: aText,
        aAction: aAction,
        bText: bText,
        bAction: bAction,
      ),
    );
  }
}

class _SimpleDialog extends StatelessWidget {
  final String title;
  final String content;
  final String aText;
  final Function() aAction;
  final String bText;
  final Function() bAction;

  const _SimpleDialog({
    required this.title,
    required this.content,
    required this.aText,
    required this.aAction,
    required this.bText,
    required this.bAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(onPressed: aAction, child: Text(aText)),
        TextButton(onPressed: bAction, child: Text(bText)),
      ],
    );
  }
}

class _NumberDialog extends StatelessWidget {
  final String title;
  final String content;
  final String aText;
  final Function() aAction;
  final String bText;
  final Function(int) bAction;

  const _NumberDialog({
    required this.title,
    required this.content,
    required this.aText,
    required this.aAction,
    required this.bText,
    required this.bAction,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
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
            if (value == null) return;
            Navigator.pop(context);
            bAction(value);
          },
          child: Text(bText),
        ),
      ],
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  void _onSubmit(BuildContext context) async {
    final repo = getIt<UserRepo>();
    await repo.logout();
    SnackbarUtils.showMessage(msg: "登出成功!");
    if (!context.mounted) return;
    Navigator.pop(context, 'OK');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("登出"),
      content: const Text("是否要登出账号?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text("取消"),
        ),
        TextButton(
          onPressed: () => _onSubmit(context),
          child: const Text("确认"),
        ),
      ],
    );
  }
}

class _InputDialog extends StatelessWidget {
  final String title;
  final String content;
  final String aText;
  final Function() aAction;
  final String bText;
  final Function(String) bAction;

  const _InputDialog({
    required this.title,
    required this.content,
    required this.aText,
    required this.aAction,
    required this.bText,
    required this.bAction,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(content),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '请输入文字'),
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
            final value = controller.text;
            Navigator.pop(context);
            bAction(value);
          },
          child: Text(bText),
        ),
      ],
    );
  }
}