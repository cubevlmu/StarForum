/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/widgets/setup_body_view.dart';
import 'package:star_forum/pages/setup/widgets/setup_next_button.dart';
import 'package:star_forum/widgets/license_view.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class GreetingPage extends StatelessWidget {
  final SetupPageController controller;

  const GreetingPage({super.key, required this.controller});
  Future<void> _showTosDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.balance),
          title: const Text("GNU GPL v2 许可协议"),
          content: const LicenseView(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("不同意"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.checkGreet();
              },
              child: const Text("同意"),
            ),
          ]
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SetupBodyView(
      title: "欢迎!",
      secondaryTitle: "欢迎使用 StarForumApp",
      body: Column(
        children: [
          Column(
            children: const [
              _FeatureItem(
                icon: Icons.chat_bubble_outline,
                text: "参与讨论，发现有价值的观点",
              ),
              SizedBox(height: 12),
              _FeatureItem(icon: Icons.notifications_none, text: "获取回复和通知"),
              SizedBox(height: 12),
              _FeatureItem(icon: Icons.bookmark_border, text: "收藏你感兴趣的内容"),
            ],
          ),

          const SizedBox(height: 80),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20, color: colorScheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "在继续之前，请阅读并同意许可协议",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showTosDialog(context),
                      child: Text(
                        "查看许可协议",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      action: Obx(() {
        if (controller.isLoading.value) {
          return Row(
            mainAxisSize: .min,
            crossAxisAlignment: .end,
            children: [
              const RefreshProgressIndicator(),
              const SizedBox(width: 5),
              SetupNextButton(
                icon: Icons.check_circle_outline,
                text: "同意并继续",
                onTap: null,
              ),
            ],
          );
        }

        return SetupNextButton(
          icon: Icons.check_circle_outline,
          text: "同意并继续",
          onTap: () async => controller.checkGreet(),
        );
      }),
    );
  }
}

@immutable
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.secondary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
