// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentService {
//   Map<String, dynamic>? paymentIntent;

//   // Method to create a payment intent
//   Future<Map<String, dynamic>> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       Map<String, String> body = {
//         'amount': calculateAmount(amount).toString(),
//         'currency': currency,
//       };

//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body.entries
//             .map((e) =>
//                 '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
//             .join('&'),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to create payment intent: ${response.body}');
//       }

//       return json.decode(response.body);
//     } catch (err) {
//       throw Exception('Payment intent creation failed: $err');
//     }
//   }

//   // Method to initiate payment
//   Future<void> makePayment(double price, BuildContext context) async {
//     try {
//       // Step 1: Create Payment Intent
//       String amount = price.toString();
//       paymentIntent = await createPaymentIntent(amount, 'pkr');
//       if (paymentIntent == null) throw Exception("Payment intent is null");

//       // Step 2: Initialize Payment Sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent!['client_secret'],
//           style: ThemeMode.light,
//           merchantDisplayName: 'Ikay',
//           allowsDelayedPaymentMethods: true,
//         ),
//       );

//       // Step 3: Display Payment Sheet
//       await displayPaymentSheet(context);
//     } catch (err) {
//       print('Error occurred during payment: $err');
//       showErrorDialog(context, 'Payment Error', err.toString());
//     }
//   }

//   // Method to display the payment sheet
//   Future<void> displayPaymentSheet(BuildContext context) async {
//     try {
//       await Stripe.instance.presentPaymentSheet().then((value) async {
//         // Show success dialog
//         showSuccessDialog(context, 'Payment Successful!');

//         // Reset payment intent
//         paymentIntent = null;

//         // Update Firestore
//       }).onError((error, stackTrace) {
//         print('Error displaying payment sheet: $error');
//         throw Exception(error);
//       });
//     } on StripeException catch (e) {
//       print('Stripe error: $e');
//       showErrorDialog(context, 'Payment Failed',
//           e.error.localizedMessage ?? 'Something went wrong');
//     } catch (e) {
//       print('Unexpected error: $e');
//       showErrorDialog(context, 'Error', e.toString());
//     }
//   }

//   // Utility to calculate the smallest currency unit
//   int calculateAmount(String amount) {
//     try {
//       double parsedAmount = double.parse(amount);
//       return (parsedAmount * 100).toInt(); // PKR to paisa conversion
//     } catch (e) {
//       throw Exception('Invalid amount format: $amount');
//     }
//   }

//   // Utility to show success dialog
//   void showSuccessDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 100.0),
//             const SizedBox(height: 10.0),
//             Text(message),
//           ],
//         ),
//       ),
//     );
//   }

//   // Utility to show error dialog
//   void showErrorDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.error, color: Colors.red),
//                 const SizedBox(width: 10.0),
//                 Expanded(child: Text(message)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
