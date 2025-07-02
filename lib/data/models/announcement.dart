// Announcement
class Announcement {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isActive;
  final DateTime? scheduledAt;
  final List<String> targetAudience; // membershipTypes or 'all'
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.isActive = true,
    this.scheduledAt,
    this.targetAudience = const ['all'],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      targetAudience: List<String>.from(json['targetAudience'] ?? ['all']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'targetAudience': targetAudience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
