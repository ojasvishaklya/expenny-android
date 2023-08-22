import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

Widget buildBottomNavBar(void Function(int index) onItemTapped) {
  return GNav(
    gap: 10,
    onTabChange: onItemTapped,
    selectedIndex: 1,
    tabs: const [
      GButton(
        icon: Icons.analytics_outlined,
        text: 'Analytics',
      ),
      GButton(
        icon: Icons.home,
        text: 'Home',
      ),
      GButton(
        icon: Icons.man_sharp,
        text: 'Profile',
      ),
      GButton(
        icon: Icons.add_box_rounded,
        text: 'Add',
      ),
    ],
  );
}
