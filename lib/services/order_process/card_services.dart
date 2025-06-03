import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CardServices {
  // Load card data from Firestore
  Future<void> loadCardData(
      String cardId,
      TextEditingController cardNumberController,
      TextEditingController expController,
      TextEditingController cvvController,
      TextEditingController cardholderNameController) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(cardId);

    final snapshot = await doc.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      cardNumberController.text = data?['cardNumber'] ?? '';
      expController.text = data?['exp'] ?? '';
      cvvController.text = data?['cvv'] ?? '';
      cardholderNameController.text = data?['cardholderName'] ?? '';
    }
  }

  // Save or update card data in Firestore
  Future<void> saveCard(
      BuildContext context,
      String? cardId,
      TextEditingController cardNumberController,
      TextEditingController expController,
      TextEditingController cvvController,
      TextEditingController cardholderNameController) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cards');

    final cardData = {
      'cardNumber': cardNumberController.text,
      'exp': expController.text,
      'cvv': cvvController.text,
      'cardholderName': cardholderNameController.text,
    };

    if (cardId == null) {
      // Add a new card
      final docRef = await cardsRef.add(cardData);
      await docRef.update({'cardId': docRef.id}); // Optionally store cardId
    } else {
      // Update existing card
      await cardsRef.doc(cardId).update(cardData);
    }

    Navigator.pop(context); // Go back after saving
  }
}
