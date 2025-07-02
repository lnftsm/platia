import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/data/models/attendance.dart';

class ClassParticipantsScreen extends StatefulWidget {
  final ClassSchedule schedule;

  const ClassParticipantsScreen({super.key, required this.schedule});

  @override
  State<ClassParticipantsScreen> createState() =>
      _ClassParticipantsScreenState();
}

class _ClassParticipantsScreenState extends State<ClassParticipantsScreen> {
  final List<_ParticipantData> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    // In real app, load participants from repository
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _markAttendance(String userId, bool present) async {
    // In real app, update attendance in database
    setState(() {
      final index = _participants.indexWhere((p) => p.user.id == userId);
      if (index != -1) {
        _participants[index] = _participants[index].copyWith(
          attendance: present
              ? AttendanceStatus.present
              : AttendanceStatus.noShow,
        );
      }
    });

    context.showSnackBar(
      present ? 'Katılım kaydedildi' : 'Katılmadı olarak işaretlendi',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClassTime = widget.schedule.startTime.isBefore(
      DateTime.now().add(const Duration(minutes: 30)),
    );
    final isPast = widget.schedule.endTime.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katılımcılar'),
        actions: [
          if (isClassTime && !isPast)
            TextButton.icon(
              onPressed: _startClass,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Dersi Başlat'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Class Info Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: context.colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatDateTime(
                          widget.schedule.startTime,
                          locale: context.languageCode,
                        ),
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.people,
                            label: 'Kayıtlı',
                            value: widget.schedule.currentEnrollment.toString(),
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.check_circle,
                            label: 'Katılan',
                            value: _participants
                                .where(
                                  (p) =>
                                      p.attendance == AttendanceStatus.present,
                                )
                                .length
                                .toString(),
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.hourglass_empty,
                            label: 'Bekleme',
                            value: '0', // Get from waitlist
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Participants List
                Expanded(
                  child: _participants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz katılımcı bulunmuyor',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _participants.length,
                          itemBuilder: (context, index) {
                            final participant = _participants[index];
                            return _ParticipantCard(
                              participant: participant,
                              canMarkAttendance: isClassTime,
                              onAttendanceChanged: (present) {
                                _markAttendance(participant.user.id, present);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _startClass() {
    context.showAlertDialog(
      title: 'Dersi Başlat',
      content: 'Dersi başlatmak istediğinizden emin misiniz?',
      confirmText: 'Başlat',
      cancelText: context.l10n.cancel,
      onConfirm: () {
        // Update class status to inProgress
        context.showSnackBar('Ders başlatıldı');
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final _ParticipantData participant;
  final bool canMarkAttendance;
  final Function(bool) onAttendanceChanged;

  const _ParticipantCard({
    required this.participant,
    required this.canMarkAttendance,
    required this.onAttendanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant.user.profileImageUrl != null
              ? NetworkImage(participant.user.profileImageUrl!)
              : null,
          child: participant.user.profileImageUrl == null
              ? Text(participant.user.firstName[0])
              : null,
        ),
        title: Text(participant.user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(participant.user.phoneNumber),
            if (participant.reservation.status == ReservationStatus.waitlisted)
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
                      color: participant.attendance == AttendanceStatus.present
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                    onPressed: () => onAttendanceChanged(true),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: participant.attendance == AttendanceStatus.noShow
                          ? AppColors.error
                          : AppColors.textHint,
                    ),
                    onPressed: () => onAttendanceChanged(false),
                  ),
                ],
              )
            : _getAttendanceIcon(participant.attendance),
      ),
    );
  }

  Widget? _getAttendanceIcon(AttendanceStatus? status) {
    if (status == null) return null;

    switch (status) {
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

// Helper class for participant data
class _ParticipantData {
  final User user;
  final Reservation reservation;
  final AttendanceStatus? attendance;

  _ParticipantData({
    required this.user,
    required this.reservation,
    this.attendance,
  });

  _ParticipantData copyWith({
    User? user,
    Reservation? reservation,
    AttendanceStatus? attendance,
  }) {
    return _ParticipantData(
      user: user ?? this.user,
      reservation: reservation ?? this.reservation,
      attendance: attendance ?? this.attendance,
    );
  }
}
