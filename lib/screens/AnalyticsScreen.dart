import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/models/Transaction.dart';

import '../controllers/TransactionController.dart';
import '../widgets/FilterSelectorWidget.dart';
import '../widgets/LineChartWidget.dart';
import '../widgets/LoadingWidget.dart';
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Center(
              child: Visibility(
                visible: _selectedTransactions.isNotEmpty,
                replacement: LoadingWidget(animationName: 'analytics_loader'),
                child: LineChartWidget(
                  transactionList: _selectedTransactions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
