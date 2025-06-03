import 'package:cloud_firestore/cloud_firestore.dart';

class AddressServices {
  final String userId;

  AddressServices({required this.userId});

  // Fetch an address by ID
  Future<Map<String, dynamic>?> getAddress(String addressId) async {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId);

    final snapshot = await doc.get();
    return snapshot.exists ? snapshot.data() : null;
  }

  // Add a new address
  Future<String> addAddress(Map<String, dynamic> addressData) async {
    final addressesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses');

    final docRef = await addressesRef.add(addressData);
    await docRef.update({'addressId': docRef.id}); // Save the document ID
    return docRef.id;
  }

  // Update an existing address
  Future<void> updateAddress(
      String addressId, Map<String, dynamic> addressData) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId);

    await docRef.update(addressData);
  }
}
