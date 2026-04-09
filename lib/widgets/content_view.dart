/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/cached_network_image.dart';
import 'package:star_forum/widgets/image_view.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum ContentLikeType { kUnknown, kLink, kUserMention, kReply }

class ContentView extends StatefulWidget {
  final String content;
  static double textSize = 16;
  static const int _syncParseThreshold = 1500;
  static const int _cacheLimit = 24;
  static final LinkedHashMap<String, List<_ParsedBlock>> _parsedCache =
      LinkedHashMap<String, List<_ParsedBlock>>();

  const ContentView({super.key, required this.content});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  late Future<List<_ParsedBlock>> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = _loadContent(widget.content);
  }

  @override
  void didUpdateWidget(covariant ContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _contentFuture = _loadContent(widget.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoadingContent = widget.content == l10n.postContentLoadingHtml;

    return RepaintBoundary(
      child: FutureBuilder<List<_ParsedBlock>>(
        future: _contentFuture,
        builder: (context, snapshot) {
          final child = switch (snapshot.connectionState) {
            ConnectionState.done when snapshot.hasData => _ContentBlocksView(
              blocks: snapshot.data!,
              rawContent: widget.content,
            ),
            _ => _ContentLoadingPlaceholder(compact: !isLoadingContent),
          };

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: child,
          );
        },
      ),
    );
  }

  Future<List<_ParsedBlock>> _loadContent(String content) {
    final cached = _readCache(content);
    if (cached != null) {
      return SynchronousFuture<List<_ParsedBlock>>(cached);
    }

    if (content.length <= ContentView._syncParseThreshold) {
      final parsed = _decodeParsedBlocks(_parseContentPayload(content));
      _writeCache(content, parsed);
      return SynchronousFuture<List<_ParsedBlock>>(parsed);
    }

    return compute(_parseContentPayload, content).then((payload) {
      final parsed = _decodeParsedBlocks(payload);
      _writeCache(content, parsed);
      return parsed;
    });
  }

  List<_ParsedBlock>? _readCache(String content) {
    final cached = ContentView._parsedCache.remove(content);
    if (cached != null) {
      ContentView._parsedCache[content] = cached;
    }
    return cached;
  }

  void _writeCache(String content, List<_ParsedBlock> blocks) {
    if (content.length > 50000) {
      return;
    }
    ContentView._parsedCache.remove(content);
    ContentView._parsedCache[content] = blocks;
    while (ContentView._parsedCache.length > ContentView._cacheLimit) {
      ContentView._parsedCache.remove(ContentView._parsedCache.keys.first);
    }
  }
}

class _ContentBlocksView extends StatelessWidget {
  const _ContentBlocksView({required this.blocks, required this.rawContent});

  final List<_ParsedBlock> blocks;
  final String rawContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(rawContent.hashCode),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [for (final block in blocks) _ContentBlockWidget(block: block)],
    );
  }
}

class _ContentBlockWidget extends StatelessWidget {
  const _ContentBlockWidget({required this.block});

  final _ParsedBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyMedium?.color;

    switch (block.type) {
      case _BlockType.paragraph:
      case _BlockType.div:
      case _BlockType.unknown:
        return _contentPadding(
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: textColor,
              ),
              children: _buildInlineSpans(context, block.inline),
            ),
          ),
        );
      case _BlockType.heading:
        return _contentPadding(
          Text(
            block.text,
            style: TextStyle(
              fontSize: block.headingSize,
              fontWeight: FontWeight.bold,
              color: block.headingSize <= 12 ? theme.dividerColor : null,
            ),
          ),
        );
      case _BlockType.divider:
        return _contentPadding(Divider(height: 1, color: theme.dividerColor));
      case _BlockType.quote:
        return Padding(
          padding: const EdgeInsets.all(5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border(
                left: BorderSide(color: scheme.outlineVariant, width: 3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: ContentView.textSize,
                    color: textColor,
                  ),
                  children: _buildInlineSpans(context, block.inline),
                ),
              ),
            ),
          ),
        );
      case _BlockType.code:
        return _contentPadding(
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  block.text,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        );
      case _BlockType.list:
        return _contentPadding(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < block.items.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    block.ordered
                        ? '${index + 1}. ${block.items[index]}'
                        : '• ${block.items[index]}',
                    style: TextStyle(
                      fontSize: ContentView.textSize,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _BlockType.empty:
        return const SizedBox.shrink();
    }
  }

  List<InlineSpan> _buildInlineSpans(
    BuildContext context,
    List<_InlinePart> parts,
  ) {
    final spans = <InlineSpan>[];
    final scheme = Theme.of(context).colorScheme;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;

    for (final part in parts) {
      switch (part.type) {
        case _InlineType.text:
          spans.add(
            TextSpan(
              text: part.text,
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: bodyColor,
                fontWeight: part.bold ? FontWeight.bold : FontWeight.normal,
                fontStyle: part.italic ? FontStyle.italic : FontStyle.normal,
                decoration: part.strike
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                backgroundColor: part.code
                    ? scheme.surfaceContainerHighest
                    : null,
              ),
            ),
          );
        case _InlineType.lineBreak:
          spans.add(const TextSpan(text: '\n'));
        case _InlineType.link:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _ContentInlineLink(
                text: part.text,
                href: part.href,
                type: _contentLikeTypeFromClassName(part.className),
              ),
            ),
          );
        case _InlineType.image:
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _ContentInlineImage(url: part.href),
            ),
          );
      }
    }

    return spans;
  }

  Widget _contentPadding(Widget child) {
    return Padding(padding: const EdgeInsets.all(5), child: child);
  }
}

class _ContentInlineLink extends StatelessWidget {
  const _ContentInlineLink({
    required this.text,
    required this.href,
    required this.type,
  });

  final String text;
  final String href;
  final ContentLikeType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;

    final Widget child = switch (type) {
      ContentLikeType.kUserMention => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      ContentLikeType.kReply => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.reply_rounded,
            size: ContentView.textSize,
            color: colorScheme.primary,
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      _ => Text(
        text,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          color: bodyColor,
        ),
      ),
    };

    return InkWell(onTap: () => _onLinkTap(context, href, type), child: child);
  }

  void _onLinkTap(BuildContext context, String target, ContentLikeType type) {
    try {
      switch (type) {
        case ContentLikeType.kLink:
          launchUrlString(target);
          break;
        case ContentLikeType.kUserMention:
          final id = int.parse(target.replaceAll("${Api.getBaseUrl}/u/", ""));
          openUserAdaptive(context, id);
          break;
        case ContentLikeType.kReply:
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(context)!.commonNoticeWorkInProgress,
          );
          break;
        default:
          break;
      }
    } catch (e, st) {
      LogUtil.errorE("[ContentView] Failed to open link: $target", e, st);
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(context)!.commonNoticeOpenFailed,
      );
    }
  }
}

class _ContentInlineImage extends StatelessWidget {
  const _ContentInlineImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final maxWidth = MediaQuery.sizeOf(context).width.clamp(180.0, 420.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => _previewImage(context),
        borderRadius: BorderRadius.circular(12),
        child: Hero(
          tag: "img:$url",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              cacheManager: CacheUtils.contentCacheManager,
              width: maxWidth,
              fit: BoxFit.cover,
              cacheWidth: (maxWidth * dpr).round(),
              placeholder: () => const _ImageLoadingPlaceholder(),
              errorWidget: () => const _ImageErrorPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }

  void _previewImage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImagePreviewWidget(url: url)));
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SkeletonShimmer(
        duration: const Duration(milliseconds: 1380),
        highlightStrength: 0.16,
        builder: (context, palette) {
          return DecoratedBox(decoration: palette.block(radius: 12));
        },
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _ContentLoadingPlaceholder extends StatefulWidget {
  const _ContentLoadingPlaceholder({required this.compact});

  final bool compact;

  @override
  State<_ContentLoadingPlaceholder> createState() =>
      _ContentLoadingPlaceholderState();
}

class _ContentLoadingPlaceholderState extends State<_ContentLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineCount = widget.compact ? 2 : 4;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final shimmerColor = Color.lerp(
          colorScheme.surfaceContainerHighest,
          colorScheme.surfaceContainerLow,
          (_controller.value - 0.5).abs() * -2 + 1,
        )!;

        return Column(
          key: ValueKey('loading:${widget.compact}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lineCount; i++)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  5,
                  i == 0 ? 5 : 7,
                  5,
                  i == lineCount - 1 ? 5 : 0,
                ),
                child: FractionallySizedBox(
                  widthFactor: i == lineCount - 1 ? 0.56 : 1,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _BlockType {
  paragraph,
  heading,
  divider,
  quote,
  code,
  list,
  div,
  unknown,
  empty,
}

enum _InlineType { text, link, image, lineBreak }

class _ParsedBlock {
  const _ParsedBlock({
    required this.type,
    this.text = '',
    this.inline = const <_InlinePart>[],
    this.items = const <String>[],
    this.ordered = false,
    this.headingSize = 16,
  });

  final _BlockType type;
  final String text;
  final List<_InlinePart> inline;
  final List<String> items;
  final bool ordered;
  final double headingSize;
}

class _InlinePart {
  const _InlinePart({
    required this.type,
    this.text = '',
    this.href = '',
    this.className = '',
    this.bold = false,
    this.italic = false,
    this.strike = false,
    this.code = false,
  });

  final _InlineType type;
  final String text;
  final String href;
  final String className;
  final bool bold;
  final bool italic;
  final bool strike;
  final bool code;
}

List<Map<String, Object?>> _parseContentPayload(String content) {
  final doc = parse(content);
  final children = doc.body?.children ?? const <dom.Element>[];

  return [for (final element in children) _parseBlockElement(element)];
}

Map<String, Object?> _parseBlockElement(dom.Element element) {
  switch (element.localName) {
    case 'p':
      return {
        'type': 'paragraph',
        'inline': _parseInlineNodes(element.nodes, const _InlineStyle()),
      };
    case 'div':
      return {
        'type': 'div',
        'inline': _parseInlineNodes(element.nodes, const _InlineStyle()),
      };
    case 'blockquote':
      return {
        'type': 'quote',
        'inline': _parseInlineNodes(element.nodes, const _InlineStyle()),
      };
    case 'pre':
      return {'type': 'code', 'text': element.text};
    case 'ol':
    case 'ul':
      return {
        'type': 'list',
        'ordered': element.localName == 'ol',
        'items': [for (final item in element.children) item.text],
      };
    case 'hr':
      return {'type': 'divider'};
    case 'br':
    case 'script':
      return {'type': 'empty'};
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      return {
        'type': 'heading',
        'text': element.text,
        'size': switch (element.localName) {
          'h1' => 22.0,
          'h2' => 20.0,
          'h3' => ContentView.textSize,
          'h4' => 16.0,
          'h5' => 14.0,
          _ => 12.0,
        },
      };
    default:
      return {
        'type': 'unknown',
        'inline': _parseInlineNodes(element.nodes, const _InlineStyle()),
      };
  }
}

List<Map<String, Object?>> _parseInlineNodes(
  dom.NodeList nodes,
  _InlineStyle style,
) {
  final parts = <Map<String, Object?>>[];

  for (final node in nodes) {
    if (node is dom.Text) {
      if (node.text.isEmpty) {
        continue;
      }
      parts.add({
        'type': 'text',
        'text': node.text,
        'bold': style.bold,
        'italic': style.italic,
        'strike': style.strike,
        'code': style.code,
      });
      continue;
    }

    if (node is! dom.Element) {
      continue;
    }

    if (node.localName == 'br') {
      parts.add({'type': 'lineBreak'});
      continue;
    }

    if (node.localName == 'a') {
      final href = node.attributes['href'] ?? '';
      final img = node.children.where((element) => element.localName == 'img');
      if (img.isNotEmpty) {
        final src = img.first.attributes['src'] ?? '';
        if (src.isNotEmpty) {
          parts.add({'type': 'image', 'href': src});
        }
      } else {
        parts.add({
          'type': 'link',
          'text': node.text,
          'href': href,
          'className': node.className,
        });
      }
      continue;
    }

    parts.addAll(
      _parseInlineNodes(
        node.nodes,
        style.merge(
          bold: node.localName == 'b' || node.localName == 'strong',
          italic: node.localName == 'em' || node.localName == 'i',
          strike: node.localName == 's' || node.localName == 'del',
          code: node.localName == 'code',
        ),
      ),
    );
  }

  return _mergeAdjacentTextParts(parts);
}

List<Map<String, Object?>> _mergeAdjacentTextParts(
  List<Map<String, Object?>> parts,
) {
  if (parts.length < 2) {
    return parts;
  }

  final merged = <Map<String, Object?>>[];

  for (final part in parts) {
    if (merged.isEmpty) {
      merged.add(Map<String, Object?>.from(part));
      continue;
    }

    final last = merged.last;
    final canMerge =
        last['type'] == 'text' &&
        part['type'] == 'text' &&
        last['bold'] == part['bold'] &&
        last['italic'] == part['italic'] &&
        last['strike'] == part['strike'] &&
        last['code'] == part['code'];

    if (canMerge) {
      last['text'] = '${last['text']}${part['text']}';
      continue;
    }

    merged.add(Map<String, Object?>.from(part));
  }

  return merged;
}

List<_ParsedBlock> _decodeParsedBlocks(List<Map<String, Object?>> payload) {
  return [for (final block in payload) _decodeParsedBlock(block)];
}

_ParsedBlock _decodeParsedBlock(Map<String, Object?> map) {
  final type = switch (map['type']) {
    'paragraph' => _BlockType.paragraph,
    'heading' => _BlockType.heading,
    'divider' => _BlockType.divider,
    'quote' => _BlockType.quote,
    'code' => _BlockType.code,
    'list' => _BlockType.list,
    'div' => _BlockType.div,
    'empty' => _BlockType.empty,
    _ => _BlockType.unknown,
  };

  final inlinePayload = (map['inline'] as List<Object?>?) ?? const [];
  final itemPayload = (map['items'] as List<Object?>?) ?? const [];

  return _ParsedBlock(
    type: type,
    text: map['text'] as String? ?? '',
    inline: [
      for (final item in inlinePayload)
        _decodeInlinePart(Map<String, Object?>.from(item! as Map)),
    ],
    items: [for (final item in itemPayload) item.toString()],
    ordered: map['ordered'] as bool? ?? false,
    headingSize: (map['size'] as num?)?.toDouble() ?? ContentView.textSize,
  );
}

_InlinePart _decodeInlinePart(Map<String, Object?> map) {
  final type = switch (map['type']) {
    'text' => _InlineType.text,
    'link' => _InlineType.link,
    'image' => _InlineType.image,
    _ => _InlineType.lineBreak,
  };

  return _InlinePart(
    type: type,
    text: map['text'] as String? ?? '',
    href: map['href'] as String? ?? '',
    className: map['className'] as String? ?? '',
    bold: map['bold'] as bool? ?? false,
    italic: map['italic'] as bool? ?? false,
    strike: map['strike'] as bool? ?? false,
    code: map['code'] as bool? ?? false,
  );
}

class _InlineStyle {
  const _InlineStyle({
    this.bold = false,
    this.italic = false,
    this.strike = false,
    this.code = false,
  });

  final bool bold;
  final bool italic;
  final bool strike;
  final bool code;

  _InlineStyle merge({
    bool bold = false,
    bool italic = false,
    bool strike = false,
    bool code = false,
  }) {
    return _InlineStyle(
      bold: this.bold || bold,
      italic: this.italic || italic,
      strike: this.strike || strike,
      code: this.code || code,
    );
  }
}

ContentLikeType _contentLikeTypeFromClassName(String className) {
  switch (className) {
    case 'UserMention':
      return ContentLikeType.kUserMention;
    case 'PostMention':
      return ContentLikeType.kReply;
    default:
      return ContentLikeType.kLink;
  }
}
