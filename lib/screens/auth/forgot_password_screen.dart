import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/l10n/app_localizations.dart';

import 'package:platia/constants/app_colors.dart';
import 'package:platia/utils/screen_utils.dart';
import 'package:platia/utils/validators.dart';
import 'package:platia/widgets/common/custom_text_field.dart';
import 'package:platia/widgets/common/custom_button.dart';
import 'package:platia/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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
                return Column(
                  children: [
                    const SizedBox(height: 40),

                    // Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Header
                    Text(
                      _emailSent ? l10n.checkYourEmail : l10n.forgotPassword,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      _emailSent
                          ? l10n.resetEmailSent
                          : l10n.resetPasswordDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    if (!_emailSent) ...[
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Error Message
                            if (authProvider.errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Email Field
                            CustomTextField(
                              label: l10n.email,
                              hint: 'example@platia.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) =>
                                  Validators.validateEmail(value, l10n),
                              onChanged: (_) => _clearError(),
                            ),
                            const SizedBox(height: 32),

                            // Send Reset Email Button
                            CustomButton(
                              text: l10n.sendResetEmail,
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleSendResetEmail,
                              isLoading: authProvider.isLoading,
                              icon: Icons.send,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Email Sent Success
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.passwordResetEmailSent,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Back to Login Button
                      CustomButton(
                        text: l10n.backToLogin,
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                        icon: Icons.arrow_back,
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _clearError() {
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleSendResetEmail() async {
    _clearError();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (success) {
      setState(() {
        _emailSent = true;
      });
    }
  }
}
