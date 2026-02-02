/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

class BaseBean {
  Links links;
  BaseData data;
  BaseIncluded included;

  BaseBean(this.links, this.data, this.included);

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
  Links links;
  BaseDataList data;
  BaseIncluded included;

  BaseListBean(this.links, this.data, this.included);

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
  final Map<String, dynamic> links;
  final dynamic data;
  final List included;

  const PrivateBaseBean(this.links, this.data, this.included);

  factory PrivateBaseBean.fromMap(Map map) {
    return PrivateBaseBean(map["links"] ?? {}, map["data"], map["included"] ?? []);
  }
}

@immutable
class BaseData {
  final String type;
  final int id;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> relationships;

  const BaseData(
    this.type,
    this.id,
    this.attributes,
    this.relationships,
  );

  factory BaseData.formBase(PrivateBaseBean baseBean) {
    Map j = baseBean.data;
    return BaseData.formMap(j);
  }

  factory BaseData.formMap(Map j) {
    return BaseData(
      j["type"] ?? "",
      int.parse(j["id"]),
      j["attributes"] ?? {},
      j["relationships"] ?? {},
    );
  }
}

@immutable
class BaseDataList {
  final List<BaseData> list;

  const BaseDataList(this.list);

  factory BaseDataList.formBase(PrivateBaseBean baseBean) {
    List l = baseBean.data;
    return BaseDataList.formList(l);
  }

  factory BaseDataList.formList(List l) {
    final r = BaseDataList([]);
    for (var map in l) {
      r.list.add(BaseData.formMap(map));
    }
    return r;
  }
}

class BaseIncluded {
  final List<BaseData> data;

  BaseIncluded(this.data);

  factory BaseIncluded.formBase(PrivateBaseBean baseBean) {
    final r = BaseIncluded([]);
    for (var map in baseBean.included) {
        r.data.add(BaseData.formMap(map));
      }
      return r;
  }
}

class Links {
  final String first;
  final String prev;
  final String next;

  static Links empty = Links(first: '', prev: '', next: '');

  factory Links.formBase(PrivateBaseBean baseBean) {
    Map? j = baseBean.links;
    if (j.isEmpty) {
      return empty;
    }
    return Links(
      first: j["first"],
      prev: j["prev"] ?? "",
      next: j["next"] ?? "",
    );
  }

  Links({required this.first, required this.prev, required this.next});
}
