import 'package:flutter/material.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/extensions/datetime_extensions.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/filter_options.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/presentation/member/screens/classes/class_detail_screen.dart';
import 'package:platia/presentation/member/screens/classes/class_filter_screen.dart';
import 'package:platia/presentation/member/widgets/class_card.dart';
import 'package:table_calendar/table_calendar.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final classProvider = context.read<ClassProvider>();
    final user = context.read<AuthProvider>().currentUser;

    await Future.wait([
      classProvider.loadClasses(),
      classProvider.loadInstructors(),
      classProvider.loadStudios(),
      classProvider.loadSchedules(date: _selectedDay),
      if (user != null) classProvider.loadUserReservations(user.id),
    ]);
  }

  List<ClassSchedule> _getClassesForDay(DateTime day) {
    final classProvider = context.read<ClassProvider>();
    return classProvider.schedules
        .where((schedule) => schedule.startTime.isSameDay(day))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    context.read<ClassProvider>().loadSchedules(date: selectedDay);
  }

  void _showFilterScreen() async {
    final filter = await context.push<FilterOptions>(const ClassFilterScreen());

    if (filter != null) {
      if (!mounted) return;
      context.read<ClassProvider>().applyFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    //final user = context.watch<AuthProvider>().currentUser;
    final schedules = _getClassesForDay(_selectedDay ?? DateTime.now());
    final hasFilter =
        classProvider.currentFilter != null &&
        !classProvider.currentFilter!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.schedule),
        actions: [
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                classProvider.clearFilter();
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterScreen,
          ),
        ],
      ),
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
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: AppColors.primary,
                ),
              ),
              onDaySelected: _onDaySelected,
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

          // Filter indicator
          if (hasFilter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtreler uygulandı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      classProvider.clearFilter();
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),

          // Classes List
          Expanded(
            child: classProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : schedules.isEmpty
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
                              ? 'Bugün için ders bulunmuyor'
                              : 'Bu tarihte ders bulunmuyor',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
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
                  ),
          ),
        ],
      ),
    );
  }
}
