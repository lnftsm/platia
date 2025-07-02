import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/currency_formatter.dart';
import 'package:platia/data/models/membership_package.dart';
import 'package:platia/data/models/payment.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/membership_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';

class MembershipPackagesScreen extends StatefulWidget {
  const MembershipPackagesScreen({super.key});

  @override
  State<MembershipPackagesScreen> createState() =>
      _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends State<MembershipPackagesScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<MembershipProvider>().loadPackages();
  }

  Future<void> _purchasePackage(MembershipPackage package) async {
    final confirmed = await context.showAlertDialog(
      title: 'Üyelik Satın Al',
      content:
          '${package.name} paketini satın almak istediğinizden emin misiniz?',
      confirmText: 'Satın Al',
      cancelText: context.l10n.cancel,
    );

    if (confirmed != true) return;

    // Show payment method selection
    final paymentMethod = await _showPaymentMethodDialog();
    if (paymentMethod == null) return;

    if (!mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    context.showLoadingDialog();

    final success = await context.read<MembershipProvider>().purchaseMembership(
      userId: user.id,
      packageId: package.id,
      paymentMethod: paymentMethod,
    );

    if (!mounted) return;
    context.hideLoadingDialog();

    if (success) {
      context.showSnackBar('Üyeliğiniz başarıyla oluşturuldu!');
      context.pop();
    } else {
      context.showErrorSnackBar(
        'Üyelik oluşturulamadı. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<PaymentMethod?> _showPaymentMethodDialog() async {
    return showDialog<PaymentMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Yöntemi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaymentMethod.values.map((method) {
            return ListTile(
              leading: Icon(_getPaymentMethodIcon(method)),
              title: Text(_getPaymentMethodName(method)),
              onTap: () => context.pop(method),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
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

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.bankTransfer:
        return 'Banka Havalesi';
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.iyzico:
        return 'iyzico';
      case PaymentMethod.paytr:
        return 'PayTR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final packages = membershipProvider.packages;
    final hasActiveMembership = membershipProvider.hasActiveMembership;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.membershipPackages)),
      body: membershipProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : packages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Üyelik paketi bulunmuyor',
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
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return _PackageCard(
                    package: package,
                    isRecommended: index == 1, // Middle package as recommended
                    hasActiveMembership: hasActiveMembership,
                    onPurchase: () => _purchasePackage(package),
                  );
                },
              ),
            ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final MembershipPackage package;
  final bool isRecommended;
  final bool hasActiveMembership;
  final VoidCallback onPurchase;

  const _PackageCard({
    required this.package,
    required this.isRecommended,
    required this.hasActiveMembership,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'ÖNERİLEN',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name, style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  package.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatTRY(package.price),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getValidityText(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...package.type == MembershipType.unlimited
                    ? [
                        _FeatureItem(
                          icon: Icons.all_inclusive,
                          text: 'Sınırsız ders katılımı',
                        ),
                      ]
                    : [
                        _FeatureItem(
                          icon: Icons.fitness_center,
                          text: '${package.classCount} ders hakkı',
                        ),
                      ],
                if (package.validityDays != null)
                  _FeatureItem(
                    icon: Icons.calendar_today,
                    text: '${package.validityDays} gün geçerlilik',
                  ),
                _FeatureItem(
                  icon: Icons.spa,
                  text: 'Tüm ders türlerine erişim',
                ),
                _FeatureItem(
                  icon: Icons.people,
                  text: 'Özel etkinliklere katılım',
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: hasActiveMembership
                      ? 'Aktif Üyeliğiniz Var'
                      : 'Paketi Satın Al',
                  onPressed: hasActiveMembership ? null : onPurchase,
                  isOutlined: !isRecommended,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getValidityText() {
    switch (package.type) {
      case MembershipType.monthly:
        return '/ ay';
      case MembershipType.yearly:
        return '/ yıl';
      case MembershipType.classPackage:
        return '/ paket';
      case MembershipType.unlimited:
        return package.validityDays != null
            ? '/ ${package.validityDays} gün'
            : '';
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
