/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_list/widgets/create_discuss.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/sheet_util.dart';

import '../../di/injector.dart';

class CreateDiscussUtil {
  static bool _checkLogin(UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.authLoginRequired,
      );
      return false;
    }
    return true;
  }

  static Future<void> showCreateDiscuss({
    required BuildContext context,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    final dRepo = getIt<DiscussionRepository>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      context: context,
      widget: CreateDiscussWidget(
        onSubmit: (tags, title, content) async {
          final (r, rs) = await Api.createDiscussion(tags, title, content);

          if (!rs) {
            repo.logout();
            SnackbarUtils.showMessage(
              msg: AppLocalizations.of(Get.context!)!.authLoginExpired,
            );
            return false;
          }

          if (r == null) {
            SnackbarUtils.showMessage(
              title: AppLocalizations.of(Get.context!)!.postCreateFailedTitle,
              msg: AppLocalizations.of(Get.context!)!.postCreateFailedNetwork,
            );
            return false;
          }

          r.user = repo.user;
          r.firstPost = r.posts.values.first;
          if (r.firstPost == null) {
            LogUtil.error(
              "[PostList] Failed to fetch firstPost for the return from create discussion.",
            );
            SnackbarUtils.showMessage(msg: AppLocalizations.of(Get.context!)!.postCreateDataError);
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

          SnackbarUtils.showMessage(msg: AppLocalizations.of(Get.context!)!.postCreateSuccess);
          return true;
        },
      ),
    );
  }
}
