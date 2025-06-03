import 'package:carousel_slider/carousel_slider.dart';
import 'package:dastkaari/services/cart/cart_service.dart';
import 'package:dastkaari/views/AR/arview.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Itemdetails extends StatefulWidget {
  final Map<String, dynamic> item;

  const Itemdetails({super.key, required this.item});

  @override
  _ItemdetailsState createState() => _ItemdetailsState();
}

class _ItemdetailsState extends State<Itemdetails> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    double price =
        (widget.item['price'] ?? 100).toDouble(); // Ensure default price
    double originalPrice = price * 1.25; // Calculate 25% greater original price

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Dastkaari',
                style: GoogleFonts.pacifico(
                    color: Color(0xffD9A441), fontSize: 28),
              ),
            ),
            const SizedBox(height: 10),
            // Back button and Share icon
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.35,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                  ),
                  items: (widget.item['images'] as List<dynamic>)
                      .map<Widget>((imageUrl) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(), // ✅ this was missing the `items:` label
                ),
              ),
            ),

            const SizedBox(height: 15),
            // AR View Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ARViewScreen(productImageUrl: widget.item['images'][0]),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff9DBE8E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(
                Icons.view_in_ar,
                color: const Color(0xffD9A441),
              ),
              label: Text(
                'View in AR',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Product Name and Bookmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item['name'] ?? 'Luxury Executive Chair',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.bookmark_outline,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Product Tags
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Green product",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.attach_money, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Save money",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Product Description
            Text(
              widget.item['description'] ?? 'No description available.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.2,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            // Quantity Selector and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.grey, size: 24),
                    ),
                    Text(
                      quantity.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.grey, size: 24),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "RS ${originalPrice.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      "RS ${price.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Add to Cart Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        // User is not logged in — prompt login
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Login Required"),
                            content: Text(
                                "You need to log in to add items to your cart."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginScreen()),
                                  );
                                },
                                child: Text("Login"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // User is logged in — proceed with adding to cart
                        CartService cartService = CartService();
                        widget.item['quantity'] = quantity;
                        cartService.addToCart(widget.item);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Added $quantity item(s) to the cart successfully!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD9A441),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 8),
              child: Text(
                'FAQs',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            ExpansionTile(
              title: Text("How do I place an order?",
                  style: GoogleFonts.poppins()),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Add products to your cart, go to checkout, select your address and payment method, then tap 'Order Now'.",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Is Cash on Delivery available?",
                  style: GoogleFonts.poppins()),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Yes, Cash on Delivery is available across Pakistan.",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title:
                  Text("Are returns available?", style: GoogleFonts.poppins()),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "As items are handmade, returns are only accepted for damaged or incorrect products.",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
