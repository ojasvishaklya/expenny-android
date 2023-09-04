import 'package:fl_chart/fl_chart.dart';
import 'package:journal/models/Transaction.dart';

class AnalyticsService {
  static List<List<FlSpot>> aggregateDataDateWise(
      List<Transaction> transactionList) {
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

  static aggregateDataMonthWise(List<Transaction> transactionList) {
    // Create lists to hold the monthly sums for income and expenses (12 months each)
    List<double> monthlyIncomeSums = List.generate(12, (_) => 0.0);
    List<double> monthlyExpenseSums = List.generate(12, (_) => 0.0);

    // Iterate through transactions and aggregate them by month
    for (final transaction in transactionList) {
      final year = transaction.date.year;
      final month = transaction.date.month;
      final index = (year - transactionList[0].date.year) * 12 + month - 1;

      // Add the transaction amount to the corresponding month's sum
      if (transaction.isExpense) {
        monthlyExpenseSums[index] += transaction.amount;
      } else {
        monthlyIncomeSums[index] += transaction.amount;
      }
    }

    double maxExpense = double.infinity;
    final List<FlSpot> expenseSpots =
    monthlyExpenseSums
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final value = entry.value;
      if (maxExpense > value) {
        maxExpense = value;
      }
      return FlSpot(index.toDouble(), value);
    }).toList();

    double maxIncome = 0;

    final List<FlSpot> incomeSpots =
    monthlyIncomeSums
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final value = entry.value;
      if (maxIncome < value) {
        maxIncome = value;
      }
      return FlSpot(index.toDouble(), value);
    }).toList();

    return [incomeSpots, maxIncome, expenseSpots,  maxExpense];
  }
}
