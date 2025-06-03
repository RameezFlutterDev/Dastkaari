// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dastkaari/provider/languageProvider.dart';
// import 'package:dastkaari/services/seller/add_products_service.dart';
// import 'package:dastkaari/views/model/categories.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class AddProductScreen extends StatefulWidget {
//   @override
//   _AddProductScreenState createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _stockController = TextEditingController();
//   List<File> _selectedImages = [];
//   String? _selectedCategory;
//   bool _isUploading = false;

//   // final List<String> _categories = [
//   //   'Wooden Crafts',
//   //   'Pottery',
//   //   'Glassworks',
//   //   'Stoneworks',
//   //   'Textiles',
//   //   'Metalworks',
//   //   'Leather Works',
//   //   'Jewelry',
//   // ];

//   Future<void> _pickImages() async {
//     const int maxImages = 5;
//     if (_selectedImages.length >= maxImages) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Maximum 5 images allowed')),
//       );
//       return;
//     }

//     final pickedFiles = await ImagePicker().pickMultiImage(
//       maxWidth: 1024,
//       maxHeight: 1024,
//       imageQuality: 85,
//     );

//     if (pickedFiles != null) {
//       int remainingSlots = maxImages - _selectedImages.length;
//       List<XFile> filesToAdd = pickedFiles.take(remainingSlots).toList();

//       setState(() {
//         _selectedImages.addAll(filesToAdd.map((f) => File(f.path)));
//       });
//     }
//   }

//   void _saveProduct() async {
//     if (_nameController.text.isEmpty ||
//         _descriptionController.text.isEmpty ||
//         _priceController.text.isEmpty ||
//         _stockController.text.isEmpty ||
//         _selectedCategory == null ||
//         _selectedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields and add images')),
//       );
//       return;
//     }

//     double price = double.tryParse(
//           _priceController.text.replaceAll(',', '.'),
//         ) ??
//         0.0;
//     int stock = int.tryParse(_stockController.text) ?? 0;

//     if (price <= 0 || stock < 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid price or stock quantity')),
//       );
//       return;
//     }

//     setState(() => _isUploading = true);

//     try {
//       final uid = FirebaseAuth.instance.currentUser!.uid;

//       // 🔹 Fetch storeName from the sellers collection
//       final sellerDoc =
//           await FirebaseFirestore.instance.collection('sellers').doc(uid).get();
//       final storeName = sellerDoc.data()?['storeName'] ?? 'Unknown Store';

//       AddProducts addProducts = AddProducts();
//       await addProducts.saveProduct(
//         name: _nameController.text,
//         description: _descriptionController.text,
//         price: price,
//         stock: stock,
//         category: _selectedCategory!,
//         sellerId: uid,
//         storeName: storeName, // 🔹 pass store name here
//         images: _selectedImages,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product added successfully')),
//       );

//       _nameController.clear();
//       _descriptionController.clear();
//       _priceController.clear();
//       _stockController.clear();
//       setState(() {
//         _selectedCategory = null;
//         _selectedImages = [];
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }

//     setState(() => _isUploading = false);
//   }

//   Widget _imageTile(File image, int index) {
//     return GestureDetector(
//       onTap: () => _showDeleteDialog(index),
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Stack(
//             children: [
//               Container(
//                 color: Colors.grey[200],
//                 child: Image.file(
//                   image,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               const Positioned(
//                 right: 4,
//                 top: 4,
//                 child: _DeleteButton(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(AppLocalizations.of(context)!.deleteImage,
//             style: GoogleFonts.poppins()),
//         content: Text(AppLocalizations.of(context)!.deleteConfirm,
//             style: GoogleFonts.poppins()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: GoogleFonts.poppins()),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() => _selectedImages.removeAt(index));
//             },
//             child:
//                 Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final langProvider = Provider.of<LanguageProvider>(context);
//     return Localizations.override(
//         context: context,
//         locale: langProvider.locale,
//         child: Builder(builder: (context) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: const Color(0xffD9A441),
//               elevation: 0,
//               title: Text(
//                 AppLocalizations.of(context)!.addProduct,
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               centerTitle: true,
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _inputField(AppLocalizations.of(context)!.productName,
//                       _nameController),
//                   const SizedBox(height: 12),
//                   _inputField(AppLocalizations.of(context)!.description,
//                       _descriptionController,
//                       maxLines: 3),
//                   const SizedBox(height: 12),
//                   _inputField(
//                       AppLocalizations.of(context)!.price, _priceController,
//                       keyboardType: TextInputType.number),
//                   const SizedBox(height: 12),
//                   _inputField(AppLocalizations.of(context)!.stockQuantity,
//                       _stockController,
//                       keyboardType: TextInputType.number),
//                   const SizedBox(height: 12),

//                   // Category Dropdown
//                   Text(
//                     AppLocalizations.of(context)!.category,
//                     style: GoogleFonts.poppins(
//                         fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _selectedCategory,
//                           items: categories.map((Category category) {
//                             return DropdownMenuItem<String>(
//                               value: category
//                                   .name, // Display the English name in the dropdown list
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     '${category.name} (${category.uname})', // Display both English and Urdu names
//                                     style: GoogleFonts.poppins(
//                                         color: Colors.black),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               _selectedCategory = newValue;
//                             });
//                           },
//                         ),
//                       )),
//                   const SizedBox(height: 20),

//                   // Image Section
//                   Text(AppLocalizations.of(context)!.productImages,
//                       style: GoogleFonts.poppins(
//                           fontSize: 14, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: _selectedImages.length,
//                     itemBuilder: (context, index) =>
//                         _imageTile(_selectedImages[index], index),
//                   ),
//                   const SizedBox(height: 8),
//                   OutlinedButton.icon(
//                     icon: const Icon(Icons.add_a_photo, size: 20),
//                     label: Text(AppLocalizations.of(context)!.addImages,
//                         style: GoogleFonts.poppins(fontSize: 14)),
//                     onPressed: _pickImages,
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.black,
//                       side: const BorderSide(color: Color(0xffD9A441)),
//                       minimumSize: const Size(double.infinity, 45),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             bottomNavigationBar: Padding(
//               padding: const EdgeInsets.all(16),
//               child: _isUploading
//                   ? SizedBox(
//                       height: 50,
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           valueColor: const AlwaysStoppedAnimation<Color>(
//                               Color(0xffD9A441)),
//                         ),
//                       ),
//                     )
//                   : ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xffD9A441),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: _saveProduct,
//                       child: Text(AppLocalizations.of(context)!.addProduct,
//                           style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.white)),
//                     ),
//             ),
//           );
//         }));
//   }
// }

// Widget _inputField(String label, TextEditingController controller,
//     {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
//   List<TextInputFormatter>? formatters;

//   if (label.contains('Price')) {
//     formatters = [
//       FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//     ];
//   } else if (label.contains('Stock')) {
//     formatters = [FilteringTextInputFormatter.digitsOnly];
//   }

//   return TextField(
//     controller: controller,
//     maxLines: maxLines,
//     keyboardType: keyboardType,
//     inputFormatters: formatters,
//     style: GoogleFonts.poppins(color: Colors.black),
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: GoogleFonts.poppins(color: Colors.grey),
//       filled: true,
//       floatingLabelBehavior: FloatingLabelBehavior.never,
//       fillColor: Colors.grey[100],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//     ),
//   );
// }

// class _DeleteButton extends StatelessWidget {
//   const _DeleteButton();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: const BoxDecoration(
//         color: Colors.black54,
//         shape: BoxShape.circle,
//       ),
//       child: const Icon(Icons.close, size: 16, color: Colors.white),
//     );
//   }
// }
