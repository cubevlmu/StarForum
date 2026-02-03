/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

@immutable
class SetupNextButton extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Function()? onTap;

  const SetupNextButton({
    super.key,
    required this.icon,
    this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return FloatingActionButton(onPressed: onTap, child: Icon(icon));
    }
    return FloatingActionButton.extended(
      onPressed: onTap,
      enableFeedback: onTap != null,
      icon: Icon(icon),
      label: Text(text ?? ""),
    );
  }
}
