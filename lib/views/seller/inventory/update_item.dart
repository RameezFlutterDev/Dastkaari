import 'package:dastkaari/provider/languageProvider.dart';
import 'package:dastkaari/services/seller/update_products_service.dart';
import 'package:dastkaari/views/model/categories.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class UpdateItemScreen extends StatefulWidget {
  final String productId;
  final String itemName;
  final String description;
  final double price;
  final int stock;
  final String category;
  // final List<String> imageUrls;

  const UpdateItemScreen({
    required this.productId,
    required this.itemName,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    // required this.imageUrls,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateItemScreenState createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  List<File> _newImages = [];
  List<String> _existingImages = [];
  String? _selectedCategory;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemName);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price.toString());
    _stockController = TextEditingController(text: widget.stock.toString());
    _selectedCategory = widget.category;
    // _existingImages = List.from(widget.imageUrls);
  }

  // Future<void> _pickImages() async {
  //   const int maxImages = 5;
  //   int currentCount = _existingImages.length + _newImages.length;

  //   if (currentCount >= maxImages) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Maximum 5 images allowed')),
  //     );
  //     return;
  //   }

  //   final pickedFiles = await ImagePicker().pickMultiImage(
  //     maxWidth: 1024,
  //     maxHeight: 1024,
  //     imageQuality: 85,
  //   );

  //   if (pickedFiles != null) {
  //     int remainingSlots = maxImages - currentCount;
  //     List<XFile> filesToAdd = pickedFiles.take(remainingSlots).toList();

  //     setState(() {
  //       _newImages.addAll(filesToAdd.map((f) => File(f.path)));
  //     });
  //   }
  // }

  void _updateProduct() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // if (_existingImages.isEmpty && _newImages.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please add at least one image')),
    //   );
    //   return;
    // }

    double price = double.tryParse(
          _priceController.text.replaceAll(',', '.'),
        ) ??
        0.0;
    int stock = int.tryParse(_stockController.text) ?? 0;

    if (price <= 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price or stock quantity')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      UpdateProductService updateService = UpdateProductService();

      // Update product details
      await updateService.updateProduct(
        productId: widget.productId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: price,
        stock: stock,
        category: _selectedCategory!,
      );

      // Delete removed images
      // List<String> imagesToDelete = widget.imageUrls
      //     .where((url) => !_existingImages.contains(url))
      //     .toList();
      // for (String imageUrl in imagesToDelete) {
      //   await updateService.deleteImage(imageUrl);
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isUpdating = false);
  }

  Widget _imageTile(ImageProvider image, int index, bool isExisting) {
    return GestureDetector(
      onTap: () => _showDeleteDialog(index, isExisting),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                color: Colors.grey[200],
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              const Positioned(
                right: 4,
                top: 4,
                child: _DeleteButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int index, bool isExisting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteImage,
            style: GoogleFonts.poppins()),
        content: Text(AppLocalizations.of(context)!.deleteConfirm,
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (isExisting) {
                  _existingImages.removeAt(index);
                } else {
                  int newIndex = index - _existingImages.length;
                  _newImages.removeAt(newIndex);
                }
              });
            },
            child: Text(AppLocalizations.of(context)!.delete,
                style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Localizations.override(
      context: context,
      locale: langProvider.locale,
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xffD9A441),
            elevation: 0,
            title: Text(
              AppLocalizations.of(context)!.updateProduct,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputField(
                    AppLocalizations.of(context)!.productName, _nameController),
                const SizedBox(height: 12),
                _inputField(AppLocalizations.of(context)!.updateProduct,
                    _descriptionController,
                    maxLines: 3),
                const SizedBox(height: 12),
                _inputField(
                    AppLocalizations.of(context)!.price, _priceController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _inputField(AppLocalizations.of(context)!.stockQuantity,
                    _stockController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                // Category Dropdown
                Text(
                  AppLocalizations.of(context)!.category,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: categories.map((Category category) {
                          return DropdownMenuItem<String>(
                            value: category
                                .name, // Display the English name in the dropdown list
                            child: Row(
                              children: [
                                Text(
                                  '${category.name} (${category.uname})', // Display both English and Urdu names
                                  style:
                                      GoogleFonts.poppins(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    )),

                const SizedBox(height: 20),

                // Image Section
                // Text('Product Images (Max 5)',
                //     style: GoogleFonts.poppins(
                //         fontSize: 14, fontWeight: FontWeight.bold)),
                // const SizedBox(height: 8),
                // GridView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 3,
                //     crossAxisSpacing: 8,
                //     mainAxisSpacing: 8,
                //     childAspectRatio: 1,
                //   ),
                //   itemCount: _existingImages.length + _newImages.length,
                //   itemBuilder: (context, index) {
                //     if (index < _existingImages.length) {
                //       return _imageTile(
                //           NetworkImage(_existingImages[index]), index, true);
                //     }
                //     return _imageTile(
                //         FileImage(_newImages[index - _existingImages.length]),
                //         index,
                //         false);
                //   },
                // ),
                const SizedBox(height: 8),
                // OutlinedButton.icon(
                //   icon: const Icon(Icons.add_a_photo, size: 20),
                //   label: Text('Add New Images',
                //       style: GoogleFonts.poppins(fontSize: 14)),
                //   onPressed: _pickImages,
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: Colors.black,
                //     side: const BorderSide(color: Color(0xffD9A441)),
                //     minimumSize: const Size(double.infinity, 45),
                //   ),
                // ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: _isUpdating
                ? SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xffD9A441)),
                      ),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD9A441),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _updateProduct,
                    child: Text(AppLocalizations.of(context)!.updateProduct,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
          ),
        );
      }),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    List<TextInputFormatter>? formatters;

    if (label.contains('Price')) {
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ];
    } else if (label.contains('Stock')) {
      formatters = [FilteringTextInputFormatter.digitsOnly];
    }

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, size: 16, color: Colors.white),
    );
  }
}
