import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/membership.dart';

class MembershipCard extends StatelessWidget {
  final Membership membership;
  final VoidCallback? onTap;

  const MembershipCard({super.key, required this.membership, this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = membership.endDate.difference(DateTime.now()).inDays;
    final isExpiring = membership.isExpiring;
    final hasLowClasses = membership.hasLowClassCount;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_membership, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Aktif Üyelik',
                    style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                  ),
                  const Spacer(),
                  if (isExpiring)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Yakında Bitiyor',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Validity Period
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Başlangıç', style: AppTextStyles.caption),
                        Text(
                          DateFormatter.formatShortDate(membership.startDate),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Bitiş', style: AppTextStyles.caption),
                        Text(
                          DateFormatter.formatShortDate(membership.endDate),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isExpiring ? AppColors.warning : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remaining Classes or Days
              if (membership.remainingClasses != null) ...[
                LinearProgressIndicator(
                  value:
                      membership.remainingClasses! /
                      20, // Assuming 20 classes package
                  backgroundColor: AppColors.textHint.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    hasLowClasses ? AppColors.warning : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kalan Ders', style: AppTextStyles.bodySmall),
                    Text(
                      '${membership.remainingClasses} ders',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasLowClasses ? AppColors.warning : null,
                      ),
                    ),
                  ],
                ),
              ] else ...[
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
                        Icons.all_inclusive,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sınırsız Üyelik',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$daysRemaining gün kaldı',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isExpiring
                        ? AppColors.warning
                        : AppColors.textSecondary,
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
