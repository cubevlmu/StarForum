import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/dao/editor_drafts_dao.dart';
import 'package:star_forum/utils/storage_utils.dart';

@immutable
class EditorDraftRecord {
  const EditorDraftRecord({
    required this.id,
    required this.title,
    required this.content,
    required this.primaryTagId,
    required this.secondaryTagIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String content;
  final int? primaryTagId;
  final List<int> secondaryTagIds;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
class EditorDraftInput {
  const EditorDraftInput({
    required this.title,
    required this.content,
    required this.primaryTagId,
    required this.secondaryTagIds,
  });

  final String title;
  final String content;
  final int? primaryTagId;
  final List<int> secondaryTagIds;

  bool get isEmpty =>
      title.trim().isEmpty &&
      content.trim().isEmpty &&
      primaryTagId == null &&
      secondaryTagIds.isEmpty;
}

class EditorDraftRepository {
  EditorDraftRepository(this.dao);

  final EditorDraftsDao dao;

  Future<List<EditorDraftRecord>> list({
    required String forumUrl,
    required int? userId,
    required String target,
  }) async {
    final rows = await dao.list(
      forumUrl: forumUrl,
      userId: userId,
      target: target,
    );
    return rows.map(_fromDb).toList(growable: false);
  }

  Future<EditorDraftRecord?> save({
    required String forumUrl,
    required int? userId,
    required String target,
    required EditorDraftInput input,
  }) async {
    if (input.isEmpty) return null;
    final now = DateTime.now();
    final id = await dao.insertDraft(
      DbEditorDraftsCompanion.insert(
        forumUrl: forumUrl,
        userId: Value(userId),
        target: target,
        title: Value(input.title),
        content: Value(input.content),
        primaryTagId: Value(input.primaryTagId),
        secondaryTagIds: Value(jsonEncode(input.secondaryTagIds)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return EditorDraftRecord(
      id: id,
      title: input.title,
      content: input.content,
      primaryTagId: input.primaryTagId,
      secondaryTagIds: List.unmodifiable(input.secondaryTagIds),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> delete(int id) async {
    await dao.deleteDraft(id);
  }

  Future<void> migrateLegacyDraft({
    required String forumUrl,
    required int? userId,
    required String target,
  }) async {
    final keys = <String>{
      _legacyKey(forumUrl: forumUrl, userId: userId, target: target),
      if (userId != null)
        _legacyKey(forumUrl: forumUrl, userId: null, target: target),
    };
    for (final key in keys) {
      await _migrateLegacyKey(
        key: key,
        forumUrl: forumUrl,
        userId: userId,
        target: target,
      );
    }
  }

  Future<void> _migrateLegacyKey({
    required String key,
    required String forumUrl,
    required int? userId,
    required String target,
  }) async {
    final rawDraft = StorageUtils.history.get(key);
    if (rawDraft == null) return;
    final input = _legacyInput(rawDraft);
    if (input == null || input.isEmpty) {
      await StorageUtils.history.delete(key);
      return;
    }

    final existing = await list(
      forumUrl: forumUrl,
      userId: userId,
      target: target,
    );
    final alreadyMigrated = existing.any(
      (draft) =>
          draft.title == input.title &&
          draft.content == input.content &&
          draft.primaryTagId == input.primaryTagId &&
          listEquals(draft.secondaryTagIds, input.secondaryTagIds),
    );
    if (!alreadyMigrated) {
      await save(
        forumUrl: forumUrl,
        userId: userId,
        target: target,
        input: input,
      );
    }
    await StorageUtils.history.delete(key);
  }

  EditorDraftRecord _fromDb(DbEditorDraft row) {
    return EditorDraftRecord(
      id: row.id,
      title: row.title,
      content: row.content,
      primaryTagId: row.primaryTagId,
      secondaryTagIds: _decodeIds(row.secondaryTagIds),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<int> _decodeIds(String source) {
    try {
      final value = jsonDecode(source);
      if (value is! List) return const [];
      return value
          .map((item) => item is int ? item : int.tryParse('$item'))
          .whereType<int>()
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  String _legacyKey({
    required String forumUrl,
    required int? userId,
    required String target,
  }) {
    return 'editorDraft:v1:$forumUrl:${userId ?? 'guest'}:$target';
  }

  EditorDraftInput? _legacyInput(Object? value) {
    if (value is! Map) return null;
    final ids = <int>[];
    final rawIds = value['secondaryTagIds'];
    if (rawIds is Iterable) {
      for (final item in rawIds) {
        final id = item is int ? item : int.tryParse('$item');
        if (id != null) ids.add(id);
      }
    }
    final rawPrimaryTagId = value['primaryTagId'];
    return EditorDraftInput(
      title: value['title'] is String ? value['title'] as String : '',
      content: value['content'] is String ? value['content'] as String : '',
      primaryTagId: rawPrimaryTagId is int
          ? rawPrimaryTagId
          : int.tryParse('$rawPrimaryTagId'),
      secondaryTagIds: ids,
    );
  }
}
