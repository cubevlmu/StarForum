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
    _controller = Get.isRegistered<SplashScreenController>()
        ? Get.find<SplashScreenController>()
        : Get.put(SplashScreenController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Obx(() {
              final stage = _controller.stage.value;
              final isLoading = stage == SplashStage.loading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _SplashHeader(
                    isLoading: isLoading,
                    title: isLoading ? l10n.splashTitle : l10n.splashErrorTitle,
                    subtitle: isLoading ? null : l10n.splashErrorTips,
                  ),
                  Text(
                    l10n.splashDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const RefreshProgressIndicator(),
                  const Spacer(),
                ],
              );
            }),
          ),
      ),
    );
  }
}

class _SplashHeader extends StatelessWidget {
  const _SplashHeader({
    required this.isLoading,
    required this.title,
    this.subtitle,
  });

  final bool isLoading;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isLoading ? colorScheme.primary : colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isLoading ? Icons.forum_rounded : Icons.error_outline_rounded,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _SplashLoadingPanel extends StatelessWidget {
  const _SplashLoadingPanel({required this.controller});

  final SplashScreenController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = <({String label, SplashProgressStep step})>[
      (
        label: l10n.splashStateInitNetwork,
        step: SplashProgressStep.initNetwork,
      ),
      (label: l10n.splashStateSyncUser, step: SplashProgressStep.syncUser),
      (label: l10n.splashStateSyncTags, step: SplashProgressStep.syncTags),
    ];

    return Obx(() {
      final currentStep = controller.progressStep.value;
      final progress = switch (currentStep) {
        SplashProgressStep.initNetwork => 1 / 3,
        SplashProgressStep.syncUser => 2 / 3,
        SplashProgressStep.syncTags => 1.0,
        SplashProgressStep.finished => 1.0,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.state.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(value: value, minHeight: 6);
            },
          ),
          const SizedBox(height: 20),
          for (final item in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SplashStepTile(
                label: item.label,
                state: _stepState(currentStep, item.step),
              ),
            ),
        ],
      );
    });
  }

  _SplashStepState _stepState(
    SplashProgressStep current,
    SplashProgressStep step,
  ) {
    if (current.index > step.index) {
      return _SplashStepState.completed;
    }
    if (current == step) {
      return _SplashStepState.active;
    }
    return _SplashStepState.pending;
  }
}

enum _SplashStepState { completed, active, pending }

class _SplashStepTile extends StatelessWidget {
  const _SplashStepTile({required this.label, required this.state});

  final String label;
  final _SplashStepState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (state) {
      _SplashStepState.completed => (
        Icons.check_circle_rounded,
        colorScheme.primary,
      ),
      _SplashStepState.active => (
        Icons.radio_button_checked_rounded,
        colorScheme.primary,
      ),
      _SplashStepState.pending => (
        Icons.radio_button_unchecked_rounded,
        colorScheme.outline,
      ),
    };

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: state == _SplashStepState.pending
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: state == _SplashStepState.active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashErrorPanel extends StatelessWidget {
  const _SplashErrorPanel({required this.controller});

  final SplashScreenController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => Text(
                  controller.errorDetail.value?.isNotEmpty == true
                      ? controller.errorDetail.value!
                      : l10n.splashErrorTips,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: controller.retry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.splashActionRetry),
            ),
            OutlinedButton.icon(
              onPressed: controller.openSetupPage,
              icon: const Icon(Icons.tune_rounded),
              label: Text(l10n.splashActionGoSetup),
            ),
          ],
        ),
      ],
    );
  }
}
