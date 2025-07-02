import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/currency_formatter.dart';
import 'package:platia/presentation/admin/widgets/stat_card.dart';

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.financialReports),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export reports
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  icon: Icons.attach_money,
                  title: 'Toplam Gelir',
                  value: CurrencyFormatter.formatTRY(125750),
                  color: Colors.green,
                  subtitle: 'Bu ay',
                ),
                StatCard(
                  icon: Icons.trending_up,
                  title: 'Büyüme',
                  value: '+18%',
                  color: AppColors.success,
                  subtitle: 'Geçen aya göre',
                ),
                StatCard(
                  icon: Icons.people,
                  title: 'Yeni Üyeler',
                  value: '42',
                  color: AppColors.primary,
                  subtitle: 'Bu ay',
                ),
                StatCard(
                  icon: Icons.school,
                  title: 'Toplam Ders',
                  value: '324',
                  color: AppColors.secondary,
                  subtitle: 'Bu ay',
                ),
              ],
            ),

            // Charts would go here
          ],
        ),
      ),
    );
  }
}
