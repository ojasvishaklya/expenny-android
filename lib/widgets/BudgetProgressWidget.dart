import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/TransactionController.dart';
import '../service/ConfigService.dart';
import '../utils/CurrencyFormatter.dart';

class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final controller = Get.find<TransactionController>();

    return Obx(() {
      final budget = configService.monthlyBudget.value;
      if (budget == null) return const SizedBox.shrink();

      final expense = controller.expense.abs();
      final progress = computeProgress(expense, budget);
      final over = isOverBudget(expense, budget);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatBudgetLabel(expense, budget),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  over ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Pure computation: returns clamped ratio [0.0, 1.0].
double computeProgress(double expense, double budget) {
  if (budget <= 0) return 0.0;
  final ratio = expense / budget;
  return ratio.clamp(0.0, 1.0);
}

/// Pure computation: formats the label string.
String formatBudgetLabel(double expense, double budget) {
  return '${formatRupees(expense)} / ${formatRupees(budget)}';
}

/// Pure computation: returns whether expense has met or exceeded budget.
bool isOverBudget(double expense, double budget) {
  return expense >= budget;
}

/// Returns null if valid, error message string if invalid.
String? validateBudgetInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null; // empty means "clear"
  final parsed = double.tryParse(trimmed);
  if (parsed == null || !parsed.isFinite) return 'Please enter a valid number';
  if (parsed <= 0) return 'Budget must be a positive amount';
  return null;
}
