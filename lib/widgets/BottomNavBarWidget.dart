import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

Widget buildBottomNavBar() {
  return GNav(
    gap: 10,
    onTabChange: (index){
      print(index);
    },
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
    ],
  );
}
