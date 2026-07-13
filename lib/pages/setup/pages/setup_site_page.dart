import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/widgets/setup_body_view.dart';
import 'package:star_forum/pages/setup/widgets/setup_next_button.dart';
import 'package:fin_ui/fin_ui.dart';

class SetupSitePage extends StatelessWidget {
  const SetupSitePage({
    super.key,
    required this.controller,
    this.onBackPressed,
  });

  final SetupPageController controller;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SetupBodyView(
      title: l10n.setupSiteConfigTitle,
      secondaryTitle: l10n.setupConnectSubtitle,
      header: FuiPageHead(
        title: l10n.setupSiteConfigTitle,
        subtitle: l10n.setupConnectSubtitle,
        onNavigationPressed: onBackPressed,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FUISection(
            title: l10n.setupSiteInfoSection,
            children: [
              Padding(
                padding: const EdgeInsets.all(FUITokens.gap14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.setupSiteAddressLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap4),
                    Text(
                      l10n.setupSiteAddressHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap14),
                    Obx(
                      () => FUITextField(
                        label: l10n.setupSiteAddressLabel,
                        hintText: 'https://forum.example.com',
                        prefixIcon: FUIIcons.building,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        enabled: !controller.isLoading.value,
                        onChanged: (text) => controller.siteUrl = text,
                        onSubmitted: (_) {
                          if (!controller.isLoading.value) {
                            controller.setupUrl();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap14),
                    _SiteInfoNotice(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      action: Obx(
        () => SetupNextButton(
          icon: FUIIcons.chevronRight,
          text: controller.isLoading.value
              ? l10n.setupValidatingSite
              : l10n.setupValidateAndContinue,
          loading: controller.isLoading.value,
          onTap: controller.isLoading.value ? null : controller.setupUrl,
        ),
      ),
    );
  }
}

class _SiteInfoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(FUITokens.gap12),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FUIIcons.info,
            size: FUITokens.iconMd,
            color: context.colors.primary,
          ),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: Text(
              l10n.setupApiRequirement,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
