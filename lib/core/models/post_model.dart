import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? content;
  final List<String>? mediaUrls;
  final String mediaType;
  final String postType;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isRepost;
  final String? originalPostId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? profile;

  PostModel({
    required this.id,
    required this.userId,
    this.content,
    this.mediaUrls,
    this.mediaType = 'none',
    this.postType = 'standard',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isRepost = false,
    this.originalPostId,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String?,
      mediaUrls: json['media_urls'] != null 
        ? List<String>.from(json['media_urls'] as List)
        : null,
      mediaType: json['media_type'] as String? ?? 'none',
      postType: json['post_type'] as String? ?? 'standard',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isRepost: json['is_repost'] as bool? ?? false,
      originalPostId: json['original_post_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profile: json['profiles'] != null 
        ? UserModel.fromJson(json['profiles'] as Map<String, dynamic>)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'media_type': mediaType,
      'post_type': postType,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'is_repost': isRepost,
      'original_post_id': originalPostId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}