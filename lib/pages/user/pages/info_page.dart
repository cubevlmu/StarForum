/*
 * @Author: khfahqp khfahqp@gmail.com
 * @LastEditors: khfahqp khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

part of '../view.dart';

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({
    required this.controller,
    required this.isAccountPage,
  });

  final UserProfileController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.info == null) {
        return const _UserInfoLoadingState();
      }
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          FUITokens.pagePadding,
          FUITokens.gap6,
          FUITokens.pagePadding,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAccountPage)
              Obx(
                () => controller.isLoading.value
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            _UserIdentityCard(
              controller: controller,
              isAccountPage: isAccountPage,
            ),
            const SizedBox(height: FUITokens.gap8),
            _UserDetailsPanel(
              controller: controller,
              isAccountPage: isAccountPage,
            ),
          ],
        ),
      );
    });
  }
}

// ── Identity card ─────────────────────────────────────────────────────────────

class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({
    required this.controller,
    required this.isAccountPage,
  });

  final UserProfileController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = controller.info;
      if (controller.isProfileLoading.value && info == null) {
        return const _UserInfoLoadingState();
      }

      return FUISurface(
        key: ValueKey('profile:${info?.id}'),
        padding: EdgeInsets.zero,
        borderRadius: FUITokens.radiusXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FUITokens.gap16),
              decoration: BoxDecoration(
                color: context.colors.primarySoft,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(FUITokens.radiusXl),
                ),
              ),
              child: _UserHeadline(
                controller: controller,
                canEditAvatar: isAccountPage || controller.isMe(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FUITokens.gap14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserBioCard(controller: controller),
                  const SizedBox(height: FUITokens.gap12),
                  _UserStatsRow(controller: controller),
                  if (controller.hasExpData) ...[
                    const SizedBox(height: FUITokens.gap12),
                    _UserExpPanel(controller: controller),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Details panel: two-column grid ───────────────────────────────────────────

class _UserDetailsPanel extends StatelessWidget {
  const _UserDetailsPanel({
    required this.controller,
    required this.isAccountPage,
  });

  final UserProfileController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_DetailItemData>[
      _DetailItemData(
        icon: ForumIcons.badge,
        label: l10n.userFieldId,
        value: controller.getUserIdLabel(),
      ),
      _DetailItemData(
        icon: FUIIcons.person,
        label: l10n.userFieldUsername,
        value: controller.getUsernameLabel(),
      ),
      _DetailItemData(
        icon: Icons.visibility_outlined,
        label: l10n.userFieldLastSeen,
        value: controller.getLastSeenAt(),
      ),
      _DetailItemData(
        icon: Icons.event_available_rounded,
        label: l10n.userFieldJoinedAt,
        value: controller.getRegisterAt(),
      ),
      if (isAccountPage || controller.isMe())
        _DetailItemData(
          icon: Icons.email_outlined,
          label: l10n.userFieldEmail,
          value: controller.getEmailLabel(),
        ),
    ];

    return FUISection(
      title: l10n.userDetailsTitle,
      children: [
        for (final item in items)
          FUITile(
            icon: item.icon,
            title: item.label,
            subtitle: item.value.isEmpty ? '--' : item.value,
            showChevron: false,
          ),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _UserInfoLoadingState extends StatelessWidget {
  const _UserInfoLoadingState();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1500),
      highlightStrength: 0.24,
      builder: (context, palette) {
        final colors = context.colors;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            FUITokens.pagePadding,
            FUITokens.gap10,
            FUITokens.pagePadding,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identity card skeleton
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(FUITokens.radiusXl),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(FUITokens.gap14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: palette.block(radius: 22),
                          ),
                          const SizedBox(width: FUITokens.gap12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 140,
                                  height: 18,
                                  decoration: palette.line(radius: 10),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 90,
                                  height: 12,
                                  decoration: palette.line(radius: 8),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 180,
                                  height: 11,
                                  decoration: palette.line(radius: 8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: colors.border),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FUITokens.gap14,
                        vertical: FUITokens.gap10,
                      ),
                      child: Row(
                        children: [
                          SkeletonBar(
                            decoration: palette.line(radius: 8),
                            widthFactor: 0.22,
                            height: 28,
                          ),
                          const SizedBox(width: FUITokens.gap12),
                          SkeletonBar(
                            decoration: palette.line(radius: 8),
                            widthFactor: 0.22,
                            height: 28,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: colors.border),
                    Padding(
                      padding: const EdgeInsets.all(FUITokens.gap10),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            FUITokens.radiusMd,
                          ),
                          border: Border(
                            left: BorderSide(
                              color: colors.primary.withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(FUITokens.gap10),
                        child: SkeletonBar(
                          decoration: palette.line(radius: 8),
                          widthFactor: 0.7,
                          height: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FUITokens.gap10),
              // Details skeleton
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(FUITokens.radiusLg),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.all(FUITokens.gap12),
                child: Column(
                  children: List.generate(2, (row) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: row == 1 ? 0 : 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: palette.circle(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SkeletonBar(
                                        decoration: palette.line(radius: 6),
                                        widthFactor: 0.5,
                                        height: 10,
                                      ),
                                      const SizedBox(height: 4),
                                      SkeletonBar(
                                        decoration: palette.line(radius: 6),
                                        widthFactor: 0.7,
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: colors.border,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: palette.circle(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SkeletonBar(
                                        decoration: palette.line(radius: 6),
                                        widthFactor: 0.5,
                                        height: 10,
                                      ),
                                      const SizedBox(height: 4),
                                      SkeletonBar(
                                        decoration: palette.line(radius: 6),
                                        widthFactor: 0.65,
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailItemData {
  const _DetailItemData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
