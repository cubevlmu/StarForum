import 'dart:convert';

import 'package:star_forum/data/json/json_reader.dart';

import 'json_api_error.dart';
import 'json_api_included_index.dart';
import 'json_api_resource.dart';

class JsonApiDocument {
  JsonApiDocument({
    required this.raw,
    required this.links,
    required this.data,
    required this.included,
    required this.meta,
    required this.errors,
  });

  final JsonMap raw;
  final JsonMap links;
  final Object? data;
  final List<JsonApiResource> included;
  final JsonMap meta;
  final List<JsonApiError> errors;

  bool get hasErrors => errors.isNotEmpty;

  late final JsonApiIncludedIndex index = JsonApiIncludedIndex(included);

  JsonApiResource? includedOne(JsonApiResource owner, String relation) {
    final identifiers = owner.relationshipIdentifiers(relation);
    if (identifiers.isEmpty) return null;
    final identifier = identifiers.first;
    return index.find(identifier.type, identifier.id);
  }

  List<JsonApiResource> includedMany(JsonApiResource owner, String relation) {
    return owner
        .relationshipIdentifiers(relation)
        .map((identifier) => index.find(identifier.type, identifier.id))
        .whereType<JsonApiResource>()
        .toList(growable: false);
  }

  factory JsonApiDocument.from(Object? raw) {
    Object? decoded = raw;
    if (raw is String && raw.isNotEmpty) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        decoded = const <String, Object?>{};
      }
    }
    final json = asJsonMap(decoded);
    return JsonApiDocument(
      raw: json,
      links: asJsonMap(json['links']),
      data: json['data'],
      included: [
        for (final item in asJsonList(json['included']))
          JsonApiResource.from(item),
      ],
      meta: asJsonMap(json['meta']),
      errors: [
        for (final item in asJsonList(json['errors'])) JsonApiError.from(item),
      ],
    );
  }
}
