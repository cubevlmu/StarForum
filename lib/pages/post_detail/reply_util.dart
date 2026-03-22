/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGame Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/widgets/reply_input_sheet.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/sheet_util.dart';

import '../../di/injector.dart';

class ReplyUtil {
  static AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  static bool _checkLogin(UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(msg: _l10n.authLoginRequired);
      return false;
    }
    return true;
  }

  static Future<void> showAddReplySheet({
    required BuildContext context,
    required String discussionId,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      context: context,
      widget: ReplyInputSheet(
        onSubmit: (content) async {
          final (r, rs) = await Api.createPost(discussionId, content);

          if (!rs) {
            repo.logout();
            SnackbarUtils.showMessage(msg: _l10n.authLoginExpired);
            return false;
          }

          if (r == null) {
            SnackbarUtils.showMessage(
              title: _l10n.postCreateFailedTitle,
              msg: _l10n.postCreateFailedNetwork,
            );
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

          SnackbarUtils.showMessage(msg: _l10n.postCreateSuccess);
          return true;
        },
      ),
    );
  }

  static Future<void> showAddReplySheet2({
    required BuildContext context,
    required String discussionId,
    required PostInfo pi,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      context: context,
      widget: ReplyInputSheet(
        hintText: _l10n.replyToUserHint(pi.user?.displayName ?? ""),
        onSubmit: (content) async {
          final (r, rs) = await Api.replyToPost(
            discussionId: discussionId,
            replyPostId: pi.id,
            replyUsername: pi.user?.displayName ?? "",
            content: content,
          );

          if (!rs) {
            repo.logout();
            SnackbarUtils.showMessage(msg: _l10n.authLoginExpired);
            return false;
          }

          if (r == null) {
            SnackbarUtils.showMessage(
              title: _l10n.postCreateFailedTitle,
              msg: _l10n.postCreateFailedNetwork,
            );
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

          SnackbarUtils.showMessage(msg: _l10n.postCreateSuccess);
          return true;
        },
      ),
    );
  }

  static Future<PostInfo?> addLikeToPost(PostInfo item) async {
    final repo = getIt<UserRepo>();
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(msg: _l10n.authLoginRequired);
      return null;
    }

    try {
      final (r, rs) = await Api.likePost(item.id.toString(), true);
      if (!rs) {
        repo.logout();
        SnackbarUtils.showMessage(msg: _l10n.authLoginExpired);
        return null;
      }

      if (r == null) {
        LogUtil.error("[PostPage] failed to like post with empty response");
        SnackbarUtils.showMessage(
          title: _l10n.postLikeFailedTitle,
          msg: _l10n.postLikeFailedNetwork,
        );
        return null;
      }

      return r;
    } catch (e, s) {
      LogUtil.errorE(
        "[PostPage] failed to like post with id :${item.id}",
        e,
        s,
      );
    }
    return null;
  }
}
