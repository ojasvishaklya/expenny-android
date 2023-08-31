import 'package:fl_chart/fl_chart.dart';
import 'package:journal/models/Transaction.dart';

class AnalyticsService {
  static List<List<FlSpot>> aggregateData(List<Transaction> transactionList) {
    final Map<DateTime, double> aggregatedIncomeData = {};
    final Map<DateTime, double> aggregatedExpenseData = {};

    for (final transaction in transactionList) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (transaction.isExpense) {
        if (aggregatedExpenseData.containsKey(date)) {
          aggregatedExpenseData[date] =
              aggregatedExpenseData[date]! + transaction.amount;
        } else {
          aggregatedExpenseData[date] = transaction.amount;
        }
      } else {
        if (aggregatedIncomeData.containsKey(date)) {
          aggregatedIncomeData[date] =
              aggregatedIncomeData[date]! + transaction.amount;
        } else {
          aggregatedIncomeData[date] = transaction.amount;
        }
      }
    }

    final List<FlSpot> incomeSpots = aggregatedIncomeData.entries.map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList();

    final List<FlSpot> expenseSpots =
        aggregatedExpenseData.entries.map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList();

    return [incomeSpots, expenseSpots];
  }
}
