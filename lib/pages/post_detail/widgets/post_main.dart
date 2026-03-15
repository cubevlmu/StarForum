/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/content_view.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:get/get.dart';

class PostMainWidget extends StatelessWidget {
  final DiscussionItem content;
  final PostInfo? info;
  final String controllerTag;

  const PostMainWidget({
    super.key,
    required this.content,
    required this.info,
    required this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final like = info?.likes ?? -1;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          _UserBox(item: content),
          _MainContent(item: content, controllerTag: controllerTag),
          const SizedBox(height: 5),
          like == -1
              ? const SizedBox.shrink()
              : _ThumUpButton(
                  likeNum: -1,
                  selected: false,
                  onPressed: () async {
                    if (info == null) return;
                    final r = await ReplyUtil.addLikeToPost(info!);
                    if (r != null) {
                      info?.likes = r.likes;
                    }
                  },
                ),
          Divider(
            color: Theme.of(context).colorScheme.secondaryContainer,
            thickness: 1,
            height: 20,
          ),
        ],
      ),
    );
  }
}

class _UserBox extends StatelessWidget {
  const _UserBox({required this.item});
  final DiscussionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openUserAdaptive(context, item.userId),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AvatarWidget(
              avatarUrl: item.authorAvatar,
              radius: 20,
              cacheWidthHeight: 200,
              placeholder: item.authorName.isEmpty ? "" : item.authorName[0],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.authorName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 12,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    StringUtil.numFormat(item.viewCount),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 12,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    StringUtil.dateTimeToAgoDate(item.lastPostedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({required this.item, required this.controllerTag});
  final DiscussionItem item;
  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    late final PostPageController model;
    try {
      model = Get.find<PostPageController>(tag: controllerTag);
    } catch (e) {
      log("[PostMain] Controller died $controllerTag");
      if (Get.isRegistered<PostPageController>(tag: controllerTag)) {
        model = Get.find<PostPageController>(tag: controllerTag);
      } else {
        model = Get.put(
          PostPageController(discussion: item),
          tag: controllerTag,
        );
      }
    }
    final l10n = AppLocalizations.of(context)!;
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Obx(() {
                final content = model.content.value;
                final isLoading = content == l10n.postContentLoadingHtml;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isLoading
                      ? const _MainContentLoadingSkeleton()
                      : ContentView(
                          key: ValueKey(content.hashCode),
                          content: content,
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainContentLoadingSkeleton extends StatelessWidget {
  const _MainContentLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('main-content-loading'),
      constraints: const BoxConstraints(minHeight: 228),
      child: SkeletonShimmer(
        duration: const Duration(milliseconds: 1350),
        highlightStrength: 0.36,
        builder: (context, palette) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.92,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.88,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.95,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.66,
                height: 14,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                height: 110,
                decoration: palette.block(),
              ),
              const SizedBox(height: 16),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.9,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.58,
                height: 14,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThumUpButton extends StatelessWidget {
  const _ThumUpButton({
    required this.onPressed,
    required this.likeNum,
    this.selected = false,
  });
  final Function()? onPressed;
  final bool selected;
  final int likeNum;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        foregroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)
            : null,
        backgroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
            : null,
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(40, 36)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          const Icon(Icons.thumb_up_rounded, size: 16),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.commonLike,
            style: textTheme.labelMedium,
          ), // StringUtil.numFormat(likeNum)
        ],
      ),
    );
  }
}
