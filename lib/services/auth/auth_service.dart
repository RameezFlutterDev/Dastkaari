import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/views/model/storeInteractions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserTokenToDatabase(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("token:$token");
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  Future<void> saveSellerTokenToDatabase(String sellerId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("token:$token");
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .update({
        'fcmToken': token,
      });
    }
  }

//Sign In
  Future<UserCredential> SignInWithEmailPassword(
      String Email, String Password) async {
    try {
      Interactions intrc = Interactions();
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: Email, password: Password);

      int userId = await intrc.assignUserIdIfNeeded();

      return userCredential;
    } catch (e) {
      throw Exception(e);
    }
    //
    // on FirebaseAuthException catch (e) {
    //   throw Exception(e.code);
  }

  //Sign up

  Future<UserCredential> SignUpWithEmailPassword(
      String Email, String Password, String Username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: Email, password: Password);
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "email": userCredential.user!.email,
        "username": Username,
        'status': 'Active',
        "uid": userCredential.user!.uid
      });

      return userCredential;
    } catch (e) {
      throw Exception(e);
    }
  }

  //Sign out
  Future<void> SignOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
