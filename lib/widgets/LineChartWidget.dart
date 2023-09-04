import 'dart:math';

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
    final dataPoints = AnalyticsService.aggregateDataMonthWise(transactionList);
    final List<FlSpot> expenseSpots = dataPoints[2];
    final maxExpense = dataPoints[3];

    final List<FlSpot> incomeSpots = dataPoints[0];
    final maxIncome = dataPoints[1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expense Last Year',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 20,),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value,meta) {


                        final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        final day = dateTime.day;
                        final month = dateTime.month;
                        final year = dateTime.year;

                        return Transform.rotate(
                          angle: 1 * (pi / 180), // Convert degrees to radians
                          child: Text(
                            '$month',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ); // Customize the date format
                      },
                    )),
                leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    width: 1, // Customize the border width
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: false,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true, // Fill color below the line
                  ),
                ),
              ])),
        ),
        SizedBox(height: 20,),
        Text('Income Last Year',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 20,),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value,meta) {


                        final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        final day = dateTime.day;
                        final month = dateTime.month;
                        final year = dateTime.year;

                        return Transform.rotate(
                          angle: 1 * (pi / 180), // Convert degrees to radians
                          child: Text(
                            '$month',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ); // Customize the date format
                      },
                    )),
                leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    width: 1, // Customize the border width
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: false,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true, // Fill color below the line
                  ),
                ),
              ])),
        ),
      ],
    );
  }
}
