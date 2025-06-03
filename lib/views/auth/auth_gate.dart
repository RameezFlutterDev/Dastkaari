import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavBar(
        userid: FirebaseAuth.instance.currentUser?.uid,
      ),
    );
  }
}

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return BottomNavBar(userid: FirebaseAuth.instance.currentUser!.uid);
//           } else {
//             return LoginScreen();
//           }
//         },
//       ),
//     );
//   }
// }
