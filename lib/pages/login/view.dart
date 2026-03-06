/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/login/controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  Widget _buildView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                labelText: AppLocalizations.of(context)!.loginAccountLabel,
                border: outlineInputBorder,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return TextField(
                obscureText: controller.obscurePassword.value,
                onChanged: (value) {
                  controller.password = value;
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.loginPasswordLabel,
                  border: outlineInputBorder,
                  suffixIcon: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(0, 0, 5, 0),
                    child: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.togglePasswordVisible,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Checkbox(
                      value: controller.autoRelogin.value,
                      onChanged: (b) {
                        if (b == null) return;
                        controller.autoRelogin.value = b;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.loginRememberMe,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: controller.isLoading ? null : controller.startLogin,
              child: Text(AppLocalizations.of(context)!.loginButton),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => launchUrlString(Api.getBaseUrl),
              child: Text(
                AppLocalizations.of(context)!.loginRegister,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
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
              title: Text(AppLocalizations.of(context)!.loginTitle),
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
