import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/widgets/auth_widgets/textfield_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final RoundedLoadingButtonController _loadingButtonController =
      RoundedLoadingButtonController();

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
                controller: _usernameController,
                labelText: 'Username',
                hintText: 'Choose username',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email, color: Color(0xffD9A441)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose username';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: _passwordController,
                obscureText: true,
                labelText: 'Choose Password',
                hintText: 'Choose your password',
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
              CustomTextFormField(
                controller: _confirmpasswordController,
                obscureText: true,
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                keyboardType: TextInputType.emailAddress,
                prefixIcon:
                    const Icon(Icons.verified, color: Color(0xffD9A441)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter correct password';
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
                    await authService.SignUpWithEmailPassword(
                            _emailController.text,
                            _passwordController.text,
                            _usernameController.text)
                        .then(
                      (value) {
                        _loadingButtonController.success();
                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Dashboard(),
                        //     ));
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
                  "Sign Up",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    },
                    child: Text(
                      "Sign In",
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
