import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/splash/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SplashScreenController>()
        ? Get.find<SplashScreenController>()
        : Get.put(SplashScreenController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<SplashScreenController>()) {
      Get.delete<SplashScreenController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(() {
                final failed = controller.stage.value == SplashStage.failed;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      failed ? FUIIcons.error : ForumIcons.forum,
                      size: 56,
                      color: failed
                          ? context.colors.danger
                          : context.colors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'StarForum',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      failed ? l10n.splashErrorTips : controller.state.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!failed)
                      Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                            strokeWidth: 2.6,
                          ),
                        ),
                      ),
                    if (failed) ...[
                      FUIButton(
                        label: l10n.refreshRefreshing,
                        icon: FUIIcons.refresh,
                        fullWidth: true,
                        onPressed: controller.retry,
                      ),
                      const SizedBox(height: 12),
                      FUIButton(
                        label: l10n.settingsReconfigureSite,
                        icon: FUIIcons.settings,
                        variant: FUIButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: controller.openSetupPage,
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
