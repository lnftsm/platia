import 'package:flutter/material.dart';
import 'package:platia/core/extensions/datetime_extensions.dart';
import 'package:platia/data/models/user_role.dart';
import 'package:platia/presentation/admin/screens/finance/inancial_reports_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/currency_formatter.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/user_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/presentation/admin/widgets/stat_card.dart';
import 'package:platia/presentation/admin/screens/users/user_management_screen.dart';
import 'package:platia/presentation/admin/screens/classes/class_management_screen.dart';
import 'package:platia/presentation/member/screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final classProvider = context.read<ClassProvider>();

    await Future.wait([
      userProvider.loadUsers(),
      classProvider.loadSchedules(date: DateTime.now()),
    ]);
  }

  void _logout() async {
    final confirmed = await context.showAlertDialog(
      title: 'Çıkış Yap',
      content: 'Çıkış yapmak istediğinizden emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: context.l10n.cancel,
    );

    if (confirmed == true) {
      if (!mounted) return;
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        context.pushReplacement(const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userProvider = context.watch<UserProvider>();
    final classProvider = context.watch<ClassProvider>();

    final activeMembers = userProvider.users
        .where((u) => u.isMember && u.isActive)
        .length;
    final todaysClasses = classProvider.schedules
        .where((s) => s.startTime.isToday)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.adminPanel),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(context.l10n.settings),
                onTap: () {
                  // Navigate to settings
                },
              ),
              PopupMenuItem(onTap: _logout, child: Text(context.l10n.logout)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş geldiniz, ${user?.firstName ?? ''}!',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.role.displayName ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics
              Text('Genel Bakış', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    icon: Icons.people,
                    title: context.l10n.activeMembers,
                    value: activeMembers.toString(),
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.calendar_today,
                    title: context.l10n.todaysClasses,
                    value: todaysClasses.toString(),
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    icon: Icons.attach_money,
                    title: 'Aylık Gelir',
                    value: CurrencyFormatter.formatTRY(45750),
                    color: Colors.green,
                  ),
                  StatCard(
                    icon: Icons.trending_up,
                    title: 'Büyüme',
                    value: '+12%',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text('Yönetim İşlemleri', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AdminMenuItem(
                    icon: Icons.people_outline,
                    title: context.l10n.userManagement,
                    subtitle: 'Üyeleri ve personeli yönetin',
                    onTap: () {
                      context.push(const UserManagementScreen());
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: context.l10n.classManagement,
                    subtitle: 'Ders programını düzenleyin',
                    onTap: () {
                      context.push(const ClassManagementScreen());
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Ödeme Yönetimi',
                    subtitle: 'Ödemeleri takip edin',
                    onTap: () {
                      // Navigate to payment management
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.analytics_outlined,
                    title: context.l10n.financialReports,
                    subtitle: 'Detaylı raporları görüntüleyin',
                    onTap: () {
                      context.push(const FinancialReportsScreen());
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.campaign_outlined,
                    title: 'Duyuru Yönetimi',
                    subtitle: 'Duyuru ve kampanyaları yönetin',
                    onTap: () {
                      // Navigate to announcement management
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
