import 'package:flutter/material.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/data/models/user_role.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/domain/providers/user_provider.dart';
import 'package:platia/domain/providers/instructor_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';

class UserEditScreen extends StatefulWidget {
  final User? user;

  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Instructor specific fields
  final _biographyController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _certificationsController = TextEditingController();

  UserRole _selectedRole = UserRole.member;
  bool _isActive = true;
  DateTime? _birthDate;
  String? _gender;

  // Instructor specific
  final Set<ClassCategory> _selectedSpecialties = {};
  bool _showInstructorFields = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _initializeFields(widget.user!);
    }
  }

  void _initializeFields(User user) {
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phoneNumber;
    _selectedRole = user.role;
    _isActive = user.isActive;
    _birthDate = user.birthDate;
    _gender = user.gender;

    _showInstructorFields = user.role == UserRole.trainer;

    // If editing a trainer, load instructor data
    if (_showInstructorFields) {
      _loadInstructorData(user.id);
    }
  }

  Future<void> _loadInstructorData(String userId) async {
    final instructor = await context
        .read<InstructorProvider>()
        .getInstructorByUserId(userId);
    if (instructor != null) {
      _biographyController.text = instructor.biography;
      _experienceYearsController.text = instructor.experienceYears.toString();
      _certificationsController.text = instructor.certifications.join(', ');
      _selectedSpecialties.addAll(instructor.specialties);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    _experienceYearsController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    context.showLoadingDialog();

    try {
      final userProvider = context.read<UserProvider>();

      // Create/Update user
      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        birthDate: _birthDate,
        gender: _gender,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        kvkkConsent: widget.user?.kvkkConsent ?? true,
      );

      bool success;
      if (widget.user == null) {
        // Create new user
        success = await userProvider.createUser(user);

        // If creating a trainer, also create auth account
        if (success &&
            _selectedRole == UserRole.trainer &&
            _passwordController.text.isNotEmpty) {
          if (!mounted) return;
          await context.read<AuthProvider>().createUserAccount(
            email: user.email,
            password: _passwordController.text,
            userId: user.id,
          );
        }
      } else {
        // Update existing user
        success = await userProvider.updateUser(user);
      }

      // If trainer, create/update instructor profile
      if (success &&
          _selectedRole == UserRole.trainer &&
          _showInstructorFields) {
        if (!mounted) return;
        final instructorProvider = context.read<InstructorProvider>();

        final instructor = Instructor(
          id: widget.user?.id ?? user.id, // Link instructor ID to user ID
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          biography: _biographyController.text.trim(),
          experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
          certifications: _certificationsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          specialties: _selectedSpecialties.toList(),
          isActive: _isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await instructorProvider.createOrUpdateInstructor(instructor);
      }

      if (!mounted) return;
      context.hideLoadingDialog();

      if (success) {
        context.showSnackBar(
          widget.user == null
              ? 'Kullanıcı başarıyla oluşturuldu'
              : 'Kullanıcı başarıyla güncellendi',
        );
        context.pop();
      } else {
        context.showErrorSnackBar('İşlem başarısız oldu');
      }
    } catch (e) {
      if (!mounted) return;
      context.hideLoadingDialog();
      context.showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kullanıcı Düzenle' : 'Yeni Kullanıcı'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic User Information
              Text('Temel Bilgiler', style: AppTextStyles.h4),
              const SizedBox(height: 16),

              // Role Selection
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Rolü',
                  prefixIcon: Icon(Icons.security),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (role) {
                  setState(() {
                    _selectedRole = role!;
                    _showInstructorFields = role == UserRole.trainer;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Email
              AppTextField(
                controller: _emailController,
                label: context.l10n.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                prefixIcon: const Icon(Icons.email_outlined),
                readOnly: isEditing, // Can't change email for existing users
              ),
              const SizedBox(height: 16),

              // Password (only for new users)
              if (!isEditing) ...[
                AppTextField(
                  controller: _passwordController,
                  label: context.l10n.password,
                  obscureText: true,
                  validator: _selectedRole == UserRole.trainer
                      ? Validators.password
                      : null, // Required for trainers
                  prefixIcon: const Icon(Icons.lock_outline),
                  hint: _selectedRole == UserRole.trainer
                      ? 'Eğitmen için zorunlu'
                      : 'Opsiyonel',
                ),
                const SizedBox(height: 16),
              ],

              // Personal Information
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      label: context.l10n.firstName,
                      validator: (value) =>
                          Validators.required(value, context.l10n.firstName),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      label: context.l10n.lastName,
                      validator: (value) =>
                          Validators.required(value, context.l10n.lastName),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: context.l10n.phoneNumber,
                keyboardType: TextInputType.phone,
                validator: Validators.phoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Aktif Kullanıcı'),
                subtitle: const Text(
                  'Kullanıcının sisteme erişimini kontrol eder',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              // Instructor Specific Fields
              if (_showInstructorFields) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                Text('Eğitmen Bilgileri', style: AppTextStyles.h4),
                const SizedBox(height: 16),

                // Biography
                AppTextField(
                  controller: _biographyController,
                  label: 'Biyografi',
                  maxLines: 4,
                  validator: (value) => Validators.required(value, 'Biyografi'),
                  hint: 'Eğitmenin kısa biyografisi',
                ),
                const SizedBox(height: 16),

                // Experience Years
                AppTextField(
                  controller: _experienceYearsController,
                  label: 'Deneyim (Yıl)',
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.required(value, 'Deneyim'),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                const SizedBox(height: 16),

                // Certifications
                AppTextField(
                  controller: _certificationsController,
                  label: 'Sertifikalar',
                  hint:
                      'Virgülle ayırarak yazın (örn: Yoga Alliance, Pilates Method)',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Specialties
                Text(
                  'Uzmanlık Alanları',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ClassCategory.values.map((category) {
                    final isSelected = _selectedSpecialties.contains(category);
                    return FilterChip(
                      label: Text(_getCategoryText(category)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecialties.add(category);
                          } else {
                            _selectedSpecialties.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              AppButton(
                text: isEditing ? 'Güncelle' : 'Kullanıcı Oluştur',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryText(ClassCategory category) {
    switch (category) {
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.yoga:
        return 'Yoga';
      case ClassCategory.meditation:
        return 'Meditasyon';
      case ClassCategory.workshop:
        return 'Workshop';
      case ClassCategory.wellness:
        return 'Wellness';
    }
  }
}
