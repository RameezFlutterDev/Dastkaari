import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/views/auth/auth_gate.dart';
import 'package:dastkaari/views/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OrderProcessedScreen extends StatelessWidget {
  const OrderProcessedScreen({super.key});

  Future<void> _clearCart() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    final cartItems = await cartRef.get();
    for (var doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkmark Animation
            Lottie.asset(
              'assets/animations/confirmOrder.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 20),

            // Success Message
            Text(
              'Order Processed!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xffD9A441),
              ),
            ),
            const SizedBox(height: 10),

            // Order Details
            Text(
              'Thank you for your purchase!',
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 10),

            // Confetti Animation
            Lottie.asset(
              'assets/animations/confetti.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 30),

            // Continue Shopping Button
            ElevatedButton(
              onPressed: () async {
                await _clearCart();

                // Go to Home and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthGate()),
                  (Route<dynamic> route) =>
                      false, // Removes all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD9A441),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:dastkaari/views/order_process/my_orders.dart';
// import 'package:flutter/material.dart';
// import 'package:order_tracker/order_tracker.dart';

// class OrderConfirmationScreen extends StatefulWidget {
//   @override
//   _OrderConfirmationScreenState createState() =>
//       _OrderConfirmationScreenState();
// }

// class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
//   // Define the order tracking steps
//   List<TextDto> orderList = [
//     TextDto("Your order has been placed", "Fri, 18th Mar '25 - 10:47pm"),
//     // TextDto("Seller has processed your order", "Sat, 16th Mar '25 - 10:19am"),
//     // TextDto("Your item has been picked up by courier partner.",
//     //     "Sun, 17th Mar '25 - 5:00pm"),
//   ];

//   List<TextDto> shippedList = [
//     // TextDto("Your order has been shipped", "Mon, 18th Mar '25 - 5:04pm"),
//     // TextDto("Your item has been received in the nearest hub to you.", null),
//   ];

//   List<TextDto> outOfDeliveryList = [
//     // TextDto("Your order is out for delivery", "Wed, 20th Mar '25 - 2:27pm"),
//   ];

//   List<TextDto> deliveredList = [
//     // TextDto("Your order has been delivered", "Thu, 21st Mar '25 - 3:58pm"),
//   ];

//   // Current order status
//   Status orderStatus = Status.shipped; // Update dynamically later

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Order Confirmation"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: OrderTracker(
//                 status: orderStatus,
//                 activeColor: Colors.green,
//                 inActiveColor: Colors.grey[300],
//                 orderTitleAndDateList: orderList,
//                 shippedTitleAndDateList: shippedList,
//                 outOfDeliveryTitleAndDateList: outOfDeliveryList,
//                 deliveredTitleAndDateList: deliveredList,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         MyOrdersScreen(), // Navigate to orders screen
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xffD9A441),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               child: Text(
//                 "View My Orders",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
