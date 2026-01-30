/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGame Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:get/get.dart';

import '../../di/injector.dart';

///发表评论工具类
class ReplyUtil {
  ///显示发表评论输入卡片
  ///
  ///type 评论区类型
  ///
  ///oid 目标评论区id
  ///
  ///root 根评论rpid（二级评论以上使用）
  ///
  ///parent 父评论rpid（二级评论同根评论id，若大于二级评论则为要回复的评论id）
  ///
  ///message 评论内容（最大10000字符，表情使用表情转义符）
  ///
  ///platform 发送平台标识
  ///
  ///newReplyItems 外部用来存放新增评论的数组
  ///
  ///updateWidget 当发表成功时用来更新评论区组件的函数
  ///
  ///scrollController 用来滚动评论区组件到最上方
  static Future<void> showAddReplySheet({
    required String discussionId,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    String message = "";
    onAddReply() async {
      final r = await Api.createPost(discussionId, message);
      if (r != null) {
        final repo = getIt<UserRepo>();
        r.user = repo.user;
        Navigator.pop(Get.context!);
        Get.rawSnackbar(message: '发表成功');
        newReplyItems.insert(0, r);
        updateWidget?.call();
        scrollController?.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      } else {
        Get.rawSnackbar(message: "...");
      }
    }

    bool isReplying = false;
    Get.bottomSheet(
      BottomSheet(
        onClosing: () => {},
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => message = value,
                    onSubmitted: (value) async {
                      if (isReplying) return;
                      isReplying = true;
                      onAddReply();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (isReplying) return;
                    isReplying = true;
                    onAddReply();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> showAddReplySheet2({
    required String discussionId,
    required PostInfo pi,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    String message = "";
    onAddReply() async {
      final r = await Api.replyToPost(
        discussionId: discussionId,
        replyPostId: pi.id,
        replyUsername: pi.user?.displayName ?? "",
        content: message,
      );
      if (r != null) {
        final repo = getIt<UserRepo>();
        r.user = repo.user;
        Navigator.pop(Get.context!);
        Get.rawSnackbar(message: '发表成功');
        newReplyItems.insert(0, r);
        updateWidget?.call();
        scrollController?.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      } else {
        Get.rawSnackbar(message: "...");
      }
    }

    bool isReplying = false;
    Get.bottomSheet(
      BottomSheet(
        onClosing: () => {},
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => message = value,
                    onSubmitted: (value) async {
                      if (isReplying) return;
                      isReplying = true;
                      onAddReply();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (isReplying) return;
                    isReplying = true;
                    onAddReply();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
