class Conversation {
  final String id;
  final String userId;
  final String? instructorId;
  final String? adminId;
  final ConversationType type;
  final String title;
  final DateTime lastMessageAt;
  final bool hasUnreadMessages;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userId,
    this.instructorId,
    this.adminId,
    required this.type,
    required this.title,
    required this.lastMessageAt,
    this.hasUnreadMessages = false,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      userId: json['userId'],
      instructorId: json['instructorId'],
      adminId: json['adminId'],
      type: ConversationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      hasUnreadMessages: json['hasUnreadMessages'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'instructorId': instructorId,
      'adminId': adminId,
      'type': type.toString().split('.').last,
      'title': title,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'hasUnreadMessages': hasUnreadMessages,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum ConversationType { userToAdmin, userToInstructor, support }
