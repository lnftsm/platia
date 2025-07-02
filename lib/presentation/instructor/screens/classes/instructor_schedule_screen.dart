import 'package:flutter/material.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/studio.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/extensions/datetime_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/domain/providers/instructor_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/presentation/instructor/screens/classes/class_participants_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class InstructorScheduleScreen extends StatefulWidget {
  const InstructorScheduleScreen({super.key});

  @override
  State<InstructorScheduleScreen> createState() =>
      _InstructorScheduleScreenState();
}

class _InstructorScheduleScreenState extends State<InstructorScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<ClassSchedule> _getClassesForDay(DateTime day) {
    final instructorProvider = context.read<InstructorProvider>();
    return instructorProvider.instructorSchedules
        .where((schedule) => schedule.startTime.isSameDay(day))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    //final instructorProvider = context.watch<InstructorProvider>();
    final classProvider = context.watch<ClassProvider>();
    final schedules = _getClassesForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Ders Programım')),
      body: Column(
        children: [
          // Calendar
          Container(
            color: context.colorScheme.surface,
            child: TableCalendar<ClassSchedule>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: _getClassesForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: AppColors.secondary,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          // Classes List
          Expanded(
            child: schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDay?.isToday == true
                              ? 'Bugün dersiniz bulunmuyor'
                              : 'Bu tarihte dersiniz bulunmuyor',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final classInfo = classProvider.getClassById(
                        schedule.classId,
                      );
                      final studio = classProvider.getStudioById(
                        schedule.studioId,
                      );
                      final isPast = schedule.startTime.isBefore(
                        DateTime.now(),
                      );

                      return _InstructorClassCard(
                        schedule: schedule,
                        classInfo: classInfo,
                        studio: studio,
                        isPast: isPast,
                        onTap: () {
                          context.push(
                            ClassParticipantsScreen(schedule: schedule),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InstructorClassCard extends StatelessWidget {
  final ClassSchedule schedule;
  final Class? classInfo;
  final Studio? studio;
  final bool isPast;
  final VoidCallback onTap;

  const _InstructorClassCard({
    required this.schedule,
    this.classInfo,
    this.studio,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyRate = schedule.maxCapacity > 0
        ? (schedule.currentEnrollment / schedule.maxCapacity * 100).round()
        : 0;
    final occupancyColor = occupancyRate >= 80
        ? AppColors.success
        : occupancyRate >= 50
        ? AppColors.warning
        : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPast
                          ? AppColors.textHint.withValues(alpha: 0.1)
                          : AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${DateFormatter.formatTime(schedule.startTime)} - ${DateFormatter.formatTime(schedule.endTime)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isPast
                            ? AppColors.textHint
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status
                  _StatusChip(schedule: schedule, isPast: isPast),
                ],
              ),
              const SizedBox(height: 12),

              // Class Name
              Text(classInfo?.name ?? 'Ders', style: AppTextStyles.h4),
              const SizedBox(height: 8),

              // Studio
              if (studio != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      studio!.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Participants Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Katılımcılar',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${schedule.currentEnrollment}/${schedule.maxCapacity} (%$occupancyRate)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: occupancyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: schedule.maxCapacity > 0
                        ? schedule.currentEnrollment / schedule.maxCapacity
                        : 0,
                    backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                  ),
                ],
              ),

              // Action Button
              if (!isPast) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('Katılımcıları Görüntüle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ClassSchedule schedule;
  final bool isPast;

  const _StatusChip({required this.schedule, required this.isPast});

  @override
  Widget build(BuildContext context) {
    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textHint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Tamamlandı',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    switch (schedule.status) {
      case ClassScheduleStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'İptal Edildi',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case ClassScheduleStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Devam Ediyor',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Planlandı',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}
