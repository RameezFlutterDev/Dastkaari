import 'package:cached_network_image/cached_network_image.dart';
import 'package:dastkaari/adHelper/instertitial_ad_helper.dart';
import 'package:dastkaari/provider/adsProvider/ads_provider.dart';
import 'package:dastkaari/services/auth/auth_service.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/home/helpcenter.dart';
import 'package:dastkaari/views/home/homepage.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/home/navigationpage.dart';
import 'package:dastkaari/views/model/rec.dart';
import 'package:dastkaari/views/model/storeInteractions.dart';
import 'package:dastkaari/views/seller/inventory/inventory.dart';
import 'package:dastkaari/views/seller/registration/seller_registration.dart';
import 'package:dastkaari/views/seller/sales/manage_orders.dart';
import 'package:dastkaari/views/seller/sales/manage_sales.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService _authService = AuthService();
  // late BannerAd _bannerAd1;
  // late BannerAd _bannerAd2;

  Future<List<String>> fetchRecommendedCategories() async {
    try {
      Interactions interactions = Interactions();
      Rec rec = Rec();

      int userId = await interactions.assignUserIdIfNeeded();
      List<Map<String, String>> latestInteractions =
          await interactions.getLatestUserInteractions();

      if (latestInteractions.isEmpty) return [];

      final recommended =
          await rec.getRecommendationsForUser(userId, latestInteractions);

      return recommended
          .map((item) => item['Category'].toString())
          .toList()
          .toSet()
          .toList(); // remove duplicates
    } catch (e) {
      print("Recommendation error: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchAllRecommendedProducts(
      List<String> categories) async {
    List<QuerySnapshot> snapshots = await Future.wait(
      categories.map((category) {
        return FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: category)
            .where('status', isEqualTo: 'Active')
            .limit(5)
            .get();
      }),
    );

    return snapshots.expand((snap) => snap.docs).toList();
  }

  // void _loadBannerAd1() {
  //   _bannerAd1 = BannerAd(
  //     adUnitId: 'ca-app-pub-5443412817411779/2122192884',
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(),
  //   )..load();
  // }

  // void _loadBannerAd2() {
  //   _bannerAd1 = BannerAd(
  //     adUnitId: 'ca-app-pub-5443412817411779/6537276159',
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(),
  //   )..load();
  // }

  @override
  void initState() {
    // TODO: implement initState
    InterstitialAdHelper.loadAd();

    Provider.of<AdProvider>(context, listen: false);
    super.initState();
  }

  // @override
  // void dispose() {
  //   _bannerAd1.dispose();
  //   _bannerAd2.dispose();
  //   super.dispose();
  // }

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
      appBar: AppBar(
        title: Text(
          'Dastkaari',
          style: GoogleFonts.pacifico(color: Colors.white, fontSize: 28),
        ),
        backgroundColor: Color(0xffD9A441),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Welcome,',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffD9A441),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Handmade's just\nfor you",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -210,
                      right: -30,
                      child: Container(
                        width: 200,
                        height: 530,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/logo.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (FirebaseAuth.instance.currentUser == null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Container(
                  height: 30,
                  color: const Color(0xffFFF4DB), // Light yellow background
                  child: Marquee(
                    text:
                        'Log in to enjoy personalized recommendations, cart, and other features!',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.brown[800],
                      fontWeight: FontWeight.w600,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 50.0,
                    velocity: 40.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),
            FutureBuilder(
              future: fetchRecommendedCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const SizedBox(); // or show error text
                } else {
                  List<String> recommendedCategories = snapshot.data ?? [];

                  if (recommendedCategories.isEmpty) {
                    return const SizedBox(); // Or return a widget like "No recommendations yet"
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<AdProvider>(
                        builder: (context, adProvider, _) {
                          return adProvider.isTopBannerAdLoaded
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: Container(
                                    height: adProvider.topBannerAd.size.height
                                        .toDouble(),
                                    width: adProvider.topBannerAd.size.width
                                        .toDouble(),
                                    child: AdWidget(ad: adProvider.topBannerAd),
                                  ),
                                )
                              : SizedBox();
                          ; // Empty placeholder if ad is not loaded
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Based on your interactions',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      FutureBuilder<List<QueryDocumentSnapshot>>(
                        future:
                            fetchAllRecommendedProducts(recommendedCategories),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          var allProducts = snapshot.data!;

                          return SizedBox(
                            height: 190,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              scrollDirection: Axis.horizontal,
                              itemCount: allProducts.length,
                              itemBuilder: (context, index) {
                                var product = allProducts[index].data()
                                    as Map<String, dynamic>;

                                return SizedBox(
                                  width: 160,
                                  child: GestureDetector(
                                    onTap: () {
                                      Interactions intrc = Interactions();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Itemdetails(item: product),
                                        ),
                                      );
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        intrc.logUserInteraction(
                                          user.uid,
                                          product['category'],
                                          "View",
                                        );
                                      }
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ClipRRect(
                                          //   borderRadius:
                                          //       const BorderRadius.vertical(
                                          //           top: Radius.circular(15)),
                                          //   child: Container(
                                          //     height: 110,
                                          //     width: 160,
                                          //     color: Colors.grey[200],
                                          //     child: CachedNetworkImage(
                                          //       imageUrl: product['images'][0],
                                          //       fit: BoxFit.cover,
                                          //       placeholder: (context, url) =>
                                          //           Shimmer.fromColors(
                                          //         baseColor:
                                          //             const Color(0xffd9a441)
                                          //                 .withOpacity(0.3),
                                          //         highlightColor:
                                          //             const Color(0xffd9a441)
                                          //                 .withOpacity(0.15),
                                          //         child: Container(
                                          //           width: 160,
                                          //           height: 110,
                                          //           color: Colors.white,
                                          //         ),
                                          //       ),
                                          //       errorWidget:
                                          //           (context, url, error) =>
                                          //               const Icon(Icons.error,
                                          //                   size: 50),
                                          //     ),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "RS ${product['price'] ?? 'N/A'}",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 11),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: _bannerAd1.size.height.toDouble(),
            //     child: AdWidget(ad: _bannerAd1),
            //   ),
            // ),
            Consumer<AdProvider>(
              builder: (context, adProvider, _) {
                return adProvider.isBottomBannerAdLoaded
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height:
                              adProvider.bottomBannerAd.size.height.toDouble(),
                          width:
                              adProvider.bottomBannerAd.size.width.toDouble(),
                          child: AdWidget(ad: adProvider.bottomBannerAd),
                        ),
                      )
                    : SizedBox();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Text(
                'Popular Categories',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('status', isEqualTo: 'Active')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var allProducts = snapshot.data!.docs;
                var categories =
                    allProducts.map((doc) => doc['category']).toSet().toList();

                return Column(
                  children: categories.map((categoryName) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryName,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BottomNavBar(
                                        userid: FirebaseAuth
                                            .instance.currentUser?.uid,
                                        category: categoryName,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See More',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xffA3553A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 190,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .where('category', isEqualTo: categoryName)
                                .where('status', isEqualTo: 'Active')
                                .limit(5)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              var products = snapshot.data!.docs;
                              return ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  var product = products[index].data()
                                      as Map<String, dynamic>;
                                  return SizedBox(
                                    width: 160,
                                    child: GestureDetector(
                                      onTap: () {
                                        Interactions intrc = Interactions();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Itemdetails(item: product),
                                          ),
                                        );
                                        User? user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user != null) {
                                          intrc.logUserInteraction(
                                            user.uid,
                                            product['category'],
                                            "View",
                                          );
                                        }
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // ClipRRect(
                                            //   borderRadius:
                                            //       const BorderRadius.vertical(
                                            //           top: Radius.circular(15)),
                                            //   child: Container(
                                            //     height: 110,
                                            //     width: 160,
                                            //     color: Colors.grey[200],
                                            //     child: CachedNetworkImage(
                                            //       imageUrl: product['images']
                                            //           [0],
                                            //       fit: BoxFit.cover,
                                            //       placeholder: (context, url) =>
                                            //           Shimmer.fromColors(
                                            //         baseColor:
                                            //             const Color(0xffd9a441)
                                            //                 .withOpacity(0.3),
                                            //         highlightColor:
                                            //             const Color(0xffd9a441)
                                            //                 .withOpacity(0.15),
                                            //         child: Container(
                                            //           width: 160,
                                            //           height: 110,
                                            //           color: Colors.white,
                                            //         ),
                                            //       ),
                                            //       errorWidget: (context, url,
                                            //               error) =>
                                            //           const Icon(Icons.error,
                                            //               size: 50),
                                            //     ),
                                            //   ),
                                            // ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['name'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "RS ${product['price'] ?? 'N/A'}",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.green[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
