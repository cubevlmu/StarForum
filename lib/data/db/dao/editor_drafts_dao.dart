import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/editor_draft_table.dart';

part 'editor_drafts_dao.g.dart';

@DriftAccessor(tables: [DbEditorDrafts])
class EditorDraftsDao extends DatabaseAccessor<AppDatabase>
    with _$EditorDraftsDaoMixin {
  EditorDraftsDao(super.db);

  Future<List<DbEditorDraft>> list({
    required String forumUrl,
    required int? userId,
    required String target,
  }) {
    final query = select(dbEditorDrafts)
      ..where((draft) {
        final userFilter = userId == null
            ? draft.userId.isNull()
            : draft.userId.equals(userId);
        return draft.forumUrl.equals(forumUrl) &
            userFilter &
            draft.target.equals(target);
      })
      ..orderBy([
        (draft) => OrderingTerm.desc(draft.updatedAt),
        (draft) => OrderingTerm.desc(draft.id),
      ]);
    return query.get();
  }

  Future<int> insertDraft(DbEditorDraftsCompanion draft) {
    return into(dbEditorDrafts).insert(draft);
  }

  Future<int> deleteDraft(int id) {
    return (delete(dbEditorDrafts)..where((draft) => draft.id.equals(id))).go();
  }
}
