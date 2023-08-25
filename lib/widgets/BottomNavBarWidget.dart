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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GNav(
        gap: 8,
        onTabChange: onIndexChanged,
        selectedIndex: currentIndex,
        // backgroundColor: Colors.black,
        tabBackgroundColor: Theme.of(context).hoverColor,
        padding: EdgeInsets.all(12),
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
            icon: Icons.search,
            text: 'Search',
          ),
          GButton(
            icon: Icons.settings,
            text: 'Preferences',
          ),
        ],
      ),
    );
  }
}
