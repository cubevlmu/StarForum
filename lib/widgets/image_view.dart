/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';

class ImagePreviewWidget extends StatefulWidget {
  final String url;

  const ImagePreviewWidget({super.key, required this.url});

  @override
  State<ImagePreviewWidget> createState() => ImagePreviewWidgetState();
}

class ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  final TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveImage,
            tooltip: '保存图片',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.3,
          maxScale: 5.0,
          child: CachedNetworkImage(
            imageUrl: widget.url,
            cacheManager: CacheUtils.contentCacheManager,
            fit: BoxFit.fill,
          ),
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('图片已保存到 $savedPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$e')));
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
