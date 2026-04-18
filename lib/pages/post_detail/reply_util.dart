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
import 'package:star_forum/pages/editor/view.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/reply_input_sheet.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/sheet_util.dart';

import '../../di/injector.dart';

class ReplyUtil {
  static AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;
  static const double _threePaneBreakPoint = 980;

  static bool _checkLogin(UserRepo repo) {
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(msg: _l10n.authLoginRequired);
      return false;
    }
    return true;
  }

  static String replyPrefix(PostInfo post) {
    return "@\"${post.user?.displayName ?? ""}\"#p${post.id} ";
  }

  static String replyInitialContent(PostInfo post, String draft) {
    final prefix = replyPrefix(post);
    final text = draft.trimLeft();
    if (text.startsWith(prefix)) {
      return text;
    }
    return "$prefix$text";
  }

  static Future<bool> submitReplyContent({
    required String discussionId,
    required String content,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return false;

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
  }

  static Future<void> showAddReplySheet({
    required BuildContext context,
    required String discussionId,
    String? replyTargetTitle,
    required List<PostInfo> newReplyItems,
    required Function()? updateWidget,
    required ScrollController? scrollController,
  }) async {
    final repo = getIt<UserRepo>();
    if (!_checkLogin(repo)) return;

    SheetUtil.newBottomSheet(
      context: context,
      widget: ReplyInputSheet(
        onOpenEditor: (draft) {
          _openReplyEditor(
            context: context,
            title: _l10n.editorReplyToTitle(
              replyTargetTitle ?? _l10n.postActionComment,
            ),
            initialContent: draft,
            onSubmitReply: (content) => submitReplyContent(
              discussionId: discussionId,
              content: content,
              newReplyItems: newReplyItems,
              updateWidget: updateWidget,
              scrollController: scrollController,
            ),
          );
        },
        onSubmit: (content) => submitReplyContent(
          discussionId: discussionId,
          content: content,
          newReplyItems: newReplyItems,
          updateWidget: updateWidget,
          scrollController: scrollController,
        ),
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
        onOpenEditor: (draft) {
          final initialContent = replyInitialContent(pi, draft);
          _openReplyEditor(
            context: context,
            title: _l10n.editorReplyToTitle(pi.user?.displayName ?? ""),
            initialContent: initialContent,
            onSubmitReply: (content) => submitReplyContent(
              discussionId: discussionId,
              content: content,
              newReplyItems: newReplyItems,
              updateWidget: updateWidget,
              scrollController: scrollController,
            ),
          );
        },
        onSubmit: (content) async {
          return submitReplyContent(
            discussionId: discussionId,
            content: replyInitialContent(pi, content),
            newReplyItems: newReplyItems,
            updateWidget: updateWidget,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  static void _openReplyEditor({
    required BuildContext context,
    required String title,
    required String initialContent,
    required Future<bool> Function(String content) onSubmitReply,
  }) {
    if (MediaQuery.sizeOf(context).width >= _threePaneBreakPoint &&
        Get.isRegistered<MainController>()) {
      Get.find<MainController>().showReplyEditorDetail(
        title: title,
        initialContent: initialContent,
        onSubmitReply: onSubmitReply,
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => EditorPage.reply(
          title: title,
          initialContent: initialContent,
          onSubmitReply: onSubmitReply,
        ),
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
