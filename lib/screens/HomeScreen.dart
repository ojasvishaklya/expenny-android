import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:journal/screens/CreateTransactionScreen.dart';
import 'package:journal/screens/TransactionsScreen.dart';
import 'package:journal/widgets/AppBarWidget.dart';
import 'package:journal/widgets/BottomNavBarWidget.dart';

import '../constants/routes.dart';
import 'AnalyticsScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    AnalyticsScreen(),
    TransactionsScreen(),
    ProfileScreen(),
    CreateTransactionScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSwipe(DragEndDetails dragEndDetails) {
    print(dragEndDetails.primaryVelocity);
    print(_selectedIndex);
    if (dragEndDetails.primaryVelocity! > 0 && _selectedIndex > 0) {
      setState(() {
        print('decrementing index');
        _selectedIndex-=1;
      });
    } else if (_selectedIndex < _widgetOptions.length - 1) {
      setState(() {
        print('incrementing index');
        _selectedIndex+=1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return Scaffold(
      appBar: buildAppBar(RouteClass.home),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: GNav(
        gap: 10,
        onTabChange: _onItemTapped,
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
      ),
    );
  }
}
