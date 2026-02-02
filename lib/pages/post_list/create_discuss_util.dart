/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/pages/post_list/widgets/create_discuss.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/widgets/sheet_util.dart';

import '../../di/injector.dart';

class CreateDiscussUtil {
  static bool _checkLogin(UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage("请先登录!");
      return false;
    }
    return true;
  }

  static Future<void> showCreateDiscuss({
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    final dRepo = getIt<DiscussionRepository>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      widget: CreateDiscussWidget(
        onSubmit: (tags, title, content) async {
          final (r, rs) = await Api.createDiscussion(tags, title, content);

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
          r.firstPost = r.posts.values.first;
          if (r.firstPost == null) {
            LogUtil.error(
              "[PostList] Failed to fetch firstPost for the return from create discussion.",
            );
            SnackbarUtils.showMessage("数据异常");
            return true;
          }

          // newReplyItems.insert(0, r.toItem());
          dRepo.manuallyInsert(r);
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
