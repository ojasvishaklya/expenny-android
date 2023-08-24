import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onIndexChanged;

  const BottomNavBarWidget(
      {Key? key, required this.currentIndex, required this.onIndexChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GNav(
      gap: 10,
      onTabChange: onIndexChanged,
      selectedIndex: currentIndex,
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
}
