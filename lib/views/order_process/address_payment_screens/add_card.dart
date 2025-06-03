import 'package:dastkaari/services/order_process/card_services.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import the CardServices class

class AddCardScreen extends StatefulWidget {
  final String? cardId;

  AddCardScreen({this.cardId}); // Pass `cardId` for editing a specific card.

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderNameController =
      TextEditingController();

  final CardServices _cardServices = CardServices(); // Instance of CardServices

  @override
  void initState() {
    super.initState();
    if (widget.cardId != null) {
      _loadCardData(); // Load card data for editing if cardId is provided.
    }
  }

  // Load card data
  void _loadCardData() async {
    try {
      await _cardServices.loadCardData(
        widget.cardId!,
        _cardNumberController,
        _expController,
        _cvvController,
        _cardholderNameController,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load card data: $e')),
      );
    }
  }

  // Save card data
  void _saveCard() async {
    try {
      await _cardServices.saveCard(
        context,
        widget.cardId,
        _cardNumberController,
        _expController,
        _cvvController,
        _cardholderNameController,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add Card',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField('Card Number', _cardNumberController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _inputField('EXP', _expController)),
                SizedBox(width: 16),
                Expanded(child: _inputField('CVV', _cvvController)),
              ],
            ),
            SizedBox(height: 16),
            _inputField('Cardholder Name', _cardholderNameController),
          ],
        ),
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
          onPressed: _saveCard,
          child: Text(
            'Save',
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

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
