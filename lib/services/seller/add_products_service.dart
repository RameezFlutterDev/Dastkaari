import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:image_background_remover/image_background_remover.dart';
import 'package:uuid/uuid.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

Future<List<String>> _uploadImages(
    List<File> images, String sellerId, String productId) async {
  List<String> imageUrls = [];
  try {
    await BackgroundRemover.instance.initializeOrt();
    for (int i = 0; i < images.length; i++) {
      File imageFile = images[i];

      // Remove background only for the first image
      if (i == 0) {
        Uint8List imageBytes = await imageFile.readAsBytes();

        // Get the background-removed image
        Image bgRemovedImage =
            await BackgroundRemover.instance.removeBg(imageBytes);

        // Convert Image to Uint8List
        ByteData? byteData =
            await bgRemovedImage.toByteData(format: ImageByteFormat.png);
        if (byteData == null) {
          throw Exception("Failed to process image");
        }

        Uint8List bgRemovedBytes = byteData.buffer.asUint8List();

        // Save as a temporary file
        String tempPath =
            '${imageFile.parent.path}/bg_removed_${Uuid().v4()}.png';
        File bgRemovedFile = File(tempPath);
        await bgRemovedFile.writeAsBytes(bgRemovedBytes);

        imageFile = bgRemovedFile; // Use processed image
      }

      // Upload image to Firebase Storage
      String fileName = '${Uuid().v4()}.jpg';
      Reference ref = _storage.ref('products/$sellerId/$productId/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  } catch (e) {
    throw Exception("Error uploading images: ${e.toString()}");
  }
}

class AddProducts {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required String sellerId,
    required String storeName,
    required List<File> images,
  }) async {
    try {
      // Generate a unique product ID
      String productId = Uuid().v4();

      // Upload images to Firebase Storage and get URLs
      List<String> imageUrls = await _uploadImages(images, sellerId, productId);

      // Store product details in Firestore
      await _firestore.collection('products').doc(productId).set({
        'productId': productId, // Storing product ID
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'sellerId': sellerId,
        'images': imageUrls,
        'storeName': storeName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending Review'
      });
    } catch (e) {
      throw Exception("Error adding product: ${e.toString()}");
    }
  }
}
