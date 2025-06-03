import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class UpdateProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    // required List<File> newImages, // Newly added images
    // required List<String> existingImages, // Existing image URLs
  }) async {
    try {
      // Reference to the product document
      DocumentReference productRef =
          _firestore.collection('products').doc(productId);

      // List<String> updatedImageUrls = List.from(existingImages);

      // // Upload new images and get their URLs
      // for (File image in newImages) {
      //   String imageUrl = await _uploadImage(image, productId);
      //   updatedImageUrls.add(imageUrl);
      // }

      // Update Firestore with new details
      await productRef.update({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        // 'images': updatedImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint("Product updated successfully.");
    } catch (e) {
      debugPrint("Error updating product: $e");
      throw Exception("Failed to update product.");
    }
  }

  // Future<String> _uploadImage(File image, String productId) async {
  //   try {
  //     String fileName =
  //         'products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     Reference ref = _storage.ref().child(fileName);
  //     UploadTask uploadTask = ref.putFile(image);

  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     debugPrint("Error uploading image: $e");
  //     throw Exception("Image upload failed.");
  //   }
  // }

  // Future<void> deleteImage(String imageUrl) async {
  //   try {
  //     if (imageUrl.isNotEmpty) {
  //       Reference imageRef = _storage.refFromURL(imageUrl);
  //       await imageRef.delete();
  //       debugPrint("Image deleted: $imageUrl");
  //     }
  //   } catch (e) {
  //     debugPrint("Error deleting image: $e");
  //   }
  // }
}
