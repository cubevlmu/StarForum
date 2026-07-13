/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/user_group/controller.dart';
import 'package:star_forum/pages/user_group/widgets/user_directory_loading_skeleton.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/widgets/forum/forum_user_avatar.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/shared_notice.dart';

class UserGroupPage extends StatefulWidget {
  const UserGroupPage({super.key});

  @override
  State<UserGroupPage> createState() => _UserGroupPageState();
}

class _UserGroupPageState extends State<UserGroupPage> {
  static const _tag = 'home_user_group';
  late final HomeController homeController;
  UserGroupController? _controller;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    if (homeController.isLogin.value) _ensureController();
  }

  UserGroupController _ensureController() {
    final existing = _controller;
    if (existing != null) return existing;
    final created = Get.isRegistered<UserGroupController>(tag: _tag)
        ? Get.find<UserGroupController>(tag: _tag)
        : Get.put(UserGroupController(), tag: _tag);
    _controller = created;
    return created;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      if (!homeController.isLogin.value) {
        return NotLoginNotice(
          title: l10n.commonNotLoggedInTitle,
          tipsText: l10n.homeUserDirectoryNotLoginTips,
        );
      }

      final controller = _ensureController();
      final showLoading =
          (controller.isInitialLoading.value ||
              controller.isCriteriaLoading.value) &&
          controller.users.isEmpty;

      return FUIRefresh(
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        refreshOnStart: false,
        refreshEnabled: !showLoading,
        loadEnabled: !showLoading,
        childBuilder: (context, physics) {
          final effectivePhysics = showLoading
              ? const NeverScrollableScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              SliverToBoxAdapter(child: _UserToolbar(controller: controller)),
              if (showLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: UserDirectoryLoadingSkeleton(),
                )
              else if (controller.filteredUsers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '👥',
                    title: l10n.homeUserDirectoryEmptyTitle,
                    tips: l10n.homeUserDirectoryEmptyTips,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    ForumLayout.edge,
                    ForumLayout.cardGap,
                    ForumLayout.edge,
                    FUITokens.gap24,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: ForumLayout.sectionGap,
                          crossAxisSpacing: ForumLayout.sectionGap,
                          mainAxisExtent: 88,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _UserCard(user: controller.filteredUsers[index]),
                      childCount: controller.filteredUsers.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      );
    });
  }
}

class _UserToolbar extends StatefulWidget {
  const _UserToolbar({required this.controller});

  final UserGroupController controller;

  @override
  State<_UserToolbar> createState() => _UserToolbarState();
}

class _UserToolbarState extends State<_UserToolbar> {
  bool _searching = false;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ForumLayout.edge,
        FUITokens.gap10,
        ForumLayout.edge,
        FUITokens.gap4,
      ),
      child: FUISurface(
        padding: const EdgeInsets.fromLTRB(
          FUITokens.gap14,
          FUITokens.gap8,
          FUITokens.gap8,
          FUITokens.gap8,
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _searching
                    ? SizedBox(
                        key: const ValueKey('search'),
                        height: FUITokens.inputHeight,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: controller.updateSearch,
                          autofocus: true,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: l10n.homeUserDirectorySearchHint,
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      )
                    : _FilterRow(controller: controller, l10n: l10n),
              ),
            ),
            const SizedBox(width: FUITokens.gap8),
            SizedBox(
              width: FUITokens.inputHeight,
              height: FUITokens.inputHeight,
              child: FUIIconButton(
                icon: _searching ? FUIIcons.close : FUIIcons.search,
                tooltip: l10n.homeUserDirectorySearchHint,
                size: FUITokens.inputHeight,
                variant: FUIIconButtonVariant.outline,
                onPressed: () {
                  if (_searching) {
                    _searchCtrl.clear();
                    controller.updateSearch('');
                  }
                  setState(() => _searching = !_searching);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller, required this.l10n});

  final UserGroupController controller;
  final AppLocalizations l10n;

  static const _allGroupsValue = 0;

  String _sortLabel(UserDirectorySort s) => switch (s) {
    UserDirectorySort.username => l10n.homeUserDirectorySortUsernameAsc,
    UserDirectorySort.usernameD => l10n.homeUserDirectorySortUsernameDesc,
    UserDirectorySort.joinedAtD => l10n.homeUserDirectorySortNewest,
    UserDirectorySort.joinedAt => l10n.homeUserDirectorySortOldest,
    UserDirectorySort.discussionCountD => l10n.homeUserDirectorySortMostTopics,
    UserDirectorySort.discussionCount => l10n.homeUserDirectorySortLeastTopics,
    UserDirectorySort.expD => l10n.homeUserDirectorySortMostExp,
    UserDirectorySort.exp => l10n.homeUserDirectorySortLeastExp,
    UserDirectorySort.unknown => '',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sort = controller.sort.value;
      final selectedGroupId = controller.selectedGroupId.value;
      final availableGroups = controller.availableGroups;
      final groupIds = [
        _allGroupsValue,
        ...availableGroups.map((group) => group.id),
      ];
      final groupValue = selectedGroupId ?? _allGroupsValue;
      return Row(
        children: [
          Expanded(
            child: _MenuField<UserDirectorySort>(
              value: sort,
              items: UserDirectorySort.values
                  .where((item) => item != UserDirectorySort.unknown)
                  .toList(),
              labelOf: _sortLabel,
              onChanged: controller.updateSort,
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          Expanded(
            child: _MenuField<int>(
              value: groupValue,
              items: groupIds,
              labelOf: (value) {
                if (value == _allGroupsValue) {
                  return l10n.homeUserDirectoryFilterAll;
                }
                for (final group in availableGroups) {
                  if (group.id == value) return group.name;
                }
                return value.toString();
              },
              onChanged: (value) {
                controller.updateGroup(value == _allGroupsValue ? null : value);
              },
            ),
          ),
        ],
      );
    });
  }
}

class _MenuField<T> extends StatelessWidget {
  const _MenuField({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FUITokens.radiusLg),
        side: BorderSide(color: colors.border),
      ),
      color: colors.surface,
      itemBuilder: (_) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item,
            child: Text(
              labelOf(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: item == value ? colors.primary : colors.textPrimary,
                fontWeight: item == value ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
      ],
      child: Container(
        height: FUITokens.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: FUITokens.gap4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                labelOf(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: FUITokens.gap4),
            Icon(Icons.expand_more_rounded, size: 16, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserInfo user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return FUISurface(
      onTap: () => FuiNavigation.openDetail(
        context,
        builder: (_) => UserPage(userId: user.id, embedded: true),
      ),
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ForumUserAvatar(
                name: user.displayName,
                avatarUrl: user.avatarUrl,
                size: 36,
              ),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            '${l10n.userRegisterAtPrefix} ${StringUtil.timeStampToAgoDate(user.joinTime.millisecondsSinceEpoch ~/ 1000)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
