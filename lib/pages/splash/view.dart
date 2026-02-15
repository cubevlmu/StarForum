/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/pages/splash/controller.dart';
import 'package:get/get.dart';

@immutable
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashScreenController _controller;

  @override
  void initState() {
    _controller = Get.put(SplashScreenController());

    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SplashScreenController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.sync_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "同步数据",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _controller.state.value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "客户端正在从论坛服务器同步数据,请稍后",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const RefreshProgressIndicator(),
    );
  }
}
