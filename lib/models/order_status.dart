import 'package:flutter/material.dart';
import 'food_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled
}

enum PaymentStatus {
  pending,
  completed,
  failed
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final DateTime orderTime;
  final DateTime? pickupTime;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final String? preparationNote;
  final int estimatedWaitingTime; // in minutes

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.orderTime,
    this.pickupTime,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    this.preparationNote,
    required this.estimatedWaitingTime,
  });
}

class OrderItem {
  final String id;
  final FoodItem food;
  final int quantity;
  final String? specialInstructions;
  final bool isAvailable;
  final PreparationStatus preparationStatus;

  OrderItem({
    required this.id,
    required this.food,
    required this.quantity,
    this.specialInstructions,
    required this.isAvailable,
    required this.preparationStatus,
  });
}

class PreparationStatus {
  final bool started;
  final double progress; // 0 to 1
  final String? currentStep;
  final DateTime? startTime;
  final DateTime? estimatedCompletionTime;

  PreparationStatus({
    required this.started,
    required this.progress,
    this.currentStep,
    this.startTime,
    this.estimatedCompletionTime,
  });
}

class CanteenTimings {
  final String dayOfWeek;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final bool isOpen;

  CanteenTimings({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });
}

class FoodAvailability {
  final String foodId;
  final bool isAvailable;
  final int remainingQuantity;
  final int preparationTime; // in minutes
  final DateTime? nextAvailableTime;

  FoodAvailability({
    required this.foodId,
    required this.isAvailable,
    required this.remainingQuantity,
    required this.preparationTime,
    this.nextAvailableTime,
  });
} 