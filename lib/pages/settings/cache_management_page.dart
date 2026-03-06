/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:path_provider/path_provider.dart';

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
        items.add(
          ListTile(
            title: Text(element.path.split('/').last),
            subtitle: Text(StringUtil.byteNumToFileSize(size)),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.dialogDeleteCacheConfirm,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.dialogNo),
                    ),
                    TextButton(
                      onPressed: () {
                        element.deleteSync(recursive: true);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: Text(AppLocalizations.of(context)!.dialogYes),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsCacheManagement),
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
