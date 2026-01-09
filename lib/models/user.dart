class UserModel {
  final String id;
  final DateTime? createdAt;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;

  UserModel({
    required this.id,
    this.createdAt,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
  });

  // Convert dari JSON ke Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Convert dari Object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    DateTime? createdAt,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}
