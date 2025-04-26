import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';
import 'dart:math';

class OrderProvider with ChangeNotifier {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // Generate a unique pickup code
  String _generatePickupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('pickupTime', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return Order.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      // Generate pickup code
      final pickupCode = _generatePickupCode();
      
      // Create order with pickup code
      final orderWithCode = Order(
        id: order.id,
        userId: order.userId,
        restaurantId: order.restaurantId,
        restaurantName: order.restaurantName,
        items: order.items,
        totalAmount: order.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        pickupTime: order.pickupTime,
        pickupCode: pickupCode,
        paymentMethod: order.paymentMethod,
        isPrepaid: order.isPrepaid,
      );

      final docRef = await _firestore.collection('orders').add(orderWithCode.toMap());
      final newOrder = Order.fromMap({...orderWithCode.toMap(), 'id': docRef.id});
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = Order.fromMap({
          ..._orders[index].toMap(),
          'status': newStatus,
        });
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> markOrderReadyForPickup(String orderId) async {
    await updateOrderStatus(orderId, 'ready_for_pickup');
  }

  Future<void> completeOrder(String orderId) async {
    await updateOrderStatus(orderId, 'completed');
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }

  List<Order> getActiveOrders() {
    return _orders.where((order) => 
      !order.isCompleted && !order.isCancelled
    ).toList();
  }

  List<Order> getReadyForPickupOrders() {
    return _orders.where((order) => order.isReadyForPickup).toList();
  }

  List<Order> getCompletedOrders() {
    return _orders.where((order) => order.isCompleted).toList();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Order? getOrderByPickupCode(String pickupCode) {
    try {
      return _orders.firstWhere((order) => order.pickupCode == pickupCode);
    } catch (e) {
      return null;
    }
  }
} 