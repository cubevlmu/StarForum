/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/utils/log_util.dart';

class SimpleEasyRefresher extends StatefulWidget {
  const SimpleEasyRefresher({
    super.key,
    required this.easyRefreshController,
    this.onLoad,
    this.onRefresh,
    required this.childBuilder,
    this.indicatorPosition = IndicatorPosition.above,
  });
  final EasyRefreshController? easyRefreshController;
  final FutureOr<dynamic> Function()? onLoad;
  final FutureOr<dynamic> Function()? onRefresh;
  final Widget Function(BuildContext context, ScrollPhysics physics)?
  childBuilder;
  final IndicatorPosition indicatorPosition;

  @override
  State<SimpleEasyRefresher> createState() => _SimpleEasyRefresherState();
}

class _SimpleEasyRefresherState extends State<SimpleEasyRefresher> {
  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      refreshOnStart: true,
      resetAfterRefresh: true,
      onLoad: () async {
        await widget.onLoad?.call();
        try {
          setState(() {});
        } catch (e, s) {
          LogUtil.errorE("[Refresher] Exception happend on setState", e, s);
        }
      },
      onRefresh: () async {
        await widget.onRefresh?.call();
        try {
          setState(() {});
        } catch (e, s) {
          LogUtil.errorE("[Refresher] Exception happend on setState:", e, s);
        }
      },
      header: ClassicHeader(
        hitOver: true,
        safeArea: true,
        processedDuration: Duration.zero,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: "正在刷新...",
        readyText: "正在刷新...",
        armedText: "释放以刷新",
        dragText: "下拉刷新",
        processedText: "刷新成功",
        failedText: "刷新失败",
      ),
      footer: ClassicFooter(
        processedDuration: Duration.zero,
        safeArea: true,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: "加载中...",
        processedText: "加载成功",
        readyText: "加载中...",
        armedText: "释放以加载更多",
        dragText: "上拉加载",
        failedText: "加载失败",
        noMoreText: "没有更多内容",
      ),
      controller: widget.easyRefreshController,
      childBuilder: widget.childBuilder,
    );
  }
}
