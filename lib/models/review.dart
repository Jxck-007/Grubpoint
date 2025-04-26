import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class Review {
  final String id;
  final String userId;
  final String userName;
  final String? restaurantId;
  final String? foodItemId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
  final Map<String, dynamic>? metadata;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.restaurantId,
    this.foodItemId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
    this.metadata,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      restaurantId: map['restaurantId'],
      foodItemId: map['foodItemId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as firestore.Timestamp).toDate(),
      images: (map['images'] as List?)?.cast<String>(),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'restaurantId': restaurantId,
      'foodItemId': foodItemId,
      'rating': rating,
      'comment': comment,
      'createdAt': firestore.Timestamp.fromDate(createdAt),
      'images': images,
      'metadata': metadata,
    };
  }
} 