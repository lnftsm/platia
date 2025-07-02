import 'package:flutter/material.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:platia/presentation/member/screens/communication/announcements_screen.dart';
import 'package:platia/presentation/member/screens/membership/my_membership_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/domain/providers/membership_provider.dart';
import 'package:platia/presentation/member/widgets/class_card.dart';
import 'package:platia/presentation/member/widgets/membership_card.dart';
import 'package:platia/presentation/member/screens/classes/class_detail_screen.dart';
import 'package:platia/presentation/member/screens/membership/membership_packages_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final classProvider = context.read<ClassProvider>();
    final membershipProvider = context.read<MembershipProvider>();

    await Future.wait([
      classProvider.loadSchedules(date: DateTime.now()),
      classProvider.loadUserReservations(user.id),
      membershipProvider.loadUserMembership(user.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final classProvider = context.watch<ClassProvider>();
    final membershipProvider = context.watch<MembershipProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(const AnnouncementsScreen());
            },
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
                            'Merhaba, ${user?.firstName ?? ''}!',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormatter.formatDate(
                              DateTime.now(),
                              locale: context.languageCode,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.spa_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Membership Status
              if (membershipProvider.hasActiveMembership) ...[
                Text('Üyelik Durumu', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                MembershipCard(
                  membership: membershipProvider.activeMembership!,
                  onTap: () {
                    context.push(const MyMembershipScreen());
                  },
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktif üyeliğiniz bulunmuyor',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hemen üyelik paketlerimizi inceleyin',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(const MembershipPackagesScreen());
                        },
                        child: const Text('İncele'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Today's Classes
              Text('Bugünün Dersleri', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              if (classProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (classProvider.schedules.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textHint.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün için ders bulunmuyor',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classProvider.schedules.take(5).length,
                  itemBuilder: (context, index) {
                    final schedule = classProvider.schedules[index];
                    final classInfo = classProvider.getClassById(
                      schedule.classId,
                    );
                    final instructor = classProvider.getInstructorById(
                      schedule.instructorId,
                    );
                    final studio = classProvider.getStudioById(
                      schedule.studioId,
                    );

                    final isReserved = classProvider.userReservations.any(
                      (r) =>
                          r.scheduleId == schedule.id &&
                          r.status == ReservationStatus.confirmed,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClassCard(
                        schedule: schedule,
                        classInfo: classInfo,
                        instructor: instructor,
                        studio: studio,
                        isReserved: isReserved,
                        onTap: () {
                          context.push(
                            ClassDetailScreen(scheduleId: schedule.id),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Quick Actions
              Text('Hızlı İşlemler', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickActionCard(
                    icon: Icons.calendar_month,
                    title: 'Ders Programı',
                    color: AppColors.primary,
                    onTap: () {
                      // Navigate to class schedule
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.card_membership,
                    title: 'Üyelik Paketleri',
                    color: AppColors.secondary,
                    onTap: () {
                      context.push(const MembershipPackagesScreen());
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.history,
                    title: 'Katılım Geçmişi',
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to attendance history
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.help_outline,
                    title: 'SSS',
                    color: Colors.teal,
                    onTap: () {
                      // Navigate to FAQ
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
