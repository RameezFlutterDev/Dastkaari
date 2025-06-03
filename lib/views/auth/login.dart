import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/views/auth/register.dart';
import 'package:dastkaari/views/home/homepage.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:dastkaari/views/model/storeInteractions.dart';
import 'package:dastkaari/widgets/auth_widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key, this.redirectTabIndex});

  final int? redirectTabIndex; // Add this line

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _loadingButtonController =
      RoundedLoadingButtonController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService _authService = AuthService();
  // FirebaseAuth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'username': userCredential.user!.displayName,
        'status': 'Active',
        'uid': userCredential.user!.uid
      });

      _authService.saveUserTokenToDatabase(userCredential.user!.uid);

      if (redirectTabIndex != null) {
        Navigator.pop(context, redirectTabIndex);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavBar(
                    userid: userCredential.user?.uid,
                  )),
          (route) => false,
        );
      }

      // Navigate to Homepage after successful sign-in
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => BottomNavBar(
      //       userid: userCredential.user!.uid,
      //     ),
      //   ),
      // );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Google Sign-In Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dastkaari",
                    style: GoogleFonts.pacifico(
                      color: const Color(0xffD9A441),
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: Image.asset("assets/logo.png"),
                  )
                ],
              ),
              CustomTextFormField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email, color: Color(0xffD9A441)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: _passwordController,
                obscureText: true,
                labelText: 'Password',
                hintText: 'Enter your password',
                keyboardType: TextInputType.emailAddress,
                prefixIcon:
                    const Icon(Icons.password, color: Color(0xffD9A441)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              RoundedLoadingButton(
                width: 2000,
                borderRadius: 10,
                controller: _loadingButtonController,
                color: const Color(0xffD9A441),
                onPressed: () async {
                  final authService = AuthService();

                  try {
                    await authService.SignInWithEmailPassword(
                            _emailController.text, _passwordController.text)
                        .then(
                      (value) {
                        if (redirectTabIndex != null) {
                          authService.saveUserTokenToDatabase(value.user!.uid);
                          Navigator.pop(context, redirectTabIndex);
                        } else {
                          authService.saveUserTokenToDatabase(value.user!.uid);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavBar(
                                      userid: value.user?.uid,
                                    )),
                            (route) => false,
                          );
                        }
                      },
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(title: Text(e.toString())),
                    );
                    _loadingButtonController.reset();
                  }

                  // Timer(Duration(seconds: 3), () {
                  //   LoginbtnController.success();
                  //   Navigator.pushReplacement(
                  //       context,
                  //       PageTransition(
                  //           type: PageTransitionType.fade, child: Login()));
                  // });
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: const Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
                label: Text(
                  "Sign in with Google",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xffD9A441), // Google-themed button color
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ));
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffD9A441)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
