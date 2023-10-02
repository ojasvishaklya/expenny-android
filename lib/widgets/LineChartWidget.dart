import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:journal/service/DateService.dart';


const height = 180.0;
const width = 500.0;

Widget buildLineChartWidget(BuildContext context, List<FlSpot> dataSpots,
    double maxY, bool isYearly) {
  final color = Theme
      .of(context)
      .colorScheme
      .primary;
  return Container(
    margin: EdgeInsets.only(top: 60, left: 16, right: 16),
    height: height,
    width: width,
    child: LineChart(LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  String xAxisPoint =(value).toInt().toString();

                  if (isYearly) {
                    xAxisPoint =
                      DateService.monthNames[value.toInt()].substring(0, 3);
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      xAxisPoint,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  );
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
            spots: dataSpots,
            isCurved: true,
            color: color,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              color: color.withOpacity(0.5),
              show: true,
            ),
          ),
        ])),
  );
}



