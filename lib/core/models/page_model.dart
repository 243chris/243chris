class PageModel {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String? description;
  final String? avatarUrl;
  final String? coverUrl;
  final String? ownerId;
  final int followersCount;
  final DateTime createdAt;

  PageModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    this.description,
    this.avatarUrl,
    this.coverUrl,
    this.ownerId,
    this.followersCount = 0,
    required this.createdAt,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      ownerId: json['owner_id'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'category': category,
      'description': description,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'owner_id': ownerId,
      'followers_count': followersCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}