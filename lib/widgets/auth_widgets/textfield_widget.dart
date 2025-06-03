import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A reusable TextFormField widget with customizable options
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function()? onTap;

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Color(0xffA3553A), width: 1),
          ),
        ),
      ),
    );
  }
}
