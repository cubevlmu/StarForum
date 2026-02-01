/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGame Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/pages/post_detail/widgets/reply_input_sheet.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/widgets/sheet_util.dart';
import 'package:get/get.dart';

import '../../di/injector.dart';

class ReplyUtil {
  static bool _checkLogin(UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage("请先登录!");
      return false;
    }
    return true;
  }

  static Future<void> showAddReplySheet({
    required String discussionId,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      widget: ReplyInputSheet(
        onSubmit: (content) async {
          final (r, rs) = await Api.createPost(discussionId, content);

          if (!rs) {
            repo.logout();
            SnackbarUtils.showMessage("登录过期!");
            return false;
          }

          if (r == null) {
            SnackbarUtils.showMessageWithTitle("发表失败", "可能是网络问题");
            return false;
          }

          r.user = repo.user;
          newReplyItems.insert(0, r);
          updateWidget?.call();

          scrollController?.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );

          SnackbarUtils.showMessage("发表成功");
          return true;
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
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      widget: ReplyInputSheet(
        hintText: "回复 @${pi.user?.displayName ?? ""}",
        onSubmit: (content) async {
          final (r, rs) = await Api.replyToPost(
            discussionId: discussionId,
            replyPostId: pi.id,
            replyUsername: pi.user?.displayName ?? "",
            content: content,
          );

          if (!rs) {
            repo.logout();
            SnackbarUtils.showMessage("登录过期!");
            return false;
          }

          if (r == null) {
            SnackbarUtils.showMessageWithTitle("发表失败", "可能是网络问题");
            return false;
          }

          r.user = repo.user;
          newReplyItems.insert(0, r);
          updateWidget?.call();

          scrollController?.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );

          SnackbarUtils.showMessage("发表成功");
          return true;
        },
      ),
    );
  }
}
