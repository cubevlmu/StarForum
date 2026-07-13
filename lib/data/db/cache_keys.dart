abstract final class CacheResourceType {
  static const discussion = 'discussions';
  static const post = 'posts';
  static const user = 'users';
  static const tag = 'tags';
  static const notification = 'notifications';
}

abstract final class DiscussionCollectionKey {
  static String feed({String sort = '', String? tagSlug}) {
    final normalizedSort = sort.isEmpty ? 'default' : sort;
    final tagPart = tagSlug == null || tagSlug.isEmpty ? 'all' : tagSlug;
    return 'discussion:feed:sort=$normalizedSort:tag=$tagPart';
  }

  static String following(String sort) {
    return 'discussion:following:sort=$sort';
  }

  static String byAuthor(String username) {
    return 'discussion:author:$username';
  }
}

abstract final class UserCollectionKey {
  static String directory(String sort, {int? groupId}) {
    final groupPart = groupId == null || groupId <= 0 ? 'all' : groupId;
    return 'user:directory:sort=$sort:group=$groupPart';
  }
}

abstract final class PostCollectionKey {
  static String byAuthor(String username) => 'post:author:$username';
}
