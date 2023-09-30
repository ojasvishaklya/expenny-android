import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:journal/service/AnalyticsService.dart';
import 'package:journal/service/DateService.dart';

import '../models/Transaction.dart';

class MonthlyLineChartWidget extends StatelessWidget {
  final List<Transaction>
      transactionList; // Assuming you have a list of transactions

  const MonthlyLineChartWidget({Key? key, required this.transactionList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataPoints = AnalyticsService.aggregateDataMonthWise(transactionList);
    final List<FlSpot> expenseSpots = dataPoints[2];
    final maxExpense = dataPoints[3];

    final List<FlSpot> incomeSpots = dataPoints[0];
    final maxIncome = dataPoints[1];
    final incomeColor=Theme.of(context).colorScheme.primary;
    final expenseColor=Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXPENSE',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
          height: 200,
          width: 500,
          child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value,meta) {
                        String monthName=DateService.monthNames[value.toInt()].substring(0, 3);
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            monthName,
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
                  isCurved: true,
                  color: expenseColor,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    color: expenseColor.withOpacity(0.5),
                    show: true, // Fill color below the line
                  ),
                ),
              ])),
        ),
        Text('INCOME',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
          height: 200,
          width: 500,
          child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value,meta) {
                        String monthName=DateService.monthNames[value.toInt()].substring(0, 3);
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            monthName,
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
                  isCurved: true,
                  color: incomeColor,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    color: incomeColor.withOpacity(0.5),
                    show: true, // Fill color below the line
                  ),
                ),
              ])),
        ),
      ],
    );
  }
}

