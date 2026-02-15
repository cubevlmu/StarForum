/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/post_detail/view.dart';
import 'package:forum/pages/post_detail/widgets/post_item.dart';
import 'package:forum/pages/user/controller.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/avatar.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.userId, this.isAccountPage = false})
    : tag = "user_space:$userId";

  final int userId;
  final String tag;
  final bool isAccountPage;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  late final UserPageController controller;

  @override
  void initState() {
    controller = Get.put(
      UserPageController(userId: widget.userId),
      tag: widget.tag,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<UserPageController>(tag: widget.tag);
    super.dispose();
  }

  Widget _onEmptyLoad(BuildContext context) {
    return Column(
      children: [
        _buildUserInfo(context),

        Expanded(
          child: const NoticeWidget(
            emoji: "🧐",
            title: "这里还没有任何帖子",
            tips: "下拉刷新试试看",
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
        const SizedBox(height: 5),
        _UserIdentityCard(controller: controller),
        Divider(
          indent: 20,
          endIndent: 20,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.isAccountPage && widget.userId > 0) return null;

    return AppBar(
      title: const Text("用户资料"),
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
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            if (controller.items.isEmpty)
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
                        padding: EdgeInsetsGeometry.fromLTRB(10, 15, 10, 0),
                        child: _DiscussionHint(
                          title: diss?.title ?? "",
                          onTap: () async {
                            if (controller.isLoading.value) return;
                            final r = await controller.naviToDisPage(
                              i.discussion,
                            );
                            if (r == null) return;
                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostPage(item: r),
                              ),
                            );
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.userId == -1) {
      return const NoticeWidget(
        emoji: "🤦‍♂️",
        title: "错误的账号",
        tips: "很抱歉,我们找不到这个账户",
      );
    } else if (widget.userId == -2) {
      return const NotLoginNotice(title: "账号未登录", tipsText: "请登录您的账号来查看");
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
          Text("于 ", style: style?.copyWith(color: Colors.grey)),
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
  const _UserIdentityCard({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (controller.info?.avatarUrl ?? "").isEmpty
                  ? const SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(child: Icon(Icons.person_outline_rounded)),
                    )
                  : AvatarWidget(
                      avatarUrl: controller.info?.avatarUrl ?? "",
                      radius: 22,
                      placeholder: StringUtil.getAvatarFirstChar(
                        controller.info?.displayName,
                      ),
                      width: 64,
                      height: 64,
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.info?.displayName ?? "加载中...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _InfoRow(
                          icon: Icons.access_time,
                          text: controller.getLastSeenAt(),
                        ),
                        const SizedBox(width: 5),
                        _InfoRow(
                          icon: Icons.person_add_alt,
                          text: "注册于 ${controller.getRegisterAt()}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (controller.isMe()) ...[
            if (controller.hasExpData) ...[
              _UserExpWidget(controller: controller),
              const SizedBox(height: 12),
            ],

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("个人简介: ${controller.info?.bio}"),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

class _UserExpWidget extends StatelessWidget {
  final UserPageController controller;

  const _UserExpWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: EdgeInsetsGeometry.all(5),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(controller.buildExpString(), style: textStyle),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.getExpPercent(),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
