import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    context.showLoadingDialog();

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      context.showSnackBar(
        'Şifre sıfırlama linki e-posta adresinize gönderildi',
      );
      context.pop();
    } else {
      context.showErrorSnackBar(authProvider.error ?? context.l10n.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.forgotPassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Icon
                const Center(
                  child: Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Description
                Text(
                  'Şifre Sıfırlama',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'E-posta adresinizi girin, size şifre sıfırlama linki gönderelim.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email Field
                AppTextField(
                  controller: _emailController,
                  label: context.l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 32),

                // Reset Button
                AppButton(
                  text: 'Şifre Sıfırlama Linki Gönder',
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
