/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/view.dart';
import 'package:forum/utils/html_utils.dart';
import 'package:forum/widgets/avatar.dart';

class PostCard extends StatelessWidget {
  final DiscussionItem item;

  const PostCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final realText = htmlToPlainText(item.excerpt);
    final needMoreSing = realText.length >= 80;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostPage(item: item)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  AvatarWidget(
                    avatarUrl: item.authorAvatar,
                    radius: 22,
                    placeholder: item.authorName[0],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              item.lastPostedAt.toString(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 47,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsetsGeometry.only(left: 55),
                  child: Text(
                    "$realText${needMoreSing? "....." : ""}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                item.likeCount == -1
                    ? Row()
                    : Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.likeCount} 点赞',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.commentCount == 0 ? 0 : (item.commentCount - 1)} 回复',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.viewCount} 阅读',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
          // ),
        ),
      ),
    );
  }
}
