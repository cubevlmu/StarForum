/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/widgets/cached_network_image.dart';
import 'package:forum/widgets/image_view.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum ContentLikeType { kUnknown, kLink, kUserMention, kReply }

class ContentView extends StatefulWidget {
  final String content;
  static double textSize = 16;

  const ContentView({super.key, required this.content});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  late dom.Document _doc;

  @override
  void initState() {
    super.initState();
    _doc = parse(widget.content);
  }

  @override
  void didUpdateWidget(covariant ContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _doc = parse(widget.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = _doc.body?.children ?? const <dom.Element>[];

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [for (final e in children) _buildBlock(context, e)],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, dom.Element element) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyMedium?.color;

    switch (element.localName) {
      case "p":
        return _padding(
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: textColor,
              ),
              children: _buildInline(context, element.nodes),
            ),
          ),
        );

      case "h1":
      case "h2":
      case "h3":
      case "h4":
      case "h5":
      case "h6":
        final size = switch (element.localName) {
          "h1" => 22.0,
          "h2" => 20.0,
          "h3" => ContentView.textSize,
          "h4" => 16.0,
          "h5" => 14.0,
          _ => 12.0,
        };
        return _padding(
          Text(
            element.text,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: element.localName == "h6" ? theme.dividerColor : null,
            ),
          ),
        );

      case "hr":
        return _padding(Divider(height: 1, color: theme.dividerColor));

      case "br":
        return const SizedBox();

      case "blockquote":
        return Card(
          elevation: 0,
          color: theme.scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: ContentView.textSize,
                  color: textColor,
                ),
                children: _buildInline(context, element.nodes),
              ),
            ),
          ),
        );

      case "pre":
        return _padding(
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  element.text,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        );

      case "ol":
      case "ul":
        final isOrdered = element.localName == "ol";
        int index = 1;
        return _padding(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in element.children)
                Text(
                  isOrdered ? "${index++}. ${c.text}" : "• ${c.text}",
                  style: TextStyle(
                    fontSize: ContentView.textSize,
                    color: textColor,
                  ),
                ),
            ],
          ),
        );

      case "script":
        return const SizedBox();

      case "div":
        return _padding(
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: textColor,
              ),
              children: _buildInline(context, element.nodes),
            ),
          ),
        );

      default:
        if (kDebugMode) {
          LogUtil.debug("UnimplementedBlock:${element.localName}");
        }
        return _padding(
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: textColor,
              ),
              children: _buildInline(context, element.nodes),
            ),
          ),
        );
    }
  }

  List<InlineSpan> _buildInline(BuildContext context, dom.NodeList nodes) {
    final spans = <InlineSpan>[];
    _walkInline(context, nodes, spans);
    return spans;
  }

  void _walkInline(
    BuildContext context,
    dom.NodeList nodes,
    List<InlineSpan> spans,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyMedium?.color;

    for (final n in nodes) {
      if (n is dom.Element && n.localName == 'a') {
        _handleAnchor(context, n, spans);
        continue;
      }

      if (n.hasChildNodes()) {
        _walkInline(context, n.nodes, spans);
        continue;
      }

      final parent = n.parent?.localName ?? "";

      switch (parent) {
        case "b":
        case "strong":
          spans.add(
            TextSpan(
              text: n.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          break;

        case "em":
          spans.add(
            TextSpan(
              text: n.text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
          break;

        case "code":
          spans.add(
            TextSpan(
              text: n.text,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          );
          break;

        case "s":
        case "del":
          spans.add(
            TextSpan(
              text: n.text,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          );
          break;

        case "br":
          spans.add(const TextSpan(text: "\n"));
          break;

        default:
          spans.add(
            TextSpan(
              text: n.text,
              style: TextStyle(
                fontSize: ContentView.textSize,
                color: textColor,
              ),
            ),
          );
          break;
      }
    }
  }

  void _handleAnchor(
    BuildContext context,
    dom.Element element,
    List<InlineSpan> spans,
  ) {
    final href = element.attributes["href"] ?? "";
    final className = element.className;
    final text = element.text;

    if (element.children.isNotEmpty &&
        element.children.first.localName == "img") {
      final url = element.children.first.attributes["src"];
      if (url != null && url.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: () => _previewImage(context, url),
              child: Hero(
                tag: "img:$url",
                child: CachedNetworkImage(
                  imageUrl: url,
                  cacheManager: CacheUtils.contentCacheManager,
                ),
              ),
            ),
          ),
        );
      }
      return;
    }

    ContentLikeType type = ContentLikeType.kLink;
    Widget child;

    switch (className) {
      case "UserMention":
        type = ContentLikeType.kUserMention;
        child = Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
        break;

      case "PostMention":
        type = ContentLikeType.kReply;
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.reply,
              size: ContentView.textSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
        break;

      default:
        child = Text(
          text,
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        );
        break;
    }

    spans.add(
      WidgetSpan(
        child: InkWell(
          onTap: () => _onLinkTap(context, href, type),
          child: child,
        ),
      ),
    );
  }

  Widget _padding(Widget child) =>
      Padding(padding: const EdgeInsets.all(5), child: child);

  void _previewImage(BuildContext context, String url) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImagePreviewWidget(url: url)));
  }

  void _onLinkTap(BuildContext context, String s, ContentLikeType type) {
    try {
      switch (type) {
        case ContentLikeType.kLink:
          launchUrlString(s);
          break;
        case ContentLikeType.kUserMention:
          final id = int.parse(s.replaceAll("${ApiConstants.apiBase}/u/", ""));
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => UserPage(userId: id)));
          break;
        case ContentLikeType.kReply:
          SnackbarUtils.showMessage(msg: "功能开发中");
          break;
        default:
          break;
      }
    } catch (e, st) {
      LogUtil.errorE("[ContentView] Failed to open link: $s", e, st);
      SnackbarUtils.showMessage(msg: "链接打开失败");
    }
  }
}
