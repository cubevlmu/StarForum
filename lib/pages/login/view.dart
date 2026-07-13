import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/login/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.embedded = false, this.onLoginSuccess});

  final bool embedded;
  final Future<void> Function(UserInfo user)? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final String _tag;
  late final LoginController controller;
  late final TextEditingController accountController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    _tag = 'LoginPage:${identityHashCode(this)}';
    controller = Get.put(
      LoginController(
        onLoginSuccessCallback: widget.onLoginSuccess,
        closeToRootOnSuccess: !widget.embedded,
      ),
      tag: _tag,
    );
    accountController = TextEditingController(text: controller.account);
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    if (Get.isRegistered<LoginController>(tag: _tag)) {
      Get.delete<LoginController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      tag: _tag,
      id: 'password_login',
      builder: (controller) => PopScope(
        canPop: !controller.isLoading,
        child: Scaffold(
          backgroundColor: context.colors.background,
          body: FUIPage(
            children: [
              _LoginBrandHeader(siteUrl: getIt<ForumRepository>().baseUrl),
              const SizedBox(height: FUITokens.gap20),
              _LoginPanel(
                controller: controller,
                accountController: accountController,
                passwordController: passwordController,
              ),
              const SizedBox(height: FUITokens.gap16),
              _LoginHelpPanel(siteUrl: getIt<ForumRepository>().baseUrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBrandHeader extends StatelessWidget {
  const _LoginBrandHeader({required this.siteUrl});

  final String siteUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FuiPageHead(title: l10n.loginTitle, subtitle: l10n.loginSubtitle),
        const SizedBox(height: FUITokens.gap10),
        Row(
          children: [
            Icon(
              FUIIcons.building,
              size: FUITokens.iconSm,
              color: context.colors.textTertiary,
            ),
            const SizedBox(width: FUITokens.gap6),
            Expanded(
              child: Text(
                siteUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.controller,
    required this.accountController,
    required this.passwordController,
  });

  final LoginController controller;
  final TextEditingController accountController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FUISurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _LoginIconBox(icon: FUIIcons.login),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loginForumAccountTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: FUITokens.gap4),
                    Text(
                      l10n.loginForumAccountSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap20),
          FUITextField(
            controller: accountController,
            label: l10n.loginAccountLabel,
            prefixIcon: FUIIcons.person,
            enabled: !controller.isLoading,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            onChanged: (value) => controller.account = value,
          ),
          const SizedBox(height: FUITokens.gap14),
          Obx(
            () => FUITextField(
              controller: passwordController,
              label: l10n.loginPasswordLabel,
              prefixIcon: FUIIcons.password,
              enabled: !controller.isLoading,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onChanged: (value) => controller.password = value,
              onSubmitted: (_) {
                if (!controller.isLoading) controller.startLogin(context);
              },
              suffix: FUIIconButton(
                icon: controller.obscurePassword.value
                    ? FUIIcons.visibilityOff
                    : FUIIcons.visibility,
                tooltip: controller.obscurePassword.value
                    ? l10n.loginShowPassword
                    : l10n.loginHidePassword,
                onPressed: controller.isLoading
                    ? null
                    : controller.togglePasswordVisible,
              ),
            ),
          ),
          const SizedBox(height: FUITokens.gap12),
          Obx(() {
            final selected = controller.autoRelogin.value;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                onTap: controller.isLoading
                    ? null
                    : () => controller.autoRelogin.value = !selected,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: selected
                              ? context.colors.primary
                              : context.colors.surface,
                          borderRadius: BorderRadius.circular(
                            FUITokens.radiusXs,
                          ),
                          border: Border.all(
                            color: selected
                                ? context.colors.primary
                                : context.colors.border,
                          ),
                        ),
                        child: selected
                            ? Icon(
                                FUIIcons.checkmark,
                                size: 15,
                                color: context.colors.textInverse,
                              )
                            : null,
                      ),
                      const SizedBox(width: FUITokens.gap10),
                      Expanded(
                        child: Text(
                          l10n.loginRememberMe,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: FUITokens.gap20),
          FUIButton(
            label: l10n.loginButton,
            icon: controller.isLoading ? null : FUIIcons.login,
            loading: controller.isLoading,
            fullWidth: true,
            onPressed: controller.isLoading
                ? null
                : () => controller.startLogin(context),
          ),
        ],
      ),
    );
  }
}

class _LoginHelpPanel extends StatelessWidget {
  const _LoginHelpPanel({required this.siteUrl});

  final String siteUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FUISurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loginHelpTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: FUITokens.gap8),
          Text(
            l10n.loginHelpDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: FUITokens.gap14),
          FUIButton(
            label: l10n.loginRegister,
            icon: FUIIcons.building,
            variant: FUIButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => launchUrlString(siteUrl),
          ),
        ],
      ),
    );
  }
}

class _LoginIconBox extends StatelessWidget {
  const _LoginIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.colors.primarySoft,
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(icon, size: FUITokens.iconMd, color: context.colors.primary),
    );
  }
}
