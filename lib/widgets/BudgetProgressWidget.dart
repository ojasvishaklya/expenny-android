import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/ConfigService.dart';
import '../utils/CurrencyFormatter.dart';
import 'analytics/AnalyticsSection.dart';

/// Progress of a period's spending against the configured monthly budget.
///
/// [expense] is the spend to measure, as a non-negative magnitude. It is passed
/// in rather than read from the controller so the widget can report any month
/// the dashboard has selected, not just the current one.
///
/// The single budget applies to every month independently — there is no
/// rollover of unused budget or overspend between months.
class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({super.key, required this.expense});

  final double expense;

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Obx(() {
      final budget = configService.monthlyBudget.value;

      if (budget == null) {
        return const AnalyticsSection(
          title: 'Monthly budget',
          child: AnalyticsEmptyHint(
            message: 'No budget set. Add a monthly budget in Preferences to '
                'track your spending against it.',
          ),
        );
      }

      return AnalyticsSection(
        title: 'Monthly budget',
        child: _BudgetBody(expense: expense, budget: budget),
      );
    });
  }
}

class _BudgetBody extends StatelessWidget {
  const _BudgetBody({required this.expense, required this.budget});

  final double expense;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progress = computeProgress(expense, budget);
    final over = isOverBudget(expense, budget);
    final usedPercent = budgetUsedPercent(expense, budget);

    // At exact equality the threshold is considered reached, so status styling
    // activates, while the remaining label still reads zero rather than an
    // overage. This preserves the existing isOverBudget contract.
    final statusLabel = expense > budget
        ? 'Over budget by ${formatRupees(expense - budget)}'
        : 'Remaining ${formatRupees(budget - expense)}';

    final statusColor = over ? colors.error : colors.onSurfaceVariant;

    return Semantics(
      container: true,
      label: 'Monthly budget, ${formatRupees(expense)} spent of '
          '${formatRupees(budget)}, ${formatPercent(usedPercent)} used, '
          '$statusLabel',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wrap rather than Spacer: both values are unbounded text and must
            // be allowed to fall onto separate lines at narrow widths.
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent of ${formatRupees(budget)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRupees(expense),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  statusLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                // Track fill is capped; the numeric percentage below is not.
                value: progress,
                minHeight: 8,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  over ? colors.error : colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${formatPercent(usedPercent)} used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
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
