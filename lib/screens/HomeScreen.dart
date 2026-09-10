import 'package:flutter/material.dart';
import 'package:expenny/screens/TransactionsScreen.dart';
import 'package:expenny/widgets/BottomNavBarWidget.dart';

import 'DashboardScreen.dart';
import 'PreferencesScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.screens}) : super(key: key);

  /// Optional override for the paged destinations, used by widget tests to
  /// inject lightweight stand-ins for the real screens. When null, the app's
  /// production screens are used in their canonical order.
  final List<Widget>? screens;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Transactions is the landing destination, sitting between Dashboard on the
  /// left and Preferences on the right. Keep this index in step with the order
  /// of [_screens] and the tabs in [BottomNavBarWidget].
  static const int _transactionsIndex = 1;

  int _selectedIndex = _transactionsIndex;
  PageController _pageController = PageController();

  late final List<Widget> _screens = widget.screens ??
      <Widget>[
        DashboardScreen(),
        TransactionsScreen(),
        PreferencesScreen(),
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
