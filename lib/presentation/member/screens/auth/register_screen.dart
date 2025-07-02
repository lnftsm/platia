import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';
import 'package:platia/presentation/member/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _kvkkConsent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_kvkkConsent) {
      context.showErrorSnackBar('KVKK onayı vermeniz gerekmektedir');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    context.showLoadingDialog();

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      kvkkConsent: _kvkkConsent,
    );

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      context.pushReplacement(const HomeScreen());
    } else {
      context.showErrorSnackBar(authProvider.error ?? context.l10n.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.register)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Information
                Text('Kişisel Bilgiler', style: AppTextStyles.h4),
                const SizedBox(height: 16),

                // First Name
                AppTextField(
                  controller: _firstNameController,
                  label: context.l10n.firstName,
                  validator: (value) =>
                      Validators.required(value, context.l10n.firstName),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),

                // Last Name
                AppTextField(
                  controller: _lastNameController,
                  label: context.l10n.lastName,
                  validator: (value) =>
                      Validators.required(value, context.l10n.lastName),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),

                // Phone Number
                AppTextField(
                  controller: _phoneController,
                  label: context.l10n.phoneNumber,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 16),

                // Birth Date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: context.l10n.birthDate,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                          : 'Seçiniz',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: context.l10n.gender,
                    prefixIcon: const Icon(Icons.wc_outlined),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(context.l10n.male),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(context.l10n.female),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Account Information
                Text('Hesap Bilgileri', style: AppTextStyles.h4),
                const SizedBox(height: 16),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: context.l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // Password
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
                const SizedBox(height: 16),

                // Confirm Password
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Şifre Tekrar',
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // KVKK Consent
                CheckboxListTile(
                  value: _kvkkConsent,
                  onChanged: (value) {
                    setState(() {
                      _kvkkConsent = value ?? false;
                    });
                  },
                  title: Text(
                    context.l10n.kvkkConsent,
                    style: AppTextStyles.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Register Button
                AppButton(text: context.l10n.register, onPressed: _register),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
