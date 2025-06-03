import 'package:dastkaari/bloc/bloc/cart_bloc.dart';
import 'package:dastkaari/bloc/bloc/cart_event.dart';
import 'package:dastkaari/bloc/bloc/cart_state.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:dastkaari/views/order_process/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBar(
                  userid: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Your Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            if (state.groupedCartItems.isEmpty) {
              return Center(
                child: Text(
                  'Your cart is empty.',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return _buildCartContent(state, context);
          } else if (state is CartError) {
            return Center(
              child: Text(
                'Failed to load cart items',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCartContent(CartLoaded state, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: state.groupedCartItems.entries.map((entry) {
              final sellerId = entry.key;
              final items = entry.value;
              final storeName = state.sellerNames[sellerId] ?? 'Unknown Seller';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Text(
                      'Store: $storeName',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((item) => _buildCartItem(item, context)),
                ],
              );
            }).toList(),
          ),
        ),
        _buildCheckoutSection(state, context),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              item['images'][0],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text('Color: ${item['color']}',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  Text(
                    'Subtotal: Rs ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Itemdetails(item: item),
                            ),
                          );
                        },
                        child: Text(
                          'View Details',
                          style: GoogleFonts.poppins(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                                RemoveItem(productId: item['productId']),
                              );
                        },
                        child: Text(
                          'Remove',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (item['quantity'] > 1) {
                      context.read<CartBloc>().add(
                            DecreaseQuantity(
                              productId: item['productId'],
                              newQuantity: item['quantity'] - 1,
                            ),
                          );
                    }
                  },
                ),
                Text(
                  '${item['quantity']}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<CartBloc>().add(
                          AddItem(
                            productId: item['productId'],
                            newQuantity: item['quantity'] + 1,
                          ),
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartLoaded state, BuildContext context) {
    final shippingCost = 250;
    final shippingCostTotal = state.groupedCartItems.keys.length * shippingCost;
    final totalPrice = _calculateTotalPrice(state.groupedCartItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping Cost',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs ${shippingCostTotal.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs ${(totalPrice + shippingCostTotal).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    cartItems: _flattenCartItems(state.groupedCartItems),
                    totalPrice: totalPrice,
                    shippingCost: shippingCostTotal.toDouble(),
                  ),
                ),
              );
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
              "Proceed to Checkout",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalPrice(
      Map<String, List<Map<String, dynamic>>> groupedCartItems) {
    double total = 0;
    for (var group in groupedCartItems.values) {
      for (var item in group) {
        total += item['price'] * item['quantity'];
      }
    }
    return total;
  }

  List<Map<String, dynamic>> _flattenCartItems(
      Map<String, List<Map<String, dynamic>>> groupedCartItems) {
    return groupedCartItems.values.expand((list) => list).toList();
  }
}
