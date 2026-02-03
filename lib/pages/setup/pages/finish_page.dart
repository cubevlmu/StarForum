/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:forum/pages/main/view.dart';
import 'package:forum/pages/setup/controller.dart';
import 'package:forum/pages/setup/widgets/setup_body_view.dart';
import 'package:forum/pages/setup/widgets/setup_next_button.dart';
import 'package:forum/utils/html_utils.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

@immutable
class FinishPage extends StatelessWidget {
  final SetupPageController controller;

  const FinishPage({super.key, required this.controller});

  Color _lagColor(BuildContext context) {
    if (controller.forumLag.value <= 1) return Colors.green;
    if (controller.forumLag.value <= 3) return Colors.amber;
    return Colors.red;
  }

  String _lagText() {
    if (controller.forumLag.value <= 1) return "连接良好";
    if (controller.forumLag.value <= 3) return "连接一般";
    return "连接较慢";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SetupBodyView(
      title: "${controller.forumInfo.value?.title} 准备完成!",
      secondaryTitle: "站点已就绪",
      leading: Icon(
        Icons.forum_outlined,
        size: 48,
        color: colorScheme.onPrimaryContainer,
      ),
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsetsGeometry.all(5),
              child: Column(
                mainAxisSize: .min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.network_check,
                      color: _lagColor(context),
                    ),
                    title: const Text("站点连接状态"),
                    subtitle: Text(_lagText()),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text(
                      controller.forumInfo.value?.welcomeTitle ?? "",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      htmlToPlainText(
                        controller.forumInfo.value?.welcomeMessage ?? "",
                      ),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                onTap: null,
                text: "完成并进入",
              ),
            ],
          );
        }

        return SetupNextButton(
          icon: Icons.check_circle_outline,
          onTap: () async {
            await controller.finishSetup();

            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
            );
          },
          text: "完成并进入",
        );
      }),
    );
  }
}
