import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/provider/languageProvider.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/model/orderstatus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SellerOrdersScreen extends StatefulWidget {
  @override
  _SellerOrdersScreenState createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String sellerId = "";

  OrderStatus? selectedStatus = statusOptions.first; // Default to "All"

  @override
  void initState() {
    super.initState();
    _getSellerId();
  }

  void _getSellerId() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        sellerId = user.uid;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchSellerOrders() async {
    if (sellerId.isEmpty) return [];

    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId);

    if (selectedStatus!.name != "All") {
      query = query.where('status', isEqualTo: selectedStatus!.name);
    }

    final orderSnapshot = await query.get();
    List<Map<String, dynamic>> sellerOrders = [];

    for (var orderDoc in orderSnapshot.docs) {
      final orderId = orderDoc.id;

      final productSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('products')
          .get();

      List<Map<String, dynamic>> products = productSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'quantity': doc['quantity'],
        };
      }).toList();

      sellerOrders.add({
        'orderId': orderId,
        'address': orderDoc['address'],
        'paymentMethod': orderDoc['paymentMethod'],
        'totalAmount': orderDoc['totalAmount'],
        'status': orderDoc['status'],
        'products': products,
      });
    }

    return sellerOrders;
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order updated to $newStatus')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Localizations.override(
      context: context,
      locale: langProvider.locale,
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  AppLocalizations.of(context)!.sellerOrders,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            backgroundColor: const Color(0xffD9A441),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Status Filter
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.filterByStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: statusOptions.length,
                        itemBuilder: (context, index) {
                          final status = statusOptions[index];
                          final isSelected = selectedStatus == status;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getStatusColor(status.name.toLowerCase())
                                    : _getStatusColor(status.name.toLowerCase())
                                        .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Text(
                                '${status.name} / ${status.uname}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchSellerOrders(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                            "No ${selectedStatus!.name.toLowerCase()} orders.",
                            style: GoogleFonts.poppins()),
                      );
                    }

                    final orders = snapshot.data!;
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(order, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.orderId} : ${order['orderId'].substring(0, 8)}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusDropdown(order['orderId'], order['status']),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                "${AppLocalizations.of(context)!.totalAmount(order['totalAmount'])} ",
                style: GoogleFonts.poppins(fontSize: 14)),
            Text(
                "${AppLocalizations.of(context)!.paymentMethod(order['paymentMethod'])}",
                style: GoogleFonts.poppins(fontSize: 14)),
            Text(
                " ${AppLocalizations.of(context)!.deliveryAddress(order['address'])}",
                style: GoogleFonts.poppins(fontSize: 14)),

            const Divider(height: 20),

            // Products
            ...order['products'].map<Widget>((product) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.check_box_outline_blank_rounded),
                title: Text("${product['name']} (x${product['quantity']})",
                    style: GoogleFonts.poppins(fontSize: 14)),
                subtitle: Text("Rs ${product['price']}",
                    style: GoogleFonts.poppins(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () async {
                    final doc = await FirebaseFirestore.instance
                        .collection('products')
                        .doc(product['id'])
                        .get();
                    if (doc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Itemdetails(item: doc.data()!),
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    OrderStatus current = statusOptions.firstWhere(
      (status) => status.name == currentStatus,
      orElse: () => statusOptions.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(current.name).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _statusColor(current.name)),
      ),
      child: DropdownButton<OrderStatus>(
        value: current,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: statusOptions
            .where((s) => s.name != "All")
            .map((status) => DropdownMenuItem<OrderStatus>(
                  value: status,
                  child: Text(
                    status.name,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ))
            .toList(),
        onChanged: (OrderStatus? newStatus) {
          if (newStatus != null) {
            _updateOrderStatus(orderId, newStatus.name);
          }
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.deepPurple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "pending":
      return Colors.orange;
    case "processing":
      return Colors.blue;
    case "shipped":
      return Colors.purple;
    case "delivered":
      return Colors.green;
    case "cancelled":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
