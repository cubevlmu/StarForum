import 'flarum_query.dart';

class DiscussionQueries {
  static const discussionFields = [
    'title',
    'createdAt',
    'lastPostedAt',
    'lastPostNumber',
    'commentCount',
    'participantCount',
    'viewCount',
    'views',
    'viewsCount',
    'isSticky',
    'isStickiest',
    'subscription',
    'user',
    'lastPostedUser',
    'tags',
    'firstPost',
  ];

  static const userFields = [
    'username',
    'displayName',
    'avatarUrl',
    'avatarSrcset',
  ];

  static const tagFields = [
    'name',
    'description',
    'slug',
    'color',
    'icon',
    'discussionCount',
    'position',
    'lastPostedAt',
    'isChild',
    'canStartDiscussion',
    'canAddToDiscussion',
    'parent',
  ];

  static FlarumQuery feed({
    required String sort,
    required int offset,
    required int limit,
    String? tagSlug,
  }) {
    final query = FlarumQuery()
        .page(offset: offset, limit: limit)
        .sort(sort)
        .include(['user', 'lastPostedUser', 'tags', 'firstPost'])
        .fields('discussions', discussionFields)
        .fields('posts', PostQueries.fields)
        .fields('users', userFields)
        .fields('tags', tagFields);
    if (tagSlug != null && tagSlug.isNotEmpty) {
      query.filter('tag', tagSlug);
    }
    return query;
  }

  static FlarumQuery detailHeader() => FlarumQuery()
      .include(['user', 'lastPostedUser', 'tags'])
      .fields('discussions', discussionFields)
      .fields('users', userFields)
      .fields('tags', tagFields);

  static FlarumQuery search({
    required String key,
    required int offset,
    required int limit,
    String? tagSlug,
  }) {
    final value = tagSlug == null || tagSlug.isEmpty
        ? key
        : '${key.trim()} tag:$tagSlug'.trim();
    return feed(sort: '', offset: offset, limit: limit).search(value);
  }
}

class PostQueries {
  static const fields = [
    'number',
    'createdAt',
    'contentType',
    'content',
    'contentHtml',
    'editedAt',
    'likesCount',
    'isLiked',
    'user',
    'discussion',
  ];
}
