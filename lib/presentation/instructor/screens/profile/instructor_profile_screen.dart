import 'package:flutter/material.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/validators.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/instructor_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/common/widgets/app_text_field.dart';
import 'package:platia/presentation/member/screens/profile/settings_screen.dart';
import 'package:platia/presentation/member/screens/auth/login_screen.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  void _logout(BuildContext context) async {
    final confirmed = await context.showAlertDialog(
      title: 'Çıkış Yap',
      content: 'Çıkış yapmak istediğinizden emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: context.l10n.cancel,
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        context.pushReplacement(const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final instructorProvider = context.watch<InstructorProvider>();
    final instructor = instructorProvider.currentInstructor;

    if (user == null || instructor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(const SettingsScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: instructor.profileImageUrl != null
                          ? NetworkImage(instructor.profileImageUrl!)
                          : null,
                      child: instructor.profileImageUrl == null
                          ? Text(
                              instructor.firstName[0].toUpperCase(),
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(instructor.fullName, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Eğitmen',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${instructor.experienceYears} yıl deneyim',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showEditProfileDialog(context, instructor);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Profili Düzenle'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Biography
            Text('Biyografi', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(instructor.biography, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),

            // Specialties
            if (instructor.specialties.isNotEmpty) ...[
              Text('Uzmanlık Alanları', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: instructor.specialties.map((specialty) {
                  return Chip(
                    label: Text(_getCategoryText(specialty)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Certifications
            if (instructor.certifications.isNotEmpty) ...[
              Text('Sertifikalar', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              ...instructor.certifications.map((cert) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 20, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(cert, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Contact Information
            Text('İletişim Bilgileri', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(instructor.email),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(instructor.phoneNumber),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Logout Button
            AppButton(
              text: context.l10n.logout,
              onPressed: () => _logout(context),
              isOutlined: true,
              color: AppColors.error,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, Instructor instructor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(instructor: instructor),
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

class _EditProfileBottomSheet extends StatefulWidget {
  final Instructor instructor;

  const _EditProfileBottomSheet({required this.instructor});

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _biographyController;
  late TextEditingController _certificationsController;
  late Set<ClassCategory> _selectedSpecialties;

  @override
  void initState() {
    super.initState();
    _biographyController = TextEditingController(
      text: widget.instructor.biography,
    );
    _certificationsController = TextEditingController(
      text: widget.instructor.certifications.join(', '),
    );
    _selectedSpecialties = widget.instructor.specialties.toSet();
  }

  @override
  void dispose() {
    _biographyController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    context.showLoadingDialog();

    final updatedInstructor = Instructor(
      id: widget.instructor.id,
      firstName: widget.instructor.firstName,
      lastName: widget.instructor.lastName,
      email: widget.instructor.email,
      phoneNumber: widget.instructor.phoneNumber,
      profileImageUrl: widget.instructor.profileImageUrl,
      biography: _biographyController.text.trim(),
      specializations: widget.instructor.specializations,
      certifications: _certificationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      specialties: _selectedSpecialties.toList(),
      experienceYears: widget.instructor.experienceYears,
      isActive: widget.instructor.isActive,
      createdAt: widget.instructor.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await context
        .read<InstructorProvider>()
        .updateInstructorProfile(updatedInstructor);

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      context.showSnackBar('Profil başarıyla güncellendi');
      context.pop();
    } else {
      context.showErrorSnackBar('Profil güncellenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Profili Düzenle', style: AppTextStyles.h3),
              const SizedBox(height: 20),

              // Biography
              AppTextField(
                controller: _biographyController,
                label: 'Biyografi',
                maxLines: 4,
                validator: (value) => Validators.required(value, 'Biyografi'),
              ),
              const SizedBox(height: 16),

              // Certifications
              AppTextField(
                controller: _certificationsController,
                label: 'Sertifikalar',
                hint: 'Virgülle ayırarak yazın',
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
              const SizedBox(height: 24),

              // Save Button
              AppButton(text: 'Kaydet', onPressed: _save),
              const SizedBox(height: 16),
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
