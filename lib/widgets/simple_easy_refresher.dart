/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class SimpleEasyRefresher extends StatefulWidget {
  const SimpleEasyRefresher({
    super.key,
    required this.easyRefreshController,
    this.onLoad,
    this.onRefresh,
    required this.childBuilder,
    this.indicatorPosition = IndicatorPosition.above,
    this.autoRefreshOnStart = true,
    this.refreshEnabled = true,
    this.loadEnabled = true,
  });
  final EasyRefreshController? easyRefreshController;
  final FutureOr<dynamic> Function()? onLoad;
  final FutureOr<dynamic> Function()? onRefresh;
  final Widget Function(BuildContext context, ScrollPhysics physics)?
  childBuilder;
  final bool autoRefreshOnStart;
  final IndicatorPosition indicatorPosition;
  final bool refreshEnabled;
  final bool loadEnabled;

  @override
  State<SimpleEasyRefresher> createState() => _SimpleEasyRefresherState();
}

class _SimpleEasyRefresherState extends State<SimpleEasyRefresher> {
  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      refreshOnStart: widget.autoRefreshOnStart,
      resetAfterRefresh: true,
      onLoad: widget.loadEnabled
          ? () async {
              await widget.onLoad?.call();
            }
          : null,
      onRefresh: widget.refreshEnabled
          ? () async {
              await widget.onRefresh?.call();
            }
          : null,
      header: ClassicHeader(
        hitOver: true,
        safeArea: true,
        processedDuration: Duration.zero,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: AppLocalizations.of(context)!.refreshRefreshing,
        readyText: AppLocalizations.of(context)!.refreshRefreshing,
        armedText: AppLocalizations.of(context)!.refreshReleaseToRefresh,
        dragText: AppLocalizations.of(context)!.refreshPullToRefresh,
        processedText: AppLocalizations.of(context)!.refreshRefreshSuccess,
        failedText: AppLocalizations.of(context)!.refreshRefreshFailed,
      ),
      footer: ClassicFooter(
        processedDuration: Duration.zero,
        safeArea: true,
        showMessage: false,
        showText: true,
        position: widget.indicatorPosition,
        processingText: AppLocalizations.of(context)!.refreshLoading,
        processedText: AppLocalizations.of(context)!.refreshLoadSuccess,
        readyText: AppLocalizations.of(context)!.refreshLoading,
        armedText: AppLocalizations.of(context)!.refreshReleaseToLoad,
        dragText: AppLocalizations.of(context)!.refreshPullToLoad,
        failedText: AppLocalizations.of(context)!.refreshLoadFailed,
        noMoreText: AppLocalizations.of(context)!.refreshNoMore,
      ),
      controller: widget.easyRefreshController,
      childBuilder: widget.childBuilder,
    );
  }
}
