import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/studio.dart';

class ClassCard extends StatelessWidget {
  final ClassSchedule schedule;
  final Class? classInfo;
  final Instructor? instructor;
  final Studio? studio;
  final bool isReserved;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.schedule,
    this.classInfo,
    this.instructor,
    this.studio,
    this.isReserved = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final availableSpots = schedule.availableSpots;
    final isFull = schedule.isFull;

    return Card(
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormatter.formatTime(schedule.startTime),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status
                  if (isReserved)
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
                            'Rezerve',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.full,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$availableSpots ${context.l10n.available}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Class Name
              Text(classInfo?.name ?? 'Ders', style: AppTextStyles.h4),
              const SizedBox(height: 8),

              // Details
              Row(
                children: [
                  // Instructor
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

                  // Studio
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
              const SizedBox(height: 8),

              // Duration and Difficulty
              Row(
                children: [
                  // Duration
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classInfo?.durationMinutes ?? 60} dk',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Difficulty
                  if (classInfo != null) ...[
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDifficultyText(classInfo!.difficulty),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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

  String _getDifficultyText(ClassDifficulty difficulty) {
    switch (difficulty) {
      case ClassDifficulty.beginner:
        return 'Başlangıç';
      case ClassDifficulty.intermediate:
        return 'Orta';
      case ClassDifficulty.advanced:
        return 'İleri';
    }
  }
}
