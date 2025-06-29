import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/l10n/app_localizations.dart';

import 'package:platia/constants/app_colors.dart';
import 'package:platia/config/routes/app_routes.dart';
import 'package:platia/utils/screen_utils.dart';
import 'package:platia/utils/validators.dart';
import 'package:platia/widgets/common/custom_text_field.dart';
import 'package:platia/widgets/common/custom_button.dart';
import 'package:platia/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ScreenUtils.getResponsivePadding(context),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header Section
                      _buildHeader(l10n),
                      const SizedBox(height: 40),

                      // Error Message
                      if (authProvider.errorMessage != null)
                        _buildErrorMessage(authProvider.errorMessage!),

                      // Form Fields
                      _buildEmailField(l10n),
                      const SizedBox(height: 24),

                      _buildPasswordField(l10n),
                      const SizedBox(height: 16),

                      // Forgot Password
                      _buildForgotPasswordLink(l10n),
                      const SizedBox(height: 32),

                      // Login Button
                      _buildLoginButton(l10n, authProvider),
                      const SizedBox(height: 24),

                      // Divider
                      _buildDivider(l10n),
                      const SizedBox(height: 24),

                      // Register Link
                      _buildRegisterLink(l10n),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.welcomeBack,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.signIn} ${l10n.appName}',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.email,
      hint: 'example@platia.com',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: (value) => Validators.validateEmail(value, l10n),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.password,
      hint: l10n.password,
      controller: _passwordController,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      validator: (value) => Validators.validatePassword(value, l10n),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildForgotPasswordLink(AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
        child: Text(
          l10n.forgotPassword,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n, AuthProvider authProvider) {
    return CustomButton(
      text: l10n.login,
      onPressed: authProvider.isLoading ? null : _handleLogin,
      isLoading: authProvider.isLoading,
      icon: Icons.login,
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.or,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.dontHaveAccount,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.register),
          child: Text(
            l10n.signUp,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  void _clearError() {
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleLogin() async {
    // Clear any existing errors
    _clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to home
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }
}
