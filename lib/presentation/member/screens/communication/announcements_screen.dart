import 'package:flutter/material.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/core/utils/date_formatter.dart';
import 'package:platia/data/models/announcement.dart';
import 'package:platia/presentation/member/screens/communication/announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Yeni Yoga Dersleri Başlıyor!',
      content:
          'Sevgili üyelerimiz, Mart ayından itibaren yeni yoga derslerimiz başlıyor. Hatha Yoga, Vinyasa Yoga ve Yin Yoga dersleri haftalık programımıza eklenmiştir.',
      imageUrl: 'https://example.com/yoga.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Announcement(
      id: '2',
      title: 'Bayram Tatili Çalışma Saatleri',
      content:
          'Bayram tatili süresince stüdyomuz açık olacaktır. Ancak ders programında bazı değişiklikler olacaktır. Detaylı program için uygulamayı takip ediniz.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Announcement(
      id: '3',
      title: '%20 İndirim Kampanyası',
      content:
          'Yeni üyelikler için %20 indirim kampanyamız başladı! Kampanya 31 Mart tarihine kadar geçerlidir.',
      targetAudience: ['all'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.announcements)),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz duyuru bulunmuyor',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return _AnnouncementCard(
                  announcement: announcement,
                  onTap: () {
                    context.push(
                      AnnouncementDetailScreen(announcement: announcement),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  announcement.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatRelative(
                          announcement.createdAt,
                          locale: context.languageCode,
                        ),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(announcement.title, style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    announcement.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
