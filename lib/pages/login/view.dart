/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:forum/pages/login/controller.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  // 主视图
  Widget _buildView(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                controller.account = value;
              },
              decoration: InputDecoration(
                labelText: "账号",
                border: outlineInputBorder,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                controller.password = value;
              },
              decoration: InputDecoration(
                labelText: "密码",
                border: outlineInputBorder,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: controller.isLoading ? null : controller.startLogin,
              child: const Text("登录"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      id: "password_login",
      builder: (_) {
        return PopScope(
          canPop: !controller.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("密码登录"),
              bottom: controller.isLoading
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(2),
                      child: LinearProgressIndicator(),
                    )
                  : null,
            ),
            body: _buildView(context),
          ),
        );
      },
    );
  }
}
