/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/user_group/controller.dart';
import 'package:star_forum/pages/user_group/widgets/user_directory_loading_skeleton.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';

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
    if (homeController.isLogin.value) {
      _ensureController();
    }
  }

  UserGroupController _ensureController() {
    final existing = _controller;
    if (existing != null) {
      return existing;
    }
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
      final users = controller.filteredUsers;
      final showLoading =
          (controller.isInitialLoading.value ||
              controller.isCriteriaLoading.value) &&
          controller.users.isEmpty;
      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        autoRefreshOnStart: false,
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
              SliverToBoxAdapter(
                child: _UserDirectoryToolbar(controller: controller),
              ),
              const SliverToBoxAdapter(child: Divider(height: 1)),
              if (showLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: UserDirectoryLoadingSkeleton(),
                )
              else if (users.isEmpty)
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
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 96,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _UserDirectoryCard(user: users[index]);
                    }, childCount: users.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      );
    });
  }
}

class _UserDirectoryToolbar extends StatefulWidget {
  const _UserDirectoryToolbar({required this.controller});

  final UserGroupController controller;

  @override
  State<_UserDirectoryToolbar> createState() => _UserDirectoryToolbarState();
}

class _UserDirectoryToolbarState extends State<_UserDirectoryToolbar> {
  static const _animDuration = Duration(milliseconds: 180);
  late final TextEditingController _searchController;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;

    Widget toolbarBody() {
      if (_showSearch) {
        return TextField(
          key: const ValueKey('search'),
          controller: _searchController,
          onChanged: controller.updateSearch,
          autofocus: true,
          decoration: InputDecoration(
            isDense: true,
            hintText: l10n.homeUserDirectorySearchHint,
            border: const OutlineInputBorder(),
          ),
        );
      }

      return Row(
        key: const ValueKey('filters'),
        children: [
          Expanded(
            child: _SortDropdown(
              value: controller.sort.value,
              l10n: l10n,
              onChanged: controller.updateSort,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GroupDropdown(
              value: controller.selectedGroup.value,
              groups: controller.availableGroups,
              l10n: l10n,
              onChanged: controller.updateGroup,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: _animDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ...previousChildren,
                    currentChild,
                  ].whereType<Widget>().toList(),
                );
              },
              child: toolbarBody(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.homeUserDirectorySearchHint,
            onPressed: () {
              if (_showSearch) {
                _searchController.clear();
                controller.updateSearch('');
              }
              setState(() => _showSearch = !_showSearch);
            },
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.value,
    required this.l10n,
    required this.onChanged,
  });

  final UserSort value;
  final AppLocalizations l10n;
  final ValueChanged<UserSort> onChanged;

  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<UserSort> item(UserSort value, String text) {
      return DropdownMenuItem(
        value: value,
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }

    return DropdownButtonFormField<UserSort>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        labelText: l10n.homeUserDirectorySort,
        border: const OutlineInputBorder(),
      ),
      items: [
        item(UserSort.username, l10n.homeUserDirectorySortUsernameAsc),
        item(UserSort.usernameD, l10n.homeUserDirectorySortUsernameDesc),
        item(UserSort.joinedAtD, l10n.homeUserDirectorySortNewest),
        item(UserSort.joinedAt, l10n.homeUserDirectorySortOldest),
        item(UserSort.discussionCountD, l10n.homeUserDirectorySortMostTopics),
        item(UserSort.discussionCount, l10n.homeUserDirectorySortLeastTopics),
        item(UserSort.expD, l10n.homeUserDirectorySortMostExp),
        item(UserSort.exp, l10n.homeUserDirectorySortLeastExp),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _GroupDropdown extends StatelessWidget {
  const _GroupDropdown({
    required this.value,
    required this.groups,
    required this.l10n,
    required this.onChanged,
  });

  final String? value;
  final List<String> groups;
  final AppLocalizations l10n;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = groups.contains(value) ? value : null;
    return DropdownButtonFormField<String?>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        labelText: l10n.homeUserDirectoryFilterGroup,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            l10n.homeUserDirectoryFilterAll,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...groups.map(
          (group) => DropdownMenuItem<String?>(
            value: group,
            child: Text(group, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _UserDirectoryCard extends StatelessWidget {
  const _UserDirectoryCard({required this.user});

  final UserInfo user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openUserAdaptive(context, user.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AvatarWidget(
                    avatarUrl: user.avatarUrl,
                    radius: 18,
                    width: 36,
                    height: 36,
                    placeholder: StringUtil.getAvatarFirstChar(
                      user.displayName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _UserIdentity(user: user)),
                ],
              ),
              Text(
                '${AppLocalizations.of(context)!.userRegisterAtPrefix} ${StringUtil.timeStampToAgoDate(user.joinTime.millisecondsSinceEpoch ~/ 1000)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserIdentity extends StatelessWidget {
  const _UserIdentity({required this.user});

  final UserInfo user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        const SizedBox(height: 2),
        Text(
          '@${user.username}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
