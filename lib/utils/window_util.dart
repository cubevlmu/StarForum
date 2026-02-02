/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class WindowResizeObserver with WidgetsBindingObserver {
  static final WindowResizeObserver instance =
      WindowResizeObserver._internal();

  WindowResizeObserver._internal();

  final RxBool resizing = false.obs;
  Timer? _debounce;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
  }

  @override
  void didChangeMetrics() {
    resizing.value = true;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      resizing.value = false;
    });
  }
}
