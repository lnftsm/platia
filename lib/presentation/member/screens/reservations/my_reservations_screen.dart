import 'package:flutter/material.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/studio.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/presentation/member/screens/classes/class_detail_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<ClassProvider>().loadUserReservations(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final reservations = classProvider.userReservations;

    final upcomingReservations = reservations
        .where(
          (r) =>
              r.status == ReservationStatus.confirmed &&
              classProvider.schedules.any(
                (s) =>
                    s.id == r.scheduleId && s.startTime.isAfter(DateTime.now()),
              ),
        )
        .toList();

    final pastReservations = reservations
        .where(
          (r) =>
              r.status == ReservationStatus.confirmed &&
              classProvider.schedules.any(
                (s) =>
                    s.id == r.scheduleId &&
                    s.startTime.isBefore(DateTime.now()),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myReservations),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Yaklaşan (${upcomingReservations.length})'),
            Tab(text: 'Geçmiş (${pastReservations.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Reservations
          _ReservationsList(
            reservations: upcomingReservations,
            isUpcoming: true,
            onRefresh: _loadData,
          ),
          // Past Reservations
          _ReservationsList(
            reservations: pastReservations,
            isUpcoming: false,
            onRefresh: _loadData,
          ),
        ],
      ),
    );
  }
}

class _ReservationsList extends StatelessWidget {
  final List<Reservation> reservations;
  final bool isUpcoming;
  final Future<void> Function() onRefresh;

  const _ReservationsList({
    required this.reservations,
    required this.isUpcoming,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'Yaklaşan rezervasyonunuz bulunmuyor'
                  : 'Geçmiş rezervasyonunuz bulunmuyor',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          final schedule = classProvider.schedules.firstWhere(
            (s) => s.id == reservation.scheduleId,
          );
          final classInfo = classProvider.getClassById(schedule.classId);
          final instructor = classProvider.getInstructorById(
            schedule.instructorId,
          );
          final studio = classProvider.getStudioById(schedule.studioId);

          return _ReservationCard(
            reservation: reservation,
            schedule: schedule,
            classInfo: classInfo,
            instructor: instructor,
            studio: studio,
            isUpcoming: isUpcoming,
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final ClassSchedule schedule;
  final Class? classInfo;
  final Instructor? instructor;
  final Studio? studio;
  final bool isUpcoming;

  const _ReservationCard({
    required this.reservation,
    required this.schedule,
    this.classInfo,
    this.instructor,
    this.studio,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(ClassDetailScreen(scheduleId: schedule.id));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.textHint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isUpcoming ? Icons.event_available : Icons.event_busy,
                      color: isUpcoming
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classInfo?.name ?? 'Ders',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatDateTime(
                            schedule.startTime,
                            locale: context.languageCode,
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reservation.attended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Katıldı',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (instructor != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      instructor!.fullName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (studio != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        studio!.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
