import 'package:flutter/material.dart';
import 'package:platia/presentation/instructor/screens/home/instructor_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';
import 'package:platia/presentation/member/screens/auth/register_screen.dart';
import 'package:platia/presentation/member/screens/auth/forgot_password_screen.dart';
import 'package:platia/presentation/member/screens/home/home_screen.dart';
import 'package:platia/presentation/admin/screens/dashboard/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    context.showLoadingDialog();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      final user = authProvider.currentUser!;
      if (user.isAdmin || user.isSuperAdmin) {
        context.pushReplacement(const AdminDashboardScreen());
      } else if (user.isTrainer) {
        context.pushReplacement(const InstructorHomeScreen());
      } else {
        context.pushReplacement(const HomeScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/platia_logo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 48),

                // Welcome Text
                Text(
                  context.l10n.welcome,
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.appTitle,
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
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
                const SizedBox(height: 16),

                // Password Field
                AppTextField(
                  controller: _passwordController,
                  label: context.l10n.password,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(const ForgotPasswordScreen());
                    },
                    child: Text(context.l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                AppButton(text: context.l10n.login, onPressed: _login),
                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabınız yok mu? ', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () {
                        context.push(const RegisterScreen());
                      },
                      child: Text(context.l10n.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
