import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserOrderCount() async {
    try {
      String uid = _auth.currentUser!.uid;

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid) // or 'buyerId' based on your schema
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error fetching order count: $e");
      return 0;
    }
  }
}
