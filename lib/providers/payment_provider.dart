import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class PaymentMethod {
  final String id;
  final String userId;
  final String type; // 'card', 'upi', 'wallet'
  final String details; // card number, UPI ID, etc.
  final bool isDefault;
  final String? cardHolderName;
  final String? expiryDate;
  final String? cvv;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.details,
    this.isDefault = false,
    this.cardHolderName,
    this.expiryDate,
    this.cvv,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      details: map['details'] ?? '',
      isDefault: map['isDefault'] ?? false,
      cardHolderName: map['cardHolderName'],
      expiryDate: map['expiryDate'],
      cvv: map['cvv'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'details': details,
      'isDefault': isDefault,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }
}

class PaymentProvider with ChangeNotifier {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  PaymentMethod? get defaultPaymentMethod => _paymentMethods.firstWhere(
        (method) => method.isDefault,
        orElse: () => _paymentMethods.first,
      );

  Future<void> fetchPaymentMethods(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: userId)
          .get();

      _paymentMethods = snapshot.docs
          .map((doc) => PaymentMethod.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      final docRef = await _firestore.collection('payment_methods').add(method.toMap());
      final newMethod = PaymentMethod.fromMap({...method.toMap(), 'id': docRef.id});
      _paymentMethods.add(newMethod);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentMethod(PaymentMethod method) async {
    try {
      await _firestore.collection('payment_methods').doc(method.id).update(method.toMap());
      final index = _paymentMethods.indexWhere((m) => m.id == method.id);
      if (index != -1) {
        _paymentMethods[index] = method;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating payment method: $e');
      rethrow;
    }
  }

  Future<void> deletePaymentMethod(String methodId) async {
    try {
      await _firestore.collection('payment_methods').doc(methodId).delete();
      _paymentMethods.removeWhere((method) => method.id == methodId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting payment method: $e');
      rethrow;
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      // Update all methods to set isDefault to false
      for (var method in _paymentMethods) {
        if (method.isDefault) {
          await _firestore.collection('payment_methods').doc(method.id).update({
            'isDefault': false,
          });
        }
      }

      // Set the new default method
      await _firestore.collection('payment_methods').doc(methodId).update({
        'isDefault': true,
      });

      // Update local state
      for (var method in _paymentMethods) {
        if (method.id == methodId) {
          method = PaymentMethod.fromMap({...method.toMap(), 'isDefault': true});
        } else if (method.isDefault) {
          method = PaymentMethod.fromMap({...method.toMap(), 'isDefault': false});
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting default payment method: $e');
      rethrow;
    }
  }

  Future<bool> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      // Here you would integrate with a real payment gateway
      // For now, we'll simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));

      // Record the payment in Firestore
      await _firestore.collection('payments').add({
        'orderId': orderId,
        'amount': amount,
        'paymentMethodId': paymentMethodId,
        'status': 'completed',
        'timestamp': firestore.Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    }
  }
} 