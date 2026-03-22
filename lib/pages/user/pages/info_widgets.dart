part of '../view.dart';

class _UserHeadline extends StatelessWidget {
  const _UserHeadline({required this.controller, required this.canEditAvatar});

  final UserPageController controller;
  final bool canEditAvatar;

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final l10n = AppLocalizations.of(context)!;
    final avatarUrl = info?.avatarUrl ?? "";

    final pageWidth = MediaQuery.sizeOf(context).width;
    final compact = pageWidth < 420;
    final lastSeenText = controller.getLastSeenAt().isEmpty
        ? l10n.userLoading
        : controller.getLastSeenAt();
    final registerText =
        "${l10n.userRegisterAtPrefix} ${controller.getRegisterAt()}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'user-avatar:${info?.id ?? controller.userId}',
          child: _EditableAvatarButton(
            controller: controller,
            avatarUrl: avatarUrl,
            canEdit: canEditAvatar,
            radius: compact ? 24 : 28,
            placeholder: StringUtil.getAvatarFirstChar(info?.displayName),
            width: compact ? 64 : 76,
            height: compact ? 64 : 76,
          ),
        ),
        SizedBox(width: compact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserHeadlineText(
                controller: controller,
                loadingText: l10n.userLoading,
              ),
              const SizedBox(height: 12),
              if (pageWidth < 300)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryLine(
                      icon: Icons.schedule_rounded,
                      text: lastSeenText,
                    ),
                    const SizedBox(height: 6),
                    _SummaryLine(
                      icon: Icons.person_add_alt_1_rounded,
                      text: registerText,
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _SummaryLine(
                      icon: Icons.schedule_rounded,
                      text: lastSeenText,
                    ),
                    _SummaryLine(
                      icon: Icons.person_add_alt_1_rounded,
                      text: registerText,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserHeadlineText extends StatelessWidget {
  const _UserHeadlineText({
    required this.controller,
    required this.loadingText,
  });

  final UserPageController controller;
  final String loadingText;

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final colorScheme = Theme.of(context).colorScheme;
    final headlineStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdaptiveHeadlineText(
          text: info?.displayName ?? loadingText,
          style: headlineStyle,
        ),
        const SizedBox(height: 4),
        Text(
          controller.getUsernameLabel(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AdaptiveHeadlineText extends StatelessWidget {
  const _AdaptiveHeadlineText({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle(fontSize: 24);
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final textDirection = Directionality.of(context);
        final resolvedFontSize = _resolveFontSize(
          text: text,
          style: baseStyle,
          maxWidth: maxWidth,
          textScaleFactor: textScaleFactor,
          textDirection: textDirection,
        );

        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(fontSize: resolvedFontSize),
        );
      },
    );
  }

  double _resolveFontSize({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required double textScaleFactor,
    required TextDirection textDirection,
  }) {
    final baseFontSize = style.fontSize ?? 24;
    final minFontSize = baseFontSize * 0.72;

    for (double fontSize = baseFontSize; fontSize >= minFontSize; fontSize--) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(fontSize: fontSize),
        ),
        maxLines: 1,
        textDirection: textDirection,
        textScaler: TextScaler.linear(textScaleFactor),
      )..layout(maxWidth: maxWidth);

      if (!painter.didExceedMaxLines) {
        return fontSize;
      }
    }

    return minFontSize;
  }
}

class _UserStatsRow extends StatelessWidget {
  const _UserStatsRow({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.userDiscussionCountLabel,
            value: StringUtil.numFormat(info?.discussionCount ?? 0),
            icon: Icons.forum_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: l10n.userCommentCountLabel,
            value: StringUtil.numFormat(info?.commentCount ?? 0),
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _UserBioCard extends StatelessWidget {
  const _UserBioCard({required this.controller});

  final UserPageController controller;

  Future<void> _editBio(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bio = await showDialog<String>(
      context: context,
      builder: (context) =>
          _BioEditDialog(initialValue: controller.info?.bio ?? ''),
    );

    if (bio == null || !context.mounted) {
      return;
    }

    final ok = await controller.updateBioText(bio);
    if (!context.mounted) {
      return;
    }

    if (ok) {
      SnackbarUtils.showSuccess(msg: l10n.userBioUpdateSuccess);
    } else {
      SnackbarUtils.showError(msg: l10n.userBioUpdateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canEdit = controller.isMe();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.65),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.userBioPrefix,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (canEdit)
                Obx(() {
                  final updating = controller.isBioUpdating.value;
                  return IconButton(
                    onPressed: updating ? null : () => _editBio(context),
                    visualDensity: VisualDensity.compact,
                    tooltip: AppLocalizations.of(context)!.userBioEditTitle,
                    icon: updating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_rounded, size: 18),
                  );
                }),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.getProfileBio(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _BioEditDialog extends StatefulWidget {
  const _BioEditDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_BioEditDialog> createState() => _BioEditDialogState();
}

class _BioEditDialogState extends State<_BioEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.userBioEditTitle),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 5,
          minLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: l10n.userBioEditHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonActionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonActionConfirm)),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserExpWidget extends StatefulWidget {
  const _UserExpWidget({required this.controller});

  final UserPageController controller;

  @override
  State<_UserExpWidget> createState() => _UserExpWidgetState();
}

class _UserExpWidgetState extends State<_UserExpWidget> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final progress = controller.getExpPercent();
    final animate = controller.shouldAnimateExp();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.userExpLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(
          controller.buildExpString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
        const SizedBox(height: 8),
        if (animate)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            onEnd: controller.markExpAnimationPlayed,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: value, minHeight: 8),
              );
            },
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AdaptiveLineText(
                text: label,
                minScale: 0.76,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              _AdaptiveLineText(
                text: value,
                minScale: 0.82,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdaptiveLineText extends StatelessWidget {
  const _AdaptiveLineText({
    required this.text,
    required this.style,
    this.minScale = 0.72,
  });

  final String text;
  final TextStyle? style;
  final double minScale;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle(fontSize: 14);
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final resolvedFontSize = _resolveFontSize(
          text: text,
          style: baseStyle,
          maxWidth: maxWidth,
          textScaleFactor: textScaleFactor,
          textDirection: textDirection,
        );

        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle.copyWith(fontSize: resolvedFontSize),
        );
      },
    );
  }

  double _resolveFontSize({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required double textScaleFactor,
    required TextDirection textDirection,
  }) {
    final baseFontSize = style.fontSize ?? 14;
    final minFontSize = baseFontSize * minScale;

    for (double fontSize = baseFontSize; fontSize >= minFontSize; fontSize--) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(fontSize: fontSize),
        ),
        maxLines: 1,
        textDirection: textDirection,
        textScaler: TextScaler.linear(textScaleFactor),
      )..layout(maxWidth: maxWidth);

      if (!painter.didExceedMaxLines) {
        return fontSize;
      }
    }

    return minFontSize;
  }
}

class _UserGroupsWrap extends StatelessWidget {
  const _UserGroupsWrap({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    final groups = controller.getGroupNames();
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final group in groups) _UserGroupChip(text: group)],
    );
  }
}

class _UserGroupChip extends StatelessWidget {
  const _UserGroupChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      backgroundColor: Colors.transparent,
    );
  }
}
