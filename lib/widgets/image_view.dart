/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';

class ImagePreviewWidget extends StatefulWidget {
  final String url;
  final bool embedded;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final bool canPopDetail;

  const ImagePreviewWidget({
    super.key,
    required this.url,
    this.embedded = false,
    this.onClose,
    this.onBack,
    this.canPopDetail = false,
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.embedded
            ? IconButton(
                icon: Icon(
                  widget.canPopDetail ? Icons.arrow_back : Icons.close,
                ),
                onPressed: widget.canPopDetail
                    ? widget.onBack
                    : (widget.onClose ??
                          () => Navigator.of(context).maybePop()),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveImage,
            tooltip: AppLocalizations.of(context)!.imageSaveTooltip,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final dpr = MediaQuery.devicePixelRatioOf(context);
          final targetWidth = (constraints.maxWidth * dpr * 1.6).round();
          final targetHeight = (constraints.maxHeight * dpr * 1.6).round();

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
    );
  }

  Future<void> _saveImage() async {
    try {
      final file = await CacheUtils.contentCacheManager.getSingleFile(
        widget.url,
      );

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
