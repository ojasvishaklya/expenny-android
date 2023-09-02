import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:journal/service/AnalyticsService.dart';

import '../models/Transaction.dart';

class LineChartWidget extends StatelessWidget {
  final List<Transaction>
      transactionList; // Assuming you have a list of transactions

  LineChartWidget({required this.transactionList});

  @override
  Widget build(BuildContext context) {
    final dataPoints = AnalyticsService.aggregateData(transactionList);
    final List<FlSpot> expenseSpots = dataPoints[0];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        // width: expenseSpots.length*500,
        height: 200,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: LineChart(LineChartData(lineBarsData: [
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ])),
        ),
      ),
    );
  }
}
