import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:dastkaari/views/seller/registration/payment_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class SellerRegistration extends StatefulWidget {
  final String? uid;
  SellerRegistration({required this.uid});

  @override
  _SellerRegistrationState createState() => _SellerRegistrationState();
}

class _SellerRegistrationState extends State<SellerRegistration> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _cnicImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  AuthService _authService = AuthService();

  bool isUrdu = false;

  Future<void> _pickImage(File? Function(File?) setImage) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        setImage(File(image.path));
      });
    }
  }

  Future<void> _saveDataToFirestore() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      String? logoUrl;
      if (_logoImage != null) {
        final ref = storage
            .ref('sellers/${DateTime.now().millisecondsSinceEpoch}_logo');
        final upload = await ref.putFile(_logoImage!);
        logoUrl = await upload.ref.getDownloadURL();
      }

      String? cnicUrl;
      if (_cnicImage != null) {
        final ref = storage
            .ref('sellers/NIC/${DateTime.now().millisecondsSinceEpoch}_cnic');
        final upload = await ref.putFile(_cnicImage!);
        cnicUrl = await upload.ref.getDownloadURL();
      }

      await firestore.collection('sellers').doc(widget.uid).set({
        'name': _nameController.text,
        'storeName': _storeNameController.text,
        'email': _emailController.text,
        'nic': _nicController.text,
        'contact': _contactController.text,
        'logoUrl': logoUrl,
        'cnicUrl': cnicUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'verificationStatus': 'pending',
        'sellerId': widget.uid
      });

      _authService.saveSellerTokenToDatabase(widget.uid!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isUrdu
                ? 'آپ کی تفصیلات کامیابی کے ساتھ جمع کر دی گئی ہیں'
                : 'Your details are submitted successfully!')),
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Submission Successful'),
            content: Text(
              isUrdu
                  ? 'آپ کی فراہم کردہ معلومات کی تصدیق کی جائے گی۔ تصدیق ہونے کے بعد، آپ کو اپنے پروڈکٹس اپ لوڈ کرنے تک رسائی حاصل ہوگی۔'
                  : 'Your provided information will be verified. Once verified, you will have access to upload your products.',
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
                        builder: (context) => BottomNavBar(
                              userid: widget.uid,
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isUrdu
                ? 'ڈیٹا محفوظ کرنے میں ناکام'
                : 'Failed to save data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setLocalState) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isUrdu ? 'سیلر پروفائل' : 'Seller Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setLocalState(() {
                        isUrdu = !isUrdu;
                      }),
                      icon: Icon(Icons.language, color: Colors.brown),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickImage((file) => _logoImage = file),
                  child: CircleAvatar(
                    child: Material(
                      elevation: 8.0,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        radius: 100.0,
                        child: _logoImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _logoImage!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : const Center(child: Icon(Icons.add)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextBox(
                    isUrdu ? 'نام' : 'Name',
                    isUrdu ? 'اپنا مکمل نام درج کریں' : 'Enter your full name',
                    _nameController),
                _buildLabeledTextBox(
                    isUrdu ? 'دکان کا نام' : 'Store Name',
                    isUrdu
                        ? 'اپنی دکان کا نام درج کریں'
                        : 'Enter your store name',
                    _storeNameController),
                _buildLabeledTextBox(
                    isUrdu ? 'ای میل' : 'Email',
                    isUrdu ? 'اپنا ای میل درج کریں' : 'Enter your email',
                    _emailController),
                _buildLabeledTextBox(
                    isUrdu ? 'شناختی کارڈ نمبر' : 'NIC',
                    isUrdu
                        ? 'اپنا شناختی کارڈ نمبر درج کریں'
                        : 'Enter your NIC',
                    _nicController),
                _buildLabeledTextBox(
                    isUrdu ? 'رابطہ نمبر' : 'Contact',
                    isUrdu
                        ? 'اپنا رابطہ نمبر درج کریں'
                        : 'Enter your contact number',
                    _contactController),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickImage((file) => _cnicImage = file),
                  child: _buildUploadBox(
                    _cnicImage,
                    isUrdu
                        ? 'شناختی کارڈ کی تصویر اپ لوڈ کریں'
                        : 'Upload NIC Image',
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    text: isUrdu ? 'اگلا' : 'Next',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_cnicImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(isUrdu
                                    ? 'براہ کرم اپنے شناختی کارڈ کی تصویر اپ لوڈ کریں۔'
                                    : 'Please upload your CNIC image.')),
                          );
                          return;
                        }
                        await _saveDataToFirestore();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLabeledTextBox(
      String label, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(File? image, String label) {
    return Container(
      alignment: Alignment.center,
      width: 250,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: image != null
          ? ClipRect(
              child: Image.file(
                image,
                fit: BoxFit.cover,
                width: 250,
                height: 120,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xffD9A441),
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
