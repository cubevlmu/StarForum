import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isHomeSearchActive = false.obs;
  final RxnString homeSearchKeyword = RxnString();

  void onDestinationSelected(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (selectedIndex.value == index) return;
    if (index != 0) {
      isHomeSearchActive.value = false;
      homeSearchKeyword.value = null;
    }
    selectedIndex.value = index;
  }

  void openHomeSearch() {
    isHomeSearchActive.value = true;
    homeSearchKeyword.value = null;
  }

  void closeHomeSearch() {
    isHomeSearchActive.value = false;
    homeSearchKeyword.value = null;
  }

  void submitHomeSearch(String keyword) {
    isHomeSearchActive.value = true;
    if (homeSearchKeyword.value == keyword) {
      homeSearchKeyword.value = '';
      Future.microtask(() {
        homeSearchKeyword.value = keyword;
      });
      return;
    }
    homeSearchKeyword.value = keyword;
  }

  void editHomeSearch() {
    homeSearchKeyword.value = null;
  }
}
