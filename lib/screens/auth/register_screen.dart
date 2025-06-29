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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _kvkkAccepted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

                      // Header
                      _buildHeader(l10n),
                      const SizedBox(height: 32),

                      // Error Message
                      if (authProvider.errorMessage != null)
                        _buildErrorMessage(authProvider.errorMessage!),

                      // Form Fields
                      Row(
                        children: [
                          Expanded(child: _buildFirstNameField(l10n)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildLastNameField(l10n)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildEmailField(l10n),
                      const SizedBox(height: 20),

                      _buildPhoneField(l10n),
                      const SizedBox(height: 20),

                      _buildPasswordField(l10n),
                      const SizedBox(height: 20),

                      _buildConfirmPasswordField(l10n),
                      const SizedBox(height: 24),

                      // KVKK Consent
                      _buildKvkkConsent(l10n),
                      const SizedBox(height: 32),

                      // Register Button
                      _buildRegisterButton(l10n, authProvider),
                      const SizedBox(height: 24),

                      // Login Link
                      _buildLoginLink(l10n),
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
          l10n.createAccount,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.joinPlatia,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
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
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
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

  // Form field methods (same as before)
  Widget _buildFirstNameField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.firstName,
      controller: _firstNameController,
      prefixIcon: Icons.person_outline,
      validator: (value) => Validators.validateName(value, l10n),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildLastNameField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.lastName,
      controller: _lastNameController,
      prefixIcon: Icons.person_outline,
      validator: (value) => Validators.validateName(value, l10n),
      onChanged: (_) => _clearError(),
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

  Widget _buildPhoneField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.phoneNumber,
      hint: '+90 555 123 45 67',
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      validator: (value) => Validators.validatePhone(value, l10n),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.password,
      controller: _passwordController,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      validator: (value) => Validators.validatePassword(value, l10n),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return CustomTextField(
      label: l10n.confirmPassword,
      controller: _confirmPasswordController,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      validator: (value) => Validators.validateConfirmPassword(
        value,
        _passwordController.text,
        l10n,
      ),
      onChanged: (_) => _clearError(),
    );
  }

  Widget _buildKvkkConsent(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _kvkkAccepted,
          onChanged: (value) {
            setState(() {
              _kvkkAccepted = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _kvkkAccepted = !_kvkkAccepted;
              });
            },
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.iAccept} ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: l10n.privacyPolicy,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' ${l10n.and} ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: l10n.termsOfService,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) {
    return CustomButton(
      text: l10n.createAccount,
      onPressed: (authProvider.isLoading || !_kvkkAccepted)
          ? null
          : _handleRegister,
      isLoading: authProvider.isLoading,
      icon: Icons.person_add,
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            l10n.signIn,
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

  Future<void> _handleRegister() async {
    _clearError();

    if (!_formKey.currentState!.validate()) return;

    if (!_kvkkAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.acceptTermsRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountCreated),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }
}
