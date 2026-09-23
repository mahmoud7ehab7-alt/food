import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/features/profile/domain/address_model.dart';

class AddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _addressCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('addresses');

  // Add new address
  Future<void> addAddress(String userId, AddressModel address) async {
    try {
      if (address.isDefault) {
        await _resetDefaults(userId);
      }
      await _addressCollection(userId).add(address.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all addresses
  Stream<List<AddressModel>> getAddresses(String userId) {
    return _addressCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _addressCollection(userId).doc(addressId).delete();
  }

  // Private helper to reset all addresses to non-default
  Future<void> _resetDefaults(String userId) async {
    final snapshot = await _addressCollection(userId).where('isDefault', isEqualTo: true).get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }
}
