/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/widgets/setup_body_view.dart';
import 'package:star_forum/pages/setup/widgets/setup_next_button.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

@immutable
class FinishPage extends StatelessWidget {
  final SetupPageController controller;
  final VoidCallback onFinish;

  const FinishPage({
    super.key,
    required this.controller,
    required this.onFinish,
  });

  Color _lagColor(BuildContext context) {
    if (controller.forumLag.value <= 1) return Colors.green;
    if (controller.forumLag.value <= 3) return Colors.amber;
    return Colors.red;
  }

  String _lagText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (controller.forumLag.value <= 1) return l10n.setupLagGood;
    if (controller.forumLag.value <= 3) return l10n.setupLagFair;
    return l10n.setupLagSlow;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SetupBodyView(
      title: l10n.setupReadyTitle(controller.forumInfo.value?.title ?? ''),
      secondaryTitle: l10n.setupReadySubtitle,
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
                    title: Text(l10n.setupSiteConnectionStatus),
                    subtitle: Text(_lagText(context)),
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
                text: l10n.commonActionFinishAndEnter,
              ),
            ],
          );
        }

        return SetupNextButton(
          icon: Icons.check_circle_outline,
          onTap: () async {
            await controller.finishSetup();

            if (!context.mounted) return;
            onFinish();
          },
          text: l10n.commonActionFinishAndEnter,
        );
      }),
    );
  }
}
