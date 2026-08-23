import 'package:flutter/material.dart';
import 'package:expenny/screens/TransactionsScreen.dart';
import 'package:expenny/widgets/BottomNavBarWidget.dart';

import 'DashboardScreen.dart';
import 'PreferencesScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Dashboard is the landing destination, sitting between Transactions on the
  /// left and Settings on the right. Keep this index in step with the order of
  /// [_screens] and the tabs in [BottomNavBarWidget].
  static const int _dashboardIndex = 1;

  int _selectedIndex = _dashboardIndex;
  PageController _pageController = PageController();

  final List<Widget> _screens = <Widget>[
    TransactionsScreen(),
    DashboardScreen(),
    PreferencesScreen()
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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
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
