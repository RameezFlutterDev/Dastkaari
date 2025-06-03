import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  CollectionReference cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('cart');

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final snapshot = await cartRef.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void addToCart(Map<String, dynamic> product) async {
    final productId = product['productId'];
    await cartRef.doc(productId).set(product);
  }

  void updateCartItem(String productId, int newQuantity) async {
    await cartRef.doc(productId).update({'quantity': newQuantity});
  }

  void removeFromCart(String productId) async {
    await cartRef.doc(productId).delete();
  }
}
