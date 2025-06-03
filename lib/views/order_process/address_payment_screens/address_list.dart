import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_address.dart';

class AddressListScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Address',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No addresses found. Add a new address!',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final addresses = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              final addressData = address.data() as Map<String, dynamic>;
              final fullAddress =
                  "${addressData['street']}, ${addressData['city']}, ${addressData['state']}, ${addressData['zipCode']}";

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, fullAddress);
                    },
                    child: _addressTile(fullAddress, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddAddressScreen(
                            userId: userId,
                            addressId: address.id,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 12),
                ],
              );
            },
          );
        },
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
                builder: (context) => AddAddressScreen(userId: userId),
              ),
            );
          },
          child: Text(
            'Add Address',
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

  Widget _addressTile(String address, VoidCallback onEditPressed) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              address,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
            ),
          ),
          IconButton(
            onPressed: onEditPressed,
            icon: Icon(Icons.edit, color: Color(0xffD9A441)),
          ),
        ],
      ),
    );
  }
}
