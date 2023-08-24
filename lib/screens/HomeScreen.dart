import 'package:flutter/material.dart';
import 'package:journal/screens/TransactionsScreen.dart';
import 'package:journal/widgets/BottomNavBarWidget.dart';

import 'AnalyticsScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  PageController _pageController = PageController();

  static final List<Widget> _screens = <Widget>[
    AnalyticsScreen(),
    TransactionsScreen(),
    ProfileScreen()
  ];

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    return Scaffold(
      // appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0),
        child: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _selectedIndex,
        onIndexChanged: _updateSelectedIndex,
      ),
    );
  }
}
