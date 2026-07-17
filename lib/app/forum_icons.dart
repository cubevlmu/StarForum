/*
 * @Author: khfahqp khfahqp@gmail.com
 * @LastEditors: khfahqp khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:fin_ui/fin_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/widgets.dart';

abstract final class ForumIcons {
  const ForumIcons._();

  static const IconData feed = FUIIcons.home;
  static const IconData feedFilled = FUIIcons.homeFilled;

  static const IconData forum = FUIIcons.list;
  static const IconData forumFilled = FUIIcons.appsFilled;

  static const IconData tags = FUIIcons.filter;
  static const IconData tagsFilled = FUIIcons.filter;

  static const IconData notifications = FUIIcons.notification;
  static const IconData notificationsFilled = FUIIcons.notificationActive;
  static const IconData mention = FluentIcons.comment_mention_24_regular;

  static const IconData profile = FUIIcons.person;
  static const IconData profileFilled = FUIIcons.person;
  static const IconData follow = FluentIcons.person_add_24_regular;

  static const IconData compose = FluentIcons.compose_24_regular;
  static const IconData reply = FluentIcons.arrow_reply_24_regular;
  static const IconData comments = FluentIcons.comment_multiple_24_regular;
  static const IconData commentsFilled = FluentIcons.comment_multiple_24_filled;

  static const IconData like = FluentIcons.thumb_like_24_regular;
  static const IconData likeFilled = FluentIcons.thumb_like_24_filled;

  static const IconData bookmark = FluentIcons.bookmark_24_regular;
  static const IconData bookmarkFilled = FluentIcons.bookmark_24_filled;

  static const IconData share = FluentIcons.share_24_regular;
  static const IconData shareFilled = FluentIcons.share_24_filled;
  static const IconData image = FluentIcons.image_24_regular;
  static const IconData code = FUIIcons.bug;
  static const IconData attachment = FluentIcons.attach_24_regular;
  static const IconData send = FluentIcons.send_24_regular;
  static const IconData upload = FluentIcons.arrow_upload_24_regular;
  static const IconData sortAscending =
      FluentIcons.arrow_sort_up_lines_24_regular;
  static const IconData sortDescending =
      FluentIcons.arrow_sort_down_lines_24_regular;
  static const IconData backToTop = FluentIcons.arrow_up_24_regular;
  static const IconData locked = FluentIcons.lock_closed_24_filled;
  static const IconData unlocked = FluentIcons.lock_open_24_regular;
  static const IconData folder = FluentIcons.folder_24_regular;
  static const IconData folderFilled = FluentIcons.folder_24_filled;
  static const IconData document = FluentIcons.document_24_regular;

  static const IconData badge = FluentIcons.ribbon_24_regular;
  static const IconData badgeFilled = FluentIcons.ribbon_24_filled;

  static const IconData people = FluentIcons.people_team_24_regular;
  static const IconData peopleFilled = FluentIcons.people_team_24_filled;

  static const IconData cache = FUIIcons.chart;
  static const IconData level = FluentIcons.arrow_trending_24_regular;
  static const IconData more = FUIIcons.more;

  static const IconData github = FluentIcons.link_24_regular;

  static const IconData hot = FluentIcons.fire_24_regular;
  static const IconData sticky = FluentIcons.pin_24_filled;
  static const IconData superSticky = FluentIcons.star_24_filled;

  static const IconData edit = FluentIcons.edit_24_regular;
}
