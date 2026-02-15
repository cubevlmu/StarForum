/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/widgets/avatar.dart';

(String, String) buildMsg(NotificationsInfo info) {
  switch (info.contentType) {
    case "quest_done":
      final real = info.subject as QuestSubject;
      return (real.quest.name, real.quest.description);

    case "levelUpdated":
      final real = info.subject as LevelSubject;
      return ("等级达成 ${real.level.name}", "等级高于 ${real.level.minExpRequired}");

    case "postMentioned":
      final real = info.subject as PostSubject;
      final txt = htmlToPlainText(real.post.contentHtml);
      return (
        "回复了你",
        "帖子：${txt.substring(0, txt.length > 30 ? 30 : txt.length)}…",
      );

    case "postLiked":
      final real = info.subject as PostSubject;
      final txt = htmlToPlainText(real.post.contentHtml);
      return (
        "点赞了你",
        "帖子：${txt.substring(0, txt.length > 30 ? 30 : txt.length)}…",
      );

    case "badgeReceived":
      return ("获得了一个勋章", "客户端暂不支持解析勋章内容");

    case "warning":
      final real = info.subject as WarningSubject;
      return (
        "收到 ${info.fromUser?.displayName} 的警告",
        "记 ${real.warning.strikes} 分："
            "${htmlToPlainText(real.warning.publicComment ?? "")}",
      );

    default:
      LogUtil.error("[NotifyCard] Unsupported type: ${info.contentType}");
      return ("不支持的通知", "请前往网页版查看");
  }
}

class NotifyCard extends StatelessWidget {
  final NotificationsInfo item;
  final NotificationPageController controller;

  const NotifyCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final (title, desc) = buildMsg(item);

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),

              GestureDetector(
                child: AvatarWidget(
                  avatarUrl: item.fromUser?.avatarUrl ?? "",
                  radius: 22,
                  placeholder: item.fromUser?.displayName[0] ?? "U",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPage(userId: item.fromUser?.id ?? -1),
                    ),
                  );
                },
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!item.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: item.isRead ? Colors.grey : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        if (item.fromUser != null)
                          Flexible(
                            child: Text(
                              item.fromUser!.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const Text(" · ", style: TextStyle(color: Colors.grey)),
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 已读按钮
              IconButton(
                icon: const Icon(Icons.check_outlined),
                color: Colors.grey,
                onPressed: item.isRead
                    ? null
                    : () async {
                        if (await controller.checkAsRead(item.id)) {}
                      },
              ),
            ],
          ),
        ),
      ),
      onTap: () => naviToPage(context),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.month}-${time.day} "
        "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  void naviToPage(BuildContext context) async {
    if (item.contentType == "postLiked" ||
        item.contentType == "postMentioned") {
      final s = item.subject as PostSubject;
      final r = await controller.naviToDisPage(s.post.discussion);
      if (r == null) {
        return;
      }
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostPage(item: r)),
      );
    }
  }
}
