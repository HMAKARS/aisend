class Review {
  final String id;
  final String userId;
  final String userName;
  final String userProfileUrl;
  final String courseId;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final List<String> likes;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl = '',
    required this.courseId,
    required this.rating,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.likes = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userProfileUrl: json['userProfileUrl'] ?? '',
      courseId: json['courseId'],
      rating: json['rating'].toDouble(),
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'courseId': courseId,
      'rating': rating,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }
}
