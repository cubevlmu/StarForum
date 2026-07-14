import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/dev_page.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/utils/app_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const authorUrl = 'https://github.com/cubevlmu';
  static const projectUrl = 'https://github.com/cubevlmu/StarForum';
  static int tapTimes = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(title: l10n.aboutTitle, subtitle: l10n.aboutSubtitle),
          const SizedBox(height: FUITokens.gap16),
          FUISurface(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 72,
                  height: 72,
                  cacheWidth: 144,
                  cacheHeight: 144,
                ),
                const SizedBox(height: FUITokens.gap12),
                Text(
                  'StarForum',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: FUITokens.gap4),
                GestureDetector(
                  onTap: _handleVersionTap,
                  child: FutureBuilder<String>(
                    future: AppInfo.versionLabel(),
                    builder: (context, snapshot) {
                      final version = snapshot.data ?? '';
                      return Text(
                        version.isEmpty
                            ? l10n.aboutVersion
                            : '${l10n.aboutVersion} $version',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: FUITokens.gap12),
                Text(
                  l10n.aboutDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.aboutProjectSection,
            children: [
              FUITile(
                icon: FUIIcons.person,
                title: l10n.aboutAuthor,
                subtitle: 'cubevlmu @ flybird studio',
                onTap: () => launchUrlString(authorUrl),
              ),
              FUITile(
                icon: ForumIcons.github,
                title: l10n.aboutProjectLink,
                subtitle: projectUrl,
                onTap: () => launchUrlString(projectUrl),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.aboutSupportSection,
            children: [
              FUITile(
                icon: FUIIcons.privacy,
                title: l10n.aboutLicense,
                subtitle: l10n.aboutLicensesSubtitle,
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const LicensePage(
                    applicationIcon: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Image(
                        image: AssetImage('assets/images/icon.png'),
                        width: 96,
                        height: 96,
                      ),
                    ),
                    applicationName: 'StarForum',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleVersionTap() {
    tapTimes++;
    if (tapTimes < 6) return;
    tapTimes = 0;
    FuiNavigation.openDetail(context, builder: (_) => const DevSettingPage());
  }
}