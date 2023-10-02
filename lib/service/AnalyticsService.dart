import 'package:fl_chart/fl_chart.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';

class AnalyticsService {
  static aggregateDataDateWise(
      List<Transaction> transactionList, int targetMonth, int targetYear) {
    // Filter transactions for the target month and year
    List<Transaction> filteredTransactions =
        transactionList.where((transaction) {
      return transaction.date.month == targetMonth &&
          transaction.date.year == targetYear;
    }).toList();

    // Create a map to hold the daily sums for income and expenses
    Map<int, double> dailyIncomeSums = {};
    Map<int, double> dailyExpenseSums = {};

    // Iterate through all days in the target month and set initial values to 0
    for (int day = 1;
        day <= DateTime(targetYear, targetMonth + 1, 0).day;
        day++) {
      dailyIncomeSums[day] = 0;
      dailyExpenseSums[day] = 0;
    }

    // Iterate through filtered transactions and aggregate them by date
    for (final transaction in filteredTransactions) {
      final day = transaction.date.day;

      // Add the transaction amount to the corresponding date's sum
      if (transaction.isExpense) {
        dailyExpenseSums[day] =
            (dailyExpenseSums[day] ?? 0) + transaction.amount;
      } else {
        dailyIncomeSums[day] = (dailyIncomeSums[day] ?? 0) + transaction.amount;
      }
    }

    double maxExpense = double.negativeInfinity;
    final List<FlSpot> expenseSpots = dailyExpenseSums.entries.map((entry) {
      final day = entry.key;
      final value = entry.value;
      if (maxExpense < value) {
        maxExpense = value;
      }
      return FlSpot(day.toDouble(), value.abs());
    }).toList();

    double maxIncome = 0;
    final List<FlSpot> incomeSpots = dailyIncomeSums.entries.map((entry) {
      final day = entry.key;
      final value = entry.value;
      if (maxIncome < value) {
        maxIncome = value;
      }
      return FlSpot(day.toDouble(), value);
    }).toList();

    return [incomeSpots, maxIncome, expenseSpots, maxExpense.abs()];
  }

  static List<List<dynamic>> aggregateDataByTag(
      List<Transaction> transactionList) {
    Map<String, double> tagIncomeMap = {};
    Map<String, double> tagExpenseMap = {};

    // Iterate through transactions and aggregate them by tag
    for (final transaction in transactionList) {
      // Add the transaction amount to the corresponding tag's sum
      if (transaction.isExpense) {
        tagExpenseMap.update(
            transaction.tag, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      } else {
        tagIncomeMap.update(
            transaction.tag, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    List<List<dynamic>> aggregatedData = [];

    for (String tagId in tagExpenseMap.keys) {
      TransactionTag tagName = TransactionTag.getTagById(tagId);
      double expense = tagExpenseMap[tagId] ?? 0;
      double income = tagIncomeMap[tagId] ?? 0;

      // Add tag name, expense, and income to the list
      aggregatedData.add([tagName, expense, income]);
    }

    // Sort the list based on the expense values (in descending order)
    aggregatedData.sort((a, b) => a[1].compareTo(b[1]));

    return aggregatedData;
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
        monthlyExpenseSums.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      if (maxExpense > value) {
        maxExpense = value;
      }
      return FlSpot(index.toDouble() + 1, value.abs());
    }).toList();

    double maxIncome = 0;

    final List<FlSpot> incomeSpots =
        monthlyIncomeSums.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      if (maxIncome < value) {
        maxIncome = value;
      }
      return FlSpot(index.toDouble() + 1, value);
    }).toList();

    return [incomeSpots, maxIncome, expenseSpots, maxExpense.abs()];
  }

  static Map<String, double> calculateStatistics(List<Transaction> transactions) {
    int transactionCount = transactions.length;
    double totalExpense = transactions.where((transaction) => transaction.isExpense).fold(0, (sum, transaction) => sum + transaction.amount);
    double totalIncome = transactions.where((transaction) => !transaction.isExpense).fold(0, (sum, transaction) => sum + transaction.amount);
    double averageTransaction = transactionCount > 0 ? (totalIncome + totalExpense) / transactionCount : 0;

    double maxTransactionAmount = transactions.isNotEmpty
        ? transactions.map((transaction) => transaction.amount).reduce((max, amount) => amount > max ? amount : max)
        : 0;

    double minTransactionAmount = transactions.isNotEmpty
        ? transactions.map((transaction) => transaction.amount).reduce((min, amount) => amount < min ? amount : min)
        : 0;

    double expenseToIncomeRatio = totalIncome != 0 ? totalExpense / totalIncome : 0;

    double savingsRate = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;

    return {
      'transactionCount': transactionCount.toDouble(),
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'averageTransaction': averageTransaction,
      'maxTransactionAmount': maxTransactionAmount,
      'minTransactionAmount': minTransactionAmount,
      'expenseToIncomeRatio': expenseToIncomeRatio,
      'savingsRate': savingsRate,
    };
  }
}
