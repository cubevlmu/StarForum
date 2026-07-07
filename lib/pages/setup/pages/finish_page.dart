import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/widgets/setup_body_view.dart';
import 'package:star_forum/pages/setup/widgets/setup_next_button.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/utils/html_utils.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({
    super.key,
    required this.controller,
    required this.onFinish,
  });

  final SetupPageController controller;
  final VoidCallback onFinish;

  String _connectionText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (controller.forumLag.value <= 1) return l10n.setupLagGood;
    if (controller.forumLag.value <= 3) return l10n.setupLagFair;
    return l10n.setupLagSlow;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(
      () => SetupBodyView(
        title: l10n.setupReadyTitle(controller.forumInfo.value?.title ?? ''),
        secondaryTitle: l10n.setupReadySubtitle,
        leading: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.colors.successSoft,
            borderRadius: BorderRadius.circular(FUITokens.radiusXl),
          ),
          child: Icon(FUIIcons.check, size: 30, color: context.colors.success),
        ),
        body: FUISection(
          title: '站点信息',
          children: [
            FUITile(
              icon: FUIIcons.refresh,
              title: l10n.setupSiteConnectionStatus,
              subtitle:
                  '${_connectionText(context)} · ${controller.forumLag.value} ms',
              showChevron: false,
            ),
            FUITile(
              icon: FUIIcons.info,
              title: controller.forumInfo.value?.welcomeTitle ?? 'Flarum',
              subtitle: htmlToPlainText(
                controller.forumInfo.value?.welcomeMessage ?? '',
              ),
              showChevron: false,
            ),
          ],
        ),
        action: SetupNextButton(
          icon: FUIIcons.checkmark,
          text: controller.isLoading.value
              ? '正在初始化'
              : l10n.commonActionFinishAndEnter,
          loading: controller.isLoading.value,
          onTap: controller.isLoading.value
              ? null
              : () async {
                  await controller.finishSetup();
                  if (context.mounted) onFinish();
                },
        ),
      ),
    );
  }
}
