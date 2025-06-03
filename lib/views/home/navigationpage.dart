import 'package:dastkaari/bloc/bloc/cart_bloc.dart';
import 'package:dastkaari/bloc/bloc/cart_event.dart';
import 'package:dastkaari/services/cart/cart_service.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/home/home.dart';
import 'package:dastkaari/views/home/homepage.dart';
import 'package:dastkaari/views/home/itemdetails.dart';
import 'package:dastkaari/views/home/userprofile.dart';
import 'package:dastkaari/views/order_process/cart.dart';
import 'package:dastkaari/views/order_process/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavBar extends StatefulWidget {
  String? userid;
  String? category;
  BottomNavBar({super.key, required this.userid, this.category});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize the _screens list here
    _screens = [
      Home(),
      Homepage(initialCategory: widget.category),
      BlocProvider(
        create: (_) => CartBloc(CartService())..add(LoadCart()),
        child: CartScreen(),
      ),
      UserProfileScreen(),
    ];

    // Set the initial selected index based on some condition
    if (widget.category != null) {
      _selectedIndex = 1; // Assuming the search screen is at index 1
    } else {
      _selectedIndex = 0; // Default to home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          bool isRestricted = (index == 2 || index == 3);

          if (isRestricted) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please log in to access this feature')),
              );

              final redirectIndex = await Navigator.push<int>(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(redirectTabIndex: index),
                ),
              );

              if (redirectIndex != null) {
                setState(() {
                  _selectedIndex = redirectIndex;
                });
              }

              return;
            }
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: Text(
              "Home",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: Text(
              "Search",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Color(0xffD9A441),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.shopping_cart),
            title: Text(
              "Cart",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Color(0xffD9A441),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: Text(
              "Profile",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
