import 'dart:convert';

class BaseBean {
  Links links;
  BaseData data;
  BaseIncluded included;

  BaseBean(this.links, this.data, this.included);

  factory BaseBean.formJson(String data) {
    PrivateBaseBean baseBean = PrivateBaseBean.formJson(data);
    return BaseBean(Links.formBase(baseBean), BaseData.formBase(baseBean),
        BaseIncluded.formBase(baseBean));
  }
}

class BaseListBean {
  Links links;
  BaseDataList data;
  BaseIncluded included;

  BaseListBean(this.links, this.data, this.included);

  factory BaseListBean.formJson(String data) {
    PrivateBaseBean baseBean = PrivateBaseBean.formJson(data);
    return BaseListBean(Links.formBase(baseBean),
        BaseDataList.formBase(baseBean), BaseIncluded.formBase(baseBean));
  }
}

class PrivateBaseBean {
  Map<String, dynamic>? links;
  dynamic data;
  List? included;

  PrivateBaseBean(this.links, this.data, this.included);

  factory PrivateBaseBean.formJson(String data) {
    Map j = json.decode(data);
    return PrivateBaseBean(j["links"], j["data"], j["included"]);
  }
}

class BaseData {
  String type;
  int id;
  Map<String, dynamic> attributes;
  Map<String, dynamic>? relationships;
  Map source;

  BaseData(this.type, this.id, this.attributes, this.relationships,this.source);

  factory BaseData.formBase(PrivateBaseBean baseBean) {
    Map j = baseBean.data;
    return BaseData.formMap(j);
  }

  factory BaseData.formMap(Map j) {
    return BaseData(
        j["type"], int.parse(j["id"]), j["attributes"], j["relationships"],j);
  }
}

class BaseDataList {
  List<BaseData> list = [];

  BaseDataList(this.list);

  factory BaseDataList.formBase(PrivateBaseBean baseBean) {
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
  List<BaseData>? data;

  BaseIncluded(this.data);

  factory BaseIncluded.formBase(PrivateBaseBean baseBean) {
    List? l = baseBean.included;
    List<BaseData> data = [];
    if (l != null) {
      for (var map in l) {
        data.add(BaseData.formMap(map));
      }
      return BaseIncluded(data);
    }
    return BaseIncluded(null);
  }
}

class Links {
  final String first;
  final String prev;
  final String next;

  static Links empty = Links(first: '', prev: '', next: '');

  factory Links.formBase(PrivateBaseBean baseBean) {
    Map? j = baseBean.links;
    if (j == null) {
      return empty;
    }
    return Links(first: j["first"], prev: j["prev"] ?? "", next: j["next"] ?? "");
  }

  Links({required this.first, required this.prev, required this.next});
}
