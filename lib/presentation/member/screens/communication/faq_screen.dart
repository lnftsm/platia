import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/data/models/faq.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQ> _faqs = [
    FAQ(
      id: '1',
      question: 'Nasıl üye olabilirim?',
      answer:
          'Uygulamayı indirdikten sonra "Kayıt Ol" butonuna tıklayarak kişisel bilgilerinizi girip üyelik oluşturabilirsiniz.',
      category: FAQCategory.membership,
      order: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FAQ(
      id: '2',
      question: 'Ders rezervasyonumu nasıl iptal edebilirim?',
      answer:
          'Derse 2 saat kalana kadar "Rezervasyonlarım" bölümünden ilgili derse tıklayıp iptal edebilirsiniz.',
      category: FAQCategory.classes,
      order: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FAQ(
      id: '3',
      question: 'Hangi ödeme yöntemlerini kabul ediyorsunuz?',
      answer:
          'Kredi kartı, banka havalesi ve nakit ödeme kabul ediyoruz. Online ödemeler güvenli altyapımız üzerinden gerçekleştirilir.',
      category: FAQCategory.payments,
      order: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FAQ(
      id: '4',
      question: 'Üyeliğimi nasıl dondurabilirim?',
      answer:
          'Üyelik dondurma işlemi için stüdyo yönetimi ile iletişime geçmeniz gerekmektedir.',
      category: FAQCategory.membership,
      order: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FAQ(
      id: '5',
      question: 'Uygulama üzerinden ders kaydı yapamıyorum, ne yapmalıyım?',
      answer:
          'Öncelikle internet bağlantınızı kontrol edin. Sorun devam ederse uygulamayı kapatıp tekrar açın. Hala sorun yaşıyorsanız destek ekibimizle iletişime geçin.',
      category: FAQCategory.technical,
      order: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  FAQCategory? _selectedCategory;
  final Map<String, bool> _expandedItems = {};

  List<FAQ> get _filteredFAQs {
    if (_selectedCategory == null) {
      return _faqs;
    }
    return _faqs.where((faq) => faq.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.faq)),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'Tümü',
                  isSelected: _selectedCategory == null,
                  onSelected: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ...FAQCategory.values.map((category) {
                  return _CategoryChip(
                    label: _getCategoryName(category),
                    isSelected: _selectedCategory == category,
                    onSelected: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bu kategoride soru bulunmuyor',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      final isExpanded = _expandedItems[faq.id] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(
                            faq.question,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more),
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _expandedItems[faq.id] = expanded;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq.answer,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(FAQCategory category) {
    switch (category) {
      case FAQCategory.membership:
        return 'Üyelik';
      case FAQCategory.classes:
        return 'Dersler';
      case FAQCategory.payments:
        return 'Ödemeler';
      case FAQCategory.technical:
        return 'Teknik';
      case FAQCategory.general:
        return 'Genel';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}
