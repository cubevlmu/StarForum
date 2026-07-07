import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
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

  DiscussionInfo? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'discussions') return null;
    return resourceItem(resource, document);
  }

  Discussions documentList(JsonApiDocument document) {
    return Discussions(
      list: [
        for (final resource in documentResources(document))
          if (resource.type == 'discussions') resourceItem(resource, document),
      ],
      links: Links(
        first: linkValue(document, 'first') ?? '',
        prev: linkValue(document, 'prev') ?? '',
        next: linkValue(document, 'next') ?? '',
      ),
    );
  }

  DiscussionInfo resourceItem(
    JsonApiResource resource,
    JsonApiDocument document,
  ) {
    final attrs = JsonReader(resource.attributes);
    final users = <int, UserInfo>{};
    final posts = <int, PostInfo>{};

    for (final userResource in document.index.ofType('users')) {
      users[userResource.intId] = userMapper.resourceItem(
        userResource,
        document: document,
      );
    }
    for (final postResource in document.index.ofType('posts')) {
      final post = postMapper.resourceItem(postResource);
      post.user = users[post.userId];
      posts[post.id] = post;
    }

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
    return DiscussionInfo(
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
        for (final tag in document.includedMany(resource, 'tags'))
          tagMapper.resourceItem(tag),
      ],
      subscription,
    );
  }

  UserInfo _userOrPlaceholder(Map<int, UserInfo> users, String? rawId) {
    final id = int.tryParse(rawId ?? '') ?? -1;
    return users[id] ??
        (id > 0 ? UserInfo.placeholder(id) : UserInfo.deletedUser);
  }
}
