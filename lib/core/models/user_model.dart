class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? region;
  final String? countryCode;
  final String language;
  final bool isVerified;
  final bool isCreator;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.region,
    this.countryCode,
    this.language = 'fr',
    this.isVerified = false,
    this.isCreator = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      region: json['region'] as String?,
      countryCode: json['country_code'] as String?,
      language: json['language'] as String? ?? 'fr',
      isVerified: json['is_verified'] as bool? ?? false,
      isCreator: json['is_creator'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'region': region,
      'country_code': countryCode,
      'language': language,
      'is_verified': isVerified,
      'is_creator': isCreator,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? region,
    String? countryCode,
    String? language,
    bool? isVerified,
    bool? isCreator,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      region: region ?? this.region,
      countryCode: countryCode ?? this.countryCode,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
      isCreator: isCreator ?? this.isCreator,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}