import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/widgets/setup_body_view.dart';
import 'package:star_forum/pages/setup/widgets/setup_next_button.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/widgets/license_view.dart';

class GreetingPage extends StatelessWidget {
  const GreetingPage({super.key, required this.controller});

  final SetupPageController controller;

  Future<void> _showLicense(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return shared.SharedDialog.showContentDialog(
      context,
      title: l10n.setupLicenseTitle,
      content: const LicenseView(),
      cancelText: l10n.commonActionDisagree,
      confirmText: l10n.commonActionAgree,
      icon: Icons.balance_rounded,
      confirmAction: controller.checkGreet,
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SetupBodyView(
      title: l10n.setupGreetingTitle,
      secondaryTitle: l10n.setupGreetingSubtitle,
      leading: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.colors.primarySoft,
          borderRadius: BorderRadius.circular(FUITokens.radiusXl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FUITokens.radiusXl),
          child: Image.asset(
            'assets/images/icon.png',
            cacheWidth: 128,
            cacheHeight: 128,
          ),
        ),
      ),
      body: FUISurface(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _FeatureItem(
              icon: ForumIcons.forum,
              text: l10n.setupFeatureDiscuss,
            ),
            const SizedBox(height: FUITokens.gap14),
            _FeatureItem(
              icon: FUIIcons.notification,
              text: l10n.setupFeatureNoti,
            ),
            const SizedBox(height: FUITokens.gap14),
            _FeatureItem(
              icon: ForumIcons.bookmark,
              text: l10n.setupFeatureBookmark,
            ),
            const SizedBox(height: FUITokens.gap16),
            Divider(color: context.colors.border),
            const SizedBox(height: FUITokens.gap12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FUIIcons.info,
                  size: FUITokens.iconMd,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: FUITokens.gap10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.setupLicenseReadAgreeTips,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      FUIButton(
                        label: l10n.setupViewLicense,
                        variant: FUIButtonVariant.ghost,
                        small: true,
                        onPressed: () => _showLicense(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      action: Obx(
        () => SetupNextButton(
          icon: FUIIcons.checkmark,
          text: l10n.commonActionAgreeAndContinue,
          loading: controller.isLoading.value,
          onTap: controller.isLoading.value ? null : controller.checkGreet,
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.primarySoft,
            borderRadius: BorderRadius.circular(FUITokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: FUITokens.iconMd,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: FUITokens.gap12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
