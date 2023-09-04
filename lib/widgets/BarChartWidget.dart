import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:journal/service/AnalyticsService.dart';

import '../models/Transaction.dart';

class BarChartWidget extends StatelessWidget {
  final List<Transaction>
      transactionList; // Assuming you have a list of transactions

  BarChartWidget({required this.transactionList});

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

            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxExpense*-1,
                barGroups: expenseSpots
                    .map(
                      (e) => BarChartGroupData(
                        x: e.x.toInt(),
                        barRods: [
                          BarChartRodData(
                            toY: e.y*-1,
                            width: 8,
                            borderRadius: BorderRadius.circular(0)
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),

        ),
        SizedBox(height: 20,),
        Text('Income Last Year',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 20,),
        SizedBox(
          height: 200,

          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxIncome,
              barGroups: incomeSpots
                  .map(
                    (e) => BarChartGroupData(
                  x: e.x.toInt(),
                  barRods: [
                    BarChartRodData(
                        toY: e.y,
                        width: 8,
                        borderRadius: BorderRadius.circular(0)
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
          ),

        ),

      ],
    );
  }
}
