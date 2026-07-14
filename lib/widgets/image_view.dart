/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';

class ImagePreviewWidget extends StatefulWidget {
  final String url;
  final bool embedded;
  final String? badCertificateHost;

  const ImagePreviewWidget({
    super.key,
    required this.url,
    this.embedded = false,
    this.badCertificateHost,
  });

  @override
  State<ImagePreviewWidget> createState() => ImagePreviewWidgetState();
}

class ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dpr = MediaQuery.devicePixelRatioOf(context);
                  final targetWidth = (constraints.maxWidth * dpr * 1.6)
                      .round();
                  final targetHeight = (constraints.maxHeight * dpr * 1.6)
                      .round();

                  return RepaintBoundary(
                    child: Center(
                      child: ClipRect(
                        child: InteractiveViewer(
                          transformationController: _controller,
                          minScale: 0.6,
                          maxScale: 4.0,
                          clipBehavior: Clip.none,
                          child: Hero(
                            tag: 'img:${widget.url}',
                            child: CachedNetworkImage(
                              imageUrl: widget.url,
                              cacheManager: CacheUtils.contentCacheManager,
                              badCertificateHost: widget.badCertificateHost,
                              fit: BoxFit.contain,
                              cacheWidth: targetWidth,
                              cacheHeight: targetHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: FUITokens.gap8,
              left: FUITokens.gap12,
              right: FUITokens.gap12,
              child: Row(
                children: [
                  _ImagePreviewAction(
                    icon: FUIIcons.close,
                    onPressed: () {
                      if (widget.embedded) {
                        FuiNavigation.closeCurrent(context);
                        return;
                      }
                      Navigator.of(context).maybePop();
                    },
                  ),
                  const Spacer(),
                  _ImagePreviewAction(
                    icon: FUIIcons.save,
                    onPressed: _saveImage,
                    tooltip: AppLocalizations.of(context)!.imageSaveTooltip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      final cacheManager = CachedNetworkImage.cacheManagerFor(
        url: widget.url,
        fallback: CacheUtils.contentCacheManager,
        badCertificateHost: widget.badCertificateHost,
      );
      final file = await cacheManager.getSingleFile(widget.url);

      final savedPath = await _copyToPictures(file);

      if (!mounted) return;
      SnackbarUtils.showSuccess(
        msg: AppLocalizations.of(context)!.imageSaveSuccess(savedPath),
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        msg: AppLocalizations.of(context)!.imageSaveFailed(e),
      );
    }
  }

  Future<String> _copyToPictures(File source) async {
    final fileName = 'forum_${DateTime.now().millisecondsSinceEpoch}.png';

    late Directory targetDir;

    if (Platform.isAndroid) {
      targetDir = Directory('/storage/emulated/0/DCIM/Forum');
    } else if (Platform.isWindows) {
      targetDir = Directory('${Platform.environment['USERPROFILE']}\\Pictures');
    } else if (Platform.isMacOS || Platform.isLinux) {
      targetDir = Directory('${Platform.environment['HOME']}/Pictures');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final targetFile = File('${targetDir.path}/$fileName');
    await source.copy(targetFile.path);

    return targetFile.path;
  }
}

class _ImagePreviewAction extends StatelessWidget {
  const _ImagePreviewAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(FUITokens.radiusFull),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FUIIconButton(
        icon: icon,
        variant: FUIIconButtonVariant.ghost,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
