import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/provider/languageProvider.dart';
import 'package:dastkaari/services/seller/inventory_service.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/model/categories.dart';
import 'package:dastkaari/views/seller/inventory/add_item.dart';

import 'package:dastkaari/views/seller/inventory/update_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final InventoryService _inventoryService = InventoryService();
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Localizations.override(
      context: context,
      locale: langProvider.locale,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xffD9A441),
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    AppLocalizations.of(context)!.manageInventory,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: langProvider.toggleLanguage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                    child: Text(
                      langProvider.currentLanguageLabel,
                      style: GoogleFonts.poppins(
                        color: const Color(0xffD9A441),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AddProductScreen(),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD9A441),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.addProduct,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category.name;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category.name;
                            });
                          },
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.brown
                                    : const Color(0xff9DBE8E),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Text(
                                '${category.name} / ${category.uname}', // Combines both names with slash
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _inventoryService.getUserProducts(
                        category:
                            selectedCategory == 'All' ? null : selectedCategory,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              selectedCategory == 'All'
                                  ? 'No products found.'
                                  : 'No products in $selectedCategory category.',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          );
                        }

                        final products = snapshot.data!.docs;

                        return ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            var product =
                                products[index].data() as Map<String, dynamic>;
                            List<dynamic>? imageUrls = product['images'];

                            return InventoryTile(
                              product: product,
                              productId: products[index].id,
                              imageUrl:
                                  (imageUrls != null && imageUrls.isNotEmpty)
                                      ? imageUrls[0]
                                      : 'https://example.com/default-image.jpg',
                              itemName: product['name'] ?? 'Unnamed Product',
                              price: (product['price'] != null)
                                  ? product['price'].toDouble()
                                  : 0.0,
                              stock: (product['stock'] != null)
                                  ? product['stock'].toInt()
                                  : 0,
                              status: (product['status'] != null)
                                  ? product['status']
                                  : 'Activee',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class InventoryTile extends StatelessWidget {
  final String productId;
  final String imageUrl;
  final String itemName;
  final double price;
  final int stock;
  final Map<String, dynamic> product;
  final String status;

  const InventoryTile(
      {required this.productId,
      required this.imageUrl,
      required this.itemName,
      required this.price,
      required this.stock,
      required this.product,
      required this.status});

  void _deleteProduct(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // For Price
                Text(
                  '${AppLocalizations.of(context)!.price} ${price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

// For Stock
                Text(
                  '${AppLocalizations.of(context)!.stockLabel(stock)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

// For Status
                Text(
                  '${AppLocalizations.of(context)!.statusLabel(status)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: status.toLowerCase() == 'pending review'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _actionButton(AppLocalizations.of(context)!.view,
                        const Color(0xffD9A441), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Itemdetails(item: product),
                          ));
                      // Navigate to product details screen
                    }),
                    const SizedBox(width: 4),
                    _actionButton(AppLocalizations.of(context)!.edit,
                        const Color(0xffD9A441), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateItemScreen(
                            productId: product['productId'],
                            itemName: product['name'] ?? 'Unnamed Product',
                            description: product['description'] ?? '',
                            price: (product['price'] ?? 0).toDouble(),
                            stock: (product['stock'] ?? 0).toInt(),
                            category: product['category'] ?? '',
                            // imageUrls: (product['image'] is List &&
                            //         product['image'] != null)
                            //     ? List<String>.from(product[
                            //         'image']) // Ensuring it's a List<String>
                            //     : ['https://example.com/default-image.jpg'],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    _actionButton(AppLocalizations.of(context)!.delete,
                        Colors.red, () => _deleteProduct(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
