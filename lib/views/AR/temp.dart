import 'package:dastkaari/views/AR/arview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Import the ARViewScreen

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId})
      : super(key: key);

  Future<String> _getProductImageUrl() async {
    final ref = FirebaseStorage.instance.ref().child('products/$productId.jpg');
    return 'https://firebasestorage.googleapis.com/v0/b/xupstore-aa3f8.appspot.com/o/uploads%2Fgames%2FYqg1O43FGvfkNiJ6gaeNrsTL5uR2%2F1964569b-d805-4934-97c0-3beb01831a5e?alt=media&token=36af5e64-56b5-4997-b7eb-e27d4a77feb0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: _getProductImageUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load image'));
          }
          return ARViewScreen(productImageUrl: snapshot.data!);
        },
      ),
    );
  }
}
