import 'package:flutter/material.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/studio.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/domain/providers/membership_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';
import 'package:platia/presentation/member/screens/membership/membership_packages_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final String scheduleId;

  const ClassDetailScreen({super.key, required this.scheduleId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  ClassSchedule? _schedule;
  Class? _classInfo;
  Instructor? _instructor;
  Studio? _studio;
  bool _isReserved = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final classProvider = context.read<ClassProvider>();
    final user = context.read<AuthProvider>().currentUser;

    // Find schedule
    _schedule = classProvider.schedules.firstWhere(
      (s) => s.id == widget.scheduleId,
    );

    // Load related data
    _classInfo = classProvider.getClassById(_schedule!.classId);
    _instructor = classProvider.getInstructorById(_schedule!.instructorId);
    _studio = classProvider.getStudioById(_schedule!.studioId);

    // Check if reserved
    if (user != null) {
      _isReserved = classProvider.userReservations.any(
        (r) =>
            r.scheduleId == widget.scheduleId &&
            r.status == ReservationStatus.confirmed,
      );
    }

    setState(() {});
  }

  Future<void> _makeReservation() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final membershipProvider = context.read<MembershipProvider>();

    // Check membership
    if (!membershipProvider.hasActiveMembership) {
      final shouldNavigate = await context.showAlertDialog(
        title: 'Üyelik Gerekli',
        content:
            'Ders rezervasyonu yapabilmek için aktif bir üyeliğiniz olması gerekiyor.',
        confirmText: 'Üyelik Paketleri',
        cancelText: context.l10n.cancel,
      );

      if (shouldNavigate == true) {
        if (!mounted) return;
        context.push(const MembershipPackagesScreen());
      }
      return;
    }

    // Check remaining classes
    if (membershipProvider.remainingClasses != null &&
        membershipProvider.remainingClasses! <= 0) {
      context.showErrorSnackBar('Kalan ders hakkınız bulunmuyor');
      return;
    }

    context.showLoadingDialog();

    final success = await context.read<ClassProvider>().makeReservation(
      user.id,
      widget.scheduleId,
    );

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      setState(() {
        _isReserved = true;
      });
      context.showSnackBar('Rezervasyonunuz başarıyla oluşturuldu');
    } else {
      context.showErrorSnackBar('Rezervasyon oluşturulamadı');
    }
  }

  Future<void> _cancelReservation() async {
    final confirmed = await context.showAlertDialog(
      title: 'Rezervasyonu İptal Et',
      content: 'Rezervasyonunuzu iptal etmek istediğinizden emin misiniz?',
      confirmText: 'İptal Et',
      cancelText: 'Vazgeç',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final classProvider = context.read<ClassProvider>();
    final reservation = classProvider.userReservations.firstWhere(
      (r) => r.scheduleId == widget.scheduleId,
    );

    context.showLoadingDialog();

    final success = await classProvider.cancelReservation(reservation.id);

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      setState(() {
        _isReserved = false;
      });
      context.showSnackBar('Rezervasyonunuz iptal edildi');
    } else {
      context.showErrorSnackBar('Rezervasyon iptal edilemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_schedule == null || _classInfo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final canReserve = _schedule!.isAvailable && !_isReserved;
    final isPast = _schedule!.startTime.isBefore(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_classInfo!.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/class_${_classInfo!.type.toString().split('.').last}.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormatter.formatDate(
                                  _schedule!.startTime,
                                  locale: context.languageCode,
                                ),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${DateFormatter.formatTime(_schedule!.startTime)} - ${DateFormatter.formatTime(_schedule!.endTime)}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructor
                  if (_instructor != null) ...[
                    Text(context.l10n.instructor, style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _instructor!.profileImageUrl != null
                              ? NetworkImage(_instructor!.profileImageUrl!)
                              : null,
                          child: _instructor!.profileImageUrl == null
                              ? Text(_instructor!.firstName[0])
                              : null,
                        ),
                        title: Text(_instructor!.fullName),
                        subtitle: Text(
                          '${_instructor!.experienceYears} yıl deneyim',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Studio
                  if (_studio != null) ...[
                    Text(context.l10n.studio, style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(_studio!.name),
                        subtitle: Text(_studio!.address),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () {
                            // Open maps
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Class Details
                  Text('Ders Detayları', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.timer_outlined,
                    label: context.l10n.duration,
                    value: '${_classInfo!.durationMinutes} dakika',
                  ),
                  _DetailRow(
                    icon: Icons.people_outline,
                    label: context.l10n.capacity,
                    value:
                        '${_schedule!.currentEnrollment}/${_schedule!.maxCapacity}',
                  ),
                  _DetailRow(
                    icon: Icons.signal_cellular_alt,
                    label: 'Seviye',
                    value: _getDifficultyText(_classInfo!.difficulty),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Açıklama', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    _classInfo!.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Equipment
                  if (_classInfo!.equipmentRequired.isNotEmpty) ...[
                    Text('Gerekli Ekipmanlar', style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _classInfo!.equipmentRequired.map((equipment) {
                        return Chip(
                          label: Text(equipment),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status
                  if (_schedule!.isFull && !_isReserved) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bu ders dolu. Bekleme listesine eklenebilirsiniz.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isPast
              ? AppButton(
                  text: 'Geçmiş Ders',
                  onPressed: null,
                  color: Colors.grey,
                )
              : _isReserved
              ? AppButton(
                  text: context.l10n.cancelReservation,
                  onPressed: _cancelReservation,
                  isOutlined: true,
                  color: AppColors.error,
                )
              : AppButton(
                  text: _schedule!.isFull
                      ? 'Bekleme Listesine Ekle'
                      : context.l10n.book,
                  onPressed: canReserve || _schedule!.isFull
                      ? _makeReservation
                      : null,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
