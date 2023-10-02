import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/models/Transaction.dart';
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
  late Filter filter;

  @override
  void initState() {
    selectedPeriod = yearly;
    filter = Filter.defaults();

    if (_selectedTransactions.isEmpty) {
      _getSelectedPeriodTransactions(filter);
    }

    super.initState();
  }

  _getSelectedPeriodTransactions(Filter filter) async {
    DateTime startDate = DateTime(filter.year, 1, 1);
    DateTime endDate = DateTime(filter.year, 12, 31);

    if (selectedPeriod == monthly) {
      startDate = DateTime(filter.year, filter.month, 1);
      endDate = DateTime(filter.year, filter.month + 1, 0);
    }
    print('fethcing data for $startDate to $endDate');
    var transactionList = await _controller.getTransactionsBetweenDates(
        startDate: startDate, endDate: endDate, tagSet: filter.tagSet);
    setState(() {
      _selectedTransactions = transactionList;
      this.filter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    var monthlyAggregatedData =
        AnalyticsService.aggregateDataMonthWise(_selectedTransactions);
    var dateWiseAggregatedData = AnalyticsService.aggregateDataDateWise(
        _selectedTransactions, filter.month, filter.year);

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
                            _getSelectedPeriodTransactions,
                        filter: filter,
                      ),
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
                  _getSelectedPeriodTransactions(filter);
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
                  _getSelectedPeriodTransactions(filter);
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
                          filter.year = filter.year - 1;
                        });
                      } else if (details.primaryVelocity! < 0) {
                        // swipe left
                        setState(() {
                          filter.year = filter.year + 1;
                        });
                        _getSelectedPeriodTransactions(filter);
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius:
                            BorderRadius.circular(10), // Border radius
                      ),
                      child: Center(child: Text(filter.year.toString())),
                    ),
                  ),
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // swipe right
                        setState(() {
                          if (filter.month == 1) {
                            filter.month = 12;
                          } else {
                            filter.month = filter.month - 1;
                          }
                        });
                      } else if (details.primaryVelocity! < 0) {
                        // swipe left
                        setState(() {
                          if (filter.month == 12) {
                            filter.month = 1;
                          } else {
                            filter.month = filter.month + 1;
                          }
                        });
                      }
                      _getSelectedPeriodTransactions(filter);
                    },
                    child: Container(
                      width: 150,
                      padding: selectedPeriod == monthly
                          ? EdgeInsets.all(8)
                          : EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor, // Background color
                        borderRadius:
                            BorderRadius.circular(10), // Border radius
                      ),
                      child: selectedPeriod == monthly
                          ? Center(child: Text(filter.getMonthName()))
                          : Container(),
                    ),
                  ),
                ],
              ),
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
              ),
              AnalyticsTitleWidget(
                text: 'Tag wise split',
              ),
              TagTableWidget(selectedTransactions: _selectedTransactions),
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
    final aggregatedData =
        AnalyticsService.aggregateDataByTag(_selectedTransactions);

    return SizedBox(
      height: 200,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tag Name')),
              DataColumn(label: Text('Expense')),
              DataColumn(label: Text('Income')),
            ],
            rows: aggregatedData.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e[0].toString())),
                  DataCell(Text(e[1].toString())),
                  DataCell(Text(e[2].toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
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
