class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final List<String> savedTrips;
  final List<String> reviewedTrips;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage = '',
    this.savedTrips = const [],
    this.reviewedTrips = const [],
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.lastLoginAt = lastLoginAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'] ?? '',
      savedTrips: List<String>.from(json['savedTrips'] ?? []),
      reviewedTrips: List<String>.from(json['reviewedTrips'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'savedTrips': savedTrips,
      'reviewedTrips': reviewedTrips,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    List<String>? savedTrips,
    List<String>? reviewedTrips,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      savedTrips: savedTrips ?? this.savedTrips,
      reviewedTrips: reviewedTrips ?? this.reviewedTrips,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}