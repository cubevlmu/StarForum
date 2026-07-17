import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';

import 'mapper_support.dart';
import 'user_mapper.dart';

class PostMapper {
  const PostMapper({this.userMapper = const UserMapper()});

  final UserMapper userMapper;

  PostInfo? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'posts') return null;
    final user = document.includedOne(resource, 'user');
    return resourceItem(
      resource,
      user: user == null ? null : userMapper.resourceItem(user),
    );
  }

  Posts documentList(JsonApiDocument document) {
    final posts = <int, PostInfo>{};
    final users = <int, UserInfo>{};
    final discussions = <int, DiscussionDetail>{};

    for (final user in document.index.ofType('users')) {
      users[user.intId] = userMapper.resourceItem(user, document: document);
    }
    for (final resource in document.index.ofType('discussions')) {
      final attrs = JsonReader(resource.attributes);
      discussions[resource.intId] = DiscussionDetail.fromMapAndId(
        attrs.json,
        resource.intId,
      );
    }
    for (final resource in documentResources(document)) {
      if (resource.type != 'posts') continue;
      final mapped = resourceItem(resource);
      final post = mapped.copyWith(
        user: users[mapped.userId] ?? _placeholderUser(mapped.userId),
      );
      posts[post.id] = post;
    }
    return Posts(posts, users, discussions);
  }

  PostInfo resourceItem(JsonApiResource resource, {UserInfo? user}) {
    final attrs = JsonReader(resource.attributes);
    final contentType = attrs.string('contentType', 'comment');
    final contentHtml = attrs.string('contentHtml');
    return PostInfo(
      resource.intId,
      attrs.string('createdAt'),
      contentHtml,
      attrs.string('editedAt'),
      int.tryParse(resource.relatedId('user') ?? '') ?? -1,
      int.tryParse(resource.relatedId('editedUser') ?? '') ?? -1,
      int.tryParse(resource.relatedId('discussion') ?? '') ?? -1,
      attrs.integer('likesCount', -1),
      number: attrs.integer('number'),
      contentType: contentType,
      isLiked: attrs.boolean('isLiked'),
      user: user,
      event: _event(contentType, attrs, contentHtml),
    );
  }

  PostEvent? _event(String contentType, JsonReader attrs, String contentHtml) {
    final content = JsonReader(attrs.map('content'));
    return switch (contentType) {
      'discussionStickied' => PostEvent.discussionStickyChanged(
        sticky: content.contains('sticky')
            ? content.boolean('sticky')
            : content.contains('isSticky')
            ? content.boolean('isSticky')
            : attrs.boolean('isSticky', true),
      ),
      'discussionStickiest' => PostEvent.discussionStickiestChanged(
        sticky: _stickiestState(content, attrs),
      ),
      'discussionLocked' || 'discussionLock' => PostEvent.discussionLockChanged(
        locked: _lockState(content, attrs),
        sourceType: contentType,
      ),
      'comment' when contentHtml.trim().isEmpty =>
        const PostEvent.commentContentUnavailable(),
      _ when contentType != 'comment' && contentHtml.trim().isEmpty =>
        PostEvent.unsupported(sourceType: contentType),
      _ => null,
    };
  }

  bool _stickiestState(JsonReader content, JsonReader attrs) {
    for (final key in const [
      'stickiest',
      'isStickiest',
      'sticky',
      'isSticky',
      'enabled',
    ]) {
      if (content.contains(key)) return content.boolean(key);
      if (attrs.contains(key)) return attrs.boolean(key);
    }
    return true;
  }

  bool _lockState(JsonReader content, JsonReader attrs) {
    for (final key in const ['locked', 'isLocked', 'enabled']) {
      if (content.contains(key)) return content.boolean(key);
      if (attrs.contains(key)) return attrs.boolean(key);
    }
    return true;
  }

  UserInfo? _placeholderUser(int userId) {
    return userId > 0 ? UserInfo.placeholder(userId) : null;
  }
}
