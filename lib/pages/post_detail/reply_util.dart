/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGame Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/editor/view.dart';
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
    final postRepo = getIt<PostRepository>();

    final result = await postRepo.createPost(discussionId, content);

    if (result.isTokenExpired) {
      repo.logout();
      SnackbarUtils.showMessage(msg: _l10n.authLoginExpired);
      return false;
    }

    final r = result.data;
    if (r == null) {
      SnackbarUtils.showError(
        title: _l10n.postCreateFailedTitle,
        msg: _l10n.postCreateFailedNetwork,
      );
      return false;
    }

    newReplyItems.insert(0, r.copyWith(user: repo.user));
    updateWidget?.call();

    scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );

    SnackbarUtils.showSuccess(msg: _l10n.postCreateSuccess);
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
            discussionId: discussionId,
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
            discussionId: discussionId,
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
    required String discussionId,
    required String title,
    required String initialContent,
    required Future<bool> Function(String content) onSubmitReply,
  }) {
    FuiNavigation.openDetail(
      context,
      builder: (_) => EditorPage.reply(
        title: title,
        discussionId: discussionId,
        initialContent: initialContent,
        onSubmitReply: onSubmitReply,
        embedded: true,
      ),
    );
  }

  static Future<PostInfo?> toggleLikeForPost(PostInfo item) async {
    final repo = getIt<UserRepo>();
    if (!repo.isLogin) {
      SnackbarUtils.showMessage(msg: _l10n.authLoginRequired);
      return null;
    }
    final postRepo = getIt<PostRepository>();

    try {
      final result = await postRepo.likePost(item.id.toString(), !item.isLiked);
      if (result.isTokenExpired) {
        repo.logout();
        SnackbarUtils.showMessage(msg: _l10n.authLoginExpired);
        return null;
      }

      final r = result.data;
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
