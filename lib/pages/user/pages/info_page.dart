part of '../view.dart';

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({
    required this.controller,
    required this.isAccountPage,
  });

  final UserPageController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showInfoSkeleton = controller.info == null;

      if (showInfoSkeleton) {
        return const _UserInfoLoadingState();
      }

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          12,
          10,
          12,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
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
              framed: false,
            ),
            const SizedBox(height: 10),
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

class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({
    required this.controller,
    required this.isAccountPage,
    this.framed = true,
  });

  final UserPageController controller;
  final bool isAccountPage;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = controller.info;
      final colorScheme = Theme.of(context).colorScheme;

      if (controller.isProfileLoading.value && info == null) {
        return const _UserInfoLoadingState();
      }

      final content = Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UserHeadline(
              controller: controller,
              canEditAvatar: isAccountPage || controller.isMe(),
            ),
            const SizedBox(height: 12),
            _UserStatsRow(controller: controller),
            if (controller.hasExpData) ...[
              const SizedBox(height: 14),
              _UserExpWidget(controller: controller),
            ],
            const SizedBox(height: 14),
            _UserBioCard(controller: controller),
            if (controller.getGroupNames().isNotEmpty) ...[
              const SizedBox(height: 12),
              _UserGroupsWrap(controller: controller),
            ],
          ],
        ),
      );

      if (!framed) {
        return Container(
          key: ValueKey('profile:${info?.id}:plain'),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
            ),
          ),
          child: content,
        );
      }

      return Card(
        key: ValueKey('profile:${info?.id}'),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: content,
      );
    });
  }
}

class _UserDetailsPanel extends StatelessWidget {
  const _UserDetailsPanel({
    required this.controller,
    required this.isAccountPage,
  });

  final UserPageController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_DetailItemData>[
      _DetailItemData(
        icon: Icons.badge_outlined,
        label: l10n.userFieldId,
        value: controller.getUserIdLabel(),
      ),
      _DetailItemData(
        icon: Icons.person_outline_rounded,
        label: l10n.userFieldUsername,
        value: controller.getUsernameLabel(),
      ),
      if (isAccountPage || controller.isMe())
        _DetailItemData(
          icon: Icons.email_outlined,
          label: l10n.userFieldEmail,
          value: controller.getEmailLabel(),
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
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.userDetailsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < items.length; index++) ...[
            _DetailRow(item: items[index]),
            if (index != items.length - 1)
              const Divider(height: 12, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _UserInfoLoadingState extends StatelessWidget {
  const _UserInfoLoadingState();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shellColor = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: 0.02),
            colorScheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            Colors.white.withValues(alpha: 0.62),
            colorScheme.surfaceContainerLowest,
          );
    final shellBorder = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.18 : 0.28,
    );
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1500),
      highlightStrength: 0.24,
      builder: (context, palette) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 64 : 76,
                    height: compact ? 64 : 76,
                    decoration: palette.block(radius: compact ? 20 : 24),
                  ),
                  SizedBox(width: compact ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: compact ? 156 : 192,
                          height: compact ? 22 : 24,
                          decoration: palette.line(radius: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: compact ? 112 : 136,
                          height: 14,
                          decoration: palette.line(radius: 8),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: compact ? 178 : 224,
                          height: 14,
                          decoration: palette.line(radius: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _UserSkeletonShell(
                      color: shellColor,
                      borderColor: shellBorder,
                      radius: 14,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: SkeletonBar(
                          decoration: palette.line(radius: 8),
                          widthFactor: 0.62,
                          height: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UserSkeletonShell(
                      color: shellColor,
                      borderColor: shellBorder,
                      radius: 14,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: SkeletonBar(
                          decoration: palette.line(radius: 8),
                          widthFactor: 0.58,
                          height: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _UserSkeletonShell(
                color: shellColor,
                borderColor: shellBorder,
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.28,
                        height: 12,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: palette.block(radius: 999),
                      ),
                      const SizedBox(height: 10),
                      SkeletonBar(
                        decoration: palette.line(radius: 8),
                        widthFactor: 0.4,
                        height: 11,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 92,
                height: 18,
                decoration: palette.line(radius: 10),
              ),
              const SizedBox(height: 14),
              _UserSkeletonShell(
                color: shellColor,
                borderColor: shellBorder,
                radius: 18,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    children: List<Widget>.generate(
                      4,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index == 3 ? 0 : 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: palette.circle(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 84,
                                    height: 12,
                                    decoration: palette.line(radius: 8),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    height: 14,
                                    decoration: palette.line(radius: 8),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserSkeletonShell extends StatelessWidget {
  const _UserSkeletonShell({
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.child,
  });

  final Color color;
  final Color borderColor;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.item});

  final _DetailItemData item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                item.value.isEmpty ? "--" : item.value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
