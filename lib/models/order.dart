import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'food_item.dart';

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<FoodItem> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'ready_for_pickup', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime pickupTime;
  final String pickupCode; // Unique code for order verification
  final String? paymentMethod;
  final bool isPrepaid;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.pickupTime,
    required this.pickupCode,
    this.paymentMethod,
    this.isPrepaid = false,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      items: (map['items'] as List?)
              ?.map((item) => FoodItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as firestore.Timestamp).toDate(),
      pickupTime: (map['pickupTime'] as firestore.Timestamp).toDate(),
      pickupCode: map['pickupCode'] ?? '',
      paymentMethod: map['paymentMethod'],
      isPrepaid: map['isPrepaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': firestore.Timestamp.fromDate(createdAt),
      'pickupTime': firestore.Timestamp.fromDate(pickupTime),
      'pickupCode': pickupCode,
      'paymentMethod': paymentMethod,
      'isPrepaid': isPrepaid,
    };
  }

  // Helper methods
  bool get isReadyForPickup => status == 'ready_for_pickup';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  Duration get timeUntilPickup => pickupTime.difference(DateTime.now());
  String get formattedPickupTime => 
      '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}';
} 