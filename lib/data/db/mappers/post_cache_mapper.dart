import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/posts.dart';

extension DbPostCacheMapper on DbPost {
  PostInfo toPostInfo() {
    return PostInfo(
      id,
      createdAt?.toIso8601String() ?? '',
      contentHtml,
      editedAt?.toIso8601String() ?? '',
      userId ?? -1,
      -1,
      discussionId,
      likesCount,
      number: number,
      contentType: contentType,
      isLiked: isLiked,
      event:
          _decodeEvent(contentType, rawJson) ??
          _fallbackEvent(contentType, contentHtml),
    );
  }
}

extension PostInfoCacheMapper on PostInfo {
  String get fingerprint {
    return [
      id,
      editedAt,
      createdAt,
      likes,
      isLiked,
      contentHtml.length,
      event?.type.name,
      event?.sourceType,
      event?.sticky,
    ].join('|');
  }

  DbPostsCompanion toDbPost() {
    return DbPostsCompanion.insert(
      id: Value(id),
      discussionId: discussion,
      number: Value(number),
      userId: Value(userId > 0 ? userId : null),
      contentType: Value(contentType),
      contentHtml: Value(contentHtml),
      createdAt: Value(DateTime.tryParse(createdAt)),
      editedAt: Value(DateTime.tryParse(editedAt)),
      likesCount: Value(likes),
      isLiked: Value(isLiked),
      fingerprint: Value(fingerprint),
      rawJson: Value(_encodeEvent(event)),
      syncedAt: DateTime.now(),
      deletedAt: const Value(null),
    );
  }
}

String? _encodeEvent(PostEvent? event) {
  if (event == null) return null;
  return jsonEncode({
    'eventType': event.type.name,
    'sourceType': event.sourceType,
    'sticky': event.sticky,
  });
}

PostEvent? _decodeEvent(String contentType, String? rawJson) {
  if (rawJson == null) return null;
  try {
    final json = asJsonMap(jsonDecode(rawJson));
    return switch (json['eventType']) {
      'discussionStickyChanged' => PostEvent.discussionStickyChanged(
        sticky: JsonReader(json).boolean('sticky'),
      ),
      'discussionStickiestChanged' => PostEvent.discussionStickiestChanged(
        sticky: JsonReader(json).boolean('sticky'),
      ),
      'unsupported' => PostEvent.unsupported(
        sourceType: JsonReader(json).string('sourceType', contentType),
      ),
      _ => null,
    };
  } on FormatException {
    return null;
  }
}

PostEvent? _fallbackEvent(String contentType, String contentHtml) {
  if (contentType == 'discussionStickied') {
    return const PostEvent.discussionStickyChanged(sticky: true);
  }
  if (contentType == 'discussionStickiest') {
    return const PostEvent.discussionStickiestChanged(sticky: true);
  }
  if (contentType != 'comment' && contentHtml.trim().isEmpty) {
    return PostEvent.unsupported(sourceType: contentType);
  }
  return null;
}
