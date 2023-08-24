import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: textTheme.headlineLarge,
          ),
          Row(
            children: [
              Text(
                'Theme Preferences',
                style: textTheme.bodyLarge,
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
            style: textTheme.bodyLarge,
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
            style: textTheme.bodyLarge,
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
