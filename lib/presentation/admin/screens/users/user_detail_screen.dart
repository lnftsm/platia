import 'package:flutter/material.dart';
import 'package:platia/data/models/user_role.dart';
import 'package:platia/presentation/admin/screens/users/user_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/domain/providers/user_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<UserProvider>().loadUserDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.selectedUser;
    final membership = userProvider.currentMembership;
    final payments = userProvider.userPayments;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(UserEditScreen(user: user));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(
                              user.firstName[0].toUpperCase(),
                              style: AppTextStyles.h1,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(user.fullName, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.email, text: user.email),
                    _InfoRow(icon: Icons.phone, text: user.phoneNumber),
                    if (user.birthDate != null)
                      _InfoRow(
                        icon: Icons.cake,
                        text: DateFormatter.formatDate(user.birthDate!),
                      ),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      text:
                          'Kayıt: ${DateFormatter.formatDate(user.createdAt)}',
                    ),
                    if (user.lastLoginAt != null)
                      _InfoRow(
                        icon: Icons.login,
                        text:
                            'Son Giriş: ${DateFormatter.formatRelative(user.lastLoginAt!)}',
                      ),
                  ],
                ),
              ),
            ),

            // Membership Info
            if (membership != null) ...[
              const SizedBox(height: 24),
              Text('Aktif Üyelik', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.card_membership,
                    color: AppColors.primary,
                  ),
                  title: const Text('Üyelik Durumu'),
                  subtitle: Text(
                    '${DateFormatter.formatShortDate(membership.startDate)} - ${DateFormatter.formatShortDate(membership.endDate)}',
                  ),
                  trailing: membership.remainingClasses != null
                      ? Text(
                          '${membership.remainingClasses} ders',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const Text('Sınırsız'),
                ),
              ),
            ],

            // Recent Payments
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Son Ödemeler', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              ...payments.take(5).map((payment) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.payment, color: AppColors.success),
                    title: Text(payment.description ?? 'Ödeme'),
                    subtitle: Text(
                      DateFormatter.formatDate(
                        payment.paidAt ?? payment.createdAt,
                      ),
                    ),
                    trailing: Text(
                      '₺${payment.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
