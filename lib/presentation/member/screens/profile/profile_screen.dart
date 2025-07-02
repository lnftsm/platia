import 'package:flutter/material.dart';
import 'package:platia/presentation/member/screens/profile/edit_profile_screen.dart';
import 'package:platia/presentation/member/screens/profile/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/presentation/member/screens/membership/my_membership_screen.dart';
import 'package:platia/presentation/member/screens/reservations/attendance_history_screen.dart';
import 'package:platia/presentation/member/screens/communication/faq_screen.dart';
import 'package:platia/presentation/member/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

    if (user == null) {
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
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primaryLight.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
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
                  const SizedBox(height: 16),
                  Text(user.fullName, style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push(const EditProfileScreen());
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Profili Düzenle'),
                  ),
                ],
              ),
            ),

            // Menu Items
            _ProfileMenuItem(
              icon: Icons.card_membership,
              title: context.l10n.myMembership,
              subtitle: 'Üyelik durumunuzu görüntüleyin',
              onTap: () {
                context.push(const MyMembershipScreen());
              },
            ),
            _ProfileMenuItem(
              icon: Icons.history,
              title: context.l10n.attendanceHistory,
              subtitle: 'Geçmiş ders katılımlarınız',
              onTap: () {
                context.push(const AttendanceHistoryScreen());
              },
            ),
            _ProfileMenuItem(
              icon: Icons.payment,
              title: context.l10n.paymentHistory,
              subtitle: 'Ödeme geçmişinizi görüntüleyin',
              onTap: () {
                // Navigate to payment history
              },
            ),
            const Divider(height: 1),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: context.l10n.faq,
              subtitle: 'Sıkça sorulan sorular',
              onTap: () {
                context.push(const FAQScreen());
              },
            ),
            _ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Gizlilik Politikası',
              subtitle: 'Gizlilik ve kullanım koşulları',
              onTap: () {
                // Navigate to privacy policy
              },
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'Hakkında',
              subtitle: 'Uygulama bilgileri',
              onTap: () {
                // Show about dialog
              },
            ),
            const Divider(height: 1),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: context.l10n.logout,
              subtitle: 'Hesabınızdan çıkış yapın',
              onTap: () => _logout(context),
              textColor: AppColors.error,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
