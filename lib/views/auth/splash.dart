import 'dart:async';

import 'package:dastkaari/views/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dastkaari",
              style: GoogleFonts.pacifico(
                color: const Color(0xffD9A441),
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            // SizedBox(
            //   height: 100,
            //   width: 70,
            //   child: Image.asset("assets/logo.png"),
            // )
          ],
        ),
      ),
    );
  }
}
