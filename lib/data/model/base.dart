/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class BaseBean {
  final Map links;
  final dynamic data;
  final List<dynamic> included;

  BaseBean._(this.links, this.data, this.included);

  factory BaseBean.fromMap(Map map) {
    return BaseBean._(map["links"] ?? {}, map["data"], map["included"] ?? []);
  }
}

class BaseListBean {
  Links links;
  BaseDataList data;
  BaseIncluded included;

  BaseListBean(this.links, this.data, this.included);

  factory BaseListBean.fromMap(Map map) {
    final base = BaseBean.fromMap(map);
    return BaseListBean(
      Links.fromBase(base),
      BaseDataList.fromBase(base),
      BaseIncluded.fromBase(base),
    );
  }
}

class BaseData {
  String type;
  int id;
  Map attributes;
  Map relationships;

  BaseData(this.type, this.id, this.attributes, this.relationships);

  factory BaseData.fromBase(BaseBean baseBean) {
    Map j = baseBean.data;
    return BaseData.formMap(j);
  }

  factory BaseData.formMap(Map j) {
    return BaseData(
      j["type"],
      int.parse(j["id"]),
      j["attributes"],
      j["relationships"] ?? {},
    );
  }
}

class BaseDataList {
  List<BaseData> list = [];

  BaseDataList(this.list);

  factory BaseDataList.fromBase(BaseBean baseBean) {
    List l = baseBean.data;
    return BaseDataList.formList(l);
  }

  factory BaseDataList.formList(List l) {
    List<BaseData> li = [];
    for (var map in l) {
      li.add(BaseData.formMap(map));
    }
    return BaseDataList(li);
  }
}

class BaseIncluded {
  final List<BaseData> data;

  BaseIncluded(this.data);

  factory BaseIncluded.fromBase(BaseBean baseBean) {
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

  factory Links.fromBase(BaseBean baseBean) {
    final j = baseBean.links;
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
