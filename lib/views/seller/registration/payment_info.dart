import 'package:dastkaari/views/home/home.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the Google Fonts package

class PaymentDetailsPage extends StatefulWidget {
  final String? documentId; // Document ID passed as a parameter

  const PaymentDetailsPage({super.key, required this.documentId});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String? selectedPaymentMethod;
  String? selectedBank;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController accountTitleController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();

  // List of Pakistani banks
  List<String> pakistaniBanks = [
    'Allied Bank Limited',
    'Askari Bank Limited',
    'Bank Alfalah',
    'Bank Al Habib',
    'Bank of Punjab',
    'Faysal Bank',
    'Habib Bank Limited',
    'MCB Bank',
    'Meezan Bank',
    'National Bank of Pakistan',
    'Silk Bank',
    'Standard Chartered Bank',
    'UBL (United Bank Limited)',
    'Summit Bank',
    'JS Bank',
    'Sindh Bank',
    'Al Baraka Bank',
  ];

  List<String> get bankOptions {
    // If Easy Paisa or Jazz Cash is selected, use it as the only bank option
    if (selectedPaymentMethod == 'Easy Paisa' ||
        selectedPaymentMethod == 'Jazz Cash') {
      return [selectedPaymentMethod!];
    }
    // Otherwise, show the list of Pakistani banks
    return pakistaniBanks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Use a Form widget
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Page Title
                  Center(
                    child: Text(
                      'Your Account Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Account Details where your store revenue will be sent',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Payment Method Label
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Payment Method Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    hint: Text(
                      'Select method',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    items: ['Bank Account', 'Easy Paisa', 'Jazz Cash']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                        selectedBank = null; // Reset bank selection
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a payment method';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bank Name Dropdown
                  Text(
                    'Bank Name',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      // fillColor: textboxcolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    hint: Text(
                      'Select Bank',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    items: bankOptions
                        .map((bank) => DropdownMenuItem(
                              value: bank,
                              child: Text(bank),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                      });
                    },
                    value: selectedBank,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a bank';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Account Title
                  Text(
                    'Account Title',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: accountTitleController,
                    decoration: InputDecoration(
                      hintText: 'Account Title',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                      filled: true,
                      // fillColor: textboxcolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an account title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Account No
                  Text(
                    'Account No.',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: accountNoController,
                    decoration: InputDecoration(
                      hintText: 'Account No.',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                      filled: true,
                      // fillColor: textboxcolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your account number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Next Button
                  Center(
                    child: CustomButton(
                      text: 'Next',
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            // Firestore reference
                            final firestore = FirebaseFirestore.instance;

                            // Data to be updated
                            Map<String, dynamic> paymentDetails = {
                              'paymentMethod': selectedPaymentMethod,
                              'bankName': selectedBank,
                              'accountTitle': accountTitleController.text,
                              'accountNumber': accountNoController.text,
                              // 'paymentStatus': 'pending',
                              'verificationStatus': 'pending',
                              'sellerId': widget.documentId
                            };

                            // Update the existing document
                            await firestore
                                .collection('sellers')
                                .doc(widget.documentId)
                                .update(paymentDetails);

                            // Navigate to the next screen

                            // Display a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Payment details updated successfully!')),
                            );

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Submission Successful'),
                                  content: const Text(
                                    'Your provided information will be verified. Once verified, you will have access to upload your products.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        // Navigate to dashboard and clear stack
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BottomNavBar(
                                                    userid: widget.documentId,
                                                  )),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            // Handle any errors
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to update payment details: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Color(0xffD9A441),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
