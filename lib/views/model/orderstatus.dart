import 'package:flutter/material.dart';

class OrderStatus {
  final String name; // English status
  final String uname; // Urdu status
  final IconData icon;

  OrderStatus({
    required this.name,
    required this.uname,
    required this.icon,
  });
}

final List<OrderStatus> statusOptions = [
  OrderStatus(
    name: 'All',
    uname: 'تمام',
    icon: Icons.list_alt,
  ),
  OrderStatus(
    name: 'pending',
    uname: 'زیر التواء',
    icon: Icons.access_time,
  ),
  OrderStatus(
    name: 'processing',
    uname: 'پروسیسنگ',
    icon: Icons.sync,
  ),
  OrderStatus(
    name: 'shipped',
    uname: 'بھیج دیا گیا',
    icon: Icons.local_shipping,
  ),
  OrderStatus(
    name: 'delivered',
    uname: 'ڈیلیور ہو گیا',
    icon: Icons.check_circle,
  ),
  OrderStatus(
    name: 'cancelled',
    uname: 'منسوخ',
    icon: Icons.cancel,
  ),
];
