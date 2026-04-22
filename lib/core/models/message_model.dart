class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? content;
  final String? mediaUrl;
  final String? emojiId;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.mediaUrl,
    this.emojiId,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      emojiId: json['emoji_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'media_url': mediaUrl,
      'emoji_id': emojiId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}