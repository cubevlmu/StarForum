import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:forum/pages/settings/widgets/settings_label.dart';
import 'package:forum/pages/settings/widgets/settings_switch_tile.dart';
import 'package:forum/utils/string_util.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CommonSettingsPage extends StatelessWidget {
  const CommonSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("通用设置")),
      body: ListView(
        children: [
          const SettingsSwitchTile(
            title: '自动检查更新',
            subTitle: '是否在启动app时检查更新',
            settingsKey: SettingsStorageKeys.autoCheckUpdate,
            defualtValue: true,
          ),
          // const SettingsLabel(text: '首页推荐'),
          // SettingsRadiosTile(
          //   title: '推荐列数',
          //   subTitle: '首页推荐卡片的列数',
          //   buildTrailingText: () => SettingsUtil.getValue(
          //           SettingsStorageKeys.recommendColumnCount,
          //           defaultValue: 2)
          //       .toString(),
          //   itemNameValue: const {'1': 1, '2': 2, '3': 3, '4': 4, '5': 5},
          //   buildGroupValue: () => SettingsUtil.getValue(
          //       SettingsStorageKeys.recommendColumnCount,
          //       defaultValue: 2),
          //   applyValue: (value) async {
          //     await SettingsUtil.setValue(
          //         SettingsStorageKeys.recommendColumnCount, value);
          //     Get.find<RecommendController>().recommendColumnCount = value;
          //     await Get.find<RecommendController>()
          //         .refreshController
          //         .callRefresh();
          //     Get.find<LiveTabPageController>().columnCount = value;
          //     await Get.find<LiveTabPageController>()
          //         .refreshController
          //         .callRefresh();
          //   },
          // ),
          // const SettingsLabel(text: '搜索'),
          // const SettingsSwitchTile(
          //     title: '显示搜索默认词',
          //     subTitle: '是否显示搜索默认词',
          //     settingsKey: SettingsStorageKeys.showSearchDefualtWord,
          //     defualtValue: true),
          // const SettingsSwitchTile(
          //     title: '显示热搜',
          //     subTitle: '是否显示热搜',
          //     settingsKey: SettingsStorageKeys.showHotSearch,
          //     defualtValue: true),
          // const SettingsSwitchTile(
          //     title: '显示搜索历史记录',
          //     subTitle: '是否显示搜索历史记录',
          //     settingsKey: SettingsStorageKeys.showSearchHistory,
          //     defualtValue: true),
          // const SettingsLabel(text: '弹幕'),
          // const SettingsSwitchTile(
          //     title: '默认打开弹幕',
          //     subTitle: '在进入视频的时候是否默认打开弹幕',
          //     settingsKey: SettingsStorageKeys.defaultShowDanmaku,
          //     defualtValue: true),
          // const SettingsSwitchTile(
          //     title: '记住弹幕开关状态',
          //     subTitle: '是否在切换视频后记住上一次视频的弹幕开关状态',
          //     settingsKey: SettingsStorageKeys.rememberDanmakuSwitch,
          //     defualtValue: false),
          // const SettingsSwitchTile(
          //     title: '记住弹幕设置',
          //     subTitle: '是否在切换视频后记住字体大小、不透明度、播放速度',
          //     settingsKey: SettingsStorageKeys.rememberDanmakuSettings,
          //     defualtValue: true),
          // SettingsSliderTile(
          //   title: '默认字体大小',
          //   subTitle: '弹幕字体大小缩放',
          //   settingsKey: SettingsStorageKeys.defaultDanmakuScale,
          //   defualtValue: 1.0,
          //   min: 0.25,
          //   max: 4,
          //   divisions: 100,
          //   buildLabel: (selectingValue) =>
          //       "${selectingValue.toStringAsFixed(2)}X",
          // ),
          // SettingsSliderTile(
          //   title: '默认不透明度',
          //   subTitle: '弹幕字体不透明度',
          //   settingsKey: SettingsStorageKeys.defaultDanmakuOpacity,
          //   defualtValue: 0.6,
          //   min: 0.01,
          //   max: 1.0,
          //   divisions: 100,
          //   buildLabel: (selectingValue) =>
          //       "${(selectingValue * 100).toStringAsFixed(0)}%",
          // ),
          // SettingsSliderTile(
          //   title: '默认滚动速度',
          //   subTitle: '弹幕滚动速度',
          //   settingsKey: SettingsStorageKeys.defaultDanmakuSpeed,
          //   defualtValue: 1.0,
          //   min: 0.25,
          //   max: 4,
          //   divisions: 15,
          //   buildLabel: (selectingValue) => "${selectingValue}X",
          // ),
          // const SettingsLabel(text: '视频'),
          // SettingsSwitchTile(
          //   title: '启用硬解',
          //   subTitle: '是否启用硬件解码否则使用软解',
          //   settingsKey: SettingsStorageKeys.isHardwareDecode,
          //   defualtValue: true,
          //   apply: () async {
          //     //应用该设置项
          //     await PlayersSingleton().dispose();
          //     await PlayersSingleton().init();
          //   },
          // ),
          // const SettingsSwitchTile(
          //     title: '后台播放',
          //     subTitle: '是否在应用进入到后台时继续播放',
          //     settingsKey: SettingsStorageKeys.isBackGroundPlay,
          //     defualtValue: true),
          // const SettingsSwitchTile(
          //     title: '详情页直接播放',
          //     subTitle: '是否在进入详情页后自动播放',
          //     settingsKey: SettingsStorageKeys.autoPlayOnInit,
          //     defualtValue: true),
          // const SettingsSwitchTile(
          //     title: '直接全屏',
          //     subTitle: '是否在进入详情页且视频加载完成后直接全屏',
          //     settingsKey: SettingsStorageKeys.fullScreenPlayOnEnter,
          //     defualtValue: false),
          // SettingsRadiosTile(
          //   title: '偏好画质',
          //   subTitle: '视频播放时默认偏向选择的画质',
          //   buildTrailingText: () =>
          //       SettingsUtil.getPreferVideoQuality().description,
          //   itemNameValue: {
          //     for (var element in VideoQuality.values)
          //       if (element != VideoQuality.unknown)
          //         element.description: element
          //   },
          //   buildGroupValue: SettingsUtil.getPreferVideoQuality,
          //   applyValue: (value) async {
          //     await SettingsUtil.putPreferVideoQuality(value);
          //   },
          // ),
          // SettingsRadiosTile(
          //   title: '偏好视频编码',
          //   subTitle: '默认偏好选择的视频编码',
          //   buildTrailingText: () => SettingsUtil.getValue(
          //       SettingsStorageKeys.preferVideoCodec,
          //       defaultValue: 'hev'),
          //   itemNameValue: const {
          //     'hev(h265)': 'hev',
          //     'avc(h264)': 'avc',
          //     'av1': 'av01'
          //   },
          //   buildGroupValue: () => SettingsUtil.getValue(
          //       SettingsStorageKeys.preferVideoCodec,
          //       defaultValue: 'hev'),
          //   applyValue: (value) {
          //     SettingsUtil.setValue(
          //         SettingsStorageKeys.preferVideoCodec, value);
          //   },
          // ),
          // SettingsRadiosTile(
          //   title: '偏好音质',
          //   subTitle: '视频播放时默认偏向选择的音质',
          //   buildTrailingText: () =>
          //       SettingsUtil.getPreferAudioQuality().description,
          //   itemNameValue: {
          //     for (var element in AudioQuality.values)
          //       if (element != AudioQuality.unknown)
          //         element.description: element
          //   },
          //   buildGroupValue: SettingsUtil.getPreferAudioQuality,
          //   applyValue: (value) async {
          //     await SettingsUtil.putPreferAudioQuality(value);
          //   },
          // ),
          // SettingsSliderTile(
          //   title: '默认播放速度',
          //   subTitle: '视频默认播放速度',
          //   settingsKey: SettingsStorageKeys.defaultVideoPlaybackSpeed,
          //   defualtValue: 1.0,
          //   min: 0.25,
          //   max: 4,
          //   divisions: 15,
          //   buildLabel: (selectingValue) => "${selectingValue}X",
          // )
          const SettingsLabel(text: '缓存'),
          ListTile(
            title: const Text("缓存管理"),
            onTap: () {
              Navigator.of(
                context,
              ).push(GetPageRoute(page: () => const CacheManagementPage()));
            },
          ),
        ],
      ),
    );
  }
}


class CacheManagementPage extends StatefulWidget {
  const CacheManagementPage({super.key});

  @override
  State<CacheManagementPage> createState() => _CacheManagementPageState();
}

class _CacheManagementPageState extends State<CacheManagementPage> {
  List<Widget> items = [];

  Future<double> getTotalSizeOfFilesInDir(FileSystemEntity file) async {
    if (file is File && await file.exists()) {
      int length = await file.length();
      return length.toDouble();
    }
    if (file is Directory && await file.exists()) {
      List children = file.listSync();
      double total = 0;
      if (children.isNotEmpty) {
        for (FileSystemEntity child in children) {
          total += await getTotalSizeOfFilesInDir(child);
        }
      }
      return total;
    }
    return 0;
  }

  Future<void> buildItems() async {
    items.clear();
    var dir = await getTemporaryDirectory();
    for (var element in dir.listSync()) {
      if (element is Directory && await element.exists()) {
        //我们只取保存在文件夹的缓存
        //如果是文件夹的话，就计算它的大小
        double size = await getTotalSizeOfFilesInDir(element);
        items.add(ListTile(
          title: Text(element.path.split('/').last),
          subtitle: Text(StringUtil.byteNumToFileSize(size)),
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("是否删除该缓存？"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("否")),
                  TextButton(
                      onPressed: () {
                        element.deleteSync(recursive: true);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: const Text("是")),
                ],
              ),
            );
          },
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("缓存管理"),
      ),
      body: FutureBuilder(
        future: buildItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(children: items);
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }
}
