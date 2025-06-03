import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/services/user/userProfileservice.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/home/helpcenter.dart';
import 'package:dastkaari/views/order_process/my_orders.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  String username = "Loading...";

  String email = "Loading...";

  AuthService _authService = AuthService();
  String? profilePicUrl;

  bool isLoading = true;

  UserProfileService upf = UserProfileService();
  int orderCount = 0; // Store the fetched order count

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Your existing function
    loadOrderCount(); // Call async wrapper
  }

  Future<void> loadOrderCount() async {
    int count = await upf.getUserOrderCount();
    setState(() {
      orderCount = count;
    });
  }

  Future<void> fetchUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'No Name';
          email = userDoc['email'] ?? 'No Email';
          profilePicUrl = userDoc.data().toString().contains('profilePic')
              ? userDoc['profilePic']
              : null;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'username': newUsername,
      });
      setState(() {
        username = newUsername;
      });
    } catch (e) {
      print("Error updating username: $e");
    }
  }

  Future<void> uploadProfilePicture() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String uid = _auth.currentUser!.uid;
    String filePath = 'profile_pictures/$uid.jpg';

    try {
      TaskSnapshot snapshot = await _storage.ref(filePath).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(uid)
          .set({'profilePic': downloadUrl}, SetOptions(merge: true));

      setState(() {
        profilePicUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  void showEditUsernameDialog() {
    TextEditingController controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Username", style: GoogleFonts.poppins(fontSize: 18)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              updateUsername(controller.text.trim());
              Navigator.pop(context);
            },
            child: Text("Save", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                // Glowing Avatar with Upload Option
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffD9A441),
                            Color(0xffFFB65D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffD9A441).withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(5), // Glow padding
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profilePicUrl != null
                            ? NetworkImage(profilePicUrl!)
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: profilePicUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          onPressed: () {
                            // Handle profile picture upload
                            uploadProfilePicture();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // User Name and Email
                Text(
                  username, // Replace with user's name
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email, // Replace with user's email
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Edit Profile Button
                ElevatedButton(
                  onPressed: showEditUsernameDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD9A441),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(Icons.shopping_bag_outlined, "Orders",
                    orderCount.toString()),
                _buildStatCard(Icons.favorite_outline, "Wishlist", "0"),
                _buildStatCard(Icons.star_outline, "Points", "0"),
              ],
            ),

            const SizedBox(height: 20),

            // Actionable List
            Column(
              children: [
                _buildListTile(
                  icon: Icons.shopping_bag_outlined,
                  title: "My Orders",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyOrdersScreen()));
                    // Navigate to orders page
                  },
                ),
                _buildListTile(
                  icon: Icons.favorite_outline,
                  title: "Wishlist",
                  onTap: () {
                    // Navigate to wishlist page
                  },
                ),
                _buildListTile(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    // Navigate to settings page
                  },
                ),
                _buildListTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpCenterScreen(),
                        ));

                    // Navigate to help & support page
                  },
                ),
                _buildListTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () {
                    // Handle logout functionality
                    _authService.SignOutUser();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xffD9A441), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black54,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
