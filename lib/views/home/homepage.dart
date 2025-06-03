import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/home/helpcenter.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/model/categories.dart';
import 'package:dastkaari/views/model/storeInteractions.dart';
import 'package:dastkaari/views/seller/inventory/inventory.dart';
import 'package:dastkaari/views/seller/registration/seller_registration.dart';
import 'package:dastkaari/views/seller/sales/manage_orders.dart';
import 'package:dastkaari/views/seller/sales/manage_sales.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Homepage extends StatefulWidget {
  final String? initialCategory;

  Homepage({this.initialCategory});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? selectedCategory;
  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xffD9A441),
              ),
              child: Text(
                'Dastkaari',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            // Only show seller options if user is logged in
            if (FirebaseAuth.instance.currentUser != null)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sellers')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  bool isVerified = false;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    isVerified = data['verificationStatus'] == 'verified';
                  }

                  return Column(
                    children: [
                      // Show if not verified (and document doesn't exist yet)
                      if (!isVerified)
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('Be a Seller'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerRegistration(
                                  uid: FirebaseAuth.instance.currentUser?.uid,
                                ),
                              ),
                            );
                          },
                        ),

                      // Show if verified
                      if (isVerified) ...[
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('Manage Inventory'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InventoryManagementScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.shopping_bag),
                          title: const Text('Manage Sales'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SalesDashboardScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('Manage Orders'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerOrdersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

            if (FirebaseAuth.instance.currentUser == null)
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('Log In'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ));
                },
              ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help Center'),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpCenterScreen(),
                    ));
              },
            ),

            // Show sign out only if logged in
            if (FirebaseAuth.instance.currentUser != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Search Bar
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffD9A441),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(100, 50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon:
                                const Icon(Icons.segment, color: Colors.white),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Dastkaari",
                          style: GoogleFonts.pacifico(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 28), // Empty space for symmetry
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xffA3553A),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xffA3553A)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Categories Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categories",
                    style: GoogleFonts.poppins(
                      color: Colors.brown,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category.name;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category.name;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.brown
                                  : const Color(0xff9DBE8E),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: Text(
                              category.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Products Section
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('status', isEqualTo: 'Active')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No products available"));
                      }

                      var products = snapshot.data!.docs.where((doc) {
                        if (selectedCategory == null) return true;
                        var data = doc.data() as Map<String, dynamic>;
                        return data['category'] == selectedCategory;
                      }).toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index];
                          var data = product.data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Itemdetails(item: data),
                                ),
                              );

                              Interactions intrc = Interactions();

                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                intrc.logUserInteraction(
                                  user.uid,
                                  product['category'],
                                  "Click",
                                );
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: product['images'][0],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: const Color(0xffd9a441)
                                              .withOpacity(0.3),
                                          highlightColor:
                                              const Color(0xffd9a441)
                                                  .withOpacity(0.15),
                                          child: Container(
                                            width: 160,
                                            height: 110,
                                            color: Colors.white,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error, size: 50),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'Unnamed Product',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "RS ${data['price'] ?? 'N/A'}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              data['rating']?.toString() ??
                                                  'N/A',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//  CachedNetworkImage(
//                                         imageUrl: product['images'][0],
//                                         fit: BoxFit.cover,
//                                         placeholder: (context, url) =>
//                                             Shimmer.fromColors(
//                                           baseColor: const Color(0xffd9a441)
//                                               .withOpacity(0.3),
//                                           highlightColor:
//                                               const Color(0xffd9a441)
//                                                   .withOpacity(0.15),
//                                           child: Container(
//                                             width: 160,
//                                             height: 110,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         errorWidget: (context, url, error) =>
//                                             const Icon(Icons.error, size: 50),
//                                       ),
