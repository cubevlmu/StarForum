/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/user/controller.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    super.key,
    required this.userId,
    this.isAccountPage = false,
    this.embedded = false,
  }) : tag = "user_space:$userId";

  final int userId;
  final String tag;
  final bool isAccountPage;
  final bool embedded;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  late final UserPageController controller;
  late final bool _shouldDeleteControllerOnDispose;

  @override
  void initState() {
    if (Get.isRegistered<UserPageController>(tag: widget.tag)) {
      controller = Get.find<UserPageController>(tag: widget.tag);
    } else {
      controller = Get.put(
        UserPageController(userId: widget.userId),
        tag: widget.tag,
      );
    }
    _shouldDeleteControllerOnDispose = !widget.embedded;
    if (controller.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.onRefresh();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_shouldDeleteControllerOnDispose &&
        Get.isRegistered<UserPageController>(tag: widget.tag)) {
      Get.delete<UserPageController>(tag: widget.tag);
    }
    super.dispose();
  }

  Widget _onEmptyLoad(BuildContext context) {
    return Column(
      children: [
        _buildUserInfo(context),

        Expanded(
          child: NoticeWidget(
            emoji: "🧐",
            title: AppLocalizations.of(context)!.userEmptyPostTitle,
            tips: AppLocalizations.of(context)!.userEmptyPostTips,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        widget.isAccountPage
            ? Obx(
                () => controller.isLoading.value
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 8),
        _UserIdentityCard(
          controller: controller,
          isAccountPage: widget.isAccountPage,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.isAccountPage && widget.userId > 0) return null;

    final mainController = widget.embedded && Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : null;

    return AppBar(
      automaticallyImplyLeading: !widget.embedded,
      leading: widget.embedded
          ? IconButton(
              onPressed: () {
                if (mainController == null) return;
                if (mainController.canPopDetail) {
                  mainController.popDetail();
                  return;
                }
                mainController.closeDetail();
              },
              icon: Icon(
                mainController?.canPopDetail == true
                    ? Icons.arrow_back_rounded
                    : Icons.close_rounded,
              ),
            )
          : null,
      title: widget.embedded
          ? Obx(
              () => Text(
                controller.info?.displayName ??
                    (widget.isAccountPage
                        ? AppLocalizations.of(context)!.userCenter
                        : AppLocalizations.of(context)!.userAppBarTitle),
              ),
            )
          : Text(AppLocalizations.of(context)!.userAppBarTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Obx(() {
          return controller.isLoading.value
              ? const LinearProgressIndicator()
              : const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final showPostSkeleton =
          controller.isPostsLoading.value && controller.items.isEmpty;
      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        autoRefreshOnStart: false,
        refreshEnabled: !showPostSkeleton,
        loadEnabled: !showPostSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showPostSkeleton
              ? const ClampingScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              if (showPostSkeleton)
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _buildUserInfo(context),
                    const _UserPostListLoadingSkeleton(),
                  ]),
                )
              else if (controller.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _onEmptyLoad(context),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return _buildUserInfo(context);
                    }
                    final i = controller.items[index - 1];
                    final diss = controller.dissItems[i.discussion];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
                          child: _DiscussionHint(
                            title: diss?.title ?? "",
                            onTap: () async {
                              if (controller.isLoading.value) return;
                              final r = await controller.naviToDisPage(
                                i.discussion,
                              );
                              if (r == null) return;
                              if (!context.mounted) return;
                              openDiscussionAdaptive(context, r);
                            },
                          ),
                        ),
                        const SizedBox(height: 5),

                        Padding(
                          padding: const EdgeInsetsGeometry.fromLTRB(
                            15,
                            0,
                            15,
                            0,
                          ),
                          child: PostItemWidget(reply: i, isUserPage: true),
                        ),

                        const SizedBox(height: 5),

                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 12,
                          endIndent: 12,
                        ),
                      ],
                    );
                  }, childCount: controller.items.length + 1),
                ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.userId == -1) {
      return NoticeWidget(
        emoji: "🤦‍♂️",
        title: AppLocalizations.of(context)!.userInvalidAccountTitle,
        tips: AppLocalizations.of(context)!.userInvalidAccountTips,
      );
    } else if (widget.userId == -2) {
      return NotLoginNotice(
        title: AppLocalizations.of(context)!.userNotLoginTitle,
        tipsText: AppLocalizations.of(context)!.userNotLoginTips,
      );
    }

    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  @override
  bool get wantKeepAlive => true;
}

class _DiscussionHint extends StatelessWidget {
  const _DiscussionHint({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.userDiscussionHintPrefix,
            style: style?.copyWith(color: Colors.grey),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({
    required this.controller,
    required this.isAccountPage,
  });

  final UserPageController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = controller.info;
      final colorScheme = Theme.of(context).colorScheme;

      if (controller.isProfileLoading.value && info == null) {
        return const _UserHeaderSkeleton();
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserHeadline(
                controller: controller,
                isAccountPage: isAccountPage,
              ),
              const SizedBox(height: 16),
              _UserStatsRow(controller: controller),
              if (controller.hasExpData) ...[
                const SizedBox(height: 18),
                _UserExpWidget(controller: controller),
              ],
              const SizedBox(height: 18),
              _UserBioCard(controller: controller),
              const SizedBox(height: 14),
              _UserGroupsWrap(controller: controller),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showUserDetailsSheet(context),
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(AppLocalizations.of(context)!.userDetailsExpand),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _showUserDetailsSheet(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: _UserDetailsPanel(
              controller: controller,
              isAccountPage: isAccountPage,
            ),
          ),
        );
      },
    );
  }
}

class _UserHeadline extends StatelessWidget {
  const _UserHeadline({required this.controller, required this.isAccountPage});

  final UserPageController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
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
          child: avatarUrl.isEmpty
              ? Container(
                  width: compact ? 64 : 76,
                  height: compact ? 64 : 76,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(compact ? 18 : 22),
                  ),
                  child: const Icon(Icons.person_outline_rounded, size: 32),
                )
              : AvatarWidget(
                  avatarUrl: avatarUrl,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UserHeadlineText(
                      controller: controller,
                      loadingText: l10n.userLoading,
                    ),
                  ),
                ],
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Text(
            AppLocalizations.of(context)!.userBioPrefix,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
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
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.userDetailsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < items.length; index++) ...[
            _DetailRow(item: items[index]),
            if (index != items.length - 1)
              const Divider(height: 16, thickness: 0.5),
          ],
        ],
      ),
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
  final UserPageController controller;

  const _UserExpWidget({required this.controller});

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

class _UserHeaderSkeleton extends StatelessWidget {
  const _UserHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 420;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: SkeletonShimmer(
        duration: const Duration(milliseconds: 1500),
        highlightStrength: 0.24,
        builder: (context, palette) {
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 22 : 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: compact ? 80 : 88,
                        height: compact ? 80 : 88,
                        decoration: palette.block(radius: compact ? 22 : 24),
                      ),
                      SizedBox(width: compact ? 16 : 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: compact ? 168 : 196,
                              height: compact ? 22 : 24,
                              decoration: palette.line(radius: 12),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: compact ? 128 : 148,
                              height: 15,
                              decoration: palette.line(radius: 8),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: compact ? 188 : 232,
                              height: compact ? 34 : 36,
                              decoration: palette.line(radius: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: compact ? 48 : 52,
                          decoration: palette.block(radius: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: compact ? 48 : 52,
                          decoration: palette.block(radius: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: compact ? 78 : 88,
                    decoration: palette.block(radius: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserPostListLoadingSkeleton extends StatelessWidget {
  const _UserPostListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1420),
      highlightStrength: 0.2,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            3,
            (index) => _UserPostLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _UserPostLoadingCard extends StatelessWidget {
  const _UserPostLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
          child: SkeletonBar(
            decoration: pillDecoration,
            widthFactor: 0.42,
            height: 12,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 45, height: 45, decoration: circleDecoration),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.3,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.22,
                      height: 10,
                    ),
                    const SizedBox(height: 14),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.95,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.86,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.6,
                      height: 12,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 32,
                          decoration: pillDecoration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
      ],
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
