import 'package:expenny/service/DataService.dart';
import 'package:expenny/service/ThemeService.dart';
import 'package:expenny/widgets/ScreenHeaderWidget.dart';
import 'package:flutter/material.dart';

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
                if(response.isError) {
                  showSnackBar(
                      context: context,
                      textContent: response.response,
                      color: response.isError ? Colors.redAccent : Colors.green,
                      duration: 5);
                }
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

class PreferenceTileWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final onTap;

  const PreferenceTileWidget(
      {Key? key, required this.text, required this.icon, this.onTap})
      : super(key: key);

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

class AlertContent extends StatelessWidget {
  const AlertContent({Key? key,
    required this.text,
    required this.showButtons,
    required this.onTap})
      : super(key: key);

  final String text;
  final bool showButtons;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: Theme
              .of(context)
              .textTheme
              .bodyLarge),
          showButtons == true ? SizedBox(height: 10.0) : Container(),
          // Add spacing between the message and buttons
          showButtons == true
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('cancel'),
              ),
              SizedBox(width: 16.0), // Add spacing between the buttons
              TextButton(
                onPressed: () {
                  onTap();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('delete'),
              ),
            ],
          )
              : Container(),
        ],
      ),
    );
  }
}
