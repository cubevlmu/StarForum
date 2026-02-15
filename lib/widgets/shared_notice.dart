/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/pages/login/view.dart';

class WorkInProgressNotice extends StatelessWidget {
  const WorkInProgressNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🚧", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            Text(
              "正在施工中...",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              "功能还在开发qwq",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class NotLoginNotice extends StatelessWidget {
  const NotLoginNotice({
    super.key,
    required this.title,
    required this.tipsText,
  });

  final String title;
  final String tipsText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🔒", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              tipsText,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _onLoginBtnPressed(context),
              child: const Text("去登录"),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginBtnPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class NoticeWidget extends StatelessWidget {
  const NoticeWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.tips,
  });

  final String emoji, title, tips;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              tips,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkInProgressPage extends StatelessWidget {
  const WorkInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("功能开发中")),
      body: const WorkInProgressNotice(),
    );
  }
}
