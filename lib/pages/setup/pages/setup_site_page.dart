/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/setup/controller.dart';
import 'package:forum/pages/setup/widgets/setup_body_view.dart';
import 'package:forum/pages/setup/widgets/setup_next_button.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SetupSitePage extends StatelessWidget {
  final SetupPageController controller;

  const SetupSitePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SetupBodyView(
      title: "配置站点",
      secondaryTitle: "请输入Flarum站点网址:",
      leading: Icon(
        Icons.public,
        size: 48,
        color: colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => TextFormField(
                decoration: InputDecoration(
                  labelText: "站点地址",
                  border: const OutlineInputBorder(),
                  hintText: "https://example.com",
                ),
                enabled: !controller.isLoading.value,
                onChanged: (text) => controller.siteUrl = text,
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
              SetupNextButton(icon: Icons.navigate_next, onTap: null),
            ],
          );
        }

        return SetupNextButton(
          icon: Icons.navigate_next,
          onTap: () async => await controller.setupUrl(),
        );
      }),
    );
  }
}