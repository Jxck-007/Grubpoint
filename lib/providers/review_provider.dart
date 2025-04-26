import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  List<Review> _reviews = [];
  bool _isLoading = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews({
    String? restaurantId,
    String? foodItemId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      firestore.Query query = _firestore.collection('reviews');

      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      } else if (foodItemId != null) {
        query = query.where('foodItemId', isEqualTo: foodItemId);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      _reviews = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return Review.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(Review review) async {
    try {
      final docRef = await _firestore.collection('reviews').add(review.toMap());
      final map = review.toMap();
      map['id'] = docRef.id;
      final newReview = Review.fromMap(map);
      _reviews.insert(0, newReview);

      // Update the average rating in the restaurant or food item document
      if (review.restaurantId != null) {
        await _updateRestaurantRating(review.restaurantId!);
      } else if (review.foodItemId != null) {
        await _updateFoodItemRating(review.foodItemId!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> updateReview(Review review) async {
    try {
      await _firestore.collection('reviews').doc(review.id).update(review.toMap());
      final index = _reviews.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        _reviews[index] = review;
      }

      // Update the average rating
      if (review.restaurantId != null) {
        await _updateRestaurantRating(review.restaurantId!);
      } else if (review.foodItemId != null) {
        await _updateFoodItemRating(review.foodItemId!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      await _firestore.collection('reviews').doc(reviewId).delete();
      _reviews.removeWhere((r) => r.id == reviewId);

      // Update the average rating
      if (review.restaurantId != null) {
        await _updateRestaurantRating(review.restaurantId!);
      } else if (review.foodItemId != null) {
        await _updateFoodItemRating(review.foodItemId!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  Future<void> _updateRestaurantRating(String restaurantId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      if (reviews.docs.isEmpty) return;

      final totalRating = reviews.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] as num).toDouble(),
      );

      final averageRating = totalRating / reviews.docs.length;

      await _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
        'totalReviews': reviews.docs.length,
      });
    } catch (e) {
      debugPrint('Error updating restaurant rating: $e');
    }
  }

  Future<void> _updateFoodItemRating(String foodItemId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('foodItemId', isEqualTo: foodItemId)
          .get();

      if (reviews.docs.isEmpty) return;

      final totalRating = reviews.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] as num).toDouble(),
      );

      final averageRating = totalRating / reviews.docs.length;

      await _firestore.collection('food_items').doc(foodItemId).update({
        'rating': averageRating,
        'totalReviews': reviews.docs.length,
      });
    } catch (e) {
      debugPrint('Error updating food item rating: $e');
    }
  }

  double getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final totalRating = _reviews.fold<double>(
      0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / _reviews.length;
  }

  List<Review> getReviewsByRating(double rating) {
    return _reviews.where((review) => review.rating == rating).toList();
  }
} 