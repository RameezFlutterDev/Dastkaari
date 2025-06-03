import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/views/order_process/address_payment_screens/address_list.dart';
import 'package:dastkaari/views/order_process/address_payment_screens/payment_list.dart';
import 'package:dastkaari/views/order_process/order_confirmation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final double shippingCost;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.shippingCost,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedAddress; // Store the selected address
  String? selectedPayment;
  void placeOrder(
      List<Map<String, dynamic>> cartItems,
      String userId,
      String address,
      String paymentMethod,
      double totalPrice,
      double shippingCost) async {
    if (cartItems.isEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ordersRef = firestore.collection('orders');

    // Group items by sellerId
    Map<String, List<Map<String, dynamic>>> sellerItemsMap = {};
    for (var item in cartItems) {
      String sellerId = item['sellerId'];
      if (!sellerItemsMap.containsKey(sellerId)) {
        sellerItemsMap[sellerId] = [];
      }
      sellerItemsMap[sellerId]!.add(item);
    }

    for (var entry in sellerItemsMap.entries) {
      String sellerId = entry.key;
      List<Map<String, dynamic>> sellerItems = entry.value;

      var uuid = Uuid();
      String orderId = uuid.v4();

      double sellerTotal = sellerItems.fold(
          0.0, (sum, item) => sum + (item['price'] * item['quantity']));

      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': userId,
        'sellerId': sellerId,
        'createdAt': Timestamp.now(),
        'status': 'pending',
        'totalAmount': sellerTotal + 250,
        'address': address,
        'paymentMethod': paymentMethod,
      };

      DocumentReference orderDoc = ordersRef.doc(orderId);
      await orderDoc.set(orderData);

      for (var item in sellerItems) {
        await orderDoc.collection('products').doc(item['productId']).set({
          'productId': item['productId'],
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
          'status': 'pending',
        });
      }
    }

    // Navigate to Order Confirmation
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = widget.totalPrice + widget.shippingCost;
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            _buildSelectionCard(
              title: selectedAddress ?? 'Add Shipping Address',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressListScreen(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedAddress = result;
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            // Payment Method Section
            _buildSelectionCard(
              title: selectedPayment ?? 'Add Payment Method',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentListScreen(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedPayment = result;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Cart Items Section
            Text(
              'Items in Your Cart',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.network(item['images'][0],
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(
                      item['name'],
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${item['quantity']} x \Rs ${item['price']}',
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 14),
                    ),
                    trailing: Text(
                      'Rs ${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Order Summary
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildSummaryRow(
                'Subtotal', 'Rs ${widget.totalPrice.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping Cost',
                'Rs ${widget.shippingCost.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax', 'Rs 0.00'),
            const Divider(color: Colors.grey, thickness: 1, height: 20),
            _buildSummaryRow('Total', 'Rs ${totalAmount.toStringAsFixed(2)}',
                isBold: true),
            const SizedBox(height: 10),

            // Proceed to Checkout Button
            ElevatedButton(
              onPressed: (selectedAddress != null && selectedPayment != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderProcessedScreen(),
                        ),
                      );
                      placeOrder(
                          widget.cartItems,
                          FirebaseAuth.instance.currentUser!.uid,
                          selectedAddress!,
                          selectedPayment!,
                          widget.totalPrice,
                          widget.shippingCost);
                    }
                  : null, // Disabled until both address & payment are selected
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD9A441),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Order Now",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
      {required String title, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.grey[200],
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isBold ? Colors.black : Colors.black54,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
