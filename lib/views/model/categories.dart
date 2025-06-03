import 'package:flutter/material.dart';

class Category {
  final String name;
  final String uname; // Urdu name field
  final IconData icon;

  Category({
    required this.name,
    required this.uname,
    required this.icon,
  });
}

final List<Category> categories = [
  Category(
    name: 'Wooden Crafts',
    uname: 'لکڑی کے دستکاری',
    icon: Icons.category,
  ),
  Category(
    name: 'Pottery',
    uname: 'مٹی کے برتن',
    icon: Icons.category,
  ),
  Category(
    name: 'Glassworks',
    uname: 'شیشہ گری',
    icon: Icons.category,
  ),
  Category(
    name: 'Stoneworks',
    uname: 'پتھر کی کاریگری',
    icon: Icons.category,
  ),
  Category(
    name: 'Metalworks',
    uname: 'دھات کی کاریگری',
    icon: Icons.category,
  ),
  Category(
    name: 'Leather Works',
    uname: 'چمڑے کا کام',
    icon: Icons.category,
  ),
  Category(
    name: 'Jewelry',
    uname: 'زیورات',
    icon: Icons.category,
  ),
  Category(
    name: 'Textiles',
    uname: 'کپڑے',
    icon: Icons.category,
  ),
  // Add more categories as needed
];
