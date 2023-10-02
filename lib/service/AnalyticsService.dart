import 'package:fl_chart/fl_chart.dart';
import 'package:journal/models/Transaction.dart';

class AnalyticsService {

  static aggregateDataDateWise(List<Transaction> transactionList, int targetMonth, int targetYear) {
    // Filter transactions for the target month and year
    List<Transaction> filteredTransactions = transactionList.where((transaction) {
      return transaction.date.month == targetMonth && transaction.date.year == targetYear;
    }).toList();

    // Create a map to hold the daily sums for income and expenses
    Map<int, double> dailyIncomeSums = {};
    Map<int, double> dailyExpenseSums = {};

    // Iterate through all days in the target month and set initial values to 0
    for (int day = 1; day <= DateTime(targetYear, targetMonth + 1, 0).day; day++) {
      dailyIncomeSums[day] = 0;
      dailyExpenseSums[day] = 0;
    }

    // Iterate through filtered transactions and aggregate them by date
    for (final transaction in filteredTransactions) {
      final day = transaction.date.day;

      // Add the transaction amount to the corresponding date's sum
      if (transaction.isExpense) {
        dailyExpenseSums[day] = (dailyExpenseSums[day] ?? 0) + transaction.amount;
      } else {
        dailyIncomeSums[day] = (dailyIncomeSums[day] ?? 0) + transaction.amount;
      }
    }

    double maxExpense = double.negativeInfinity;
    final List<FlSpot> expenseSpots =
    dailyExpenseSums.entries.map((entry) {
      final day = entry.key;
      final value = entry.value;
      if (maxExpense < value) {
        maxExpense = value;
      }
      return FlSpot(day.toDouble(), value.abs());
    }).toList();

    double maxIncome = 0;
    final List<FlSpot> incomeSpots =
    dailyIncomeSums.entries.map((entry) {
      final day = entry.key;
      final value = entry.value;
      if (maxIncome < value) {
        maxIncome = value;
      }
      return FlSpot(day.toDouble(), value);
    }).toList();

    return [incomeSpots, maxIncome, expenseSpots, maxExpense.abs()];
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
      return FlSpot(index.toDouble()+1, value.abs());
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
      return FlSpot(index.toDouble()+1, value);
    }).toList();

    return [incomeSpots, maxIncome, expenseSpots,  maxExpense.abs()];
  }
}


