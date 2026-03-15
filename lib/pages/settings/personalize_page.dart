import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/personalize_controller.dart';
import 'package:star_forum/pages/settings/widgets/settings_label.dart';
import 'package:star_forum/utils/setting_util.dart';

class PersonalizeSettingsPage extends StatefulWidget {
  const PersonalizeSettingsPage({super.key});

  @override
  State<PersonalizeSettingsPage> createState() =>
      _PersonalizeSettingsPageState();
}

class _PersonalizeSettingsPageState extends State<PersonalizeSettingsPage> {
  late final PersonalizeSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PersonalizeSettingsController(),
      tag: runtimeType.toString(),
    );
  }

  @override
  void dispose() {
    Get.delete<PersonalizeSettingsController>(tag: runtimeType.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPersonalizeTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          SettingsLabel(text: l10n.settingsThemeSection),
          const SizedBox(height: 8),
          Obx(
            () => _ThemeModeSection(
              currentValue: controller.themeMode.value,
              onChanged: controller.changeThemeMode,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _ThemeColorSection(
              currentValue: controller.theme.value,
              onChanged: controller.changeTheme,
            ),
          ),
          const SizedBox(height: 16),
          SettingsLabel(text: l10n.settingsFontSection),
          const SizedBox(height: 8),
          Obx(
            () => _FontScaleTile(
              value: controller.textScaleFactor.value,
              onChanged: controller.changeTextScaleFactor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSection extends StatelessWidget {
  const _ThemeModeSection({
    required this.currentValue,
    required this.onChanged,
  });

  final ThemeMode currentValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: AppLocalizations.of(context)!.settingsThemeMode,
      subtitle: currentValue.value,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<ThemeMode>(
            segments: [
              for (final item in ThemeMode.values)
                ButtonSegment<ThemeMode>(
                  value: item,
                  icon: Icon(_themeModeIcon(item)),
                  label: Text(item.value),
                ),
            ],
            selected: {currentValue},
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
            showSelectedIcon: false,
            onSelectionChanged: (value) {
              if (value.isNotEmpty) {
                onChanged(value.first);
              }
            },
          ),
        ),
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}

class _ThemeColorSection extends StatelessWidget {
  const _ThemeColorSection({
    required this.currentValue,
    required this.onChanged,
  });

  final AppTheme currentValue;
  final ValueChanged<AppTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: AppLocalizations.of(context)!.settingsThemeColor,
      subtitle: currentValue.value,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final columnCount = (constraints.maxWidth / 110).floor().clamp(
              2,
              4,
            );
            final itemWidth =
                (constraints.maxWidth - (columnCount - 1) * spacing) /
                columnCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final theme in AppTheme.values)
                  SizedBox(
                    width: itemWidth,
                    child: _ThemeColorOption(
                      theme: theme,
                      selected: theme == currentValue,
                      onTap: () => onChanged(theme),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeColorOption extends StatelessWidget {
  const _ThemeColorOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  static const double _borderRadius = 17;

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ThemeColorPreview(theme: theme, selected: selected),
              const SizedBox(height: 8),
              Text(
                theme.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeColorPreview extends StatelessWidget {
  const _ThemeColorPreview({required this.theme, required this.selected});

  final AppTheme theme;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (theme == AppTheme.dynamic) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.tertiary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          selected ? Icons.check_rounded : Icons.auto_awesome_rounded,
          color: colorScheme.onPrimary,
          size: 18,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.seedColor,
          ),
        ),
        if (selected)
          const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      ],
    );
  }
}

class _FontScaleTile extends StatelessWidget {
  const _FontScaleTile({required this.value, required this.onChanged});

  final double value;
  final Future<void> Function(double value) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          title: Text(l10n.settingsFontSize),
          subtitle: Text(value.toStringAsFixed(1)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) =>
                _FontScaleDialog(initialValue: value, onChanged: onChanged),
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

class _FontScaleDialog extends StatefulWidget {
  const _FontScaleDialog({required this.initialValue, required this.onChanged});

  final double initialValue;
  final Future<void> Function(double value) onChanged;

  @override
  State<_FontScaleDialog> createState() => _FontScaleDialogState();
}

class _FontScaleDialogState extends State<_FontScaleDialog> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(l10n.settingsFontSize),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Slider(
              value: _value,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              label: _value.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonActionCancel),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onChanged(_value);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(l10n.commonActionConfirm),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(title), subtitle: Text(subtitle)),
        child,
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
