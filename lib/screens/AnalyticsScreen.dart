import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/widgets/BarChartWidget.dart';

import '../controllers/TransactionController.dart';
import '../widgets/FilterSelectorWidget.dart';
import '../widgets/LineChartWidget.dart';
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

  @override
  void initState() {
    if(_selectedTransactions.isEmpty){
      _getSelectedPeriodTransactions(Filter(
        startDate: DateTime.now().subtract(Duration(days: 365)),
        endDate: DateTime.now(),
        tagSet: {}
      ));
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
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
          Visibility(
            visible: _selectedTransactions.isNotEmpty,
            replacement:
                CircularProgressIndicator(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LineChartWidget(
                    transactionList: _selectedTransactions,
                  ),
                  BarChartWidget(
                    transactionList: _selectedTransactions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
