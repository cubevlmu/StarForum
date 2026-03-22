part of '../view.dart';

bool _isDesktopPlatform() {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return false;
  }
}

Uint8List _cropAvatarBytes(Map<String, Object> request) {
  final fileData = request['fileData']! as Uint8List;
  final srcX = request['srcX']! as double;
  final srcY = request['srcY']! as double;
  final srcSize = request['srcSize']! as double;
  final hasAlpha = request['hasAlpha']! as bool;

  final decoded = img.decodeImage(fileData);
  if (decoded == null) {
    return Uint8List(0);
  }

  final maxWidth = decoded.width;
  final maxHeight = decoded.height;
  final cropSize = srcSize.clamp(1, math.min(maxWidth, maxHeight)).round();
  final cropX = srcX.clamp(0, maxWidth - cropSize).round();
  final cropY = srcY.clamp(0, maxHeight - cropSize).round();

  final cropped = img.copyCrop(
    decoded,
    x: cropX,
    y: cropY,
    width: cropSize,
    height: cropSize,
  );

  final output = hasAlpha
      ? img.encodePng(cropped)
      : img.encodeJpg(cropped, quality: 92);
  return Uint8List.fromList(output);
}

class _AvatarCropResult {
  const _AvatarCropResult({required this.fileData, required this.fileName});

  final Uint8List fileData;
  final String fileName;
}

class _AvatarSourceMeta {
  const _AvatarSourceMeta({
    required this.width,
    required this.height,
    required this.hasAlpha,
  });

  final int width;
  final int height;
  final bool hasAlpha;
}

class _EditableAvatarButton extends StatefulWidget {
  const _EditableAvatarButton({
    required this.controller,
    required this.avatarUrl,
    required this.canEdit,
    required this.radius,
    required this.placeholder,
    required this.width,
    required this.height,
  });

  final UserPageController controller;
  final String avatarUrl;
  final bool canEdit;
  final double radius;
  final String placeholder;
  final double width;
  final double height;

  @override
  State<_EditableAvatarButton> createState() => _EditableAvatarButtonState();
}

class _EditableAvatarButtonState extends State<_EditableAvatarButton> {
  bool _hovered = false;

  Future<void> _pickAndEditAvatar() async {
    if (!widget.canEdit || widget.controller.isAvatarUploading.value) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    try {
      final picked = result.files.single;
      final fileData = picked.bytes;
      if (fileData == null || fileData.isEmpty) {
        throw StateError('empty file data');
      }
      if (!mounted) {
        return;
      }

      final cropResult = await showDialog<_AvatarCropResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            _AvatarCropDialog(fileData: fileData, fileName: picked.name),
      );

      if (!mounted || cropResult == null) {
        return;
      }

      final ok = await widget.controller.uploadAvatarBytes(
        fileData: cropResult.fileData,
        fileName: cropResult.fileName,
      );
      if (!mounted) {
        return;
      }

      if (ok) {
        SnackbarUtils.showSuccess(msg: l10n.userAvatarUploadSuccess);
      } else {
        SnackbarUtils.showError(msg: l10n.userAvatarUploadFailed);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      SnackbarUtils.showError(msg: l10n.userAvatarSelectFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = _isDesktopPlatform();

    return MouseRegion(
      onEnter: (_) {
        if (!desktop || !widget.canEdit) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!desktop || !widget.canEdit) return;
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.canEdit ? _pickAndEditAvatar : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AvatarWidget(
                avatarUrl: widget.avatarUrl,
                radius: widget.radius,
                placeholder: widget.placeholder,
                width: widget.width,
                height: widget.height,
              ),
              if (widget.canEdit)
                Obx(() {
                  final uploading = widget.controller.isAvatarUploading.value;
                  final showOverlay = uploading || (desktop && _hovered);
                  return IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: showOverlay ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.42),
                        ),
                        child: Center(
                          child: uploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                  ),
                                )
                              : const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCropDialog extends StatefulWidget {
  const _AvatarCropDialog({required this.fileData, required this.fileName});

  final Uint8List fileData;
  final String fileName;

  @override
  State<_AvatarCropDialog> createState() => _AvatarCropDialogState();
}

class _AvatarCropDialogState extends State<_AvatarCropDialog> {
  final TransformationController _transformController =
      TransformationController();
  _AvatarSourceMeta? _sourceMeta;
  double? _viewportSize;
  double? _baseScale;
  Size? _childSize;
  bool _submitting = false;

  bool get _ready =>
      _sourceMeta != null &&
      _viewportSize != null &&
      _baseScale != null &&
      _childSize != null;

  @override
  void initState() {
    super.initState();
    final decoded = img.decodeImage(widget.fileData);
    if (decoded != null) {
      _sourceMeta = _AvatarSourceMeta(
        width: decoded.width,
        height: decoded.height,
        hasAlpha: decoded.hasAlpha,
      );
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _initializeViewport(double viewportSize) {
    final sourceMeta = _sourceMeta;
    if (sourceMeta == null) {
      return;
    }

    final baseScale = math.max(
      viewportSize / sourceMeta.width,
      viewportSize / sourceMeta.height,
    );
    final childSize = Size(
      sourceMeta.width * baseScale,
      sourceMeta.height * baseScale,
    );

    final matrix = Matrix4.identity()
      ..setTranslationRaw(
        (viewportSize - childSize.width) / 2,
        (viewportSize - childSize.height) / 2,
        0,
      );

    _viewportSize = viewportSize;
    _baseScale = baseScale;
    _childSize = childSize;
    _transformController.value = matrix;
  }

  void _clampTransform() {
    if (!_ready) {
      return;
    }

    final viewportSize = _viewportSize!;
    final childSize = _childSize!;
    final current = _transformController.value.clone();
    final scale = current.getMaxScaleOnAxis().clamp(1.0, 4.0);

    final scaledWidth = childSize.width * scale;
    final scaledHeight = childSize.height * scale;

    double tx = current.storage[12];
    double ty = current.storage[13];

    if (scaledWidth <= viewportSize) {
      tx = (viewportSize - scaledWidth) / 2;
    } else {
      tx = tx.clamp(viewportSize - scaledWidth, 0.0);
    }

    if (scaledHeight <= viewportSize) {
      ty = (viewportSize - scaledHeight) / 2;
    } else {
      ty = ty.clamp(viewportSize - scaledHeight, 0.0);
    }

    final matrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setTranslationRaw(tx, ty, 0);
    _transformController.value = matrix;
  }

  String _buildOutputFileName(bool hasAlpha) {
    final original = widget.fileName;
    final dotIndex = original.lastIndexOf('.');
    final baseName = dotIndex > 0 ? original.substring(0, dotIndex) : original;
    final ext = hasAlpha ? 'png' : 'jpg';
    return '${baseName.isEmpty ? 'avatar' : baseName}_crop.$ext';
  }

  Future<void> _submitCrop() async {
    if (!_ready || _submitting) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final sourceMeta = _sourceMeta!;
    _clampTransform();

    final viewportSize = _viewportSize!;
    final baseScale = _baseScale!;
    final matrix = _transformController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.storage[12];
    final ty = matrix.storage[13];
    final sourceScale = baseScale * scale;

    final srcX = (-tx) / sourceScale;
    final srcY = (-ty) / sourceScale;
    final srcSize = viewportSize / sourceScale;

    setState(() => _submitting = true);
    try {
      final cropped = await compute(_cropAvatarBytes, <String, Object>{
        'fileData': widget.fileData,
        'srcX': srcX,
        'srcY': srcY,
        'srcSize': srcSize,
        'hasAlpha': sourceMeta.hasAlpha,
      });

      if (!mounted) {
        return;
      }
      if (cropped.isEmpty) {
        SnackbarUtils.showError(msg: l10n.userAvatarInvalidImage);
        return;
      }

      Navigator.of(context).pop(
        _AvatarCropResult(
          fileData: cropped,
          fileName: _buildOutputFileName(sourceMeta.hasAlpha),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      SnackbarUtils.showError(msg: l10n.userAvatarUploadFailed);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sourceMeta = _sourceMeta;
    final screenSize = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: math.min(screenSize.height * 0.8, 620),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.userAvatarCropTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cropSize = math
                          .min(constraints.maxWidth, constraints.maxHeight)
                          .clamp(220.0, 360.0);
                      final previewCacheSize =
                          (cropSize *
                                  MediaQuery.devicePixelRatioOf(context) *
                                  1.8)
                              .round();

                      if (sourceMeta == null) {
                        return Center(child: Text(l10n.userAvatarInvalidImage));
                      }

                      if (_viewportSize != cropSize) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _initializeViewport(cropSize));
                        });
                      }

                      final childSize = _childSize;
                      if (childSize == null) {
                        return SizedBox.square(
                          dimension: cropSize,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return SizedBox.square(
                        dimension: cropSize,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                InteractiveViewer(
                                  transformationController:
                                      _transformController,
                                  constrained: false,
                                  boundaryMargin: const EdgeInsets.all(
                                    double.infinity,
                                  ),
                                  minScale: 1,
                                  maxScale: 4,
                                  clipBehavior: Clip.none,
                                  onInteractionEnd: (_) => _clampTransform(),
                                  child: SizedBox(
                                    width: childSize.width,
                                    height: childSize.height,
                                    child: Image.memory(
                                      widget.fileData,
                                      fit: BoxFit.fill,
                                      cacheWidth: previewCacheSize,
                                      cacheHeight: previewCacheSize,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: CustomPaint(
                                    painter: _AvatarCropOverlayPainter(
                                      borderColor: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.userAvatarCropHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.commonActionCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submitting ? null : _submitCrop,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.userAvatarCropUpload),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCropOverlayPainter extends CustomPainter {
  const _AvatarCropOverlayPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor.withValues(alpha: 0.92);
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.35);

    canvas.drawRect(rect.deflate(1), borderPaint);

    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    for (int i = 1; i < 3; i++) {
      final dx = thirdW * i;
      final dy = thirdH * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarCropOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor;
  }
}
