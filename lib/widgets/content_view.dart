/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/widgets/cached_network_image.dart';
import 'package:forum/widgets/image_view.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

typedef OnLinkTap = void Function(String link);

class ContentView extends StatelessWidget {
  final String content;
  final OnLinkTap? onLinkTap;
  static double textSize = 16;

  const ContentView({super.key, this.onLinkTap, required this.content});

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    parse(content).body?.children.forEach((element) {
      widgets.add(getWidget(context, element));
    });
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  List<InlineSpan> getRichTextSpan(
    BuildContext context,
    dom.NodeList nodes, {
    List<InlineSpan>? span,
  }) {
    final scheme = Theme.of(context).colorScheme;

    span ??= <InlineSpan>[];
    for (var n in nodes) {
      if (n is dom.Element && n.localName == 'a') {
        final n1 = n.firstChild;
        if (n1 is dom.Element && n1.localName == "img") {
          String? url = n1.attributes["src"];

          if (url != null && url.isNotEmpty) {
            span.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle, // 解决图片与文字对齐问题

                child: contentPadding(
                  Center(
                    child: InkWell(
                      child: Hero(
                        tag: url,

                        child: CachedNetworkImage(
                          imageUrl: url,
                          scale: 2.15,
                          cacheManager: CacheUtils.contentCacheManager,
                        ),
                      ),

                      onTap: () {
                        // 这里建议调用你 getWidget 里的那个图片预览逻辑

                        _previewImage(context, url);
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          getRichTextSpan(context, n.nodes, span: span);
        }
        continue;
      }

      if (n.hasChildNodes()) {
        getRichTextSpan(context, n.nodes, span: span);
      } else {
        switch (n.parent?.localName ?? "") {
          case "div":
          case "span":
            getRichTextSpan(context, n.nodes).forEach((s) {
              span!.add(s);
            });
            break;
          case "p":
            if (n.text?.contains("img") ?? false) {
              String? url = n.attributes["src"];
              String k = UniqueKey().toString();
              span.add(
                WidgetSpan(
                  child: contentPadding(
                    Center(
                      child: InkWell(
                        child: Material(
                          child: Hero(
                            tag: k,
                            child: CachedNetworkImage(
                              imageUrl: url ?? "",
                              cacheManager: CacheUtils.contentCacheManager,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return CachedNetworkImage(
                                  imageUrl: n.attributes["src"] ?? "",
                                  cacheManager: CacheUtils.contentCacheManager,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            } else {
              span.add(
                TextSpan(
                  text: "${n.text}",
                  style: TextStyle(
                    fontSize: textSize,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }
            break;
          case "a":
            // PATCH FIX:
            if (n.firstChild != null) {
              log(n.firstChild.toString());
            }

            switch (n.parent?.className ?? "") {
              case "UserMention":
                span.add(
                  WidgetSpan(
                    child: InkWell(
                      child: Text(
                        "${n.text}",
                        style: TextStyle(
                          fontSize: textSize,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        onLinkTap?.call(n.parent!.attributes["href"]!);
                      },
                    ),
                  ),
                );
                break;
              case "PostMention":
                span.add(
                  WidgetSpan(
                    child: InkWell(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.reply,
                              color: Theme.of(context).colorScheme.primary,
                              size: textSize,
                            ),
                          ),
                          Text(
                            "${n.text}",
                            style: TextStyle(
                              fontSize: textSize,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        onLinkTap?.call(n.parent!.attributes["href"]!);
                      },
                    ),
                  ),
                );
                break;
              case "github-issue-link":
                span.add(
                  WidgetSpan(
                    child: InkWell(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 2),
                            child: Icon(
                              Icons.link,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            "${n.text}",
                            style: TextStyle(
                              fontSize: textSize,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        onLinkTap?.call(n.parent!.attributes["href"]!);
                      },
                    ),
                  ),
                );
                break;
              default:
                span.add(
                  WidgetSpan(
                    child: InkWell(
                      child: Text(
                        "${n.text}",
                        style: TextStyle(
                          fontSize: textSize,
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        onLinkTap?.call(n.parent!.attributes["href"]!);
                      },
                    ),
                  ),
                );
                if (n.parent!.className != "") {
                  log("UnimplementedUrlClass:${n.parent!.className}");
                }
                break;
            }
            break;
          case "b":
          case "strong":
            span.add(
              TextSpan(
                text: "${n.text}",
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            break;
          case "br":
            span.add(WidgetSpan(child: Text("\n")));
            break;
          case "em":
            span.add(
              TextSpan(
                text: n.text,
                style: TextStyle(
                  fontSize: textSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
            break;
          case "code":
            span.add(
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
            span.add(
              TextSpan(
                text: "${n.text}",
                style: TextStyle(
                  fontSize: textSize,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            );
            break;
          default:
            log("UnimplementedNode:${n.parent?.localName}");
            span.add(
              WidgetSpan(
                child: Text(
                  "${n.text}",
                  style: TextStyle(
                    fontSize: textSize,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            );
            break;
        }
      }
    }
    return span;
  }

  Widget getWidget(BuildContext context, dom.Element element) {
    final scheme = Theme.of(context).colorScheme;

    switch (element.localName) {
      case "p":
        return contentPadding(
          RichText(
            text: TextSpan(
              children: getRichTextSpan(context, element.nodes),
              style: TextStyle(
                fontSize: textSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      case "h1":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        );
      case "h2":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      case "h3":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
          ),
        );
      case "h4":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      case "h5":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      case "h6":
        return contentPadding(
          Text(
            element.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).dividerColor,
            ),
          ),
        );
      case "hr":
        return contentPadding(
          Divider(height: 1, color: Theme.of(context).dividerColor),
        );
      case "br":
        return contentPadding(SizedBox());
      case "details":
        return contentPadding(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                //TODO primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                "title_show_details",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    var e = element.outerHtml.replaceAll("<details", "<p");
                    return AlertDialog(
                      title: Text("title_details"),
                      content: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(e), //, onLinkTap: onLinkTap),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("close"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      case "ol":
        List<Widget> list = [];
        int index = 1;
        for (var c in element.children) {
          list.add(
            Text(
              "$index.${c.text}",
              style: TextStyle(
                fontSize: textSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
          index++;
        }
        return Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list,
            ),
          ),
        );
      case "ul":
        List<Widget> list = [];
        for (var c in element.children) {
          list.add(
            Text(
              "• ${c.text}",
              style: TextStyle(
                fontSize: textSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list,
            ),
          ),
        );
      case "blockquote":
        Color background = Theme.of(
          context,
        ).scaffoldBackgroundColor; //HexColor.fromHex("#e7edf3");
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 0,
            color: background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                  children: getRichTextSpan(context, element.nodes),
                  style: TextStyle(
                    fontSize: textSize,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        );
      case "pre":
        Color backGroundColor = scheme.surfaceContainerHighest;
        return contentPadding(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              child: Card(
                elevation: 0,
                color: backGroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: NotificationListener(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        element.text,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      // onNotification: (ScrollNotification notification) {
                      //   return true;
                      // },
                    ),
                  ),
                ),
                // onTap: () async {
                //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                //       overlays: []);
                //   SystemChrome.setPreferredOrientations([
                //     DeviceOrientation.landscapeRight,
                //     DeviceOrientation.landscapeRight,
                //   ]);
                //   await Navigator.push(context,
                //       MaterialPageRoute(builder: (BuildContext context) {
                //     return CodeView(element.text);
                //   }));
                //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                //       overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                //   SystemChrome.setPreferredOrientations([
                //     DeviceOrientation.portraitUp,
                //   ]);
                // },
              ),
            ),
          ),
        );
      case "div":
        return Text(element.outerHtml.replaceAll("<div", "<p"));
      case "script":
        return SizedBox();
      default:
        return contentPadding(
          RichText(
            text: TextSpan(
              children: getRichTextSpan(context, element.nodes),
              style: TextStyle(
                fontSize: textSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      // return contentPadding(contentPadding(SizedBox(
      //   width: MediaQuery.of(context).size.width,
      //   child: RaisedButton(
      //       color: Colors.red,
      //       child: Text(
      //         "UnimplementedNode",
      //         style: TextStyle(color: Colors.white),
      //       ),
      //       onPressed: () {
      //         showDialog(
      //             context: context,
      //             builder: (BuildContext context) {
      //               return AlertDialog(
      //                 title: Text("Source"),
      //                 content: Text(element.outerHtml),
      //               );
      //             });
      //       }),
      // )));
    }
  }

  Widget contentPadding(Widget child) {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
      child: child,
    );
  }

  // 建议抽离的预览方法
  void _previewImage(BuildContext context, String url) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImagePreviewWidget(url: url)));
  }
}
