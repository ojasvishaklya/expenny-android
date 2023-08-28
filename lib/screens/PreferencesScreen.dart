import 'package:flutter/material.dart';
import 'package:journal/service/ThemeService.dart';
import 'package:journal/widgets/ScreenHeaderWidget.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isDarkMode = false;
  bool _showNotifications = true;
  int _selectedCurrency = 0; // 0 for USD, 1 for EUR, etc.

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      ThemeService.changeThemeMode();
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _showNotifications = value;
    });
  }

  void _changeCurrency(int index) {
    setState(() {
      _selectedCurrency = index;
    });
  }

  @override
  void initState() {
    _isDarkMode = ThemeService.getDarkThemeStatus();
    print(_isDarkMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeaderWidget(text: 'Preferences'),
          Row(
            children: const [
              Text(
                'Theme Preferences',
              ),
            ],
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Notification Preferences',
          ),
          ListTile(
            title: Text('Show Notifications'),
            trailing: Switch(
              value: _showNotifications,
              onChanged: _toggleNotifications,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Currency Preferences',
          ),
          ListTile(
            title: Text('Currency'),
            trailing: DropdownButton<int>(
              value: _selectedCurrency,
              onChanged: (index) {},
              items: const [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text('USD'),
                ),
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('EUR'),
                ),
                // Add more currency options...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
