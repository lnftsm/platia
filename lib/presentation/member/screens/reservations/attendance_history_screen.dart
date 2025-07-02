import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/attendance.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - In real app, this would come from provider
    final attendances = <Attendance>[];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.attendanceHistory)),
      body: attendances.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz katılım kaydınız bulunmuyor',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.check_circle, color: AppColors.success),
                    ),
                    title: const Text('Pilates Mat'),
                    subtitle: Text(
                      DateFormatter.formatDateTime(
                        attendance.checkedInAt,
                        locale: context.languageCode,
                      ),
                    ),
                    trailing: attendance.duration != null
                        ? Text(
                            '${attendance.duration!.inMinutes} dk',
                            style: AppTextStyles.bodySmall,
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
