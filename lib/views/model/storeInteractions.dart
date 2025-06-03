import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Interactions {
  Future<void> logUserInteraction(
      String userId, String category, String interaction) async {
    await FirebaseFirestore.instance
        .collection('interactions')
        .doc(userId)
        .collection('userInteractions')
        .add({
      'category': category,
      'interaction': interaction,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<int> assignUserIdIfNeeded() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    final existing = await userDoc.get();

    if (existing.exists && existing.data()?['userId'] != null) {
      return existing['userId'];
    }

    // Count how many users already exist (i.e., total documents in userMeta)
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final newId = allUsers.docs.length + 1;

    await userDoc.update({
      'userId': newId,
    });

    return newId;
  }

  Future<List<Map<String, String>>> getLatestUserInteractions() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('interactions')
        .doc(uid)
        .collection('userInteractions')
        .orderBy('timestamp', descending: true)
        .limit(2)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'Category': data['category'].toString(),
        'Interaction': data['interaction'].toString(),
      };
    }).toList();
  }
}
