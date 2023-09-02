import 'package:flutter/material.dart';
import 'package:journal/service/DataService.dart';
import 'package:journal/service/ThemeService.dart';
import 'package:journal/widgets/ScreenHeaderWidget.dart';

import '../widgets/PopupWidget.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isDarkMode = false;
  final _dataService = DataService();

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      ThemeService.changeThemeMode();
    });
  }

  @override
  void initState() {
    _isDarkMode = ThemeService.getDarkThemeStatus();
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
            children: [
              Expanded(
                flex: 4,
                child: PreferenceTileWidget(
                    text: 'Dark mode', icon: Icons.nightlight_round),
              ),
              Expanded(
                flex: 1,
                child: Switch(
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
              ),
            ],
          ),
          Spacer(),
          PreferenceTileWidget(
              text: 'Download as excel',
              icon: Icons.archive_rounded,
              onTap: () async {
                final response = await _dataService.exportToExcel();
                showSnackBar(
                    context: context,
                    textContent: response.response,
                    color: response.isError ? Colors.redAccent : Colors.green,
                    duration: 5);
              }),
          PreferenceTileWidget(
              text: 'Delete all data', icon: Icons.delete, onTap: () {}),
        ],
      ),
    );
  }
}

class PreferenceTileWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final onTap;

  PreferenceTileWidget(
      {required this.text, required this.icon, this.onTap = null});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // Make the border round
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 16.0),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
