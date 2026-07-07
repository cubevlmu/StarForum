/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_list/widgets/create_discuss.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/sheet_util.dart';

import '../../di/injector.dart';

class CreateDiscussUtil {
  static bool _checkLogin(BuildContext context, UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(context)!.authLoginRequired,
      );
      return false;
    }
    return true;
  }

  static Future<bool> submitDiscussion({
    required BuildContext context,
    required List<int> tags,
    required String title,
    required String content,
    Function()? updateWidget,
    ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    final dRepo = getIt<DiscussionRepository>();
    if (!_checkLogin(context, repo)) return false;
    final l10n = AppLocalizations.of(context)!;

    final result = await dRepo.createDiscussion(tags, title, content);

    if (result.isTokenExpired) {
      repo.logout();
      SnackbarUtils.showMessage(msg: l10n.authLoginExpired);
      return false;
    }

    final r = result.data;
    if (r == null) {
      SnackbarUtils.showMessage(
        title: l10n.postCreateFailedTitle,
        msg: l10n.postCreateFailedNetwork,
        type: AppNoticeType.error,
      );
      return false;
    }

    r.user = repo.user;
    r.firstPost = r.posts.values.first;
    if (r.firstPost == null) {
      LogUtil.error(
        "[PostList] Failed to fetch firstPost for the return from create discussion.",
      );
      SnackbarUtils.showMessage(
        msg: l10n.postCreateDataError,
        type: AppNoticeType.warning,
      );
      return true;
    }

    dRepo.manuallyInsert(r);
    updateWidget?.call();

    scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );

    SnackbarUtils.showMessage(
      msg: l10n.postCreateSuccess,
      type: AppNoticeType.success,
    );
    return true;
  }

  static Future<void> showCreateDiscuss({
    required BuildContext context,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(context, repo)) return;

    SheetUtil.newBottomSheet(
      context: context,
      widget: CreateDiscussWidget(
        onSubmit: (tags, title, content) async {
          return submitDiscussion(
            context: context,
            tags: tags,
            title: title,
            content: content,
            updateWidget: updateWidget,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
