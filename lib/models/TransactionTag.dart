import 'dart:math';

import 'package:flutter/material.dart';

class TransactionTag {
  final String name;
  final String id;
  final IconData icon;
  final Color color;

  TransactionTag({
    required this.name,
    required this.id,
    required this.icon,
    required this.color,
  });

  static TransactionTag getTagById(String id) {
    return TransactionTag.tags.firstWhere((tag) => tag.id == id,
        orElse: () => TransactionTag(
            name: 'Unknown',
            id: 'unknown',
            icon: Icons.error,
            color: Colors.red));
  }

  static String getRandomTagId() {
    final random = Random();
    int randomIndex = random.nextInt(TransactionTag.tags.length);
    return TransactionTag.tags[randomIndex].id;
  }

  static final List<TransactionTag> tags = [
    TransactionTag(
      name: 'Food',
      id: 'food',
      icon: Icons.restaurant,
      color: Color(0xFF6200EE), // Purple
    ),
    TransactionTag(
      name: 'Football Turf',
      id: 'football_turf',
      icon: Icons.sports_soccer,
      color: Color(0xFF03DAC6), // Teal
    ),
    TransactionTag(
      name: 'Wifi Bill',
      id: 'wifi_bill',
      icon: Icons.wifi,
      color: Color(0xFFAA66CC), // Purple
    ),
    TransactionTag(
      name: 'Phone Bill',
      id: 'phone_bill',
      icon: Icons.phone,
      color: Color(0xFFFFD700), // Gold
    ),
    TransactionTag(
      name: 'Metro Recharge',
      id: 'metro_recharge',
      icon: Icons.directions_train_sharp,
      color: Color(0xFF03DAC6), // Teal
    ),
    TransactionTag(
      name: 'Loan',
      id: 'loan',
      icon: Icons.face,
      color: Color(0xFFB00020), // Red
    ),
    TransactionTag(
      name: 'Transportation',
      id: 'transportation',
      icon: Icons.directions_car,
      color: Color(0xFF2962FF), // Blue
    ),
    TransactionTag(
      name: 'Gym Fee',
      id: 'gym_fee',
      icon: Icons.fitness_center,
      color: Color(0xFF26A69A), // Teal
    ),
    TransactionTag(
      name: 'Gym Supplements',
      id: 'gym_supplements',
      icon: Icons.sports_gymnastics,
      color: Color(0xFFFF4081), // Pink
    ),
    TransactionTag(
      name: 'Grocery',
      id: 'grocery',
      icon: Icons.local_grocery_store,
      color: Color(0xFF4CAF50), // Green
    ),
    TransactionTag(
      name: 'Entertainment',
      id: 'entertainment',
      icon: Icons.local_movies,
      color: Color(0xFFFF6F00), // Orange
    ),
    TransactionTag(
      name: 'Healthcare',
      id: 'healthcare',
      icon: Icons.local_hospital,
      color: Color(0xFFD32F2F), // Red
    ),
    TransactionTag(
      name: 'Salary',
      id: 'salary',
      icon: Icons.insights_sharp,
      color: Color(0xFF039BE5), // Blue
    ),
    TransactionTag(
      name: 'Miscellaneous',
      id: 'miscellaneous',
      icon: Icons.more_horiz,
      color: Color(0xFF607D8B), // Grey
    ),
  ];

}
