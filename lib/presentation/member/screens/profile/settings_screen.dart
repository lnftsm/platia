import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/settings_provider.dart';
import 'package:platia/domain/providers/language_provider.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/member/screens/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final settings = settingsProvider.settings;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        children: [
          // User Info Section
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: context.colorScheme.surface,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(
                            user.firstName[0].toUpperCase(),
                            style: AppTextStyles.h3,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: AppTextStyles.h4),
                        Text(
                          user.email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Appearance Section
          _SettingsSection(
            title: 'Görünüm',
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(context.l10n.theme),
                subtitle: Text(
                  settingsProvider.themeMode == ThemeMode.dark
                      ? context.l10n.darkTheme
                      : context.l10n.lightTheme,
                ),
                trailing: Switch(
                  value: settingsProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settingsProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
            ],
          ),

          // Language Section
          _SettingsSection(
            title: context.l10n.language,
            children: [
              RadioListTile<String>(
                title: const Text('Türkçe'),
                subtitle: const Text('Varsayılan dil'),
                value: 'tr',
                groupValue: languageProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                subtitle: const Text('English language'),
                value: 'en',
                groupValue: languageProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                  }
                },
              ),
            ],
          ),

          // Notifications Section
          _SettingsSection(
            title: context.l10n.notifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Bildirimler'),
                subtitle: const Text('Tüm bildirimleri aç/kapa'),
                value: settings?.pushNotifications ?? true,
                onChanged: (value) {
                  settingsProvider.setNotifications(value);
                },
              ),
              if (settings?.pushNotifications ?? false) ...[
                SwitchListTile(
                  secondary: const Icon(Icons.access_time),
                  title: const Text('Ders Hatırlatıcıları'),
                  subtitle: const Text('Ders öncesi bildirim al'),
                  value: settings?.classReminders ?? true,
                  onChanged: (value) {
                    if (settings != null) {
                      settingsProvider.updateSettings(
                        settings.copyWith(classReminders: value),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.card_membership),
                  title: const Text('Üyelik Hatırlatıcıları'),
                  subtitle: const Text('Üyelik bitiş bildirimleri'),
                  value: settings?.membershipReminders ?? true,
                  onChanged: (value) {
                    if (settings != null) {
                      settingsProvider.updateSettings(
                        settings.copyWith(membershipReminders: value),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.campaign),
                  title: const Text('Duyuru Bildirimleri'),
                  subtitle: const Text('Yeni duyurulardan haberdar ol'),
                  value: settings?.announcementNotifications ?? true,
                  onChanged: (value) {
                    if (settings != null) {
                      settingsProvider.updateSettings(
                        settings.copyWith(announcementNotifications: value),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Hatırlatıcı Süresi'),
                  subtitle: Text(
                    'Ders öncesi ${settings?.reminderMinutes ?? 60} dakika',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final minutes = await _showReminderTimeDialog(
                      context,
                      settings?.reminderMinutes ?? 60,
                    );
                    if (minutes != null && settings != null) {
                      settingsProvider.updateSettings(
                        settings.copyWith(reminderMinutes: minutes),
                      );
                    }
                  },
                ),
              ],
            ],
          ),

          // Privacy & Security Section
          _SettingsSection(
            title: 'Gizlilik ve Güvenlik',
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Şifre Değiştir'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to change password screen
                  context.showSnackBar(
                    'Şifre değiştirme özelliği yakında eklenecek',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Gizlilik Politikası'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy policy
                  context.showSnackBar(
                    'Gizlilik politikası sayfası yakında eklenecek',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Kullanım Koşulları'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to terms of service
                  context.showSnackBar(
                    'Kullanım koşulları sayfası yakında eklenecek',
                  );
                },
              ),
            ],
          ),

          // About Section
          _SettingsSection(
            title: 'Hakkında',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Uygulama Hakkında'),
                subtitle: const Text('Versiyon 0.1.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Platia',
                    applicationVersion: '0.1.0',
                    applicationIcon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.spa, color: Colors.white),
                    ),
                    children: [
                      const Text(
                        'Platia, pilates ve yoga stüdyolarının yönetimini kolaylaştıran modern bir mobil uygulamadır.',
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.rate_review_outlined),
                title: const Text('Uygulamayı Değerlendir'),
                onTap: () {
                  // Open app store for rating
                  context.showSnackBar(
                    'Uygulama mağazasına yönlendiriliyorsunuz...',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Uygulamayı Paylaş'),
                onTap: () {
                  // Share app
                  context.showSnackBar('Paylaşım özelliği yakında eklenecek');
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined),
                title: const Text('Destek'),
                subtitle: const Text('support@platia.com'),
                onTap: () {
                  // Open support
                  context.showSnackBar('Destek sayfası yakında eklenecek');
                },
              ),
            ],
          ),

          // Danger Zone
          _SettingsSection(
            title: 'Hesap İşlemleri',
            titleColor: AppColors.error,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  context.l10n.logout,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
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
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: AppColors.error),
                title: Text(
                  'Hesabı Sil',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: Text(
                  'Bu işlem geri alınamaz',
                  style: TextStyle(
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () async {
                  final confirmed = await context.showAlertDialog(
                    title: 'Hesabı Sil',
                    content:
                        'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
                    confirmText: 'Hesabı Sil',
                    cancelText: context.l10n.cancel,
                  );

                  if (confirmed == true) {
                    if (!context.mounted) return;
                    // Implement account deletion
                    context.showSnackBar(
                      'Hesap silme özelliği yakında eklenecek',
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<int?> _showReminderTimeDialog(
    BuildContext context,
    int currentMinutes,
  ) async {
    final options = [15, 30, 60, 120];

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcı Süresi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes dakika önce'),
              value: minutes,
              groupValue: currentMinutes,
              onChanged: (value) => context.pop(value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? titleColor;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: titleColor ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.1),
              ),
              bottom: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
