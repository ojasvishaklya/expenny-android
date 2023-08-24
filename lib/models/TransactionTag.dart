import 'dart:math';

import 'package:flutter/material.dart';

class TransactionTag {
  final String name;
  final String id;
  final IconData icon;

  TransactionTag({required this.name, required this.id, required this.icon});

  static TransactionTag getTagById(String id) {
    return TransactionTag.tags.firstWhere((tag) => tag.id == id,
        orElse: () =>
            TransactionTag(name: 'Unknown', id: 'unknown', icon: Icons.error));
  }

  static String getRandomTagId() {
    final random = Random();
    int randomIndex = random.nextInt(TransactionTag.tags.length);
    return TransactionTag.tags[randomIndex].id;
  }

  static final List<TransactionTag> tags = [
    TransactionTag(name: 'Food', id: 'food', icon: Icons.restaurant),
    TransactionTag(
        name: 'Football Turf', id: 'football_turf', icon: Icons.sports_soccer),
    TransactionTag(name: 'Wifi Bill', id: 'wifi_bill', icon: Icons.wifi),
    TransactionTag(name: 'Phone Bill', id: 'phone_bill', icon: Icons.phone),
    TransactionTag(
        name: 'Metro Recharge',
        id: 'metro_recharge',
        icon: Icons.directions_train_sharp),
    TransactionTag(
        name: 'Transportation',
        id: 'transportation',
        icon: Icons.directions_car),
    TransactionTag(name: 'Gym Fee', id: 'gym_fee', icon: Icons.fitness_center),
    TransactionTag(
        name: 'Gym Supplements',
        id: 'gym_supplements',
        icon: Icons.sports_gymnastics),
    TransactionTag(
        name: 'Grocery', id: 'grocery', icon: Icons.local_grocery_store),
    TransactionTag(name: 'Housing', id: 'housing', icon: Icons.home),
    TransactionTag(
        name: 'Entertainment', id: 'entertainment', icon: Icons.local_movies),
    TransactionTag(
        name: 'Healthcare', id: 'healthcare', icon: Icons.local_hospital),
    TransactionTag(
        name: 'Salary', id: 'salary', icon: Icons.insights_sharp),
    TransactionTag(
        name: 'Miscellaneous', id: 'miscellaneous', icon: Icons.more_horiz),
  ];
}
