import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/widgets/LineChartWidget.dart';
import 'package:journal/widgets/MonthlyLineChartWidget.dart';

import '../controllers/TransactionController.dart';
import '../widgets/DateTextWidget.dart';
import '../widgets/FilterSelectorWidget.dart';
import '../widgets/PopupWidget.dart';
import '../widgets/ScreenHeaderWidget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late List<Transaction> _selectedTransactions = [];
  final _controller = Get.find<TransactionController>();
  final String yearly = 'Y e a r l y';
  final String monthly = 'M o n t h l y';
  late String selectedPeriod;
  late DateTime selectedYear;
  late DateTime selectedMonth;

  setSelectedYear(date) {
    setState(() {
      selectedYear = date;
    });
  }

  setSelectedMonth(date) {
    setState(() {
      selectedMonth = date;
    });
  }

  @override
  void initState() {
    if (_selectedTransactions.isEmpty) {
      _getSelectedPeriodTransactions(Filter(
          startDate: DateTime.now().subtract(Duration(days: 365)),
          endDate: DateTime.now(),
          tagSet: {}));
    }
    selectedPeriod = monthly;
    super.initState();
  }

  _getSelectedPeriodTransactions(Filter filter) async {
    var transactionList = await _controller.getTransactionsBetweenDates(
        startDate: filter.startDate,
        endDate: filter.endDate,
        tagSet: filter.tagSet);
    setState(() {
      _selectedTransactions = transactionList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeaderWidget(text: 'Analytics'),
              Spacer(),
              IconButton(
                  onPressed: () {
                    _controller.insertRandomData();
                  },
                  icon: Icon(Icons.add)),
              IconButton(
                  onPressed: () {
                    showAlertContent(
                      context: context,
                      content: FilterSelectorWidget(
                          getSelectedPeriodTransactions:
                              _getSelectedPeriodTransactions),
                    );
                  },
                  icon: Icon(Icons.filter_alt)),
            ],
          ),
          Expanded(
              child: ListView(
            children:
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = yearly;
                        });
                      },
                      child: Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedPeriod == yearly
                                ? Theme.of(context).colorScheme.onBackground
                                : Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius:
                          BorderRadius.circular(2.0), // Set the BorderRadius
                        ),
                        child: Center(child: Text(yearly.toUpperCase())),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = monthly;
                        });
                      },
                      child: Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedPeriod == monthly
                                ? Theme.of(context).colorScheme.onBackground
                                : Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius:
                          BorderRadius.circular(2.0), // Set the BorderRadius
                        ),
                        child: Center(child: Text(monthly.toUpperCase())),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 150,
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius: BorderRadius.circular(10), // Border radius
                      ),
                      child: Center(child: Text('2023')),
                    ),
                    Container(
                      width: 150,
                      margin: EdgeInsets.only(bottom: 8),
                      padding: selectedPeriod==monthly?EdgeInsets.all(8) : EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius: BorderRadius.circular(10), // Border radius
                      ),
                      child: selectedPeriod==monthly?Center(child: Text('July')):Container(),
                    ),
                  ],
                ),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Tag Name')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: _selectedTransactions.take(10).map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(entry.tag)),
                        DataCell(Text(entry.amount.toString())),
                      ],
                    );
                  }).toList(),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      MonthlyLineChartWidget(transactionList: _selectedTransactions),
                      // Add more widgets here if needed
                    ],
                  ),
                ),
              ]
            ,
          ))

        ],
      ),
    );
  }
}
