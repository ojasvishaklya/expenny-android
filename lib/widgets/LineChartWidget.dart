import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/Transaction.dart';

class LineChartWidget extends StatelessWidget {
  final List<Transaction>
      transactions; // Assuming you have a list of transactions

  LineChartWidget({required this.transactions});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dataPoints = [];

    // Convert Transaction objects to FlSpot data points
    // for (var transaction in transactions) {
    //   dataPoints.add(FlSpot(transaction.date.millisecondsSinceEpoch.toDouble(), transaction.amount));
    // }
    for (int i = 0; i < 10; i++) {
      dataPoints.add(FlSpot(i + 0.0, i * 10));
    }
    return AspectRatio(
      aspectRatio: 16 / 9, // Set the desired aspect ratio
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: transactions.first.date.millisecondsSinceEpoch.toDouble(),
          maxX: transactions.last.date.millisecondsSinceEpoch.toDouble(),
          minY: 0,
          maxY: 1000,
          // You can adjust the maximum Y value as needed
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
