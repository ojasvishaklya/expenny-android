import 'package:flutter/material.dart';

class StatisticsDisplayWidget extends StatelessWidget {
  final Map<String, double> statistics;

  StatisticsDisplayWidget({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0), // Set the BorderRadius
      ),
      margin: EdgeInsets.only(top: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatRow('Transaction Count', statistics['transactionCount']!.toString()),
            _buildStatRow('Total Expense', statistics['totalExpense']!.toStringAsFixed(2)),
            _buildStatRow('Total Income', statistics['totalIncome']!.toStringAsFixed(2)),
            _buildStatRow('Average Transaction', statistics['averageTransaction']!.toStringAsFixed(2)),
            _buildStatRow('Max Transaction Amount', statistics['maxTransactionAmount']!.toStringAsFixed(2)),
            _buildStatRow('Min Transaction Amount', statistics['minTransactionAmount']!.toStringAsFixed(2)),
            _buildStatRow('Expense to Income Ratio', statistics['expenseToIncomeRatio']!.toStringAsFixed(2)),
            _buildStatRow('Savings Rate', '${statistics['savingsRate']!.toStringAsFixed(2)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16,)),
        ],
      ),
    );
  }
}
