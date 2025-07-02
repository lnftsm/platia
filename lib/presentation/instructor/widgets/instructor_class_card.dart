import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/studio.dart';

class InstructorClassCard extends StatelessWidget {
  final ClassSchedule schedule;
  final Class? classInfo;
  final Studio? studio;
  final bool isPast;
  final VoidCallback onTap;

  const InstructorClassCard({
    super.key,
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
                  _buildStatusChip(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
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
