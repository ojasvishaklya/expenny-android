import 'package:flutter/material.dart';
import 'package:journal/models/Transaction.dart';

import '../widgets/ScreenHeaderWidget.dart';

enum DateRangeOption { lastWeek, lastMonth, lastYear, customDates }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateRangeOption _selectedOption = DateRangeOption.lastWeek;
  late List<Transaction> _selectedTransactions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeaderWidget(text: 'Analytics'),
            // buildDatePeriodSelector(),
            // Text(_selectedTransactions.toString())
          ],
        ),
      ),
    );
  }

  Center buildDatePeriodSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<DateRangeOption>(
            value: _selectedOption,
            onChanged: (option) {
              setState(() {
                _selectedOption = option!;
              });
            },
            items: DateRangeOption.values.map((option) {
              return DropdownMenuItem<DateRangeOption>(
                value: option,
                child: Text(option.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
