import 'package:dastkaari/services/order_process/address_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId; // User ID to store the address
  final String? addressId; // For editing an existing address

  AddAddressScreen({required this.userId, this.addressId});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  bool _isSaving = false; // To prevent multiple saves
  late final AddressServices addressServices;

  @override
  void initState() {
    super.initState();
    addressServices = AddressServices(userId: widget.userId);
    if (widget.addressId != null) {
      _loadAddressData();
    }
  }

  void _loadAddressData() async {
    final data = await addressServices.getAddress(widget.addressId!);
    if (data != null) {
      setState(() {
        _streetController.text = data['street'] ?? '';
        _cityController.text = data['city'] ?? '';
        _stateController.text = data['state'] ?? '';
        _zipController.text = data['zipCode'] ?? '';
      });
    }
  }

  void _saveAddress() async {
    if (!_validateFields()) {
      return;
    }

    final addressData = {
      'street': _streetController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zipCode': _zipController.text,
    };

    try {
      setState(() {
        _isSaving = true; // Disable the save button
      });

      if (widget.addressId == null) {
        // Add a new address
        await addressServices.addAddress(addressData);
      } else {
        // Update an existing address
        await addressServices.updateAddress(widget.addressId!, addressData);
      }

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Address saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error dialog if something goes wrong
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while saving the address.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isSaving = false; // Re-enable the save button
      });
    }
  }

  bool _validateFields() {
    if (_streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.addressId == null ? 'Add Address' : 'Edit Address',
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
            _inputField('Street Address', _streetController, Icons.home),
            SizedBox(height: 16),
            _inputField('City', _cityController, Icons.location_city),
            SizedBox(height: 16),
            _inputField('State', _stateController, Icons.flag),
            SizedBox(height: 16),
            _inputField('Zip Code', _zipController, Icons.mail),
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
          onPressed: _isSaving ? null : _saveAddress, // Disable if saving
          child: _isSaving
              ? CircularProgressIndicator(color: Colors.white) // Show loader
              : Text(
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

  Widget _inputField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
    );
  }
}
