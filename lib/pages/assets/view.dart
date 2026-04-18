import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/assets/controller.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({
    super.key,
    this.embedded = false,
    this.selectionEnabled = false,
    this.onSelected,
  });

  final bool embedded;
  final bool selectionEnabled;
  final ValueChanged<UploadFileInfo>? onSelected;

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  late final String _tag;
  late final AssetsController controller;

  @override
  void initState() {
    super.initState();
    _tag = 'AssetsPage:${identityHashCode(this)}';
    controller = Get.put(AssetsController(), tag: _tag);
  }

  @override
  void dispose() {
    if (Get.isRegistered<AssetsController>(tag: _tag)) {
      Get.delete<AssetsController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: _AssetsPageTitle(controller: controller)),
      body: Column(
        children: [
          Expanded(
            child: _AssetsBody(
              controller: controller,
              showHeaderTitle: widget.embedded,
              selectionEnabled: widget.selectionEnabled,
            ),
          ),
          if (widget.selectionEnabled)
            _AssetsFooter(
              controller: controller,
              onCancel: () => Navigator.of(context).maybePop(),
              onUseSelected: (file) {
                widget.onSelected?.call(file);
                if (widget.onSelected == null) {
                  Navigator.of(context).maybePop(file);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _AssetsBody extends StatelessWidget {
  const _AssetsBody({
    required this.controller,
    required this.showHeaderTitle,
    required this.selectionEnabled,
  });

  final AssetsController controller;
  final bool showHeaderTitle;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading =
          controller.isInitialLoading.value && controller.files.isEmpty;

      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        autoRefreshOnStart: false,
        refreshEnabled: !isLoading,
        loadEnabled: !isLoading,
        childBuilder: (context, physics) {
          return CustomScrollView(
            controller: controller.scrollController,
            cacheExtent: 320,
            physics: isLoading ? const NeverScrollableScrollPhysics() : physics,
            slivers: [
              SliverToBoxAdapter(
                child: _AssetsHeader(
                  controller: controller,
                  showTitle: showHeaderTitle,
                ),
              ),
              if (isLoading)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: _AssetsLoadingGrid(),
                )
              else if (controller.files.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '🖼️',
                    title: AppLocalizations.of(context)!.assetsEmptyTitle,
                    tips: AppLocalizations.of(context)!.assetsEmptyTips,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: _AssetsGrid(
                    controller: controller,
                    selectionEnabled: selectionEnabled,
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}

class _AssetsHeader extends StatelessWidget {
  const _AssetsHeader({required this.controller, required this.showTitle});

  final AssetsController controller;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showTitle)
            Expanded(
              child: Text(
                l10n.assetsManagerTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          Obx(() {
            final uploading = controller.isUploading.value;
            final canUpload = controller.userRepo.canUpload.value;
            return Tooltip(
              message: canUpload ? l10n.assetsUpload : l10n.assetsUploadDenied,
              child: FilledButton.tonalIcon(
                onPressed: uploading || !canUpload
                    ? null
                    : () => pickAndUploadWithNotice(context, controller),
                icon: uploading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_upload_outlined),
                label: Text(l10n.assetsUpload),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AssetsPageTitle extends StatelessWidget {
  const _AssetsPageTitle({required this.controller});

  final AssetsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.assetsManagerTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Obx(() {
          final uploading = controller.isUploading.value;
          final canUpload = controller.userRepo.canUpload.value;
          return IconButton(
            tooltip: canUpload ? l10n.assetsUpload : l10n.assetsUploadDenied,
            onPressed: uploading || !canUpload
                ? null
                : () => pickAndUploadWithNotice(context, controller),
            icon: uploading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_upload_outlined),
          );
        }),
      ],
    );
  }
}

Future<void> pickAndUploadWithNotice(
  BuildContext context,
  AssetsController controller,
) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await controller.pickAndUpload();
  if (!context.mounted || result == null) {
    return;
  }

  if (result) {
    SnackbarUtils.showSuccess(msg: l10n.assetsUploadSuccess);
  } else {
    SnackbarUtils.showError(msg: l10n.assetsUploadFailed);
  }
}

class _AssetsGrid extends StatelessWidget {
  const _AssetsGrid({required this.controller, required this.selectionEnabled});

  final AssetsController controller;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final count = math.max(2, math.min(6, (width / 164).floor()));
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 176,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final file = controller.files[index];
            return Obx(() {
              final selected = controller.selectedFile.value?.id == file.id;
              return RepaintBoundary(
                child: _AssetTile(
                  controller: controller,
                  file: file,
                  selected: selectionEnabled && selected,
                  selectionEnabled: selectionEnabled,
                  onTap: selectionEnabled
                      ? () => controller.selectFile(file)
                      : null,
                ),
              );
            });
          }, childCount: controller.files.length),
        );
      },
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.controller,
    required this.file,
    required this.selected,
    required this.selectionEnabled,
    required this.onTap,
  });

  final AssetsController controller;
  final UploadFileInfo file;
  final bool selected;
  final bool selectionEnabled;
  final VoidCallback? onTap;

  bool get _isImage => file.type.startsWith('image/');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.72);

    return Material(
      color: colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AssetPreview(file: file, isImage: _isImage),
                  if (selectionEnabled)
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    bottom: 6,
                    end: 6,
                    child: _AssetActions(controller: controller, file: file),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    file.baseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.assetsFileSize(file.humanSize),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetPreview extends StatelessWidget {
  const _AssetPreview({required this.file, required this.isImage});

  final UploadFileInfo file;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isImage || file.url.isEmpty) {
      return ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 36,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = math.min((constraints.maxWidth * dpr).round(), 360);
        final cacheHeight = math.min(
          (constraints.maxHeight * dpr).round(),
          300,
        );
        return Semantics(
          label: AppLocalizations.of(context)!.assetsImagePreview,
          image: true,
          child: CachedNetworkImage(
            imageUrl: file.url,
            cacheManager: CacheUtils.assetThumbCacheManager,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            placeholder: () => ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: () => ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AssetActions extends StatelessWidget {
  const _AssetActions({required this.controller, required this.file});

  final AssetsController controller;
  final UploadFileInfo file;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final deleting = controller.deletingIds.contains(file.id);
            return Tooltip(
              message: l10n.assetsDeleteFile,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: file.canDelete && !deleting
                    ? () => _confirmDelete(context)
                    : null,
                icon: deleting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.assetsDeleteFile),
          content: Text(l10n.assetsDeleteConfirm(file.baseName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonActionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonActionConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final ok = await controller.deleteFile(file);
    if (!context.mounted) {
      return;
    }

    if (ok) {
      SnackbarUtils.showSuccess(msg: l10n.assetsDeleteSuccess);
    } else {
      SnackbarUtils.showError(msg: l10n.assetsDeleteFailed);
    }
  }
}

class _AssetsFooter extends StatelessWidget {
  const _AssetsFooter({
    required this.controller,
    required this.onCancel,
    required this.onUseSelected,
  });

  final AssetsController controller;
  final VoidCallback onCancel;
  final ValueChanged<UploadFileInfo> onUseSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Obx(() {
            final selected = controller.selectedFile.value;
            return Row(
              children: [
                TextButton(onPressed: onCancel, child: Text(l10n.assetsCancel)),
                const Spacer(),
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () => onUseSelected(selected),
                  child: Text(
                    selected == null
                        ? l10n.assetsNoSelection
                        : l10n.assetsUseSelected,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _AssetsLoadingGrid extends StatelessWidget {
  const _AssetsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final count = math.max(2, math.min(6, (width / 164).floor()));
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 176,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }, childCount: count * 3),
        );
      },
    );
  }
}
