import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Stream<QuerySnapshot> getUserProducts({String? category}) {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    Query query = _productsCollection.where('sellerId', isEqualTo: userId);

    // Add category filter if provided and not 'All'
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots();
  }
}
