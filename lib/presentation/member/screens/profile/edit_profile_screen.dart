import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _birthDate = user.birthDate;
      _gender = user.gender;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser!;

    final updatedUser = User(
      id: currentUser.id,
      email: currentUser.email,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      profileImageUrl: currentUser.profileImageUrl,
      role: currentUser.role,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
      lastLoginAt: currentUser.lastLoginAt,
      isActive: currentUser.isActive,
      kvkkConsent: currentUser.kvkkConsent,
    );

    await authProvider.updateProfile(updatedUser);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    context.showSnackBar('Profil başarıyla güncellendi');
    context.pop();
  }

  Future<void> _changeProfilePhoto() async {
    // TODO: Implement photo picker
    context.showSnackBar('Fotoğraf yükleme özelliği yakında eklenecek');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profili Düzenle')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Photo
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(
                              user.firstName[0].toUpperCase(),
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _changeProfilePhoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _changeProfilePhoto,
                child: const Text('Fotoğrafı Değiştir'),
              ),
              const SizedBox(height: 24),

              // Email (Read-only)
              AppTextField(
                controller: TextEditingController(text: user.email),
                label: context.l10n.email,
                readOnly: true,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // First Name
              AppTextField(
                controller: _firstNameController,
                label: context.l10n.firstName,
                validator: (value) =>
                    Validators.required(value, context.l10n.firstName),
                prefixIcon: const Icon(Icons.person_outline),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Last Name
              AppTextField(
                controller: _lastNameController,
                label: context.l10n.lastName,
                validator: (value) =>
                    Validators.required(value, context.l10n.lastName),
                prefixIcon: const Icon(Icons.person_outline),
                textCapitalization: TextCapitalization.words,
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
                  DropdownMenuItem(value: 'other', child: const Text('Diğer')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              AppButton(
                text: context.l10n.save,
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
