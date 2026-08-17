import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/ConfigService.dart';
import '../utils/CurrencyFormatter.dart';
import 'analytics/AnalyticsSection.dart';

/// Progress of a period's spending against the configured monthly budget.
///
/// [expense] is the spend to measure, as a non-negative magnitude. It is passed
/// in rather than read from the controller so the widget can report any month
/// the analytics screen has selected, not just the current one.
///
/// The single budget applies to every month independently — there is no
/// rollover of unused budget or overspend between months.
class BudgetProgressWidget extends StatelessWidget {
  final double expense;

  const BudgetProgressWidget({Key? key, required this.expense})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final theme = Theme.of(context);

    return Obx(() {
      final budget = configService.monthlyBudget.value;

      if (budget == null) {
        return const AnalyticsSection(
          title: 'Budget',
          child: AnalyticsEmptyHint(
            message: 'Set a monthly budget in Preferences to track your '
                'spending against it.',
          ),
        );
      }

      final progress = computeProgress(expense, budget);
      final over = isOverBudget(expense, budget);

      return AnalyticsSection(
        title: 'Budget',
        trailing: Text(
          formatPercent(budgetUsedPercent(expense, budget)),
          style: theme.textTheme.labelMedium?.copyWith(
            color: over ? Colors.red : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  formatBudgetLabel(expense, budget),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  formatBudgetRemainder(expense, budget),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        over ? Colors.red : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

/// Pure computation: percentage of the budget consumed. Unlike
/// [computeProgress] this is not capped, so overspending reports above 100.
/// Returns 0 for a non-positive budget.
double budgetUsedPercent(double expense, double budget) {
  if (budget <= 0) return 0.0;
  return (expense / budget) * 100;
}

/// Pure computation: how much budget is left, or how far past it the spend is.
String formatBudgetRemainder(double expense, double budget) {
  final difference = budget - expense;
  if (difference >= 0) return '${formatRupees(difference)} left';
  return '${formatRupees(difference.abs())} over';
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
