import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Address> _addresses = [];
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  Address? get defaultAddress => _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.first,
      );

  Future<void> fetchAddresses(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      _addresses = snapshot.docs
          .map((doc) => Address.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      final docRef = await _firestore.collection('addresses').add(address.toMap());
      final newAddress = Address.fromMap({...address.toMap(), 'id': docRef.id});
      _addresses.add(newAddress);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      await _firestore.collection('addresses').doc(address.id).update(address.toMap());
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
      _addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      // Update all addresses to set isDefault to false
      for (var address in _addresses) {
        if (address.isDefault) {
          await _firestore.collection('addresses').doc(address.id).update({
            'isDefault': false,
          });
        }
      }

      // Set the new default address
      await _firestore.collection('addresses').doc(addressId).update({
        'isDefault': true,
      });

      // Update local state
      for (var address in _addresses) {
        if (address.id == addressId) {
          address = Address.fromMap({...address.toMap(), 'isDefault': true});
        } else if (address.isDefault) {
          address = Address.fromMap({...address.toMap(), 'isDefault': false});
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }
} 