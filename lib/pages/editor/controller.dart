/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/repository/editor_draft_repository.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/di/injector.dart';

class EditorController extends GetxController {
  EditorController({
    required this.forumUrl,
    required this.userId,
    required this.draftTarget,
    this.initialContent,
  });

  final String forumUrl;
  final int? userId;
  final String draftTarget;
  final String? initialContent;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();

  final Rxn<TagInfo> primaryTag = Rxn<TagInfo>();
  final RxList<TagInfo> secondaryTags = <TagInfo>[].obs;
  final RxBool isSelectingTags = false.obs;
  final RxBool isSubmitting = false.obs;

  final TagRepo tagRepo = getIt<TagRepo>();
  final EditorDraftRepository _draftRepository = getIt<EditorDraftRepository>();
  int? _pendingPrimaryTagId;
  List<int> _pendingSecondaryTagIds = const [];
  int? _activeDraftId;

  @override
  void onInit() {
    super.onInit();
    if (initialContent?.isNotEmpty == true) {
      contentController.text = initialContent!;
    }
    _moveCaretToEnd(titleController);
    _moveCaretToEnd(contentController);
  }

  String buildTagLabel(String fallbackLabel) {
    final primary = primaryTag.value;
    if (primary == null) {
      return fallbackLabel;
    }

    if (secondaryTags.isEmpty) {
      return primary.name;
    }

    return "${primary.name} / ${secondaryTags.map((tag) => tag.name).join(", ")}";
  }

  void applyTagSelection({
    required TagInfo? primary,
    required List<TagInfo> secondary,
  }) {
    primaryTag.value = primary;
    secondaryTags.assignAll(secondary);
    _pendingPrimaryTagId = primary?.id;
    _pendingSecondaryTagIds = secondary.map((tag) => tag.id).toList();
  }

  void resolveDraftTags() {
    final primaryId = _pendingPrimaryTagId;
    if (primaryId != null) {
      primaryTag.value = tagRepo.getTagById(primaryId);
    }
    secondaryTags.assignAll(
      _pendingSecondaryTagIds.map(tagRepo.getTagById).whereType<TagInfo>(),
    );
  }

  void insertWrap(String prefix, [String suffix = ""]) {
    final controller = contentController;
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = text.substring(start, end);
    final normalizedSuffix = suffix.isEmpty ? prefix : suffix;
    final replacement = '$prefix$selected$normalizedSuffix';
    final newText = text.replaceRange(start, end, replacement);

    controller.value = controller.value.copyWith(
      text: newText,
      selection: selected.isEmpty
          ? TextSelection.collapsed(offset: start + prefix.length)
          : TextSelection(
              baseOffset: start + prefix.length,
              extentOffset: start + prefix.length + selected.length,
            ),
      composing: TextRange.empty,
    );
    contentFocusNode.requestFocus();
  }

  void insertLinePrefix(String prefix) {
    _replaceSelection((selected) {
      final value = selected.isEmpty ? "" : selected;
      final lines = value.split("\n");
      return lines.map((line) => "$prefix$line").join("\n");
    });
  }

  void insertSnippet(String snippet, {int cursorOffset = 0}) {
    final controller = contentController;
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final newText = text.replaceRange(start, end, snippet);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + cursorOffset),
      composing: TextRange.empty,
    );
  }

  void insertTextAtCursor(String text) {
    final controller = contentController;
    final selection = controller.selection;
    final value = controller.text;
    final start = selection.isValid ? selection.start : value.length;
    final end = selection.isValid ? selection.end : value.length;
    final newText = value.replaceRange(start, end, text);
    final caret = start + text.length;

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
    contentFocusNode.requestFocus();
  }

  void _replaceSelection(String Function(String selected) transform) {
    final controller = contentController;
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = text.substring(start, end);
    final replacement = transform(selected);
    final newText = text.replaceRange(start, end, replacement);
    final caret = start + replacement.length;

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
    contentFocusNode.requestFocus();
  }

  void _moveCaretToEnd(TextEditingController controller) {
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  Future<void> migrateLegacyDraft() {
    return _draftRepository.migrateLegacyDraft(
      forumUrl: forumUrl,
      userId: userId,
      target: draftTarget,
    );
  }

  Future<List<EditorDraftRecord>> listDrafts() {
    return _draftRepository.list(
      forumUrl: forumUrl,
      userId: userId,
      target: draftTarget,
    );
  }

  Future<EditorDraftRecord?> saveDraft() async {
    final draft = await _draftRepository.save(
      forumUrl: forumUrl,
      userId: userId,
      target: draftTarget,
      input: EditorDraftInput(
        title: titleController.text,
        content: contentController.text,
        primaryTagId: primaryTag.value?.id ?? _pendingPrimaryTagId,
        secondaryTagIds: secondaryTags.isNotEmpty
            ? secondaryTags.map((tag) => tag.id).toList()
            : _pendingSecondaryTagIds,
      ),
    );
    _activeDraftId = draft?.id;
    return draft;
  }

  void loadDraft(EditorDraftRecord draft) {
    _activeDraftId = draft.id;
    titleController.text = draft.title;
    contentController.text = draft.content;
    _pendingPrimaryTagId = draft.primaryTagId;
    _pendingSecondaryTagIds = draft.secondaryTagIds;
    resolveDraftTags();
    _moveCaretToEnd(titleController);
    _moveCaretToEnd(contentController);
  }

  Future<void> deleteDraft(int id) async {
    await _draftRepository.delete(id);
    if (_activeDraftId == id) _activeDraftId = null;
  }

  Future<void> deleteActiveDraft() async {
    final id = _activeDraftId;
    if (id == null) return;
    await deleteDraft(id);
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.onClose();
  }
}
