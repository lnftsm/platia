import 'package:flutter/material.dart';
import 'package:platia/data/models/payment.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/currency_formatter.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/membership_provider.dart';
import 'package:platia/presentation/member/widgets/membership_card.dart';
import 'package:platia/presentation/member/screens/membership/membership_packages_screen.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';

class MyMembershipScreen extends StatefulWidget {
  const MyMembershipScreen({super.key});

  @override
  State<MyMembershipScreen> createState() => _MyMembershipScreenState();
}

class _MyMembershipScreenState extends State<MyMembershipScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final membershipProvider = context.read<MembershipProvider>();
      await Future.wait([
        membershipProvider.loadUserMembership(user.id),
        membershipProvider.loadPaymentHistory(user.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final membership = membershipProvider.activeMembership;
    final payments = membershipProvider.payments;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myMembership)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (membership != null) ...[
                MembershipCard(membership: membership),
                const SizedBox(height: 24),

                // Actions
                if (membership.isExpiring)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Üyeliğiniz yakında sona eriyor!',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Üyeliğinizi yenileyerek ayrıcalıklarınızdan yararlanmaya devam edin.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Üyeliği Yenile',
                          onPressed: () {
                            context.push(const MembershipPackagesScreen());
                          },
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                // No active membership
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_membership,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aktif üyeliğiniz bulunmuyor',
                        style: AppTextStyles.h4,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hemen bir üyelik paketi seçerek pilates yolculuğunuza başlayın!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Üyelik Paketlerini İncele',
                        onPressed: () {
                          context.push(const MembershipPackagesScreen());
                        },
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Payment History
              Text(context.l10n.paymentHistory, style: AppTextStyles.h4),
              const SizedBox(height: 16),

              if (payments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textHint.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ödeme geçmişi bulunmuyor',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return _PaymentHistoryItem(payment: payment);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final Payment payment;

  const _PaymentHistoryItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(payment.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentIcon(payment.method),
            color: _getStatusColor(payment.status),
          ),
        ),
        title: Text(
          payment.description ?? 'Ödeme',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormatter.formatDateTime(
            payment.paidAt ?? payment.createdAt,
            locale: context.languageCode,
          ),
          style: AppTextStyles.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatTRY(payment.amount),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: _getStatusColor(payment.status),
              ),
            ),
            Text(
              _getStatusText(payment.status),
              style: AppTextStyles.caption.copyWith(
                color: _getStatusColor(payment.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.iyzico:
      case PaymentMethod.paytr:
        return Icons.payment;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
      case PaymentStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}
