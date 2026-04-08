class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final int totalPoints;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.totalPoints,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      phone: json['phone'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
      totalPoints: json['totalPoints'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
  }) {
    return UserProfile(
      id: id,
      username: username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role,
      isActive: isActive,
      totalPoints: totalPoints,
      createdAt: createdAt,
    );
  }
}
