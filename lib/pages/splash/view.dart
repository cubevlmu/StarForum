/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/splash/controller.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 15),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          _controller.stage.value == SplashStage.loading
                              ? Icons.sync_outlined
                              : Icons.error_outline_rounded,
                          color: _controller.stage.value == SplashStage.loading
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => Text(
                      _controller.stage.value == SplashStage.loading
                          ? l10n.splashTitle
                          : l10n.splashErrorTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _controller.stage.value == SplashStage.loading
                          ? _controller.state.value
                          : l10n.splashErrorTips,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (_controller.stage.value == SplashStage.loading) {
                      return Row(
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
                              l10n.splashDescription,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _controller.errorDetail.value?.isNotEmpty ==
                                          true
                                      ? _controller.errorDetail.value!
                                      : l10n.splashErrorTips,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _controller.openSetupPage,
                                icon: const Icon(Icons.tune_rounded),
                                label: Text(l10n.splashActionGoSetup),
                              ),
                              FilledButton.icon(
                                onPressed: _controller.retry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(l10n.splashActionRetry),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => _controller.stage.value == SplashStage.loading
            ? const RefreshProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}
