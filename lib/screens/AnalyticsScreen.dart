import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/service/DateService.dart';
import 'package:journal/widgets/LineChartWidget.dart';

import '../controllers/TransactionController.dart';
import '../service/AnalyticsService.dart';
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

  int monthIndex=DateTime.now().month;
  int year=DateTime.now().year;

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
    selectedPeriod = yearly;
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
    var monthlyAggregatedData =
        AnalyticsService.aggregateDataMonthWise(_selectedTransactions);
    var dateWiseAggregatedData =
        AnalyticsService.aggregateDataDateWise(_selectedTransactions, 9, 2023);

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
          Expanded(
              child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // swipe right
                        setState(() {
                          year=year-1;
                        });
                      } else if (details.primaryVelocity! < 0) {
                        // swipe left
                        setState(() {
                          year=year+1;
                        });
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius: BorderRadius.circular(10), // Border radius
                      ),
                      child: Center(child: Text(year.toString())),
                    ),
                  ),
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // swipe right
                        setState(() {
                          if(monthIndex==1){
                            monthIndex=12;
                          }
                          monthIndex=monthIndex-1;
                        });
                      } else if (details.primaryVelocity! < 0) {
                        // swipe left
                        setState(() {
                          if(monthIndex==12){
                            monthIndex=1;
                          }
                          monthIndex=monthIndex+1;
                        });
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: selectedPeriod == monthly
                          ? EdgeInsets.all(8)
                          : EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius: BorderRadius.circular(10), // Border radius
                      ),
                      child: selectedPeriod == monthly
                          ? Center(child: Text(DateService.monthNames[monthIndex]))
                          : Container(),
                    ),
                  ),

                ],
              ),
              // TagTableWidget(selectedTransactions: _selectedTransactions),
              AnalyticsTitleWidget(
                text: 'Expense Trend',
              ),
              Scrollbar(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: selectedPeriod == yearly
                        ? buildLineChartWidget(
                            context,
                            monthlyAggregatedData[2],
                            monthlyAggregatedData[3],
                            true)
                        : buildLineChartWidget(
                            context,
                            dateWiseAggregatedData[2],
                            monthlyAggregatedData[3],
                            false)),
              ),
              AnalyticsTitleWidget(
                text: 'Income Trend',
              ),
              Scrollbar(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: selectedPeriod == yearly
                        ? buildLineChartWidget(
                            context,
                            monthlyAggregatedData[0],
                            monthlyAggregatedData[1],
                            true)
                        : buildLineChartWidget(
                            context,
                            dateWiseAggregatedData[0],
                            monthlyAggregatedData[1],
                            false)),
              )
            ],
          ))
        ],
      ),
    );
  }
}

class SideArrowWidget extends StatelessWidget {
  const SideArrowWidget({
    Key? key,
    required this.shouldShow,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final bool shouldShow;
  final String text;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        padding: shouldShow == true ? EdgeInsets.all(8) : EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor, // Background color
          borderRadius: BorderRadius.circular(100), // Border radius
        ),
        child: shouldShow == true ? Center(child: Text(text)) : Container(),
      ),
    );
  }
}

class TagTableWidget extends StatelessWidget {
  const TagTableWidget({
    Key? key,
    required List<Transaction> selectedTransactions,
  })  : _selectedTransactions = selectedTransactions,
        super(key: key);

  final List<Transaction> _selectedTransactions;

  @override
  Widget build(BuildContext context) {
    return DataTable(
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
    );
  }
}

class AnalyticsTitleWidget extends StatelessWidget {
  final String text;

  const AnalyticsTitleWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(2.0), // Set the BorderRadius
      ),
      margin: EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
