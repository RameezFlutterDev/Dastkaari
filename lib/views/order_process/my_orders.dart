import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/views/order_process/order_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedStatus = 'All';

  final List<String> statusOptions = [
    'All',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Orders",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          // Filter options
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
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getStatusColor(status.toLowerCase())
                          : _getStatusColor(status.toLowerCase())
                              .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 2,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Orders list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedStatus == 'All'
                  ? _firestore
                      .collection('orders')
                      .where('userId', isEqualTo: _auth.currentUser?.uid)
                      .snapshots()
                  : _firestore
                      .collection('orders')
                      .where('userId', isEqualTo: _auth.currentUser?.uid)
                      .where('status', isEqualTo: selectedStatus)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${selectedStatus == 'All' ? '' : selectedStatus} orders found",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    String status = order['status'];
    String orderId = order.id;
    Timestamp orderDate = order['createdAt'];
    double totalPrice = order['totalAmount'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
          ),
        ),
        title: Text(
          "Order #${orderId.substring(0, 8)}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total: Rs ${totalPrice.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
            Text(
              "Placed on: ${orderDate.toDate().toLocal()}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                status[0].toUpperCase() + status.substring(1),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(status),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: orderId),
            ),
          );
        },
      ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.access_time;
      case "processing":
        return Icons.sync;
      case "shipped":
        return Icons.local_shipping_outlined;
      case "delivered":
        return Icons.check_circle_outline;
      case "cancelled":
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }
}
