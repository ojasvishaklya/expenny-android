import 'package:flutter/material.dart';
import 'package:journal/service/DataService.dart';
import 'package:journal/service/ThemeService.dart';
import 'package:journal/widgets/ScreenHeaderWidget.dart';

import '../widgets/PopupWidget.dart';
import 'PreferencesWidgets/AlertContent.dart';
import 'PreferencesWidgets/PreferenceTile.dart';

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
          SizedBox(height: 16,),
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
              text: 'Import transaction data',
              icon: Icons.arrow_upward,
              onTap: () async {
                showSnackBar(
                    context: context,
                    textContent: "I'll work on this feature after 500 downloads",
                    color: Colors.orange,
                    duration: 5);
              }),
          PreferenceTileWidget(
              text: 'Export data as excel',
              icon: Icons.arrow_downward,
              onTap: () async {
                final response = await _dataService.exportToExcel();
                showSnackBar(
                    context: context,
                    textContent: response.response,
                    color: response.isError ? Colors.redAccent : Colors.green,
                    duration: 5);
              }),
          PreferenceTileWidget(
              text: 'Delete all data',
              icon: Icons.delete,
              onTap: () async {
                showAlertContent(context: context, content: AlertContent(
                    text: "Are you sure you want to delete all data?",
                    showButtons: true,
                    onTap:() async{
                      final response = await _dataService.deleteAllTransactions();
                      showSnackBar(
                          context: context,
                          textContent: response.response,
                          color: response.isError ? Colors.redAccent : Colors.green,
                          duration: 5);
                    }
                )
                );
              }
              ),
        ],
      ),
    );
  }
}



