/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class LicenseView extends StatelessWidget {
  const LicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: FutureBuilder<String>(
        future: rootBundle.loadString('assets/licenses/GPL-2.0.txt'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("协议加载失败"));
          }

          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.only(right: 12),
              child: SelectableText(
                snapshot.data!,
                textAlign: .center,
                style: textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ),
          );
        },
      ),
    );
  }
}
