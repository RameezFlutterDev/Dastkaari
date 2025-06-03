import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/views/order_process/address_payment_screens/add_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentListScreen extends StatelessWidget {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('cards')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No payment methods available.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final cards = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final cardNumber = card['cardNumber'] ?? '**** **** ****';
                    final lastFourDigits =
                        cardNumber.substring(cardNumber.length - 4);
                    final cardId = card.id;

                    return Column(
                      children: [
                        _paymentTile(
                          '**** $lastFourDigits',
                          Icons.credit_card,
                          onPressed: () {
                            Navigator.pop(
                                context, 'Card: **** $lastFourDigits');
                          },
                        ),
                        SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Cash on Delivery Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _paymentTile(
              'Cash on Delivery',
              Icons.money,
              onPressed: () {
                Navigator.pop(context, 'Cash on Delivery');
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffD9A441),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCardScreen(),
              ),
            );
          },
          child: Text(
            'Add Card',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(String text, IconData icon,
      {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xffD9A441)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }
}
