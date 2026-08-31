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

  /// Maps retired tag ids to their current equivalent.
  ///
  /// The tag taxonomy was refreshed to a smaller, more common set; earlier
  /// niche tags were folded into broader categories. Historical transactions
  /// still carry the old id in the database, so both [getTagById] (display) and
  /// the schema-v2 DB migration (storage) route ids through [normalizeTagId] to
  /// keep old data resolvable and, once migrated, consolidated.
  static const Map<String, String> aliases = {
    'football_turf': 'entertainment',
    'wifi_bill': 'bills',
    'phone_bill': 'bills',
    'metro_recharge': 'transport',
    'cab': 'transport',
    'loan': 'finance',
    'gym': 'health',
    'gym_supplements': 'health',
    'healthcare': 'health',
    'apparel': 'shopping',
  };

  /// Resolves [id] to a current tag id, following an alias if one exists.
  ///
  /// Pure and side-effect free so it can back both display resolution and the
  /// database id-normalization migration. Unknown ids pass through unchanged
  /// (and surface as the `unknown` fallback in [getTagById]).
  static String normalizeTagId(String id) => aliases[id] ?? id;

  static TransactionTag getTagById(String id) {
    final resolved = normalizeTagId(id);
    return TransactionTag.tags.firstWhere((tag) => tag.id == resolved,
        orElse: () => TransactionTag(
            name: 'Unknown',
            id: 'unknown',
            icon: Icons.error,
            color: Colors.red));
  }

  static TransactionTag getRandomTag() {
    final random = Random();
    int randomIndex = random.nextInt(TransactionTag.tags.length);
    return TransactionTag.tags[randomIndex];
  }

  static final List<TransactionTag> tags = [
    TransactionTag(
      name: 'Food & Drink',
      id: 'food',
      icon: Icons.restaurant,
      color: Color(0xFF6750A4), // Purple
    ),
    TransactionTag(
      name: 'Groceries',
      id: 'grocery',
      icon: Icons.local_grocery_store,
      color: Color(0xFF4CAF50), // Green
    ),
    TransactionTag(
      name: 'Transport',
      id: 'transport',
      icon: Icons.directions_car,
      color: Color(0xFF2962FF), // Blue
    ),
    TransactionTag(
      name: 'Shopping',
      id: 'shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFFF6F00), // Orange
    ),
    TransactionTag(
      name: 'Bills & Utilities',
      id: 'bills',
      icon: Icons.receipt_long,
      color: Color(0xFFAA66CC), // Light purple
    ),
    TransactionTag(
      name: 'Rent & Housing',
      id: 'rent',
      icon: Icons.home,
      color: Color(0xFF00897B), // Teal
    ),
    TransactionTag(
      name: 'Entertainment',
      id: 'entertainment',
      icon: Icons.local_movies,
      color: Color(0xFFFF4081), // Pink
    ),
    TransactionTag(
      name: 'Health & Fitness',
      id: 'health',
      icon: Icons.favorite,
      color: Color(0xFFD32F2F), // Red
    ),
    TransactionTag(
      name: 'Travel',
      id: 'travel',
      icon: Icons.flight,
      color: Color(0xFF039BE5), // Light blue
    ),
    TransactionTag(
      name: 'Education',
      id: 'education',
      icon: Icons.school,
      color: Color(0xFF5E35B1), // Deep purple
    ),
    TransactionTag(
      name: 'Personal Care',
      id: 'personal_care',
      icon: Icons.spa,
      color: Color(0xFFEC407A), // Pink
    ),
    TransactionTag(
      name: 'Finance & Fees',
      id: 'finance',
      icon: Icons.account_balance,
      color: Color(0xFF6D4C41), // Brown
    ),
    TransactionTag(
      name: 'Gifts & Donations',
      id: 'gifts',
      icon: Icons.card_giftcard,
      color: Color(0xFFC2185B), // Magenta
    ),
    TransactionTag(
      name: 'Investments',
      id: 'investments',
      icon: Icons.trending_up,
      color: Color(0xFF00ACC1), // Cyan
    ),
    TransactionTag(
      name: 'Salary',
      id: 'salary',
      icon: Icons.payments,
      color: Color(0xFF43A047), // Green
    ),
    TransactionTag(
      name: 'Miscellaneous',
      id: 'miscellaneous',
      icon: Icons.more_horiz,
      color: Color(0xFF607D8B), // Grey
    ),
  ];
}
