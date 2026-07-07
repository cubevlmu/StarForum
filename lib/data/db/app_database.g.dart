// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DbDiscussionsTable extends DbDiscussions
    with TableInfo<$DbDiscussionsTable, DbDiscussion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDiscussionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantCountMeta = const VerificationMeta(
    'participantCount',
  );
  @override
  late final GeneratedColumn<int> participantCount = GeneratedColumn<int>(
    'participant_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewCountMeta = const VerificationMeta(
    'viewCount',
  );
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
    'view_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _authorAvatarMeta = const VerificationMeta(
    'authorAvatar',
  );
  @override
  late final GeneratedColumn<String> authorAvatar = GeneratedColumn<String>(
    'author_avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPostedAtMeta = const VerificationMeta(
    'lastPostedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPostedAt = GeneratedColumn<DateTime>(
    'last_posted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPostNumberMeta = const VerificationMeta(
    'lastPostNumber',
  );
  @override
  late final GeneratedColumn<int> lastPostNumber = GeneratedColumn<int>(
    'last_post_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPostIdMeta = const VerificationMeta(
    'firstPostId',
  );
  @override
  late final GeneratedColumn<int> firstPostId = GeneratedColumn<int>(
    'first_post_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _posterIdMeta = const VerificationMeta(
    'posterId',
  );
  @override
  late final GeneratedColumn<int> posterId = GeneratedColumn<int>(
    'poster_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscriptionMeta = const VerificationMeta(
    'subscription',
  );
  @override
  late final GeneratedColumn<int> subscription = GeneratedColumn<int>(
    'subscription',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    slug,
    commentCount,
    participantCount,
    viewCount,
    likeCount,
    authorName,
    authorAvatar,
    createdAt,
    lastPostedAt,
    lastSeenAt,
    syncedAt,
    deletedAt,
    lastPostNumber,
    firstPostId,
    posterId,
    subscription,
    fingerprint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_discussions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDiscussion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commentCountMeta);
    }
    if (data.containsKey('participant_count')) {
      context.handle(
        _participantCountMeta,
        participantCount.isAcceptableOrUnknown(
          data['participant_count']!,
          _participantCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantCountMeta);
    }
    if (data.containsKey('view_count')) {
      context.handle(
        _viewCountMeta,
        viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('author_avatar')) {
      context.handle(
        _authorAvatarMeta,
        authorAvatar.isAcceptableOrUnknown(
          data['author_avatar']!,
          _authorAvatarMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_posted_at')) {
      context.handle(
        _lastPostedAtMeta,
        lastPostedAt.isAcceptableOrUnknown(
          data['last_posted_at']!,
          _lastPostedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_post_number')) {
      context.handle(
        _lastPostNumberMeta,
        lastPostNumber.isAcceptableOrUnknown(
          data['last_post_number']!,
          _lastPostNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPostNumberMeta);
    }
    if (data.containsKey('first_post_id')) {
      context.handle(
        _firstPostIdMeta,
        firstPostId.isAcceptableOrUnknown(
          data['first_post_id']!,
          _firstPostIdMeta,
        ),
      );
    }
    if (data.containsKey('poster_id')) {
      context.handle(
        _posterIdMeta,
        posterId.isAcceptableOrUnknown(data['poster_id']!, _posterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_posterIdMeta);
    }
    if (data.containsKey('subscription')) {
      context.handle(
        _subscriptionMeta,
        subscription.isAcceptableOrUnknown(
          data['subscription']!,
          _subscriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriptionMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDiscussion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDiscussion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      )!,
      participantCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_count'],
      )!,
      viewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_count'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      authorAvatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_avatar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastPostedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_posted_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      lastPostNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_post_number'],
      )!,
      firstPostId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_post_id'],
      )!,
      posterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}poster_id'],
      )!,
      subscription: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subscription'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
    );
  }

  @override
  $DbDiscussionsTable createAlias(String alias) {
    return $DbDiscussionsTable(attachedDatabase, alias);
  }
}

class DbDiscussion extends DataClass implements Insertable<DbDiscussion> {
  final String id;
  final String title;
  final String slug;
  final int commentCount;
  final int participantCount;
  final int viewCount;
  final int likeCount;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final DateTime? lastPostedAt;
  final DateTime lastSeenAt;
  final DateTime? syncedAt;
  final DateTime? deletedAt;
  final int lastPostNumber;
  final int firstPostId;
  final int posterId;
  final int subscription;
  final String fingerprint;
  const DbDiscussion({
    required this.id,
    required this.title,
    required this.slug,
    required this.commentCount,
    required this.participantCount,
    required this.viewCount,
    required this.likeCount,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    this.lastPostedAt,
    required this.lastSeenAt,
    this.syncedAt,
    this.deletedAt,
    required this.lastPostNumber,
    required this.firstPostId,
    required this.posterId,
    required this.subscription,
    required this.fingerprint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['slug'] = Variable<String>(slug);
    map['comment_count'] = Variable<int>(commentCount);
    map['participant_count'] = Variable<int>(participantCount);
    map['view_count'] = Variable<int>(viewCount);
    map['like_count'] = Variable<int>(likeCount);
    map['author_name'] = Variable<String>(authorName);
    map['author_avatar'] = Variable<String>(authorAvatar);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastPostedAt != null) {
      map['last_posted_at'] = Variable<DateTime>(lastPostedAt);
    }
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['last_post_number'] = Variable<int>(lastPostNumber);
    map['first_post_id'] = Variable<int>(firstPostId);
    map['poster_id'] = Variable<int>(posterId);
    map['subscription'] = Variable<int>(subscription);
    map['fingerprint'] = Variable<String>(fingerprint);
    return map;
  }

  DbDiscussionsCompanion toCompanion(bool nullToAbsent) {
    return DbDiscussionsCompanion(
      id: Value(id),
      title: Value(title),
      slug: Value(slug),
      commentCount: Value(commentCount),
      participantCount: Value(participantCount),
      viewCount: Value(viewCount),
      likeCount: Value(likeCount),
      authorName: Value(authorName),
      authorAvatar: Value(authorAvatar),
      createdAt: Value(createdAt),
      lastPostedAt: lastPostedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostedAt),
      lastSeenAt: Value(lastSeenAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastPostNumber: Value(lastPostNumber),
      firstPostId: Value(firstPostId),
      posterId: Value(posterId),
      subscription: Value(subscription),
      fingerprint: Value(fingerprint),
    );
  }

  factory DbDiscussion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDiscussion(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      slug: serializer.fromJson<String>(json['slug']),
      commentCount: serializer.fromJson<int>(json['commentCount']),
      participantCount: serializer.fromJson<int>(json['participantCount']),
      viewCount: serializer.fromJson<int>(json['viewCount']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      authorName: serializer.fromJson<String>(json['authorName']),
      authorAvatar: serializer.fromJson<String>(json['authorAvatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastPostedAt: serializer.fromJson<DateTime?>(json['lastPostedAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastPostNumber: serializer.fromJson<int>(json['lastPostNumber']),
      firstPostId: serializer.fromJson<int>(json['firstPostId']),
      posterId: serializer.fromJson<int>(json['posterId']),
      subscription: serializer.fromJson<int>(json['subscription']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'slug': serializer.toJson<String>(slug),
      'commentCount': serializer.toJson<int>(commentCount),
      'participantCount': serializer.toJson<int>(participantCount),
      'viewCount': serializer.toJson<int>(viewCount),
      'likeCount': serializer.toJson<int>(likeCount),
      'authorName': serializer.toJson<String>(authorName),
      'authorAvatar': serializer.toJson<String>(authorAvatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastPostedAt': serializer.toJson<DateTime?>(lastPostedAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastPostNumber': serializer.toJson<int>(lastPostNumber),
      'firstPostId': serializer.toJson<int>(firstPostId),
      'posterId': serializer.toJson<int>(posterId),
      'subscription': serializer.toJson<int>(subscription),
      'fingerprint': serializer.toJson<String>(fingerprint),
    };
  }

  DbDiscussion copyWith({
    String? id,
    String? title,
    String? slug,
    int? commentCount,
    int? participantCount,
    int? viewCount,
    int? likeCount,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    Value<DateTime?> lastPostedAt = const Value.absent(),
    DateTime? lastSeenAt,
    Value<DateTime?> syncedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    int? lastPostNumber,
    int? firstPostId,
    int? posterId,
    int? subscription,
    String? fingerprint,
  }) => DbDiscussion(
    id: id ?? this.id,
    title: title ?? this.title,
    slug: slug ?? this.slug,
    commentCount: commentCount ?? this.commentCount,
    participantCount: participantCount ?? this.participantCount,
    viewCount: viewCount ?? this.viewCount,
    likeCount: likeCount ?? this.likeCount,
    authorName: authorName ?? this.authorName,
    authorAvatar: authorAvatar ?? this.authorAvatar,
    createdAt: createdAt ?? this.createdAt,
    lastPostedAt: lastPostedAt.present ? lastPostedAt.value : this.lastPostedAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lastPostNumber: lastPostNumber ?? this.lastPostNumber,
    firstPostId: firstPostId ?? this.firstPostId,
    posterId: posterId ?? this.posterId,
    subscription: subscription ?? this.subscription,
    fingerprint: fingerprint ?? this.fingerprint,
  );
  DbDiscussion copyWithCompanion(DbDiscussionsCompanion data) {
    return DbDiscussion(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      slug: data.slug.present ? data.slug.value : this.slug,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      participantCount: data.participantCount.present
          ? data.participantCount.value
          : this.participantCount,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      authorAvatar: data.authorAvatar.present
          ? data.authorAvatar.value
          : this.authorAvatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPostedAt: data.lastPostedAt.present
          ? data.lastPostedAt.value
          : this.lastPostedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastPostNumber: data.lastPostNumber.present
          ? data.lastPostNumber.value
          : this.lastPostNumber,
      firstPostId: data.firstPostId.present
          ? data.firstPostId.value
          : this.firstPostId,
      posterId: data.posterId.present ? data.posterId.value : this.posterId,
      subscription: data.subscription.present
          ? data.subscription.value
          : this.subscription,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('commentCount: $commentCount, ')
          ..write('participantCount: $participantCount, ')
          ..write('viewCount: $viewCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('authorName: $authorName, ')
          ..write('authorAvatar: $authorAvatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPostedAt: $lastPostedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastPostNumber: $lastPostNumber, ')
          ..write('firstPostId: $firstPostId, ')
          ..write('posterId: $posterId, ')
          ..write('subscription: $subscription, ')
          ..write('fingerprint: $fingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    slug,
    commentCount,
    participantCount,
    viewCount,
    likeCount,
    authorName,
    authorAvatar,
    createdAt,
    lastPostedAt,
    lastSeenAt,
    syncedAt,
    deletedAt,
    lastPostNumber,
    firstPostId,
    posterId,
    subscription,
    fingerprint,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDiscussion &&
          other.id == this.id &&
          other.title == this.title &&
          other.slug == this.slug &&
          other.commentCount == this.commentCount &&
          other.participantCount == this.participantCount &&
          other.viewCount == this.viewCount &&
          other.likeCount == this.likeCount &&
          other.authorName == this.authorName &&
          other.authorAvatar == this.authorAvatar &&
          other.createdAt == this.createdAt &&
          other.lastPostedAt == this.lastPostedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.syncedAt == this.syncedAt &&
          other.deletedAt == this.deletedAt &&
          other.lastPostNumber == this.lastPostNumber &&
          other.firstPostId == this.firstPostId &&
          other.posterId == this.posterId &&
          other.subscription == this.subscription &&
          other.fingerprint == this.fingerprint);
}

class DbDiscussionsCompanion extends UpdateCompanion<DbDiscussion> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> slug;
  final Value<int> commentCount;
  final Value<int> participantCount;
  final Value<int> viewCount;
  final Value<int> likeCount;
  final Value<String> authorName;
  final Value<String> authorAvatar;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastPostedAt;
  final Value<DateTime> lastSeenAt;
  final Value<DateTime?> syncedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> lastPostNumber;
  final Value<int> firstPostId;
  final Value<int> posterId;
  final Value<int> subscription;
  final Value<String> fingerprint;
  final Value<int> rowid;
  const DbDiscussionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.slug = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.participantCount = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorAvatar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPostedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastPostNumber = const Value.absent(),
    this.firstPostId = const Value.absent(),
    this.posterId = const Value.absent(),
    this.subscription = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbDiscussionsCompanion.insert({
    required String id,
    required String title,
    required String slug,
    required int commentCount,
    required int participantCount,
    this.viewCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorAvatar = const Value.absent(),
    required DateTime createdAt,
    this.lastPostedAt = const Value.absent(),
    required DateTime lastSeenAt,
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int lastPostNumber,
    this.firstPostId = const Value.absent(),
    required int posterId,
    required int subscription,
    this.fingerprint = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       slug = Value(slug),
       commentCount = Value(commentCount),
       participantCount = Value(participantCount),
       createdAt = Value(createdAt),
       lastSeenAt = Value(lastSeenAt),
       lastPostNumber = Value(lastPostNumber),
       posterId = Value(posterId),
       subscription = Value(subscription);
  static Insertable<DbDiscussion> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? slug,
    Expression<int>? commentCount,
    Expression<int>? participantCount,
    Expression<int>? viewCount,
    Expression<int>? likeCount,
    Expression<String>? authorName,
    Expression<String>? authorAvatar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastPostedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? lastPostNumber,
    Expression<int>? firstPostId,
    Expression<int>? posterId,
    Expression<int>? subscription,
    Expression<String>? fingerprint,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (commentCount != null) 'comment_count': commentCount,
      if (participantCount != null) 'participant_count': participantCount,
      if (viewCount != null) 'view_count': viewCount,
      if (likeCount != null) 'like_count': likeCount,
      if (authorName != null) 'author_name': authorName,
      if (authorAvatar != null) 'author_avatar': authorAvatar,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPostedAt != null) 'last_posted_at': lastPostedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastPostNumber != null) 'last_post_number': lastPostNumber,
      if (firstPostId != null) 'first_post_id': firstPostId,
      if (posterId != null) 'poster_id': posterId,
      if (subscription != null) 'subscription': subscription,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbDiscussionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? slug,
    Value<int>? commentCount,
    Value<int>? participantCount,
    Value<int>? viewCount,
    Value<int>? likeCount,
    Value<String>? authorName,
    Value<String>? authorAvatar,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastPostedAt,
    Value<DateTime>? lastSeenAt,
    Value<DateTime?>? syncedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? lastPostNumber,
    Value<int>? firstPostId,
    Value<int>? posterId,
    Value<int>? subscription,
    Value<String>? fingerprint,
    Value<int>? rowid,
  }) {
    return DbDiscussionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      commentCount: commentCount ?? this.commentCount,
      participantCount: participantCount ?? this.participantCount,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      lastPostedAt: lastPostedAt ?? this.lastPostedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      lastPostNumber: lastPostNumber ?? this.lastPostNumber,
      firstPostId: firstPostId ?? this.firstPostId,
      posterId: posterId ?? this.posterId,
      subscription: subscription ?? this.subscription,
      fingerprint: fingerprint ?? this.fingerprint,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (participantCount.present) {
      map['participant_count'] = Variable<int>(participantCount.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (authorAvatar.present) {
      map['author_avatar'] = Variable<String>(authorAvatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPostedAt.present) {
      map['last_posted_at'] = Variable<DateTime>(lastPostedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastPostNumber.present) {
      map['last_post_number'] = Variable<int>(lastPostNumber.value);
    }
    if (firstPostId.present) {
      map['first_post_id'] = Variable<int>(firstPostId.value);
    }
    if (posterId.present) {
      map['poster_id'] = Variable<int>(posterId.value);
    }
    if (subscription.present) {
      map['subscription'] = Variable<int>(subscription.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('commentCount: $commentCount, ')
          ..write('participantCount: $participantCount, ')
          ..write('viewCount: $viewCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('authorName: $authorName, ')
          ..write('authorAvatar: $authorAvatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPostedAt: $lastPostedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastPostNumber: $lastPostNumber, ')
          ..write('firstPostId: $firstPostId, ')
          ..write('posterId: $posterId, ')
          ..write('subscription: $subscription, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbFirstPostsTable extends DbFirstPosts
    with TableInfo<$DbFirstPostsTable, DbFirstPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbFirstPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _discussionIdMeta = const VerificationMeta(
    'discussionId',
  );
  @override
  late final GeneratedColumn<String> discussionId = GeneratedColumn<String>(
    'discussion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    discussionId,
    content,
    updatedAt,
    likeCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_first_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFirstPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('discussion_id')) {
      context.handle(
        _discussionIdMeta,
        discussionId.isAcceptableOrUnknown(
          data['discussion_id']!,
          _discussionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discussionIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    } else if (isInserting) {
      context.missing(_likeCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {discussionId};
  @override
  DbFirstPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFirstPost(
      discussionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discussion_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
    );
  }

  @override
  $DbFirstPostsTable createAlias(String alias) {
    return $DbFirstPostsTable(attachedDatabase, alias);
  }
}

class DbFirstPost extends DataClass implements Insertable<DbFirstPost> {
  final String discussionId;

  /// 原始内容（Markdown / HTML）
  final String content;

  /// firstPost.updatedAt
  final DateTime updatedAt;

  /// firstPost.likeCount
  final int likeCount;
  const DbFirstPost({
    required this.discussionId,
    required this.content,
    required this.updatedAt,
    required this.likeCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['discussion_id'] = Variable<String>(discussionId);
    map['content'] = Variable<String>(content);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['like_count'] = Variable<int>(likeCount);
    return map;
  }

  DbFirstPostsCompanion toCompanion(bool nullToAbsent) {
    return DbFirstPostsCompanion(
      discussionId: Value(discussionId),
      content: Value(content),
      updatedAt: Value(updatedAt),
      likeCount: Value(likeCount),
    );
  }

  factory DbFirstPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFirstPost(
      discussionId: serializer.fromJson<String>(json['discussionId']),
      content: serializer.fromJson<String>(json['content']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'discussionId': serializer.toJson<String>(discussionId),
      'content': serializer.toJson<String>(content),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'likeCount': serializer.toJson<int>(likeCount),
    };
  }

  DbFirstPost copyWith({
    String? discussionId,
    String? content,
    DateTime? updatedAt,
    int? likeCount,
  }) => DbFirstPost(
    discussionId: discussionId ?? this.discussionId,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
    likeCount: likeCount ?? this.likeCount,
  );
  DbFirstPost copyWithCompanion(DbFirstPostsCompanion data) {
    return DbFirstPost(
      discussionId: data.discussionId.present
          ? data.discussionId.value
          : this.discussionId,
      content: data.content.present ? data.content.value : this.content,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFirstPost(')
          ..write('discussionId: $discussionId, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('likeCount: $likeCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(discussionId, content, updatedAt, likeCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFirstPost &&
          other.discussionId == this.discussionId &&
          other.content == this.content &&
          other.updatedAt == this.updatedAt &&
          other.likeCount == this.likeCount);
}

class DbFirstPostsCompanion extends UpdateCompanion<DbFirstPost> {
  final Value<String> discussionId;
  final Value<String> content;
  final Value<DateTime> updatedAt;
  final Value<int> likeCount;
  final Value<int> rowid;
  const DbFirstPostsCompanion({
    this.discussionId = const Value.absent(),
    this.content = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbFirstPostsCompanion.insert({
    required String discussionId,
    required String content,
    required DateTime updatedAt,
    required int likeCount,
    this.rowid = const Value.absent(),
  }) : discussionId = Value(discussionId),
       content = Value(content),
       updatedAt = Value(updatedAt),
       likeCount = Value(likeCount);
  static Insertable<DbFirstPost> custom({
    Expression<String>? discussionId,
    Expression<String>? content,
    Expression<DateTime>? updatedAt,
    Expression<int>? likeCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (discussionId != null) 'discussion_id': discussionId,
      if (content != null) 'content': content,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (likeCount != null) 'like_count': likeCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbFirstPostsCompanion copyWith({
    Value<String>? discussionId,
    Value<String>? content,
    Value<DateTime>? updatedAt,
    Value<int>? likeCount,
    Value<int>? rowid,
  }) {
    return DbFirstPostsCompanion(
      discussionId: discussionId ?? this.discussionId,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (discussionId.present) {
      map['discussion_id'] = Variable<String>(discussionId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbFirstPostsCompanion(')
          ..write('discussionId: $discussionId, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('likeCount: $likeCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbDiscussionExcerptCacheTable extends DbDiscussionExcerptCache
    with
        TableInfo<
          $DbDiscussionExcerptCacheTable,
          DbDiscussionExcerptCacheData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDiscussionExcerptCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _discussionIdMeta = const VerificationMeta(
    'discussionId',
  );
  @override
  late final GeneratedColumn<String> discussionId = GeneratedColumn<String>(
    'discussion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excerptMeta = const VerificationMeta(
    'excerpt',
  );
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
    'excerpt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUpdatedAtMeta = const VerificationMeta(
    'sourceUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sourceUpdatedAt =
      GeneratedColumn<DateTime>(
        'source_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    discussionId,
    excerpt,
    sourceUpdatedAt,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_discussion_excerpt_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDiscussionExcerptCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('discussion_id')) {
      context.handle(
        _discussionIdMeta,
        discussionId.isAcceptableOrUnknown(
          data['discussion_id']!,
          _discussionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discussionIdMeta);
    }
    if (data.containsKey('excerpt')) {
      context.handle(
        _excerptMeta,
        excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta),
      );
    } else if (isInserting) {
      context.missing(_excerptMeta);
    }
    if (data.containsKey('source_updated_at')) {
      context.handle(
        _sourceUpdatedAtMeta,
        sourceUpdatedAt.isAcceptableOrUnknown(
          data['source_updated_at']!,
          _sourceUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceUpdatedAtMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {discussionId};
  @override
  DbDiscussionExcerptCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDiscussionExcerptCacheData(
      discussionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discussion_id'],
      )!,
      excerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excerpt'],
      )!,
      sourceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}source_updated_at'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $DbDiscussionExcerptCacheTable createAlias(String alias) {
    return $DbDiscussionExcerptCacheTable(attachedDatabase, alias);
  }
}

class DbDiscussionExcerptCacheData extends DataClass
    implements Insertable<DbDiscussionExcerptCacheData> {
  final String discussionId;

  /// 已生成的纯文本摘要
  final String excerpt;

  /// 摘要基于的 firstPost.updatedAt
  final DateTime sourceUpdatedAt;

  /// 摘要生成时间（用于粗失效判断）
  final DateTime generatedAt;
  const DbDiscussionExcerptCacheData({
    required this.discussionId,
    required this.excerpt,
    required this.sourceUpdatedAt,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['discussion_id'] = Variable<String>(discussionId);
    map['excerpt'] = Variable<String>(excerpt);
    map['source_updated_at'] = Variable<DateTime>(sourceUpdatedAt);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  DbDiscussionExcerptCacheCompanion toCompanion(bool nullToAbsent) {
    return DbDiscussionExcerptCacheCompanion(
      discussionId: Value(discussionId),
      excerpt: Value(excerpt),
      sourceUpdatedAt: Value(sourceUpdatedAt),
      generatedAt: Value(generatedAt),
    );
  }

  factory DbDiscussionExcerptCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDiscussionExcerptCacheData(
      discussionId: serializer.fromJson<String>(json['discussionId']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      sourceUpdatedAt: serializer.fromJson<DateTime>(json['sourceUpdatedAt']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'discussionId': serializer.toJson<String>(discussionId),
      'excerpt': serializer.toJson<String>(excerpt),
      'sourceUpdatedAt': serializer.toJson<DateTime>(sourceUpdatedAt),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  DbDiscussionExcerptCacheData copyWith({
    String? discussionId,
    String? excerpt,
    DateTime? sourceUpdatedAt,
    DateTime? generatedAt,
  }) => DbDiscussionExcerptCacheData(
    discussionId: discussionId ?? this.discussionId,
    excerpt: excerpt ?? this.excerpt,
    sourceUpdatedAt: sourceUpdatedAt ?? this.sourceUpdatedAt,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  DbDiscussionExcerptCacheData copyWithCompanion(
    DbDiscussionExcerptCacheCompanion data,
  ) {
    return DbDiscussionExcerptCacheData(
      discussionId: data.discussionId.present
          ? data.discussionId.value
          : this.discussionId,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      sourceUpdatedAt: data.sourceUpdatedAt.present
          ? data.sourceUpdatedAt.value
          : this.sourceUpdatedAt,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussionExcerptCacheData(')
          ..write('discussionId: $discussionId, ')
          ..write('excerpt: $excerpt, ')
          ..write('sourceUpdatedAt: $sourceUpdatedAt, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(discussionId, excerpt, sourceUpdatedAt, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDiscussionExcerptCacheData &&
          other.discussionId == this.discussionId &&
          other.excerpt == this.excerpt &&
          other.sourceUpdatedAt == this.sourceUpdatedAt &&
          other.generatedAt == this.generatedAt);
}

class DbDiscussionExcerptCacheCompanion
    extends UpdateCompanion<DbDiscussionExcerptCacheData> {
  final Value<String> discussionId;
  final Value<String> excerpt;
  final Value<DateTime> sourceUpdatedAt;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const DbDiscussionExcerptCacheCompanion({
    this.discussionId = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.sourceUpdatedAt = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbDiscussionExcerptCacheCompanion.insert({
    required String discussionId,
    required String excerpt,
    required DateTime sourceUpdatedAt,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : discussionId = Value(discussionId),
       excerpt = Value(excerpt),
       sourceUpdatedAt = Value(sourceUpdatedAt),
       generatedAt = Value(generatedAt);
  static Insertable<DbDiscussionExcerptCacheData> custom({
    Expression<String>? discussionId,
    Expression<String>? excerpt,
    Expression<DateTime>? sourceUpdatedAt,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (discussionId != null) 'discussion_id': discussionId,
      if (excerpt != null) 'excerpt': excerpt,
      if (sourceUpdatedAt != null) 'source_updated_at': sourceUpdatedAt,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbDiscussionExcerptCacheCompanion copyWith({
    Value<String>? discussionId,
    Value<String>? excerpt,
    Value<DateTime>? sourceUpdatedAt,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return DbDiscussionExcerptCacheCompanion(
      discussionId: discussionId ?? this.discussionId,
      excerpt: excerpt ?? this.excerpt,
      sourceUpdatedAt: sourceUpdatedAt ?? this.sourceUpdatedAt,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (discussionId.present) {
      map['discussion_id'] = Variable<String>(discussionId.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (sourceUpdatedAt.present) {
      map['source_updated_at'] = Variable<DateTime>(sourceUpdatedAt.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussionExcerptCacheCompanion(')
          ..write('discussionId: $discussionId, ')
          ..write('excerpt: $excerpt, ')
          ..write('sourceUpdatedAt: $sourceUpdatedAt, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbCacheCollectionItemsTable extends DbCacheCollectionItems
    with TableInfo<$DbCacheCollectionItemsTable, DbCacheCollectionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbCacheCollectionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionKeyMeta = const VerificationMeta(
    'collectionKey',
  );
  @override
  late final GeneratedColumn<String> collectionKey = GeneratedColumn<String>(
    'collection_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<DateTime> seenAt = GeneratedColumn<DateTime>(
    'seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionKey,
    resourceType,
    resourceId,
    sortIndex,
    fingerprint,
    seenAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_cache_collection_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCacheCollectionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_key')) {
      context.handle(
        _collectionKeyMeta,
        collectionKey.isAcceptableOrUnknown(
          data['collection_key']!,
          _collectionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionKeyMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(
        _seenAtMeta,
        seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_seenAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    collectionKey,
    resourceType,
    resourceId,
  };
  @override
  DbCacheCollectionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCacheCollectionItem(
      collectionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_key'],
      )!,
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $DbCacheCollectionItemsTable createAlias(String alias) {
    return $DbCacheCollectionItemsTable(attachedDatabase, alias);
  }
}

class DbCacheCollectionItem extends DataClass
    implements Insertable<DbCacheCollectionItem> {
  final String collectionKey;
  final String resourceType;
  final String resourceId;
  final int sortIndex;
  final String fingerprint;
  final DateTime seenAt;
  final DateTime syncedAt;
  const DbCacheCollectionItem({
    required this.collectionKey,
    required this.resourceType,
    required this.resourceId,
    required this.sortIndex,
    required this.fingerprint,
    required this.seenAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_key'] = Variable<String>(collectionKey);
    map['resource_type'] = Variable<String>(resourceType);
    map['resource_id'] = Variable<String>(resourceId);
    map['sort_index'] = Variable<int>(sortIndex);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['seen_at'] = Variable<DateTime>(seenAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  DbCacheCollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return DbCacheCollectionItemsCompanion(
      collectionKey: Value(collectionKey),
      resourceType: Value(resourceType),
      resourceId: Value(resourceId),
      sortIndex: Value(sortIndex),
      fingerprint: Value(fingerprint),
      seenAt: Value(seenAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory DbCacheCollectionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCacheCollectionItem(
      collectionKey: serializer.fromJson<String>(json['collectionKey']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      seenAt: serializer.fromJson<DateTime>(json['seenAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionKey': serializer.toJson<String>(collectionKey),
      'resourceType': serializer.toJson<String>(resourceType),
      'resourceId': serializer.toJson<String>(resourceId),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'seenAt': serializer.toJson<DateTime>(seenAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  DbCacheCollectionItem copyWith({
    String? collectionKey,
    String? resourceType,
    String? resourceId,
    int? sortIndex,
    String? fingerprint,
    DateTime? seenAt,
    DateTime? syncedAt,
  }) => DbCacheCollectionItem(
    collectionKey: collectionKey ?? this.collectionKey,
    resourceType: resourceType ?? this.resourceType,
    resourceId: resourceId ?? this.resourceId,
    sortIndex: sortIndex ?? this.sortIndex,
    fingerprint: fingerprint ?? this.fingerprint,
    seenAt: seenAt ?? this.seenAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  DbCacheCollectionItem copyWithCompanion(
    DbCacheCollectionItemsCompanion data,
  ) {
    return DbCacheCollectionItem(
      collectionKey: data.collectionKey.present
          ? data.collectionKey.value
          : this.collectionKey,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCacheCollectionItem(')
          ..write('collectionKey: $collectionKey, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('seenAt: $seenAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    collectionKey,
    resourceType,
    resourceId,
    sortIndex,
    fingerprint,
    seenAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCacheCollectionItem &&
          other.collectionKey == this.collectionKey &&
          other.resourceType == this.resourceType &&
          other.resourceId == this.resourceId &&
          other.sortIndex == this.sortIndex &&
          other.fingerprint == this.fingerprint &&
          other.seenAt == this.seenAt &&
          other.syncedAt == this.syncedAt);
}

class DbCacheCollectionItemsCompanion
    extends UpdateCompanion<DbCacheCollectionItem> {
  final Value<String> collectionKey;
  final Value<String> resourceType;
  final Value<String> resourceId;
  final Value<int> sortIndex;
  final Value<String> fingerprint;
  final Value<DateTime> seenAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const DbCacheCollectionItemsCompanion({
    this.collectionKey = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbCacheCollectionItemsCompanion.insert({
    required String collectionKey,
    required String resourceType,
    required String resourceId,
    required int sortIndex,
    required String fingerprint,
    required DateTime seenAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : collectionKey = Value(collectionKey),
       resourceType = Value(resourceType),
       resourceId = Value(resourceId),
       sortIndex = Value(sortIndex),
       fingerprint = Value(fingerprint),
       seenAt = Value(seenAt),
       syncedAt = Value(syncedAt);
  static Insertable<DbCacheCollectionItem> custom({
    Expression<String>? collectionKey,
    Expression<String>? resourceType,
    Expression<String>? resourceId,
    Expression<int>? sortIndex,
    Expression<String>? fingerprint,
    Expression<DateTime>? seenAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionKey != null) 'collection_key': collectionKey,
      if (resourceType != null) 'resource_type': resourceType,
      if (resourceId != null) 'resource_id': resourceId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (seenAt != null) 'seen_at': seenAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbCacheCollectionItemsCompanion copyWith({
    Value<String>? collectionKey,
    Value<String>? resourceType,
    Value<String>? resourceId,
    Value<int>? sortIndex,
    Value<String>? fingerprint,
    Value<DateTime>? seenAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return DbCacheCollectionItemsCompanion(
      collectionKey: collectionKey ?? this.collectionKey,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      sortIndex: sortIndex ?? this.sortIndex,
      fingerprint: fingerprint ?? this.fingerprint,
      seenAt: seenAt ?? this.seenAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionKey.present) {
      map['collection_key'] = Variable<String>(collectionKey.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<DateTime>(seenAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbCacheCollectionItemsCompanion(')
          ..write('collectionKey: $collectionKey, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('seenAt: $seenAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbSyncStatesTable extends DbSyncStates
    with TableInfo<$DbSyncStatesTable, DbSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionKeyMeta = const VerificationMeta(
    'collectionKey',
  );
  @override
  late final GeneratedColumn<String> collectionKey = GeneratedColumn<String>(
    'collection_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextUrlMeta = const VerificationMeta(
    'nextUrl',
  );
  @override
  late final GeneratedColumn<String> nextUrl = GeneratedColumn<String>(
    'next_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttlSecondsMeta = const VerificationMeta(
    'ttlSeconds',
  );
  @override
  late final GeneratedColumn<int> ttlSeconds = GeneratedColumn<int>(
    'ttl_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionKey,
    nextUrl,
    lastSyncAt,
    lastSuccessAt,
    lastError,
    ttlSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_key')) {
      context.handle(
        _collectionKeyMeta,
        collectionKey.isAcceptableOrUnknown(
          data['collection_key']!,
          _collectionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionKeyMeta);
    }
    if (data.containsKey('next_url')) {
      context.handle(
        _nextUrlMeta,
        nextUrl.isAcceptableOrUnknown(data['next_url']!, _nextUrlMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('ttl_seconds')) {
      context.handle(
        _ttlSecondsMeta,
        ttlSeconds.isAcceptableOrUnknown(data['ttl_seconds']!, _ttlSecondsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionKey};
  @override
  DbSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncState(
      collectionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_key'],
      )!,
      nextUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_url'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      ttlSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_seconds'],
      )!,
    );
  }

  @override
  $DbSyncStatesTable createAlias(String alias) {
    return $DbSyncStatesTable(attachedDatabase, alias);
  }
}

class DbSyncState extends DataClass implements Insertable<DbSyncState> {
  final String collectionKey;
  final String? nextUrl;
  final DateTime? lastSyncAt;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final int ttlSeconds;
  const DbSyncState({
    required this.collectionKey,
    this.nextUrl,
    this.lastSyncAt,
    this.lastSuccessAt,
    this.lastError,
    required this.ttlSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_key'] = Variable<String>(collectionKey);
    if (!nullToAbsent || nextUrl != null) {
      map['next_url'] = Variable<String>(nextUrl);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['ttl_seconds'] = Variable<int>(ttlSeconds);
    return map;
  }

  DbSyncStatesCompanion toCompanion(bool nullToAbsent) {
    return DbSyncStatesCompanion(
      collectionKey: Value(collectionKey),
      nextUrl: nextUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(nextUrl),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      ttlSeconds: Value(ttlSeconds),
    );
  }

  factory DbSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncState(
      collectionKey: serializer.fromJson<String>(json['collectionKey']),
      nextUrl: serializer.fromJson<String?>(json['nextUrl']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      ttlSeconds: serializer.fromJson<int>(json['ttlSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionKey': serializer.toJson<String>(collectionKey),
      'nextUrl': serializer.toJson<String?>(nextUrl),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastError': serializer.toJson<String?>(lastError),
      'ttlSeconds': serializer.toJson<int>(ttlSeconds),
    };
  }

  DbSyncState copyWith({
    String? collectionKey,
    Value<String?> nextUrl = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? ttlSeconds,
  }) => DbSyncState(
    collectionKey: collectionKey ?? this.collectionKey,
    nextUrl: nextUrl.present ? nextUrl.value : this.nextUrl,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    ttlSeconds: ttlSeconds ?? this.ttlSeconds,
  );
  DbSyncState copyWithCompanion(DbSyncStatesCompanion data) {
    return DbSyncState(
      collectionKey: data.collectionKey.present
          ? data.collectionKey.value
          : this.collectionKey,
      nextUrl: data.nextUrl.present ? data.nextUrl.value : this.nextUrl,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      ttlSeconds: data.ttlSeconds.present
          ? data.ttlSeconds.value
          : this.ttlSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncState(')
          ..write('collectionKey: $collectionKey, ')
          ..write('nextUrl: $nextUrl, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('ttlSeconds: $ttlSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    collectionKey,
    nextUrl,
    lastSyncAt,
    lastSuccessAt,
    lastError,
    ttlSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncState &&
          other.collectionKey == this.collectionKey &&
          other.nextUrl == this.nextUrl &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastError == this.lastError &&
          other.ttlSeconds == this.ttlSeconds);
}

class DbSyncStatesCompanion extends UpdateCompanion<DbSyncState> {
  final Value<String> collectionKey;
  final Value<String?> nextUrl;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> lastError;
  final Value<int> ttlSeconds;
  final Value<int> rowid;
  const DbSyncStatesCompanion({
    this.collectionKey = const Value.absent(),
    this.nextUrl = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSyncStatesCompanion.insert({
    required String collectionKey,
    this.nextUrl = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collectionKey = Value(collectionKey);
  static Insertable<DbSyncState> custom({
    Expression<String>? collectionKey,
    Expression<String>? nextUrl,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? lastError,
    Expression<int>? ttlSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionKey != null) 'collection_key': collectionKey,
      if (nextUrl != null) 'next_url': nextUrl,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastError != null) 'last_error': lastError,
      if (ttlSeconds != null) 'ttl_seconds': ttlSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSyncStatesCompanion copyWith({
    Value<String>? collectionKey,
    Value<String?>? nextUrl,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? lastError,
    Value<int>? ttlSeconds,
    Value<int>? rowid,
  }) {
    return DbSyncStatesCompanion(
      collectionKey: collectionKey ?? this.collectionKey,
      nextUrl: nextUrl ?? this.nextUrl,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastError: lastError ?? this.lastError,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionKey.present) {
      map['collection_key'] = Variable<String>(collectionKey.value);
    }
    if (nextUrl.present) {
      map['next_url'] = Variable<String>(nextUrl.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (ttlSeconds.present) {
      map['ttl_seconds'] = Variable<int>(ttlSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncStatesCompanion(')
          ..write('collectionKey: $collectionKey, ')
          ..write('nextUrl: $nextUrl, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('ttlSeconds: $ttlSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbUsersTable extends DbUsers with TableInfo<$DbUsersTable, DbUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avatarSrcsetMeta = const VerificationMeta(
    'avatarSrcset',
  );
  @override
  late final GeneratedColumn<String> avatarSrcset = GeneratedColumn<String>(
    'avatar_srcset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discussionCountMeta = const VerificationMeta(
    'discussionCount',
  );
  @override
  late final GeneratedColumn<int> discussionCount = GeneratedColumn<int>(
    'discussion_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    displayName,
    avatarUrl,
    avatarSrcset,
    joinedAt,
    lastSeenAt,
    discussionCount,
    commentCount,
    email,
    bio,
    rawJson,
    syncedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('avatar_srcset')) {
      context.handle(
        _avatarSrcsetMeta,
        avatarSrcset.isAcceptableOrUnknown(
          data['avatar_srcset']!,
          _avatarSrcsetMeta,
        ),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('discussion_count')) {
      context.handle(
        _discussionCountMeta,
        discussionCount.isAcceptableOrUnknown(
          data['discussion_count']!,
          _discussionCountMeta,
        ),
      );
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      )!,
      avatarSrcset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_srcset'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      discussionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discussion_count'],
      )!,
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DbUsersTable createAlias(String alias) {
    return $DbUsersTable(attachedDatabase, alias);
  }
}

class DbUser extends DataClass implements Insertable<DbUser> {
  final int id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String avatarSrcset;
  final DateTime? joinedAt;
  final DateTime? lastSeenAt;
  final int discussionCount;
  final int commentCount;
  final String email;
  final String bio;
  final String? rawJson;
  final DateTime syncedAt;
  final DateTime? deletedAt;
  const DbUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.avatarSrcset,
    this.joinedAt,
    this.lastSeenAt,
    required this.discussionCount,
    required this.commentCount,
    required this.email,
    required this.bio,
    this.rawJson,
    required this.syncedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    map['avatar_url'] = Variable<String>(avatarUrl);
    map['avatar_srcset'] = Variable<String>(avatarSrcset);
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['discussion_count'] = Variable<int>(discussionCount);
    map['comment_count'] = Variable<int>(commentCount);
    map['email'] = Variable<String>(email);
    map['bio'] = Variable<String>(bio);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DbUsersCompanion toCompanion(bool nullToAbsent) {
    return DbUsersCompanion(
      id: Value(id),
      username: Value(username),
      displayName: Value(displayName),
      avatarUrl: Value(avatarUrl),
      avatarSrcset: Value(avatarSrcset),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      discussionCount: Value(discussionCount),
      commentCount: Value(commentCount),
      email: Value(email),
      bio: Value(bio),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      syncedAt: Value(syncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DbUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUser(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      avatarSrcset: serializer.fromJson<String>(json['avatarSrcset']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      discussionCount: serializer.fromJson<int>(json['discussionCount']),
      commentCount: serializer.fromJson<int>(json['commentCount']),
      email: serializer.fromJson<String>(json['email']),
      bio: serializer.fromJson<String>(json['bio']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'avatarSrcset': serializer.toJson<String>(avatarSrcset),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'discussionCount': serializer.toJson<int>(discussionCount),
      'commentCount': serializer.toJson<int>(commentCount),
      'email': serializer.toJson<String>(email),
      'bio': serializer.toJson<String>(bio),
      'rawJson': serializer.toJson<String?>(rawJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DbUser copyWith({
    int? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? avatarSrcset,
    Value<DateTime?> joinedAt = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    int? discussionCount,
    int? commentCount,
    String? email,
    String? bio,
    Value<String?> rawJson = const Value.absent(),
    DateTime? syncedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DbUser(
    id: id ?? this.id,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    avatarSrcset: avatarSrcset ?? this.avatarSrcset,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    discussionCount: discussionCount ?? this.discussionCount,
    commentCount: commentCount ?? this.commentCount,
    email: email ?? this.email,
    bio: bio ?? this.bio,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    syncedAt: syncedAt ?? this.syncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DbUser copyWithCompanion(DbUsersCompanion data) {
    return DbUser(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      avatarSrcset: data.avatarSrcset.present
          ? data.avatarSrcset.value
          : this.avatarSrcset,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      discussionCount: data.discussionCount.present
          ? data.discussionCount.value
          : this.discussionCount,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      email: data.email.present ? data.email.value : this.email,
      bio: data.bio.present ? data.bio.value : this.bio,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUser(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarSrcset: $avatarSrcset, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('discussionCount: $discussionCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('email: $email, ')
          ..write('bio: $bio, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    displayName,
    avatarUrl,
    avatarSrcset,
    joinedAt,
    lastSeenAt,
    discussionCount,
    commentCount,
    email,
    bio,
    rawJson,
    syncedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUser &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.avatarSrcset == this.avatarSrcset &&
          other.joinedAt == this.joinedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.discussionCount == this.discussionCount &&
          other.commentCount == this.commentCount &&
          other.email == this.email &&
          other.bio == this.bio &&
          other.rawJson == this.rawJson &&
          other.syncedAt == this.syncedAt &&
          other.deletedAt == this.deletedAt);
}

class DbUsersCompanion extends UpdateCompanion<DbUser> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String> avatarUrl;
  final Value<String> avatarSrcset;
  final Value<DateTime?> joinedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<int> discussionCount;
  final Value<int> commentCount;
  final Value<String> email;
  final Value<String> bio;
  final Value<String?> rawJson;
  final Value<DateTime> syncedAt;
  final Value<DateTime?> deletedAt;
  const DbUsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarSrcset = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.discussionCount = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.email = const Value.absent(),
    this.bio = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DbUsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.avatarSrcset = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.discussionCount = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.email = const Value.absent(),
    this.bio = const Value.absent(),
    this.rawJson = const Value.absent(),
    required DateTime syncedAt,
    this.deletedAt = const Value.absent(),
  }) : username = Value(username),
       displayName = Value(displayName),
       syncedAt = Value(syncedAt);
  static Insertable<DbUser> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? avatarSrcset,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? discussionCount,
    Expression<int>? commentCount,
    Expression<String>? email,
    Expression<String>? bio,
    Expression<String>? rawJson,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarSrcset != null) 'avatar_srcset': avatarSrcset,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (discussionCount != null) 'discussion_count': discussionCount,
      if (commentCount != null) 'comment_count': commentCount,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (rawJson != null) 'raw_json': rawJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DbUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? displayName,
    Value<String>? avatarUrl,
    Value<String>? avatarSrcset,
    Value<DateTime?>? joinedAt,
    Value<DateTime?>? lastSeenAt,
    Value<int>? discussionCount,
    Value<int>? commentCount,
    Value<String>? email,
    Value<String>? bio,
    Value<String?>? rawJson,
    Value<DateTime>? syncedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return DbUsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarSrcset: avatarSrcset ?? this.avatarSrcset,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      discussionCount: discussionCount ?? this.discussionCount,
      commentCount: commentCount ?? this.commentCount,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      rawJson: rawJson ?? this.rawJson,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (avatarSrcset.present) {
      map['avatar_srcset'] = Variable<String>(avatarSrcset.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (discussionCount.present) {
      map['discussion_count'] = Variable<int>(discussionCount.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbUsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarSrcset: $avatarSrcset, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('discussionCount: $discussionCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('email: $email, ')
          ..write('bio: $bio, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DbPostsTable extends DbPosts with TableInfo<$DbPostsTable, DbPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discussionIdMeta = const VerificationMeta(
    'discussionId',
  );
  @override
  late final GeneratedColumn<int> discussionId = GeneratedColumn<int>(
    'discussion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('comment'),
  );
  static const VerificationMeta _contentHtmlMeta = const VerificationMeta(
    'contentHtml',
  );
  @override
  late final GeneratedColumn<String> contentHtml = GeneratedColumn<String>(
    'content_html',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likesCountMeta = const VerificationMeta(
    'likesCount',
  );
  @override
  late final GeneratedColumn<int> likesCount = GeneratedColumn<int>(
    'likes_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isLikedMeta = const VerificationMeta(
    'isLiked',
  );
  @override
  late final GeneratedColumn<bool> isLiked = GeneratedColumn<bool>(
    'is_liked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    discussionId,
    number,
    userId,
    contentType,
    contentHtml,
    createdAt,
    editedAt,
    likesCount,
    isLiked,
    fingerprint,
    rawJson,
    syncedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('discussion_id')) {
      context.handle(
        _discussionIdMeta,
        discussionId.isAcceptableOrUnknown(
          data['discussion_id']!,
          _discussionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discussionIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('content_html')) {
      context.handle(
        _contentHtmlMeta,
        contentHtml.isAcceptableOrUnknown(
          data['content_html']!,
          _contentHtmlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('likes_count')) {
      context.handle(
        _likesCountMeta,
        likesCount.isAcceptableOrUnknown(data['likes_count']!, _likesCountMeta),
      );
    }
    if (data.containsKey('is_liked')) {
      context.handle(
        _isLikedMeta,
        isLiked.isAcceptableOrUnknown(data['is_liked']!, _isLikedMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      discussionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discussion_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      contentHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_html'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      likesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}likes_count'],
      )!,
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DbPostsTable createAlias(String alias) {
    return $DbPostsTable(attachedDatabase, alias);
  }
}

class DbPost extends DataClass implements Insertable<DbPost> {
  final int id;
  final int discussionId;
  final int number;
  final int userId;
  final String contentType;
  final String contentHtml;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int likesCount;
  final bool isLiked;
  final String fingerprint;
  final String? rawJson;
  final DateTime syncedAt;
  final DateTime? deletedAt;
  const DbPost({
    required this.id,
    required this.discussionId,
    required this.number,
    required this.userId,
    required this.contentType,
    required this.contentHtml,
    this.createdAt,
    this.editedAt,
    required this.likesCount,
    required this.isLiked,
    required this.fingerprint,
    this.rawJson,
    required this.syncedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['discussion_id'] = Variable<int>(discussionId);
    map['number'] = Variable<int>(number);
    map['user_id'] = Variable<int>(userId);
    map['content_type'] = Variable<String>(contentType);
    map['content_html'] = Variable<String>(contentHtml);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    map['likes_count'] = Variable<int>(likesCount);
    map['is_liked'] = Variable<bool>(isLiked);
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DbPostsCompanion toCompanion(bool nullToAbsent) {
    return DbPostsCompanion(
      id: Value(id),
      discussionId: Value(discussionId),
      number: Value(number),
      userId: Value(userId),
      contentType: Value(contentType),
      contentHtml: Value(contentHtml),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      likesCount: Value(likesCount),
      isLiked: Value(isLiked),
      fingerprint: Value(fingerprint),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      syncedAt: Value(syncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DbPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPost(
      id: serializer.fromJson<int>(json['id']),
      discussionId: serializer.fromJson<int>(json['discussionId']),
      number: serializer.fromJson<int>(json['number']),
      userId: serializer.fromJson<int>(json['userId']),
      contentType: serializer.fromJson<String>(json['contentType']),
      contentHtml: serializer.fromJson<String>(json['contentHtml']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      likesCount: serializer.fromJson<int>(json['likesCount']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'discussionId': serializer.toJson<int>(discussionId),
      'number': serializer.toJson<int>(number),
      'userId': serializer.toJson<int>(userId),
      'contentType': serializer.toJson<String>(contentType),
      'contentHtml': serializer.toJson<String>(contentHtml),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'likesCount': serializer.toJson<int>(likesCount),
      'isLiked': serializer.toJson<bool>(isLiked),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'rawJson': serializer.toJson<String?>(rawJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DbPost copyWith({
    int? id,
    int? discussionId,
    int? number,
    int? userId,
    String? contentType,
    String? contentHtml,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> editedAt = const Value.absent(),
    int? likesCount,
    bool? isLiked,
    String? fingerprint,
    Value<String?> rawJson = const Value.absent(),
    DateTime? syncedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DbPost(
    id: id ?? this.id,
    discussionId: discussionId ?? this.discussionId,
    number: number ?? this.number,
    userId: userId ?? this.userId,
    contentType: contentType ?? this.contentType,
    contentHtml: contentHtml ?? this.contentHtml,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    likesCount: likesCount ?? this.likesCount,
    isLiked: isLiked ?? this.isLiked,
    fingerprint: fingerprint ?? this.fingerprint,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    syncedAt: syncedAt ?? this.syncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DbPost copyWithCompanion(DbPostsCompanion data) {
    return DbPost(
      id: data.id.present ? data.id.value : this.id,
      discussionId: data.discussionId.present
          ? data.discussionId.value
          : this.discussionId,
      number: data.number.present ? data.number.value : this.number,
      userId: data.userId.present ? data.userId.value : this.userId,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      contentHtml: data.contentHtml.present
          ? data.contentHtml.value
          : this.contentHtml,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      likesCount: data.likesCount.present
          ? data.likesCount.value
          : this.likesCount,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPost(')
          ..write('id: $id, ')
          ..write('discussionId: $discussionId, ')
          ..write('number: $number, ')
          ..write('userId: $userId, ')
          ..write('contentType: $contentType, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('likesCount: $likesCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    discussionId,
    number,
    userId,
    contentType,
    contentHtml,
    createdAt,
    editedAt,
    likesCount,
    isLiked,
    fingerprint,
    rawJson,
    syncedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPost &&
          other.id == this.id &&
          other.discussionId == this.discussionId &&
          other.number == this.number &&
          other.userId == this.userId &&
          other.contentType == this.contentType &&
          other.contentHtml == this.contentHtml &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt &&
          other.likesCount == this.likesCount &&
          other.isLiked == this.isLiked &&
          other.fingerprint == this.fingerprint &&
          other.rawJson == this.rawJson &&
          other.syncedAt == this.syncedAt &&
          other.deletedAt == this.deletedAt);
}

class DbPostsCompanion extends UpdateCompanion<DbPost> {
  final Value<int> id;
  final Value<int> discussionId;
  final Value<int> number;
  final Value<int> userId;
  final Value<String> contentType;
  final Value<String> contentHtml;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> editedAt;
  final Value<int> likesCount;
  final Value<bool> isLiked;
  final Value<String> fingerprint;
  final Value<String?> rawJson;
  final Value<DateTime> syncedAt;
  final Value<DateTime?> deletedAt;
  const DbPostsCompanion({
    this.id = const Value.absent(),
    this.discussionId = const Value.absent(),
    this.number = const Value.absent(),
    this.userId = const Value.absent(),
    this.contentType = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.likesCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DbPostsCompanion.insert({
    this.id = const Value.absent(),
    required int discussionId,
    this.number = const Value.absent(),
    this.userId = const Value.absent(),
    this.contentType = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.likesCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rawJson = const Value.absent(),
    required DateTime syncedAt,
    this.deletedAt = const Value.absent(),
  }) : discussionId = Value(discussionId),
       syncedAt = Value(syncedAt);
  static Insertable<DbPost> custom({
    Expression<int>? id,
    Expression<int>? discussionId,
    Expression<int>? number,
    Expression<int>? userId,
    Expression<String>? contentType,
    Expression<String>? contentHtml,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editedAt,
    Expression<int>? likesCount,
    Expression<bool>? isLiked,
    Expression<String>? fingerprint,
    Expression<String>? rawJson,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (discussionId != null) 'discussion_id': discussionId,
      if (number != null) 'number': number,
      if (userId != null) 'user_id': userId,
      if (contentType != null) 'content_type': contentType,
      if (contentHtml != null) 'content_html': contentHtml,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (likesCount != null) 'likes_count': likesCount,
      if (isLiked != null) 'is_liked': isLiked,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rawJson != null) 'raw_json': rawJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DbPostsCompanion copyWith({
    Value<int>? id,
    Value<int>? discussionId,
    Value<int>? number,
    Value<int>? userId,
    Value<String>? contentType,
    Value<String>? contentHtml,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? editedAt,
    Value<int>? likesCount,
    Value<bool>? isLiked,
    Value<String>? fingerprint,
    Value<String?>? rawJson,
    Value<DateTime>? syncedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return DbPostsCompanion(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      number: number ?? this.number,
      userId: userId ?? this.userId,
      contentType: contentType ?? this.contentType,
      contentHtml: contentHtml ?? this.contentHtml,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      fingerprint: fingerprint ?? this.fingerprint,
      rawJson: rawJson ?? this.rawJson,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (discussionId.present) {
      map['discussion_id'] = Variable<int>(discussionId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (contentHtml.present) {
      map['content_html'] = Variable<String>(contentHtml.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (likesCount.present) {
      map['likes_count'] = Variable<int>(likesCount.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbPostsCompanion(')
          ..write('id: $id, ')
          ..write('discussionId: $discussionId, ')
          ..write('number: $number, ')
          ..write('userId: $userId, ')
          ..write('contentType: $contentType, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('likesCount: $likesCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DbTagsTable extends DbTags with TableInfo<$DbTagsTable, DbTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discussionCountMeta = const VerificationMeta(
    'discussionCount',
  );
  @override
  late final GeneratedColumn<int> discussionCount = GeneratedColumn<int>(
    'discussion_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    name,
    color,
    icon,
    position,
    discussionCount,
    parentId,
    rawJson,
    syncedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('discussion_count')) {
      context.handle(
        _discussionCountMeta,
        discussionCount.isAcceptableOrUnknown(
          data['discussion_count']!,
          _discussionCountMeta,
        ),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      discussionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discussion_count'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DbTagsTable createAlias(String alias) {
    return $DbTagsTable(attachedDatabase, alias);
  }
}

class DbTag extends DataClass implements Insertable<DbTag> {
  final int id;
  final String slug;
  final String name;
  final String color;
  final String icon;
  final int position;
  final int discussionCount;
  final int? parentId;
  final String? rawJson;
  final DateTime syncedAt;
  final DateTime? deletedAt;
  const DbTag({
    required this.id,
    required this.slug,
    required this.name,
    required this.color,
    required this.icon,
    required this.position,
    required this.discussionCount,
    this.parentId,
    this.rawJson,
    required this.syncedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    map['position'] = Variable<int>(position);
    map['discussion_count'] = Variable<int>(discussionCount);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DbTagsCompanion toCompanion(bool nullToAbsent) {
    return DbTagsCompanion(
      id: Value(id),
      slug: Value(slug),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      position: Value(position),
      discussionCount: Value(discussionCount),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      syncedAt: Value(syncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DbTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTag(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      position: serializer.fromJson<int>(json['position']),
      discussionCount: serializer.fromJson<int>(json['discussionCount']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'position': serializer.toJson<int>(position),
      'discussionCount': serializer.toJson<int>(discussionCount),
      'parentId': serializer.toJson<int?>(parentId),
      'rawJson': serializer.toJson<String?>(rawJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DbTag copyWith({
    int? id,
    String? slug,
    String? name,
    String? color,
    String? icon,
    int? position,
    int? discussionCount,
    Value<int?> parentId = const Value.absent(),
    Value<String?> rawJson = const Value.absent(),
    DateTime? syncedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DbTag(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    position: position ?? this.position,
    discussionCount: discussionCount ?? this.discussionCount,
    parentId: parentId.present ? parentId.value : this.parentId,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    syncedAt: syncedAt ?? this.syncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DbTag copyWithCompanion(DbTagsCompanion data) {
    return DbTag(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      position: data.position.present ? data.position.value : this.position,
      discussionCount: data.discussionCount.present
          ? data.discussionCount.value
          : this.discussionCount,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTag(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('position: $position, ')
          ..write('discussionCount: $discussionCount, ')
          ..write('parentId: $parentId, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    name,
    color,
    icon,
    position,
    discussionCount,
    parentId,
    rawJson,
    syncedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTag &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.position == this.position &&
          other.discussionCount == this.discussionCount &&
          other.parentId == this.parentId &&
          other.rawJson == this.rawJson &&
          other.syncedAt == this.syncedAt &&
          other.deletedAt == this.deletedAt);
}

class DbTagsCompanion extends UpdateCompanion<DbTag> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> name;
  final Value<String> color;
  final Value<String> icon;
  final Value<int> position;
  final Value<int> discussionCount;
  final Value<int?> parentId;
  final Value<String?> rawJson;
  final Value<DateTime> syncedAt;
  final Value<DateTime?> deletedAt;
  const DbTagsCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.position = const Value.absent(),
    this.discussionCount = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DbTagsCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.position = const Value.absent(),
    this.discussionCount = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rawJson = const Value.absent(),
    required DateTime syncedAt,
    this.deletedAt = const Value.absent(),
  }) : slug = Value(slug),
       name = Value(name),
       syncedAt = Value(syncedAt);
  static Insertable<DbTag> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? position,
    Expression<int>? discussionCount,
    Expression<int>? parentId,
    Expression<String>? rawJson,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (position != null) 'position': position,
      if (discussionCount != null) 'discussion_count': discussionCount,
      if (parentId != null) 'parent_id': parentId,
      if (rawJson != null) 'raw_json': rawJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DbTagsCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? name,
    Value<String>? color,
    Value<String>? icon,
    Value<int>? position,
    Value<int>? discussionCount,
    Value<int?>? parentId,
    Value<String?>? rawJson,
    Value<DateTime>? syncedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return DbTagsCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      discussionCount: discussionCount ?? this.discussionCount,
      parentId: parentId ?? this.parentId,
      rawJson: rawJson ?? this.rawJson,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (discussionCount.present) {
      map['discussion_count'] = Variable<int>(discussionCount.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbTagsCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('position: $position, ')
          ..write('discussionCount: $discussionCount, ')
          ..write('parentId: $parentId, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DbDiscussionTagsTable extends DbDiscussionTags
    with TableInfo<$DbDiscussionTagsTable, DbDiscussionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDiscussionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _discussionIdMeta = const VerificationMeta(
    'discussionId',
  );
  @override
  late final GeneratedColumn<String> discussionId = GeneratedColumn<String>(
    'discussion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [discussionId, tagId, sortIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_discussion_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDiscussionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('discussion_id')) {
      context.handle(
        _discussionIdMeta,
        discussionId.isAcceptableOrUnknown(
          data['discussion_id']!,
          _discussionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discussionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {discussionId, tagId};
  @override
  DbDiscussionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDiscussionTag(
      discussionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discussion_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $DbDiscussionTagsTable createAlias(String alias) {
    return $DbDiscussionTagsTable(attachedDatabase, alias);
  }
}

class DbDiscussionTag extends DataClass implements Insertable<DbDiscussionTag> {
  final String discussionId;
  final int tagId;
  final int sortIndex;
  const DbDiscussionTag({
    required this.discussionId,
    required this.tagId,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['discussion_id'] = Variable<String>(discussionId);
    map['tag_id'] = Variable<int>(tagId);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  DbDiscussionTagsCompanion toCompanion(bool nullToAbsent) {
    return DbDiscussionTagsCompanion(
      discussionId: Value(discussionId),
      tagId: Value(tagId),
      sortIndex: Value(sortIndex),
    );
  }

  factory DbDiscussionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDiscussionTag(
      discussionId: serializer.fromJson<String>(json['discussionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'discussionId': serializer.toJson<String>(discussionId),
      'tagId': serializer.toJson<int>(tagId),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  DbDiscussionTag copyWith({
    String? discussionId,
    int? tagId,
    int? sortIndex,
  }) => DbDiscussionTag(
    discussionId: discussionId ?? this.discussionId,
    tagId: tagId ?? this.tagId,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  DbDiscussionTag copyWithCompanion(DbDiscussionTagsCompanion data) {
    return DbDiscussionTag(
      discussionId: data.discussionId.present
          ? data.discussionId.value
          : this.discussionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussionTag(')
          ..write('discussionId: $discussionId, ')
          ..write('tagId: $tagId, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(discussionId, tagId, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDiscussionTag &&
          other.discussionId == this.discussionId &&
          other.tagId == this.tagId &&
          other.sortIndex == this.sortIndex);
}

class DbDiscussionTagsCompanion extends UpdateCompanion<DbDiscussionTag> {
  final Value<String> discussionId;
  final Value<int> tagId;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const DbDiscussionTagsCompanion({
    this.discussionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbDiscussionTagsCompanion.insert({
    required String discussionId,
    required int tagId,
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : discussionId = Value(discussionId),
       tagId = Value(tagId);
  static Insertable<DbDiscussionTag> custom({
    Expression<String>? discussionId,
    Expression<int>? tagId,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (discussionId != null) 'discussion_id': discussionId,
      if (tagId != null) 'tag_id': tagId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbDiscussionTagsCompanion copyWith({
    Value<String>? discussionId,
    Value<int>? tagId,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return DbDiscussionTagsCompanion(
      discussionId: discussionId ?? this.discussionId,
      tagId: tagId ?? this.tagId,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (discussionId.present) {
      map['discussion_id'] = Variable<String>(discussionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDiscussionTagsCompanion(')
          ..write('discussionId: $discussionId, ')
          ..write('tagId: $tagId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbNotificationsTable extends DbNotifications
    with TableInfo<$DbNotificationsTable, DbNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromUserIdMeta = const VerificationMeta(
    'fromUserId',
  );
  @override
  late final GeneratedColumn<int> fromUserId = GeneratedColumn<int>(
    'from_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectTypeMeta = const VerificationMeta(
    'subjectType',
  );
  @override
  late final GeneratedColumn<String> subjectType = GeneratedColumn<String>(
    'subject_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedTitleMeta = const VerificationMeta(
    'cachedTitle',
  );
  @override
  late final GeneratedColumn<String> cachedTitle = GeneratedColumn<String>(
    'cached_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedDescMeta = const VerificationMeta(
    'cachedDesc',
  );
  @override
  late final GeneratedColumn<String> cachedDesc = GeneratedColumn<String>(
    'cached_desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    isRead,
    createdAt,
    readAt,
    fromUserId,
    subjectType,
    subjectId,
    contentJson,
    cachedTitle,
    cachedDesc,
    fingerprint,
    rawJson,
    syncedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('from_user_id')) {
      context.handle(
        _fromUserIdMeta,
        fromUserId.isAcceptableOrUnknown(
          data['from_user_id']!,
          _fromUserIdMeta,
        ),
      );
    }
    if (data.containsKey('subject_type')) {
      context.handle(
        _subjectTypeMeta,
        subjectType.isAcceptableOrUnknown(
          data['subject_type']!,
          _subjectTypeMeta,
        ),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    }
    if (data.containsKey('cached_title')) {
      context.handle(
        _cachedTitleMeta,
        cachedTitle.isAcceptableOrUnknown(
          data['cached_title']!,
          _cachedTitleMeta,
        ),
      );
    }
    if (data.containsKey('cached_desc')) {
      context.handle(
        _cachedDescMeta,
        cachedDesc.isAcceptableOrUnknown(data['cached_desc']!, _cachedDescMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      fromUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_user_id'],
      ),
      subjectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_type'],
      ),
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      ),
      cachedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_title'],
      ),
      cachedDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_desc'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DbNotificationsTable createAlias(String alias) {
    return $DbNotificationsTable(attachedDatabase, alias);
  }
}

class DbNotification extends DataClass implements Insertable<DbNotification> {
  final int id;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final int? fromUserId;
  final String? subjectType;
  final String? subjectId;
  final String? contentJson;
  final String? cachedTitle;
  final String? cachedDesc;
  final String fingerprint;
  final String? rawJson;
  final DateTime syncedAt;
  final DateTime? deletedAt;
  const DbNotification({
    required this.id,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.fromUserId,
    this.subjectType,
    this.subjectId,
    this.contentJson,
    this.cachedTitle,
    this.cachedDesc,
    required this.fingerprint,
    this.rawJson,
    required this.syncedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || fromUserId != null) {
      map['from_user_id'] = Variable<int>(fromUserId);
    }
    if (!nullToAbsent || subjectType != null) {
      map['subject_type'] = Variable<String>(subjectType);
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || contentJson != null) {
      map['content_json'] = Variable<String>(contentJson);
    }
    if (!nullToAbsent || cachedTitle != null) {
      map['cached_title'] = Variable<String>(cachedTitle);
    }
    if (!nullToAbsent || cachedDesc != null) {
      map['cached_desc'] = Variable<String>(cachedDesc);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DbNotificationsCompanion toCompanion(bool nullToAbsent) {
    return DbNotificationsCompanion(
      id: Value(id),
      type: Value(type),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      fromUserId: fromUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromUserId),
      subjectType: subjectType == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectType),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      contentJson: contentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contentJson),
      cachedTitle: cachedTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedTitle),
      cachedDesc: cachedDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedDesc),
      fingerprint: Value(fingerprint),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      syncedAt: Value(syncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DbNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbNotification(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      fromUserId: serializer.fromJson<int?>(json['fromUserId']),
      subjectType: serializer.fromJson<String?>(json['subjectType']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      contentJson: serializer.fromJson<String?>(json['contentJson']),
      cachedTitle: serializer.fromJson<String?>(json['cachedTitle']),
      cachedDesc: serializer.fromJson<String?>(json['cachedDesc']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'fromUserId': serializer.toJson<int?>(fromUserId),
      'subjectType': serializer.toJson<String?>(subjectType),
      'subjectId': serializer.toJson<String?>(subjectId),
      'contentJson': serializer.toJson<String?>(contentJson),
      'cachedTitle': serializer.toJson<String?>(cachedTitle),
      'cachedDesc': serializer.toJson<String?>(cachedDesc),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'rawJson': serializer.toJson<String?>(rawJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DbNotification copyWith({
    int? id,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Value<DateTime?> readAt = const Value.absent(),
    Value<int?> fromUserId = const Value.absent(),
    Value<String?> subjectType = const Value.absent(),
    Value<String?> subjectId = const Value.absent(),
    Value<String?> contentJson = const Value.absent(),
    Value<String?> cachedTitle = const Value.absent(),
    Value<String?> cachedDesc = const Value.absent(),
    String? fingerprint,
    Value<String?> rawJson = const Value.absent(),
    DateTime? syncedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DbNotification(
    id: id ?? this.id,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    fromUserId: fromUserId.present ? fromUserId.value : this.fromUserId,
    subjectType: subjectType.present ? subjectType.value : this.subjectType,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    contentJson: contentJson.present ? contentJson.value : this.contentJson,
    cachedTitle: cachedTitle.present ? cachedTitle.value : this.cachedTitle,
    cachedDesc: cachedDesc.present ? cachedDesc.value : this.cachedDesc,
    fingerprint: fingerprint ?? this.fingerprint,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    syncedAt: syncedAt ?? this.syncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DbNotification copyWithCompanion(DbNotificationsCompanion data) {
    return DbNotification(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      fromUserId: data.fromUserId.present
          ? data.fromUserId.value
          : this.fromUserId,
      subjectType: data.subjectType.present
          ? data.subjectType.value
          : this.subjectType,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      cachedTitle: data.cachedTitle.present
          ? data.cachedTitle.value
          : this.cachedTitle,
      cachedDesc: data.cachedDesc.present
          ? data.cachedDesc.value
          : this.cachedDesc,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbNotification(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('contentJson: $contentJson, ')
          ..write('cachedTitle: $cachedTitle, ')
          ..write('cachedDesc: $cachedDesc, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    isRead,
    createdAt,
    readAt,
    fromUserId,
    subjectType,
    subjectId,
    contentJson,
    cachedTitle,
    cachedDesc,
    fingerprint,
    rawJson,
    syncedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbNotification &&
          other.id == this.id &&
          other.type == this.type &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt &&
          other.fromUserId == this.fromUserId &&
          other.subjectType == this.subjectType &&
          other.subjectId == this.subjectId &&
          other.contentJson == this.contentJson &&
          other.cachedTitle == this.cachedTitle &&
          other.cachedDesc == this.cachedDesc &&
          other.fingerprint == this.fingerprint &&
          other.rawJson == this.rawJson &&
          other.syncedAt == this.syncedAt &&
          other.deletedAt == this.deletedAt);
}

class DbNotificationsCompanion extends UpdateCompanion<DbNotification> {
  final Value<int> id;
  final Value<String> type;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<int?> fromUserId;
  final Value<String?> subjectType;
  final Value<String?> subjectId;
  final Value<String?> contentJson;
  final Value<String?> cachedTitle;
  final Value<String?> cachedDesc;
  final Value<String> fingerprint;
  final Value<String?> rawJson;
  final Value<DateTime> syncedAt;
  final Value<DateTime?> deletedAt;
  const DbNotificationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.cachedTitle = const Value.absent(),
    this.cachedDesc = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DbNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.isRead = const Value.absent(),
    required DateTime createdAt,
    this.readAt = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.cachedTitle = const Value.absent(),
    this.cachedDesc = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rawJson = const Value.absent(),
    required DateTime syncedAt,
    this.deletedAt = const Value.absent(),
  }) : type = Value(type),
       createdAt = Value(createdAt),
       syncedAt = Value(syncedAt);
  static Insertable<DbNotification> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<int>? fromUserId,
    Expression<String>? subjectType,
    Expression<String>? subjectId,
    Expression<String>? contentJson,
    Expression<String>? cachedTitle,
    Expression<String>? cachedDesc,
    Expression<String>? fingerprint,
    Expression<String>? rawJson,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (subjectType != null) 'subject_type': subjectType,
      if (subjectId != null) 'subject_id': subjectId,
      if (contentJson != null) 'content_json': contentJson,
      if (cachedTitle != null) 'cached_title': cachedTitle,
      if (cachedDesc != null) 'cached_desc': cachedDesc,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rawJson != null) 'raw_json': rawJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DbNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
    Value<DateTime?>? readAt,
    Value<int?>? fromUserId,
    Value<String?>? subjectType,
    Value<String?>? subjectId,
    Value<String?>? contentJson,
    Value<String?>? cachedTitle,
    Value<String?>? cachedDesc,
    Value<String>? fingerprint,
    Value<String?>? rawJson,
    Value<DateTime>? syncedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return DbNotificationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      fromUserId: fromUserId ?? this.fromUserId,
      subjectType: subjectType ?? this.subjectType,
      subjectId: subjectId ?? this.subjectId,
      contentJson: contentJson ?? this.contentJson,
      cachedTitle: cachedTitle ?? this.cachedTitle,
      cachedDesc: cachedDesc ?? this.cachedDesc,
      fingerprint: fingerprint ?? this.fingerprint,
      rawJson: rawJson ?? this.rawJson,
      syncedAt: syncedAt ?? this.syncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (fromUserId.present) {
      map['from_user_id'] = Variable<int>(fromUserId.value);
    }
    if (subjectType.present) {
      map['subject_type'] = Variable<String>(subjectType.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (cachedTitle.present) {
      map['cached_title'] = Variable<String>(cachedTitle.value);
    }
    if (cachedDesc.present) {
      map['cached_desc'] = Variable<String>(cachedDesc.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('contentJson: $contentJson, ')
          ..write('cachedTitle: $cachedTitle, ')
          ..write('cachedDesc: $cachedDesc, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('rawJson: $rawJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbDiscussionsTable dbDiscussions = $DbDiscussionsTable(this);
  late final $DbFirstPostsTable dbFirstPosts = $DbFirstPostsTable(this);
  late final $DbDiscussionExcerptCacheTable dbDiscussionExcerptCache =
      $DbDiscussionExcerptCacheTable(this);
  late final $DbCacheCollectionItemsTable dbCacheCollectionItems =
      $DbCacheCollectionItemsTable(this);
  late final $DbSyncStatesTable dbSyncStates = $DbSyncStatesTable(this);
  late final $DbUsersTable dbUsers = $DbUsersTable(this);
  late final $DbPostsTable dbPosts = $DbPostsTable(this);
  late final $DbTagsTable dbTags = $DbTagsTable(this);
  late final $DbDiscussionTagsTable dbDiscussionTags = $DbDiscussionTagsTable(
    this,
  );
  late final $DbNotificationsTable dbNotifications = $DbNotificationsTable(
    this,
  );
  late final DiscussionsDao discussionsDao = DiscussionsDao(
    this as AppDatabase,
  );
  late final FirstPostsDao firstPostsDao = FirstPostsDao(this as AppDatabase);
  late final ExcerptDao excerptDao = ExcerptDao(this as AppDatabase);
  late final CacheCollectionDao cacheCollectionDao = CacheCollectionDao(
    this as AppDatabase,
  );
  late final ResourceCacheDao resourceCacheDao = ResourceCacheDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbDiscussions,
    dbFirstPosts,
    dbDiscussionExcerptCache,
    dbCacheCollectionItems,
    dbSyncStates,
    dbUsers,
    dbPosts,
    dbTags,
    dbDiscussionTags,
    dbNotifications,
  ];
}

typedef $$DbDiscussionsTableCreateCompanionBuilder =
    DbDiscussionsCompanion Function({
      required String id,
      required String title,
      required String slug,
      required int commentCount,
      required int participantCount,
      Value<int> viewCount,
      Value<int> likeCount,
      Value<String> authorName,
      Value<String> authorAvatar,
      required DateTime createdAt,
      Value<DateTime?> lastPostedAt,
      required DateTime lastSeenAt,
      Value<DateTime?> syncedAt,
      Value<DateTime?> deletedAt,
      required int lastPostNumber,
      Value<int> firstPostId,
      required int posterId,
      required int subscription,
      Value<String> fingerprint,
      Value<int> rowid,
    });
typedef $$DbDiscussionsTableUpdateCompanionBuilder =
    DbDiscussionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> slug,
      Value<int> commentCount,
      Value<int> participantCount,
      Value<int> viewCount,
      Value<int> likeCount,
      Value<String> authorName,
      Value<String> authorAvatar,
      Value<DateTime> createdAt,
      Value<DateTime?> lastPostedAt,
      Value<DateTime> lastSeenAt,
      Value<DateTime?> syncedAt,
      Value<DateTime?> deletedAt,
      Value<int> lastPostNumber,
      Value<int> firstPostId,
      Value<int> posterId,
      Value<int> subscription,
      Value<String> fingerprint,
      Value<int> rowid,
    });

class $$DbDiscussionsTableFilterComposer
    extends Composer<_$AppDatabase, $DbDiscussionsTable> {
  $$DbDiscussionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPostedAt => $composableBuilder(
    column: $table.lastPostedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstPostId => $composableBuilder(
    column: $table.firstPostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subscription => $composableBuilder(
    column: $table.subscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbDiscussionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDiscussionsTable> {
  $$DbDiscussionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPostedAt => $composableBuilder(
    column: $table.lastPostedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstPostId => $composableBuilder(
    column: $table.firstPostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subscription => $composableBuilder(
    column: $table.subscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbDiscussionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDiscussionsTable> {
  $$DbDiscussionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPostedAt => $composableBuilder(
    column: $table.lastPostedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstPostId => $composableBuilder(
    column: $table.firstPostId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get posterId =>
      $composableBuilder(column: $table.posterId, builder: (column) => column);

  GeneratedColumn<int> get subscription => $composableBuilder(
    column: $table.subscription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );
}

class $$DbDiscussionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbDiscussionsTable,
          DbDiscussion,
          $$DbDiscussionsTableFilterComposer,
          $$DbDiscussionsTableOrderingComposer,
          $$DbDiscussionsTableAnnotationComposer,
          $$DbDiscussionsTableCreateCompanionBuilder,
          $$DbDiscussionsTableUpdateCompanionBuilder,
          (
            DbDiscussion,
            BaseReferences<_$AppDatabase, $DbDiscussionsTable, DbDiscussion>,
          ),
          DbDiscussion,
          PrefetchHooks Function()
        > {
  $$DbDiscussionsTableTableManager(_$AppDatabase db, $DbDiscussionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDiscussionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbDiscussionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbDiscussionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<int> participantCount = const Value.absent(),
                Value<int> viewCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> authorAvatar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastPostedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> lastPostNumber = const Value.absent(),
                Value<int> firstPostId = const Value.absent(),
                Value<int> posterId = const Value.absent(),
                Value<int> subscription = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionsCompanion(
                id: id,
                title: title,
                slug: slug,
                commentCount: commentCount,
                participantCount: participantCount,
                viewCount: viewCount,
                likeCount: likeCount,
                authorName: authorName,
                authorAvatar: authorAvatar,
                createdAt: createdAt,
                lastPostedAt: lastPostedAt,
                lastSeenAt: lastSeenAt,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
                lastPostNumber: lastPostNumber,
                firstPostId: firstPostId,
                posterId: posterId,
                subscription: subscription,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String slug,
                required int commentCount,
                required int participantCount,
                Value<int> viewCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> authorAvatar = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastPostedAt = const Value.absent(),
                required DateTime lastSeenAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required int lastPostNumber,
                Value<int> firstPostId = const Value.absent(),
                required int posterId,
                required int subscription,
                Value<String> fingerprint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionsCompanion.insert(
                id: id,
                title: title,
                slug: slug,
                commentCount: commentCount,
                participantCount: participantCount,
                viewCount: viewCount,
                likeCount: likeCount,
                authorName: authorName,
                authorAvatar: authorAvatar,
                createdAt: createdAt,
                lastPostedAt: lastPostedAt,
                lastSeenAt: lastSeenAt,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
                lastPostNumber: lastPostNumber,
                firstPostId: firstPostId,
                posterId: posterId,
                subscription: subscription,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbDiscussionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbDiscussionsTable,
      DbDiscussion,
      $$DbDiscussionsTableFilterComposer,
      $$DbDiscussionsTableOrderingComposer,
      $$DbDiscussionsTableAnnotationComposer,
      $$DbDiscussionsTableCreateCompanionBuilder,
      $$DbDiscussionsTableUpdateCompanionBuilder,
      (
        DbDiscussion,
        BaseReferences<_$AppDatabase, $DbDiscussionsTable, DbDiscussion>,
      ),
      DbDiscussion,
      PrefetchHooks Function()
    >;
typedef $$DbFirstPostsTableCreateCompanionBuilder =
    DbFirstPostsCompanion Function({
      required String discussionId,
      required String content,
      required DateTime updatedAt,
      required int likeCount,
      Value<int> rowid,
    });
typedef $$DbFirstPostsTableUpdateCompanionBuilder =
    DbFirstPostsCompanion Function({
      Value<String> discussionId,
      Value<String> content,
      Value<DateTime> updatedAt,
      Value<int> likeCount,
      Value<int> rowid,
    });

class $$DbFirstPostsTableFilterComposer
    extends Composer<_$AppDatabase, $DbFirstPostsTable> {
  $$DbFirstPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbFirstPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbFirstPostsTable> {
  $$DbFirstPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbFirstPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbFirstPostsTable> {
  $$DbFirstPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);
}

class $$DbFirstPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbFirstPostsTable,
          DbFirstPost,
          $$DbFirstPostsTableFilterComposer,
          $$DbFirstPostsTableOrderingComposer,
          $$DbFirstPostsTableAnnotationComposer,
          $$DbFirstPostsTableCreateCompanionBuilder,
          $$DbFirstPostsTableUpdateCompanionBuilder,
          (
            DbFirstPost,
            BaseReferences<_$AppDatabase, $DbFirstPostsTable, DbFirstPost>,
          ),
          DbFirstPost,
          PrefetchHooks Function()
        > {
  $$DbFirstPostsTableTableManager(_$AppDatabase db, $DbFirstPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbFirstPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbFirstPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbFirstPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> discussionId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbFirstPostsCompanion(
                discussionId: discussionId,
                content: content,
                updatedAt: updatedAt,
                likeCount: likeCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String discussionId,
                required String content,
                required DateTime updatedAt,
                required int likeCount,
                Value<int> rowid = const Value.absent(),
              }) => DbFirstPostsCompanion.insert(
                discussionId: discussionId,
                content: content,
                updatedAt: updatedAt,
                likeCount: likeCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbFirstPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbFirstPostsTable,
      DbFirstPost,
      $$DbFirstPostsTableFilterComposer,
      $$DbFirstPostsTableOrderingComposer,
      $$DbFirstPostsTableAnnotationComposer,
      $$DbFirstPostsTableCreateCompanionBuilder,
      $$DbFirstPostsTableUpdateCompanionBuilder,
      (
        DbFirstPost,
        BaseReferences<_$AppDatabase, $DbFirstPostsTable, DbFirstPost>,
      ),
      DbFirstPost,
      PrefetchHooks Function()
    >;
typedef $$DbDiscussionExcerptCacheTableCreateCompanionBuilder =
    DbDiscussionExcerptCacheCompanion Function({
      required String discussionId,
      required String excerpt,
      required DateTime sourceUpdatedAt,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$DbDiscussionExcerptCacheTableUpdateCompanionBuilder =
    DbDiscussionExcerptCacheCompanion Function({
      Value<String> discussionId,
      Value<String> excerpt,
      Value<DateTime> sourceUpdatedAt,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$DbDiscussionExcerptCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DbDiscussionExcerptCacheTable> {
  $$DbDiscussionExcerptCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbDiscussionExcerptCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDiscussionExcerptCacheTable> {
  $$DbDiscussionExcerptCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbDiscussionExcerptCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDiscussionExcerptCacheTable> {
  $$DbDiscussionExcerptCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<DateTime> get sourceUpdatedAt => $composableBuilder(
    column: $table.sourceUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$DbDiscussionExcerptCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbDiscussionExcerptCacheTable,
          DbDiscussionExcerptCacheData,
          $$DbDiscussionExcerptCacheTableFilterComposer,
          $$DbDiscussionExcerptCacheTableOrderingComposer,
          $$DbDiscussionExcerptCacheTableAnnotationComposer,
          $$DbDiscussionExcerptCacheTableCreateCompanionBuilder,
          $$DbDiscussionExcerptCacheTableUpdateCompanionBuilder,
          (
            DbDiscussionExcerptCacheData,
            BaseReferences<
              _$AppDatabase,
              $DbDiscussionExcerptCacheTable,
              DbDiscussionExcerptCacheData
            >,
          ),
          DbDiscussionExcerptCacheData,
          PrefetchHooks Function()
        > {
  $$DbDiscussionExcerptCacheTableTableManager(
    _$AppDatabase db,
    $DbDiscussionExcerptCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDiscussionExcerptCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DbDiscussionExcerptCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DbDiscussionExcerptCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> discussionId = const Value.absent(),
                Value<String> excerpt = const Value.absent(),
                Value<DateTime> sourceUpdatedAt = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionExcerptCacheCompanion(
                discussionId: discussionId,
                excerpt: excerpt,
                sourceUpdatedAt: sourceUpdatedAt,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String discussionId,
                required String excerpt,
                required DateTime sourceUpdatedAt,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionExcerptCacheCompanion.insert(
                discussionId: discussionId,
                excerpt: excerpt,
                sourceUpdatedAt: sourceUpdatedAt,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbDiscussionExcerptCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbDiscussionExcerptCacheTable,
      DbDiscussionExcerptCacheData,
      $$DbDiscussionExcerptCacheTableFilterComposer,
      $$DbDiscussionExcerptCacheTableOrderingComposer,
      $$DbDiscussionExcerptCacheTableAnnotationComposer,
      $$DbDiscussionExcerptCacheTableCreateCompanionBuilder,
      $$DbDiscussionExcerptCacheTableUpdateCompanionBuilder,
      (
        DbDiscussionExcerptCacheData,
        BaseReferences<
          _$AppDatabase,
          $DbDiscussionExcerptCacheTable,
          DbDiscussionExcerptCacheData
        >,
      ),
      DbDiscussionExcerptCacheData,
      PrefetchHooks Function()
    >;
typedef $$DbCacheCollectionItemsTableCreateCompanionBuilder =
    DbCacheCollectionItemsCompanion Function({
      required String collectionKey,
      required String resourceType,
      required String resourceId,
      required int sortIndex,
      required String fingerprint,
      required DateTime seenAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$DbCacheCollectionItemsTableUpdateCompanionBuilder =
    DbCacheCollectionItemsCompanion Function({
      Value<String> collectionKey,
      Value<String> resourceType,
      Value<String> resourceId,
      Value<int> sortIndex,
      Value<String> fingerprint,
      Value<DateTime> seenAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$DbCacheCollectionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DbCacheCollectionItemsTable> {
  $$DbCacheCollectionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbCacheCollectionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbCacheCollectionItemsTable> {
  $$DbCacheCollectionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbCacheCollectionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbCacheCollectionItemsTable> {
  $$DbCacheCollectionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$DbCacheCollectionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbCacheCollectionItemsTable,
          DbCacheCollectionItem,
          $$DbCacheCollectionItemsTableFilterComposer,
          $$DbCacheCollectionItemsTableOrderingComposer,
          $$DbCacheCollectionItemsTableAnnotationComposer,
          $$DbCacheCollectionItemsTableCreateCompanionBuilder,
          $$DbCacheCollectionItemsTableUpdateCompanionBuilder,
          (
            DbCacheCollectionItem,
            BaseReferences<
              _$AppDatabase,
              $DbCacheCollectionItemsTable,
              DbCacheCollectionItem
            >,
          ),
          DbCacheCollectionItem,
          PrefetchHooks Function()
        > {
  $$DbCacheCollectionItemsTableTableManager(
    _$AppDatabase db,
    $DbCacheCollectionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbCacheCollectionItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DbCacheCollectionItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DbCacheCollectionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> collectionKey = const Value.absent(),
                Value<String> resourceType = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<DateTime> seenAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbCacheCollectionItemsCompanion(
                collectionKey: collectionKey,
                resourceType: resourceType,
                resourceId: resourceId,
                sortIndex: sortIndex,
                fingerprint: fingerprint,
                seenAt: seenAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionKey,
                required String resourceType,
                required String resourceId,
                required int sortIndex,
                required String fingerprint,
                required DateTime seenAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => DbCacheCollectionItemsCompanion.insert(
                collectionKey: collectionKey,
                resourceType: resourceType,
                resourceId: resourceId,
                sortIndex: sortIndex,
                fingerprint: fingerprint,
                seenAt: seenAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbCacheCollectionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbCacheCollectionItemsTable,
      DbCacheCollectionItem,
      $$DbCacheCollectionItemsTableFilterComposer,
      $$DbCacheCollectionItemsTableOrderingComposer,
      $$DbCacheCollectionItemsTableAnnotationComposer,
      $$DbCacheCollectionItemsTableCreateCompanionBuilder,
      $$DbCacheCollectionItemsTableUpdateCompanionBuilder,
      (
        DbCacheCollectionItem,
        BaseReferences<
          _$AppDatabase,
          $DbCacheCollectionItemsTable,
          DbCacheCollectionItem
        >,
      ),
      DbCacheCollectionItem,
      PrefetchHooks Function()
    >;
typedef $$DbSyncStatesTableCreateCompanionBuilder =
    DbSyncStatesCompanion Function({
      required String collectionKey,
      Value<String?> nextUrl,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<int> ttlSeconds,
      Value<int> rowid,
    });
typedef $$DbSyncStatesTableUpdateCompanionBuilder =
    DbSyncStatesCompanion Function({
      Value<String> collectionKey,
      Value<String?> nextUrl,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> lastSuccessAt,
      Value<String?> lastError,
      Value<int> ttlSeconds,
      Value<int> rowid,
    });

class $$DbSyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $DbSyncStatesTable> {
  $$DbSyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextUrl => $composableBuilder(
    column: $table.nextUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbSyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $DbSyncStatesTable> {
  $$DbSyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextUrl => $composableBuilder(
    column: $table.nextUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbSyncStatesTable> {
  $$DbSyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextUrl =>
      $composableBuilder(column: $table.nextUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get ttlSeconds => $composableBuilder(
    column: $table.ttlSeconds,
    builder: (column) => column,
  );
}

class $$DbSyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbSyncStatesTable,
          DbSyncState,
          $$DbSyncStatesTableFilterComposer,
          $$DbSyncStatesTableOrderingComposer,
          $$DbSyncStatesTableAnnotationComposer,
          $$DbSyncStatesTableCreateCompanionBuilder,
          $$DbSyncStatesTableUpdateCompanionBuilder,
          (
            DbSyncState,
            BaseReferences<_$AppDatabase, $DbSyncStatesTable, DbSyncState>,
          ),
          DbSyncState,
          PrefetchHooks Function()
        > {
  $$DbSyncStatesTableTableManager(_$AppDatabase db, $DbSyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collectionKey = const Value.absent(),
                Value<String?> nextUrl = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> ttlSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSyncStatesCompanion(
                collectionKey: collectionKey,
                nextUrl: nextUrl,
                lastSyncAt: lastSyncAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                ttlSeconds: ttlSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionKey,
                Value<String?> nextUrl = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> ttlSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSyncStatesCompanion.insert(
                collectionKey: collectionKey,
                nextUrl: nextUrl,
                lastSyncAt: lastSyncAt,
                lastSuccessAt: lastSuccessAt,
                lastError: lastError,
                ttlSeconds: ttlSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbSyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbSyncStatesTable,
      DbSyncState,
      $$DbSyncStatesTableFilterComposer,
      $$DbSyncStatesTableOrderingComposer,
      $$DbSyncStatesTableAnnotationComposer,
      $$DbSyncStatesTableCreateCompanionBuilder,
      $$DbSyncStatesTableUpdateCompanionBuilder,
      (
        DbSyncState,
        BaseReferences<_$AppDatabase, $DbSyncStatesTable, DbSyncState>,
      ),
      DbSyncState,
      PrefetchHooks Function()
    >;
typedef $$DbUsersTableCreateCompanionBuilder =
    DbUsersCompanion Function({
      Value<int> id,
      required String username,
      required String displayName,
      Value<String> avatarUrl,
      Value<String> avatarSrcset,
      Value<DateTime?> joinedAt,
      Value<DateTime?> lastSeenAt,
      Value<int> discussionCount,
      Value<int> commentCount,
      Value<String> email,
      Value<String> bio,
      Value<String?> rawJson,
      required DateTime syncedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$DbUsersTableUpdateCompanionBuilder =
    DbUsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> displayName,
      Value<String> avatarUrl,
      Value<String> avatarSrcset,
      Value<DateTime?> joinedAt,
      Value<DateTime?> lastSeenAt,
      Value<int> discussionCount,
      Value<int> commentCount,
      Value<String> email,
      Value<String> bio,
      Value<String?> rawJson,
      Value<DateTime> syncedAt,
      Value<DateTime?> deletedAt,
    });

class $$DbUsersTableFilterComposer
    extends Composer<_$AppDatabase, $DbUsersTable> {
  $$DbUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarSrcset => $composableBuilder(
    column: $table.avatarSrcset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $DbUsersTable> {
  $$DbUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarSrcset => $composableBuilder(
    column: $table.avatarSrcset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbUsersTable> {
  $$DbUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get avatarSrcset => $composableBuilder(
    column: $table.avatarSrcset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DbUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbUsersTable,
          DbUser,
          $$DbUsersTableFilterComposer,
          $$DbUsersTableOrderingComposer,
          $$DbUsersTableAnnotationComposer,
          $$DbUsersTableCreateCompanionBuilder,
          $$DbUsersTableUpdateCompanionBuilder,
          (DbUser, BaseReferences<_$AppDatabase, $DbUsersTable, DbUser>),
          DbUser,
          PrefetchHooks Function()
        > {
  $$DbUsersTableTableManager(_$AppDatabase db, $DbUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> avatarUrl = const Value.absent(),
                Value<String> avatarSrcset = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> discussionCount = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbUsersCompanion(
                id: id,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                avatarSrcset: avatarSrcset,
                joinedAt: joinedAt,
                lastSeenAt: lastSeenAt,
                discussionCount: discussionCount,
                commentCount: commentCount,
                email: email,
                bio: bio,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String displayName,
                Value<String> avatarUrl = const Value.absent(),
                Value<String> avatarSrcset = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> discussionCount = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                required DateTime syncedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbUsersCompanion.insert(
                id: id,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                avatarSrcset: avatarSrcset,
                joinedAt: joinedAt,
                lastSeenAt: lastSeenAt,
                discussionCount: discussionCount,
                commentCount: commentCount,
                email: email,
                bio: bio,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbUsersTable,
      DbUser,
      $$DbUsersTableFilterComposer,
      $$DbUsersTableOrderingComposer,
      $$DbUsersTableAnnotationComposer,
      $$DbUsersTableCreateCompanionBuilder,
      $$DbUsersTableUpdateCompanionBuilder,
      (DbUser, BaseReferences<_$AppDatabase, $DbUsersTable, DbUser>),
      DbUser,
      PrefetchHooks Function()
    >;
typedef $$DbPostsTableCreateCompanionBuilder =
    DbPostsCompanion Function({
      Value<int> id,
      required int discussionId,
      Value<int> number,
      Value<int> userId,
      Value<String> contentType,
      Value<String> contentHtml,
      Value<DateTime?> createdAt,
      Value<DateTime?> editedAt,
      Value<int> likesCount,
      Value<bool> isLiked,
      Value<String> fingerprint,
      Value<String?> rawJson,
      required DateTime syncedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$DbPostsTableUpdateCompanionBuilder =
    DbPostsCompanion Function({
      Value<int> id,
      Value<int> discussionId,
      Value<int> number,
      Value<int> userId,
      Value<String> contentType,
      Value<String> contentHtml,
      Value<DateTime?> createdAt,
      Value<DateTime?> editedAt,
      Value<int> likesCount,
      Value<bool> isLiked,
      Value<String> fingerprint,
      Value<String?> rawJson,
      Value<DateTime> syncedAt,
      Value<DateTime?> deletedAt,
    });

class $$DbPostsTableFilterComposer
    extends Composer<_$AppDatabase, $DbPostsTable> {
  $$DbPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbPostsTable> {
  $$DbPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbPostsTable> {
  $$DbPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DbPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbPostsTable,
          DbPost,
          $$DbPostsTableFilterComposer,
          $$DbPostsTableOrderingComposer,
          $$DbPostsTableAnnotationComposer,
          $$DbPostsTableCreateCompanionBuilder,
          $$DbPostsTableUpdateCompanionBuilder,
          (DbPost, BaseReferences<_$AppDatabase, $DbPostsTable, DbPost>),
          DbPost,
          PrefetchHooks Function()
        > {
  $$DbPostsTableTableManager(_$AppDatabase db, $DbPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> discussionId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> contentHtml = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> likesCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbPostsCompanion(
                id: id,
                discussionId: discussionId,
                number: number,
                userId: userId,
                contentType: contentType,
                contentHtml: contentHtml,
                createdAt: createdAt,
                editedAt: editedAt,
                likesCount: likesCount,
                isLiked: isLiked,
                fingerprint: fingerprint,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int discussionId,
                Value<int> number = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> contentHtml = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> likesCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                required DateTime syncedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbPostsCompanion.insert(
                id: id,
                discussionId: discussionId,
                number: number,
                userId: userId,
                contentType: contentType,
                contentHtml: contentHtml,
                createdAt: createdAt,
                editedAt: editedAt,
                likesCount: likesCount,
                isLiked: isLiked,
                fingerprint: fingerprint,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbPostsTable,
      DbPost,
      $$DbPostsTableFilterComposer,
      $$DbPostsTableOrderingComposer,
      $$DbPostsTableAnnotationComposer,
      $$DbPostsTableCreateCompanionBuilder,
      $$DbPostsTableUpdateCompanionBuilder,
      (DbPost, BaseReferences<_$AppDatabase, $DbPostsTable, DbPost>),
      DbPost,
      PrefetchHooks Function()
    >;
typedef $$DbTagsTableCreateCompanionBuilder =
    DbTagsCompanion Function({
      Value<int> id,
      required String slug,
      required String name,
      Value<String> color,
      Value<String> icon,
      Value<int> position,
      Value<int> discussionCount,
      Value<int?> parentId,
      Value<String?> rawJson,
      required DateTime syncedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$DbTagsTableUpdateCompanionBuilder =
    DbTagsCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> name,
      Value<String> color,
      Value<String> icon,
      Value<int> position,
      Value<int> discussionCount,
      Value<int?> parentId,
      Value<String?> rawJson,
      Value<DateTime> syncedAt,
      Value<DateTime?> deletedAt,
    });

class $$DbTagsTableFilterComposer
    extends Composer<_$AppDatabase, $DbTagsTable> {
  $$DbTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbTagsTable> {
  $$DbTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbTagsTable> {
  $$DbTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get discussionCount => $composableBuilder(
    column: $table.discussionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DbTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbTagsTable,
          DbTag,
          $$DbTagsTableFilterComposer,
          $$DbTagsTableOrderingComposer,
          $$DbTagsTableAnnotationComposer,
          $$DbTagsTableCreateCompanionBuilder,
          $$DbTagsTableUpdateCompanionBuilder,
          (DbTag, BaseReferences<_$AppDatabase, $DbTagsTable, DbTag>),
          DbTag,
          PrefetchHooks Function()
        > {
  $$DbTagsTableTableManager(_$AppDatabase db, $DbTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> discussionCount = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbTagsCompanion(
                id: id,
                slug: slug,
                name: name,
                color: color,
                icon: icon,
                position: position,
                discussionCount: discussionCount,
                parentId: parentId,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String name,
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> discussionCount = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                required DateTime syncedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbTagsCompanion.insert(
                id: id,
                slug: slug,
                name: name,
                color: color,
                icon: icon,
                position: position,
                discussionCount: discussionCount,
                parentId: parentId,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbTagsTable,
      DbTag,
      $$DbTagsTableFilterComposer,
      $$DbTagsTableOrderingComposer,
      $$DbTagsTableAnnotationComposer,
      $$DbTagsTableCreateCompanionBuilder,
      $$DbTagsTableUpdateCompanionBuilder,
      (DbTag, BaseReferences<_$AppDatabase, $DbTagsTable, DbTag>),
      DbTag,
      PrefetchHooks Function()
    >;
typedef $$DbDiscussionTagsTableCreateCompanionBuilder =
    DbDiscussionTagsCompanion Function({
      required String discussionId,
      required int tagId,
      Value<int> sortIndex,
      Value<int> rowid,
    });
typedef $$DbDiscussionTagsTableUpdateCompanionBuilder =
    DbDiscussionTagsCompanion Function({
      Value<String> discussionId,
      Value<int> tagId,
      Value<int> sortIndex,
      Value<int> rowid,
    });

class $$DbDiscussionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $DbDiscussionTagsTable> {
  $$DbDiscussionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbDiscussionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDiscussionTagsTable> {
  $$DbDiscussionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbDiscussionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDiscussionTagsTable> {
  $$DbDiscussionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get discussionId => $composableBuilder(
    column: $table.discussionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);
}

class $$DbDiscussionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbDiscussionTagsTable,
          DbDiscussionTag,
          $$DbDiscussionTagsTableFilterComposer,
          $$DbDiscussionTagsTableOrderingComposer,
          $$DbDiscussionTagsTableAnnotationComposer,
          $$DbDiscussionTagsTableCreateCompanionBuilder,
          $$DbDiscussionTagsTableUpdateCompanionBuilder,
          (
            DbDiscussionTag,
            BaseReferences<
              _$AppDatabase,
              $DbDiscussionTagsTable,
              DbDiscussionTag
            >,
          ),
          DbDiscussionTag,
          PrefetchHooks Function()
        > {
  $$DbDiscussionTagsTableTableManager(
    _$AppDatabase db,
    $DbDiscussionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDiscussionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbDiscussionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbDiscussionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> discussionId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionTagsCompanion(
                discussionId: discussionId,
                tagId: tagId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String discussionId,
                required int tagId,
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbDiscussionTagsCompanion.insert(
                discussionId: discussionId,
                tagId: tagId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbDiscussionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbDiscussionTagsTable,
      DbDiscussionTag,
      $$DbDiscussionTagsTableFilterComposer,
      $$DbDiscussionTagsTableOrderingComposer,
      $$DbDiscussionTagsTableAnnotationComposer,
      $$DbDiscussionTagsTableCreateCompanionBuilder,
      $$DbDiscussionTagsTableUpdateCompanionBuilder,
      (
        DbDiscussionTag,
        BaseReferences<_$AppDatabase, $DbDiscussionTagsTable, DbDiscussionTag>,
      ),
      DbDiscussionTag,
      PrefetchHooks Function()
    >;
typedef $$DbNotificationsTableCreateCompanionBuilder =
    DbNotificationsCompanion Function({
      Value<int> id,
      required String type,
      Value<bool> isRead,
      required DateTime createdAt,
      Value<DateTime?> readAt,
      Value<int?> fromUserId,
      Value<String?> subjectType,
      Value<String?> subjectId,
      Value<String?> contentJson,
      Value<String?> cachedTitle,
      Value<String?> cachedDesc,
      Value<String> fingerprint,
      Value<String?> rawJson,
      required DateTime syncedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$DbNotificationsTableUpdateCompanionBuilder =
    DbNotificationsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<bool> isRead,
      Value<DateTime> createdAt,
      Value<DateTime?> readAt,
      Value<int?> fromUserId,
      Value<String?> subjectType,
      Value<String?> subjectId,
      Value<String?> contentJson,
      Value<String?> cachedTitle,
      Value<String?> cachedDesc,
      Value<String> fingerprint,
      Value<String?> rawJson,
      Value<DateTime> syncedAt,
      Value<DateTime?> deletedAt,
    });

class $$DbNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromUserId => $composableBuilder(
    column: $table.fromUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedTitle => $composableBuilder(
    column: $table.cachedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedDesc => $composableBuilder(
    column: $table.cachedDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromUserId => $composableBuilder(
    column: $table.fromUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedTitle => $composableBuilder(
    column: $table.cachedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedDesc => $composableBuilder(
    column: $table.cachedDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<int> get fromUserId => $composableBuilder(
    column: $table.fromUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachedTitle => $composableBuilder(
    column: $table.cachedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachedDesc => $composableBuilder(
    column: $table.cachedDesc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DbNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbNotificationsTable,
          DbNotification,
          $$DbNotificationsTableFilterComposer,
          $$DbNotificationsTableOrderingComposer,
          $$DbNotificationsTableAnnotationComposer,
          $$DbNotificationsTableCreateCompanionBuilder,
          $$DbNotificationsTableUpdateCompanionBuilder,
          (
            DbNotification,
            BaseReferences<
              _$AppDatabase,
              $DbNotificationsTable,
              DbNotification
            >,
          ),
          DbNotification,
          PrefetchHooks Function()
        > {
  $$DbNotificationsTableTableManager(
    _$AppDatabase db,
    $DbNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbNotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<int?> fromUserId = const Value.absent(),
                Value<String?> subjectType = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> cachedTitle = const Value.absent(),
                Value<String?> cachedDesc = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbNotificationsCompanion(
                id: id,
                type: type,
                isRead: isRead,
                createdAt: createdAt,
                readAt: readAt,
                fromUserId: fromUserId,
                subjectType: subjectType,
                subjectId: subjectId,
                contentJson: contentJson,
                cachedTitle: cachedTitle,
                cachedDesc: cachedDesc,
                fingerprint: fingerprint,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<bool> isRead = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> readAt = const Value.absent(),
                Value<int?> fromUserId = const Value.absent(),
                Value<String?> subjectType = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> cachedTitle = const Value.absent(),
                Value<String?> cachedDesc = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                required DateTime syncedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => DbNotificationsCompanion.insert(
                id: id,
                type: type,
                isRead: isRead,
                createdAt: createdAt,
                readAt: readAt,
                fromUserId: fromUserId,
                subjectType: subjectType,
                subjectId: subjectId,
                contentJson: contentJson,
                cachedTitle: cachedTitle,
                cachedDesc: cachedDesc,
                fingerprint: fingerprint,
                rawJson: rawJson,
                syncedAt: syncedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbNotificationsTable,
      DbNotification,
      $$DbNotificationsTableFilterComposer,
      $$DbNotificationsTableOrderingComposer,
      $$DbNotificationsTableAnnotationComposer,
      $$DbNotificationsTableCreateCompanionBuilder,
      $$DbNotificationsTableUpdateCompanionBuilder,
      (
        DbNotification,
        BaseReferences<_$AppDatabase, $DbNotificationsTable, DbNotification>,
      ),
      DbNotification,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbDiscussionsTableTableManager get dbDiscussions =>
      $$DbDiscussionsTableTableManager(_db, _db.dbDiscussions);
  $$DbFirstPostsTableTableManager get dbFirstPosts =>
      $$DbFirstPostsTableTableManager(_db, _db.dbFirstPosts);
  $$DbDiscussionExcerptCacheTableTableManager get dbDiscussionExcerptCache =>
      $$DbDiscussionExcerptCacheTableTableManager(
        _db,
        _db.dbDiscussionExcerptCache,
      );
  $$DbCacheCollectionItemsTableTableManager get dbCacheCollectionItems =>
      $$DbCacheCollectionItemsTableTableManager(
        _db,
        _db.dbCacheCollectionItems,
      );
  $$DbSyncStatesTableTableManager get dbSyncStates =>
      $$DbSyncStatesTableTableManager(_db, _db.dbSyncStates);
  $$DbUsersTableTableManager get dbUsers =>
      $$DbUsersTableTableManager(_db, _db.dbUsers);
  $$DbPostsTableTableManager get dbPosts =>
      $$DbPostsTableTableManager(_db, _db.dbPosts);
  $$DbTagsTableTableManager get dbTags =>
      $$DbTagsTableTableManager(_db, _db.dbTags);
  $$DbDiscussionTagsTableTableManager get dbDiscussionTags =>
      $$DbDiscussionTagsTableTableManager(_db, _db.dbDiscussionTags);
  $$DbNotificationsTableTableManager get dbNotifications =>
      $$DbNotificationsTableTableManager(_db, _db.dbNotifications);
}
