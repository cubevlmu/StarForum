/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/login/controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    this.embedded = false,
    this.showEmbeddedBack = false,
    this.onEmbeddedLeadingPressed,
    this.onLoginSuccess,
  });

  final bool embedded;
  final bool showEmbeddedBack;
  final VoidCallback? onEmbeddedLeadingPressed;
  final Future<void> Function(UserInfo user)? onLoginSuccess;

  Widget _buildView(BuildContext context, LoginController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var outlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          controller.account = value;
                        },
                        decoration: InputDecoration(
                          labelText: l10n.loginAccountLabel,
                          border: outlineInputBorder,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return TextField(
                          obscureText: controller.obscurePassword.value,
                          onChanged: (value) {
                            controller.password = value;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.loginPasswordLabel,
                            border: outlineInputBorder,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 5),
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
                      const SizedBox(height: 12),
                      Obx(
                        () => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: controller.autoRelogin.value,
                          onChanged: (b) {
                            if (b == null) return;
                            controller.autoRelogin.value = b;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            l10n.loginRememberMe,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          if (controller.isLoading) return;
                          controller.startLogin();
                        },
                        child: SizedBox(
                          height: 22,
                          child: Center(
                            child: controller.isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primaryContainer,
                                      ),
                                    ),
                                  )
                                : Text(l10n.loginButton),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => launchUrlString(Api.getBaseUrl),
                          child: Text(
                            l10n.loginRegister,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(
        onLoginSuccessCallback: onLoginSuccess,
        closeToRootOnSuccess: !embedded,
      ),
      id: "password_login",
      builder: (controller) {
        return PopScope(
          canPop: !controller.isLoading,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: !embedded,
              leading: embedded
                  ? IconButton(
                      icon: Icon(
                        showEmbeddedBack
                            ? Icons.arrow_back_rounded
                            : Icons.close_rounded,
                      ),
                      onPressed: onEmbeddedLeadingPressed,
                    )
                  : null,
              title: Text(AppLocalizations.of(context)!.loginTitle),
            ),
            body: _buildView(context, controller),
          ),
        );
      },
    );
  }
}

class LoginPaneNavigator extends StatefulWidget {
  const LoginPaneNavigator({
    super.key,
    required this.onClose,
    required this.onBack,
    required this.canPopDetail,
    required this.onLoginSuccess,
  });

  final VoidCallback onClose;
  final VoidCallback onBack;
  final bool canPopDetail;
  final Future<void> Function(UserInfo user) onLoginSuccess;

  @override
  State<LoginPaneNavigator> createState() => _LoginPaneNavigatorState();
}

class _LoginPaneNavigatorState extends State<LoginPaneNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => LoginPage(
            embedded: true,
            showEmbeddedBack: widget.canPopDetail,
            onEmbeddedLeadingPressed: _handleLeadingPressed,
            onLoginSuccess: widget.onLoginSuccess,
          ),
          settings: settings,
        );
      },
    );
  }

  void _handleLeadingPressed() {
    if (widget.canPopDetail) {
      widget.onBack();
      return;
    }
    widget.onClose();
  }
}
