import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:platia/data/models/attendance.dart';

class ParticipantCard extends StatelessWidget {
  final User user;
  final Reservation reservation;
  final AttendanceStatus? attendance;
  final bool canMarkAttendance;
  final Function(bool) onAttendanceChanged;

  const ParticipantCard({
    super.key,
    required this.user,
    required this.reservation,
    this.attendance,
    required this.canMarkAttendance,
    required this.onAttendanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null ? Text(user.firstName[0]) : null,
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.phoneNumber),
            if (reservation.status == ReservationStatus.waitlisted)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Bekleme Listesi',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: canMarkAttendance
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: attendance == AttendanceStatus.present
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                    onPressed: () => onAttendanceChanged(true),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: attendance == AttendanceStatus.noShow
                          ? AppColors.error
                          : AppColors.textHint,
                    ),
                    onPressed: () => onAttendanceChanged(false),
                  ),
                ],
              )
            : _getAttendanceIcon(),
      ),
    );
  }

  Widget? _getAttendanceIcon() {
    if (attendance == null) return null;

    switch (attendance!) {
      case AttendanceStatus.present:
        return Icon(Icons.check_circle, color: AppColors.success);
      case AttendanceStatus.late:
        return Icon(Icons.schedule, color: AppColors.warning);
      case AttendanceStatus.noShow:
        return Icon(Icons.cancel, color: AppColors.error);
      case AttendanceStatus.leftEarly:
        return Icon(Icons.exit_to_app, color: AppColors.warning);
    }
  }
}
