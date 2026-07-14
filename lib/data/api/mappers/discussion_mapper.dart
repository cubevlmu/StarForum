import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/model/users.dart';

import 'mapper_support.dart';
import 'post_mapper.dart';
import 'tag_mapper.dart';
import 'user_mapper.dart';

class DiscussionMapper {
  const DiscussionMapper({
    this.userMapper = const UserMapper(),
    this.postMapper = const PostMapper(),
    this.tagMapper = const TagMapper(),
  });

  final UserMapper userMapper;
  final PostMapper postMapper;
  final TagMapper tagMapper;

  DiscussionDetail? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'discussions') return null;
    final included = _mapIncluded(document);
    return resourceItem(
      resource,
      document,
      includedUsers: included.users,
      includedPosts: included.posts,
      includedTags: included.tags,
    );
  }

  List<DiscussionDetail> documentList(JsonApiDocument document) {
    final included = _mapIncluded(document);
    return [
      for (final resource in documentResources(document))
        if (resource.type == 'discussions')
          resourceItem(
            resource,
            document,
            includedUsers: included.users,
            includedPosts: included.posts,
            includedTags: included.tags,
          ),
    ];
  }

  DiscussionDetail resourceItem(
    JsonApiResource resource,
    JsonApiDocument document, {
    Map<int, UserInfo>? includedUsers,
    Map<int, PostInfo>? includedPosts,
    Map<int, TagInfo>? includedTags,
  }) {
    final attrs = JsonReader(resource.attributes);
    final mapped =
        includedUsers == null || includedPosts == null || includedTags == null
        ? _mapIncluded(document)
        : null;
    final users = includedUsers ?? mapped!.users;
    final posts = includedPosts ?? mapped!.posts;
    final tags = includedTags ?? mapped!.tags;

    final firstPostId =
        int.tryParse(resource.relatedId('firstPost') ?? '') ?? -1;
    final postIds = resource
        .relatedIds('posts')
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    if (firstPostId >= 0 && !postIds.contains(firstPostId)) {
      postIds.insert(0, firstPostId);
    }
    final subscription = switch (resource.attributes['subscription']) {
      final int value => value,
      'ignore' => 2,
      'follow' => 1,
      _ => 0,
    };
    final rawViews =
        resource.attributes['viewCount'] ?? resource.attributes['views'];
    return DiscussionDetail(
      resource.id,
      attrs.string('title'),
      attrs.integer('commentCount'),
      attrs.integer('participantCount'),
      JsonValue.asInt(rawViews),
      attrs.dateTime('createdAt'),
      attrs.dateTime('lastPostedAt'),
      attrs.integer('lastPostNumber'),
      firstPostId,
      _userOrPlaceholder(users, resource.relatedId('user')),
      _userOrPlaceholder(users, resource.relatedId('lastPostedUser')),
      posts[firstPostId],
      postIds,
      {
        for (final id in postIds)
          if (posts[id] != null) id: posts[id]!,
      },
      users,
      [
        for (final id in resource.relatedIds('tags').map(int.tryParse))
          if (id != null && tags[id] != null) tags[id]!,
      ],
      subscription,
      isSticky: attrs.boolean('isSticky'),
      authorRelationshipLoaded: resource.relationships.containsKey('user'),
    );
  }

  ({Map<int, UserInfo> users, Map<int, PostInfo> posts, Map<int, TagInfo> tags})
  _mapIncluded(JsonApiDocument document) {
    final users = <int, UserInfo>{};
    for (final resource in document.index.ofType('users')) {
      users[resource.intId] = userMapper.resourceItem(
        resource,
        document: document,
      );
    }

    final posts = <int, PostInfo>{};
    for (final resource in document.index.ofType('posts')) {
      final mapped = postMapper.resourceItem(resource);
      final post = mapped.copyWith(user: users[mapped.userId]);
      posts[post.id] = post;
    }

    final tags = <int, TagInfo>{};
    for (final resource in document.index.ofType('tags')) {
      tags[resource.intId] = tagMapper.resourceItem(resource);
    }
    return (users: users, posts: posts, tags: tags);
  }

  UserInfo? _userOrPlaceholder(Map<int, UserInfo> users, String? rawId) {
    final id = int.tryParse(rawId ?? '');
    if (id == null || id <= 0) return null;
    return users[id] ?? UserInfo.placeholder(id);
  }
}
