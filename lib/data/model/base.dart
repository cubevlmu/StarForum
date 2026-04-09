/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap asJsonMap(Object? value) {
  if (value is JsonMap) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return <String, Object?>{};
}

List<Object?> asJsonList(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const <Object?>[];
}

class JsonValue {
  static String asString(Object? value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static int asInt(Object? value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool asBool(Object? value, [bool fallback = false]) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
        case '1':
          return true;
        case 'false':
        case '0':
          return false;
      }
    }
    return fallback;
  }

  static DateTime asDateTime(Object? value, [DateTime? fallback]) {
    final defaultValue = fallback ?? DateTime.utc(1980);
    if (value == null) return defaultValue;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
}

@immutable
class JsonReader {
  final JsonMap json;

  const JsonReader(this.json);

  Object? operator [](String key) => json[key];

  bool contains(String key) => json.containsKey(key);

  String string(String key, [String fallback = '']) {
    return JsonValue.asString(json[key], fallback);
  }

  int integer(String key, [int fallback = 0]) {
    return JsonValue.asInt(json[key], fallback);
  }

  bool boolean(String key, [bool fallback = false]) {
    return JsonValue.asBool(json[key], fallback);
  }

  DateTime dateTime(String key, [DateTime? fallback]) {
    return JsonValue.asDateTime(json[key], fallback);
  }

  JsonMap map(String key) => asJsonMap(json[key]);

  List<Object?> list(String key) => asJsonList(json[key]);
}

class BaseBean {
  final Links links;
  final BaseData data;
  final BaseIncluded included;

  const BaseBean(this.links, this.data, this.included);

  factory BaseBean.fromMap(Map map) {
    final baseBean = PrivateBaseBean.fromMap(map);
    return BaseBean(
      Links.formBase(baseBean),
      BaseData.formBase(baseBean),
      BaseIncluded.formBase(baseBean),
    );
  }
}

class BaseListBean {
  final Links links;
  final BaseDataList data;
  final BaseIncluded included;

  const BaseListBean(this.links, this.data, this.included);

  factory BaseListBean.fromMap(Map map) {
    final base = PrivateBaseBean.fromMap(map);
    return BaseListBean(
      Links.formBase(base),
      BaseDataList.formBase(base),
      BaseIncluded.formBase(base),
    );
  }
}

@immutable
class PrivateBaseBean {
  final JsonMap links;
  final Object? data;
  final List<Object?> included;

  const PrivateBaseBean(this.links, this.data, this.included);

  factory PrivateBaseBean.fromMap(Map map) {
    final json = asJsonMap(map);
    return PrivateBaseBean(
      asJsonMap(json['links']),
      json['data'],
      asJsonList(json['included']),
    );
  }
}

@immutable
class BaseData {
  final String type;
  final int id;
  final JsonMap attributes;
  final JsonMap relationships;

  const BaseData(this.type, this.id, this.attributes, this.relationships);

  JsonReader get attrs => JsonReader(attributes);
  JsonReader get rels => JsonReader(relationships);

  factory BaseData.formBase(PrivateBaseBean baseBean) {
    return BaseData.formMap(asJsonMap(baseBean.data));
  }

  factory BaseData.formMap(Map j) {
    final json = asJsonMap(j);
    return BaseData(
      JsonValue.asString(json['type']),
      JsonValue.asInt(json['id']),
      asJsonMap(json['attributes']),
      asJsonMap(json['relationships']),
    );
  }

  int relatedId(String key, [int fallback = 0]) {
    final data = asJsonMap(asJsonMap(relationships[key])['data']);
    return JsonValue.asInt(data['id'], fallback);
  }

  List<int> relatedIds(String key) {
    final rawData = asJsonList(asJsonMap(relationships[key])['data']);
    final result = <int>[];
    for (final item in rawData) {
      final id = JsonValue.asInt(asJsonMap(item)['id'], -1);
      if (id >= 0) {
        result.add(id);
      }
    }
    return result;
  }

  String relatedType(String key, [String fallback = '']) {
    final data = asJsonMap(asJsonMap(relationships[key])['data']);
    return JsonValue.asString(data['type'], fallback);
  }

  JsonMap relatedData(String key) {
    return asJsonMap(asJsonMap(relationships[key])['data']);
  }
}

@immutable
class BaseDataList {
  final List<BaseData> list;

  const BaseDataList(this.list);

  factory BaseDataList.formBase(PrivateBaseBean baseBean) {
    return BaseDataList.formList(asJsonList(baseBean.data));
  }

  factory BaseDataList.formList(List<Object?> l) {
    final result = <BaseData>[];
    for (final map in l) {
      result.add(BaseData.formMap(asJsonMap(map)));
    }
    return BaseDataList(result);
  }
}

class BaseIncluded {
  final List<BaseData> data;
  late final Map<String, Map<int, BaseData>> _index = _buildIndex(data);

  BaseIncluded(this.data);

  factory BaseIncluded.formBase(PrivateBaseBean baseBean) {
    final result = <BaseData>[];
    for (final map in baseBean.included) {
      result.add(BaseData.formMap(asJsonMap(map)));
    }
    return BaseIncluded(result);
  }

  Iterable<BaseData> ofType(String type) {
    return _index[type]?.values ?? const <BaseData>[];
  }

  BaseData? find(String type, int id) => _index[type]?[id];

  static Map<String, Map<int, BaseData>> _buildIndex(List<BaseData> values) {
    final result = <String, Map<int, BaseData>>{};
    for (final value in values) {
      result.putIfAbsent(value.type, () => <int, BaseData>{})[value.id] = value;
    }
    return result;
  }
}

class Links {
  final String first;
  final String prev;
  final String next;

  static final Links empty = Links(first: '', prev: '', next: '');

  factory Links.formBase(PrivateBaseBean baseBean) {
    final reader = JsonReader(baseBean.links);
    if (baseBean.links.isEmpty) {
      return empty;
    }
    return Links(
      first: reader.string('first'),
      prev: reader.string('prev'),
      next: reader.string('next'),
    );
  }

  const Links({required this.first, required this.prev, required this.next});
}
