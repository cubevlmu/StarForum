/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/di/injector.dart';

class EditorController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();

  final Rxn<TagInfo> primaryTag = Rxn<TagInfo>();
  final RxList<TagInfo> secondaryTags = <TagInfo>[].obs;
  final RxBool isSubmitting = false.obs;

  final TagRepo tagRepo = getIt<TagRepo>();

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
  }

  void insertWrap(String prefix, [String suffix = ""]) {
    _replaceSelection((selected) {
      final normalizedSuffix = suffix.isEmpty ? prefix : suffix;
      if (selected.isEmpty) {
        return "$prefix$normalizedSuffix";
      }
      return "$prefix$selected$normalizedSuffix";
    });
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

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    contentFocusNode.dispose();
    super.onClose();
  }
}
