import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/widgets/forum/forum_asset_tile.dart';
import 'package:star_forum/widgets/forum/forum_badge_card.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tile.dart';
import 'package:star_forum/widgets/forum/forum_post_card.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/widgets/shared_dialog.dart';

class DevSettingPage extends StatelessWidget {
  const DevSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: AppLocalizations.of(context)!.devMenuTitle,
            subtitle: '调试导航、日志导出和共享组件预览',
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: '调试工具',
            children: [
              FUITile(
                icon: FUIIcons.apps,
                title: '页面导航',
                subtitle: '打开用户页或讨论详情测试入口',
                onTap: () => _showPageSelector(context),
              ),
              FUITile(
                icon: FUIIcons.bug,
                title: '分享日志',
                subtitle: '导出今天的应用运行日志',
                onTap: () => LogUtil.shareLog(day: DateTime.now()),
              ),
              const FUITile(
                icon: FUIIcons.building,
                title: '设置 API 地址',
                subtitle: '当前调试入口尚未启用',
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: '共享组件预览',
            children: const [
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumAssetTile(
                  name: 'Asset tile',
                  subtitle: 'File information preview',
                  thumbnail: null,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumBadgeCard(
                  title: 'Badge card',
                  subtitle: 'Progress preview',
                  progress: 0.5,
                  progressLabel: '50%',
                  icon: ForumIcons.badge,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumDiscussionTile(
                  title: 'Discussion tile',
                  excerpt: 'Shared discussion component preview',
                  author: 'developer',
                  tags: ['debug', 'preview'],
                  replyCount: 10,
                  lastActivity: 'now',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumPostCard(
                  author: 'Developer',
                  content: Text('Shared post card preview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showPageSelector(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FUITile(
                icon: FUIIcons.person,
                title: 'UserPage',
                subtitle: '输入用户 ID 后打开用户资料页',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openUserPage(context);
                },
              ),
              FUITile(
                icon: ForumIcons.forum,
                title: 'DiscussionPage',
                subtitle: '打开临时讨论详情页',
                onTap: () {
                  Navigator.pop(sheetContext);
                  FuiNavigation.openDetail(
                    context,
                    builder: (_) => PostPage(
                      item: DiscussionItem(
                        id: '0',
                        title: 'TEMP',
                        excerpt: '<h1>TEMP</h1>',
                        lastPostedAt: DateTime.utc(1980),
                        userId: 0,
                        subscription: 0,
                      ),
                      embedded: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUserPage(BuildContext context) {
    SharedDialog.showNumberDialog(
      context,
      'UserId',
      '-1 for invalid, -2 for not login',
      'Cancel',
      () {},
      'Open',
      (id) => FuiNavigation.openDetail(
        context,
        builder: (_) => UserPage(userId: id, embedded: true),
      ),
    );
  }
}
