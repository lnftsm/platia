import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/extensions/datetime_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/instructor_provider.dart';
import 'package:platia/presentation/admin/widgets/stat_card.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final instructorProvider = context.watch<InstructorProvider>();
    //final instructor = instructorProvider.currentInstructor;
    final todaysClasses = instructorProvider.instructorSchedules
        .where((s) => s.startTime.isToday)
        .toList();
    final upcomingClasses = instructorProvider.instructorSchedules
        .where((s) => s.startTime.isAfter(DateTime.now()))
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitmen Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await instructorProvider.loadInstructorByUserId(user.id);
          }
        },
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
                    colors: [AppColors.secondary, AppColors.secondaryDark],
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
                            'Eğitmen',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics
              if (instructorProvider.statistics.isNotEmpty) ...[
                Text('İstatistiklerim', style: AppTextStyles.h4),
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
                      icon: Icons.calendar_month,
                      title: 'Bu Ayki Dersler',
                      value:
                          instructorProvider.statistics['monthlyClasses']
                              ?.toString() ??
                          '0',
                      color: AppColors.primary,
                    ),
                    StatCard(
                      icon: Icons.people,
                      title: 'Toplam Öğrenci',
                      value:
                          instructorProvider.statistics['totalStudents']
                              ?.toString() ??
                          '0',
                      color: AppColors.secondary,
                    ),
                    StatCard(
                      icon: Icons.star,
                      title: 'Ortalama Puan',
                      value:
                          '${instructorProvider.statistics['averageRating'] ?? 0}/5',
                      color: Colors.orange,
                    ),
                    StatCard(
                      icon: Icons.trending_up,
                      title: 'Doluluk Oranı',
                      value:
                          '%${instructorProvider.statistics['occupancyRate'] ?? 0}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Today's Classes
              Text('Bugünün Dersleri', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              if (todaysClasses.isEmpty)
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
                          'Bugün dersiniz bulunmuyor',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...todaysClasses.map((schedule) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        DateFormatter.formatTime(schedule.startTime),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${schedule.currentEnrollment}/${schedule.maxCapacity} katılımcı',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Upcoming Classes
              Text('Yaklaşan Dersler', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              if (upcomingClasses.isEmpty)
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
                    child: Text(
                      'Yaklaşan ders bulunmuyor',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...upcomingClasses.map((schedule) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        DateFormatter.formatDate(
                          schedule.startTime,
                          locale: context.languageCode,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormatter.formatTime(schedule.startTime)} - ${DateFormatter.formatTime(schedule.endTime)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${schedule.currentEnrollment}/${schedule.maxCapacity}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
