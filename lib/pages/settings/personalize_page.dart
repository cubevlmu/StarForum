import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/personalize_controller.dart';
import 'package:star_forum/pages/settings/widgets/settings_toggle_tile.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;

class PersonalizeSettingsPage extends StatefulWidget {
  const PersonalizeSettingsPage({super.key});

  @override
  State<PersonalizeSettingsPage> createState() =>
      _PersonalizeSettingsPageState();
}

class _PersonalizeSettingsPageState extends State<PersonalizeSettingsPage> {
  late final String _tag;
  late final PersonalizeSettingsController controller;

  @override
  void initState() {
    super.initState();
    _tag = 'PersonalizeSettings:${identityHashCode(this)}';
    controller = Get.put(PersonalizeSettingsController(), tag: _tag);
  }

  @override
  void dispose() {
    if (Get.isRegistered<PersonalizeSettingsController>(tag: _tag)) {
      Get.delete<PersonalizeSettingsController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.settingsPersonalizeTitle,
            subtitle: '调整主题模式和界面文字大小',
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.settingsThemeSection,
            children: [
              Padding(
                padding: const EdgeInsets.all(FUITokens.gap14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsThemeMode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap10),
                    Obx(
                      () => FUISegmentedControl<ThemeMode>(
                        value: controller.themeMode.value,
                        items: [
                          FUISegmentedItem(
                            value: ThemeMode.system,
                            label: ThemeMode.system.value,
                            icon: FUIIcons.autoBrightness,
                          ),
                          FUISegmentedItem(
                            value: ThemeMode.light,
                            label: ThemeMode.light.value,
                            icon: FUIIcons.lightMode,
                          ),
                          FUISegmentedItem(
                            value: ThemeMode.dark,
                            label: ThemeMode.dark.value,
                            icon: FUIIcons.darkMode,
                          ),
                        ],
                        onChanged: controller.changeThemeMode,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(FUITokens.gap14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsThemeColor,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap10),
                    Obx(
                      () => _ThemeColorPicker(
                        selected: controller.theme.value,
                        onSelected: controller.changeTheme,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          Obx(
            () => FUISection(
              title: l10n.settingsFontSection,
              children: [
                SettingsToggleTile(
                  icon: FUIIcons.apps,
                  title: '按钮组只显示图标',
                  subtitle: '主页、用户页等切换按钮始终隐藏文字，仅通过图标和提示说明显示含义',
                  value: controller.buttonGroupIconOnly.value,
                  onChanged: controller.changeButtonGroupIconOnly,
                ),
                SettingsToggleTile(
                  icon: FUIIcons.list,
                  title: '显示主题简介',
                  subtitle: '开启后会缓存并同步首帖内容来生成列表简介，关闭可减少请求和解析开销',
                  value: controller.showDiscussionExcerpt.value,
                  onChanged: controller.changeShowDiscussionExcerpt,
                ),
                Padding(
                  padding: const EdgeInsets.all(FUITokens.gap14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '按钮组对齐',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: FUITokens.gap10),
                      FUISegmentedControl<ButtonGroupAlignmentPreference>(
                        value: controller.buttonGroupAlignment.value,
                        items: [
                          for (final item
                              in ButtonGroupAlignmentPreference.values)
                            FUISegmentedItem(
                              value: item,
                              label: item.label,
                              icon:
                                  item ==
                                      ButtonGroupAlignmentPreference.centered
                                  ? FUIIcons.apps
                                  : FUIIcons.list,
                            ),
                        ],
                        onChanged: controller.changeButtonGroupAlignment,
                      ),
                    ],
                  ),
                ),
                FUITile(
                  icon: FUIIcons.list,
                  title: l10n.settingsFontSize,
                  subtitle: _fontScaleDescription(
                    controller.textScaleFactor.value,
                  ),
                  trailing: Text(
                    '${(controller.textScaleFactor.value * 100).round()}%',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    final value = ValueNotifier<double>(
                      controller.textScaleFactor.value,
                    );
                    final confirmed =
                        await shared.SharedDialog.showContentDialog(
                          context,
                          title: l10n.settingsFontSize,
                          content: _FontScaleDialog(value: value),
                          cancelText: l10n.commonActionCancel,
                          confirmText: l10n.commonActionConfirm,
                        );
                    if (confirmed) {
                      await controller.changeTextScaleFactor(value.value);
                    }
                    value.dispose();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fontScaleDescription(double value) {
    if (value < 0.9) return '紧凑，适合希望显示更多内容的界面';
    if (value > 1.1) return '较大，提升正文和控件文字可读性';
    return '标准大小，适合大多数手机屏幕';
  }
}

class _ThemeColorPicker extends StatelessWidget {
  const _ThemeColorPicker({required this.selected, required this.onSelected});

  final AppTheme selected;
  final ValueChanged<AppTheme> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FUITokens.gap10,
      runSpacing: FUITokens.gap10,
      children: [
        for (final theme in AppTheme.values)
          _ThemeColorButton(
            theme: theme,
            selected: theme == selected,
            onTap: () => onSelected(theme),
          ),
      ],
    );
  }
}

class _ThemeColorButton extends StatelessWidget {
  const _ThemeColorButton({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatch = theme == AppTheme.dynamic ? colors.primary : theme.seedColor;
    return Material(
      color: selected ? colors.primarySoft : colors.surfaceAlt,
      borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
        onTap: onTap,
        child: SizedBox(
          width: 108,
          height: 38,
          child: Row(
            children: [
              const SizedBox(width: FUITokens.gap12),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: swatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: Text(
                  theme.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? colors.primary : colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(
                width: 16,
                height: 16,
                child: selected
                    ? Icon(FUIIcons.checkmark, size: 16, color: colors.primary)
                    : null,
              ),
              const SizedBox(width: FUITokens.gap8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontScaleDialog extends StatelessWidget {
  const _FontScaleDialog({required this.value});

  final ValueNotifier<double> value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: value,
      builder: (context, current, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(current * 100).round()}%',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: current,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              label: '${(current * 100).round()}%',
              onChanged: (next) => value.value = next,
            ),
            Text(
              'StarForum 文字预览',
              textScaler: TextScaler.linear(current),
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}
