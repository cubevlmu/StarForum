part of '../view.dart';

// ── Identity card ─────────────────────────────────────────────────────────────
// Layout:
//   [Avatar]  DisplayName
//             @username  [groups]
//             🕐 last seen · 📅 joined
//   ─────────────────────────────────
//   12 讨论 · 34 回复  [exp bar if available]
//   ─────────────────────────────────
//   Bio text …                    [edit]

class _UserHeadline extends StatelessWidget {
  const _UserHeadline({required this.controller, required this.canEditAvatar});

  final UserProfileController controller;
  final bool canEditAvatar;

  Future<void> _editNickname(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(
      text: controller.info?.displayName ?? '',
    );
    final confirmed = await shared.SharedDialog.showContentDialog(
      context,
      title: l10n.userNicknameEditTitle,
      content: _NicknameEditContent(controller: textController),
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.commonActionConfirm,
      icon: FUIIcons.person,
    );
    final nickname = confirmed ? textController.text.trim() : null;
    textController.dispose();
    if (nickname == null || nickname.isEmpty || !context.mounted) return;
    final ok = await controller.updateNicknameText(nickname);
    if (!context.mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(msg: l10n.userNicknameUpdateSuccess);
    } else {
      SnackbarUtils.showError(msg: l10n.userNicknameUpdateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = controller.info;
    final l10n = AppLocalizations.of(context)!;
    final avatarUrl = info?.avatarUrl ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'user-avatar:${info?.id ?? controller.userId}',
          child: _EditableAvatarButton(
            controller: controller,
            avatarUrl: avatarUrl,
            canEdit: canEditAvatar,
            radius: 28,
            placeholder: StringUtil.getAvatarFirstChar(info?.displayName),
            width: 72,
            height: 72,
          ),
        ),
        const SizedBox(width: FUITokens.gap16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AdaptiveHeadlineText(
                      text: info?.displayName ?? l10n.userLoading,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  if (controller.isMe()) ...[
                    const SizedBox(width: FUITokens.gap6),
                    Obx(() {
                      final updating = controller.isNicknameUpdating.value;
                      return FUIIconButton(
                        icon: FUIIcons.settings,
                        variant: FUIIconButtonVariant.ghost,
                        tooltip: l10n.userNicknameEditTitle,
                        onPressed: updating
                            ? null
                            : () => _editNickname(context),
                      );
                    }),
                  ],
                ],
              ),
              const SizedBox(height: FUITokens.gap4),
              Text(
                controller.getUsernameLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (controller.getGroupNames().isNotEmpty) ...[
                const SizedBox(height: FUITokens.gap8),
                _UserGroupsWrap(controller: controller),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Scales font down if text overflows — keeps single line without ellipsis
// for short names, gracefully shrinks for longer ones.
class _AdaptiveHeadlineText extends StatelessWidget {
  const _AdaptiveHeadlineText({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle(fontSize: 18);
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
    final baseFontSize = style.fontSize ?? 18;
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

      if (!painter.didExceedMaxLines) return fontSize;
    }
    return minFontSize;
  }
}

// ── Compact stats row ─────────────────────────────────────────────────────────
// Shows discussion count · reply count inline.
// Exp bar appears on the same surface if available.

class _UserStatsRow extends StatelessWidget {
  const _UserStatsRow({required this.controller});

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _InlineStat(
            icon: ForumIcons.forum,
            value: StringUtil.numFormat(info?.discussionCount ?? 0),
            label: l10n.userDiscussionCountLabel,
          ),
        ),
        const SizedBox(width: FUITokens.gap10),
        Expanded(
          child: _InlineStat(
            icon: ForumIcons.comments,
            value: StringUtil.numFormat(info?.commentCount ?? 0),
            label: l10n.userCommentCountLabel,
          ),
        ),
      ],
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(FUITokens.gap12),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            ),
            child: Icon(icon, size: FUITokens.iconMd, color: colors.primary),
          ),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: FUITokens.gap2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bio card ──────────────────────────────────────────────────────────────────

class _UserBioCard extends StatelessWidget {
  const _UserBioCard({required this.controller});

  final UserProfileController controller;

  Future<void> _editBio(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bioController = TextEditingController(
      text: controller.info?.bio ?? '',
    );
    final confirmed = await shared.SharedDialog.showContentDialog(
      context,
      title: l10n.userBioEditTitle,
      content: _BioEditContent(controller: bioController),
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.commonActionConfirm,
      icon: FUIIcons.person,
    );
    final bio = confirmed ? bioController.text.trim() : null;
    bioController.dispose();
    if (bio == null || !context.mounted) return;
    final ok = await controller.updateBioText(bio);
    if (!context.mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(msg: l10n.userBioUpdateSuccess);
    } else {
      SnackbarUtils.showError(msg: l10n.userBioUpdateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canEdit = controller.isMe();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FUITokens.gap12),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FUIIcons.person,
                size: FUITokens.iconSm,
                color: colors.primary,
              ),
              const SizedBox(width: FUITokens.gap6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.userBioPrefix,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (canEdit)
                Obx(() {
                  final updating = controller.isBioUpdating.value;
                  return FUIIconButton(
                    icon: FUIIcons.settings,
                    variant: FUIIconButtonVariant.ghost,
                    tooltip: AppLocalizations.of(context)!.userBioEditTitle,
                    onPressed: updating ? null : () => _editBio(context),
                  );
                }),
            ],
          ),
          const SizedBox(height: FUITokens.gap6),
          Text(
            controller.getProfileBio(),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserExpPanel extends StatelessWidget {
  const _UserExpPanel({required this.controller});

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FUITokens.gap12),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: _UserExpWidget(controller: controller),
    );
  }
}

class _BioEditContent extends StatelessWidget {
  const _BioEditContent({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      borderSide: BorderSide(color: colors.border),
    );
    return SizedBox(
      width: 420,
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 5,
        minLines: 4,
        maxLength: 200,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: l10n.userBioEditHint,
          filled: true,
          fillColor: colors.surface,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _NicknameEditContent extends StatelessWidget {
  const _NicknameEditContent({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      borderSide: BorderSide(color: colors.border),
    );
    return SizedBox(
      width: 420,
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 1,
        maxLength: 50,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: l10n.userNicknameEditHint,
          filled: true,
          fillColor: colors.surface,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

// ── Summary meta line ─────────────────────────────────────────────────────────

// ── Exp progress ──────────────────────────────────────────────────────────────

class _UserExpWidget extends StatefulWidget {
  const _UserExpWidget({required this.controller});

  final UserProfileController controller;

  @override
  State<_UserExpWidget> createState() => _UserExpWidgetState();
}

class _UserExpWidgetState extends State<_UserExpWidget> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = widget.controller;
    final progress = controller.getExpPercent();
    final animate = controller.shouldAnimateExp();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.userExpLabel,
              style: TextStyle(color: colors.textTertiary, fontSize: 10),
            ),
            const SizedBox(width: FUITokens.gap4),
            Expanded(
              child: Text(
                controller.buildExpString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(FUITokens.radiusFull),
          child: animate
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  onEnd: controller.markExpAnimationPlayed,
                  builder: (context, value, _) =>
                      LinearProgressIndicator(value: value, minHeight: 5),
                )
              : LinearProgressIndicator(value: progress, minHeight: 5),
        ),
      ],
    );
  }
}

// ── Group tags ────────────────────────────────────────────────────────────────

class _UserGroupsWrap extends StatelessWidget {
  const _UserGroupsWrap({required this.controller});

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    final groups = controller.getGroupNames();
    if (groups.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: FUITokens.gap4,
      runSpacing: FUITokens.gap4,
      children: [
        for (final group in groups)
          FUITag(label: group, variant: FUITagVariant.neutral),
      ],
    );
  }
}
