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
    lastPostNumber,
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
      lastPostNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_post_number'],
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

  /// 作者（discussion.user）
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final DateTime? lastPostedAt;
  final int lastPostNumber;
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
    required this.lastPostNumber,
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
    map['last_post_number'] = Variable<int>(lastPostNumber);
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
      lastPostNumber: Value(lastPostNumber),
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
      lastPostNumber: serializer.fromJson<int>(json['lastPostNumber']),
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
      'lastPostNumber': serializer.toJson<int>(lastPostNumber),
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
    int? lastPostNumber,
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
    lastPostNumber: lastPostNumber ?? this.lastPostNumber,
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
      lastPostNumber: data.lastPostNumber.present
          ? data.lastPostNumber.value
          : this.lastPostNumber,
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
          ..write('lastPostNumber: $lastPostNumber')
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
    lastPostNumber,
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
          other.lastPostNumber == this.lastPostNumber);
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
  final Value<int> lastPostNumber;
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
    this.lastPostNumber = const Value.absent(),
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
    required int lastPostNumber,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       slug = Value(slug),
       commentCount = Value(commentCount),
       participantCount = Value(participantCount),
       createdAt = Value(createdAt),
       lastPostNumber = Value(lastPostNumber);
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
    Expression<int>? lastPostNumber,
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
      if (lastPostNumber != null) 'last_post_number': lastPostNumber,
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
    Value<int>? lastPostNumber,
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
      lastPostNumber: lastPostNumber ?? this.lastPostNumber,
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
    if (lastPostNumber.present) {
      map['last_post_number'] = Variable<int>(lastPostNumber.value);
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
          ..write('lastPostNumber: $lastPostNumber, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbDiscussionsTable dbDiscussions = $DbDiscussionsTable(this);
  late final $DbFirstPostsTable dbFirstPosts = $DbFirstPostsTable(this);
  late final $DbDiscussionExcerptCacheTable dbDiscussionExcerptCache =
      $DbDiscussionExcerptCacheTable(this);
  late final DiscussionsDao discussionsDao = DiscussionsDao(
    this as AppDatabase,
  );
  late final FirstPostsDao firstPostsDao = FirstPostsDao(this as AppDatabase);
  late final ExcerptDao excerptDao = ExcerptDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbDiscussions,
    dbFirstPosts,
    dbDiscussionExcerptCache,
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
      required int lastPostNumber,
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
      Value<int> lastPostNumber,
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

  ColumnFilters<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
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

  ColumnOrderings<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
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

  GeneratedColumn<int> get lastPostNumber => $composableBuilder(
    column: $table.lastPostNumber,
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
                Value<int> lastPostNumber = const Value.absent(),
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
                lastPostNumber: lastPostNumber,
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
                required int lastPostNumber,
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
                lastPostNumber: lastPostNumber,
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
}
