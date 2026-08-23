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
        return AnalyticsSection(
          title: 'Monthly budget',
          trailing: const _EditBudgetButton(),
          keepTrailingInline: true,
          child: const AnalyticsEmptyHint(
            message: 'No budget set. Add a monthly budget in Preferences to '
                'track your spending against it.',
          ),
        );
      }

      return AnalyticsSection(
        title: 'Monthly budget',
        trailing: const _EditBudgetButton(),
        keepTrailingInline: true,
        child: _BudgetBody(expense: expense, budget: budget),
      );
    });
  }
}

/// Section-heading action that opens the shared monthly-budget editor. Shown in
/// both the configured and empty states so the budget can be set, changed, or
/// cleared without leaving the Dashboard. A plain [TextButton] so it carries
/// standard Material button tap and accessibility semantics.
class _EditBudgetButton extends StatelessWidget {
  const _EditBudgetButton();

  @override
  Widget build(BuildContext context) {
    // Drop the button's default horizontal inset and right-align its label so
    // the visible 'Edit' text ends flush with the section's right edge, while
    // a 48x48 minimum size keeps the Material touch target at accessibility
    // size — the extra tap area extends left of the text, not past the edge.
    return TextButton(
      onPressed: () => showMonthlyBudgetDialog(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerRight,
      ),
      child: const Text('Edit'),
    );
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
    final difference = budgetDifference(expense, budget);

    // At exact equality the threshold is considered reached, so status styling
    // activates, while the remaining label still reads zero rather than an
    // overage. This preserves the existing isOverBudget contract.
    final statusLabel = difference < 0
        ? 'Over budget by ${formatRupees(difference.abs())}'
        : 'Remaining ${formatRupees(difference)}';

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
///
/// The dashboard states this as `Remaining {amount}` or `Over budget by
/// {amount}`; this returns the signed difference those labels are built from.
double budgetDifference(double expense, double budget) => budget - expense;

/// Returns null if valid, error message string if invalid.
String? validateBudgetInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null; // empty means "clear"
  final parsed = double.tryParse(trimmed);
  if (parsed == null || !parsed.isFinite) return 'Please enter a valid number';
  if (parsed <= 0) return 'Budget must be a positive amount';
  return null;
}

/// The single monthly-budget editor, shared so the Dashboard's Edit action and
/// the Preferences tile open the exact same dialog, validation, and
/// persistence path rather than each maintaining its own copy.
///
/// An empty field clears the budget; a valid positive amount sets it. Both
/// route through [ConfigService.setMonthlyBudget], which persists the value and
/// keeps the home-screen widget in sync.
Future<void> showMonthlyBudgetDialog(BuildContext context) async {
  final configService = Get.find<ConfigService>();
  final textController = TextEditingController(
    text: configService.monthlyBudget.value?.toStringAsFixed(0) ?? '',
  );
  String? errorText;

  try {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Monthly Budget'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter budget amount (leave empty to clear)',
              prefixText: '₹ ',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text.trim();
                final validationError = validateBudgetInput(text);
                if (validationError != null) {
                  setDialogState(() => errorText = validationError);
                  return;
                }
                if (text.isEmpty) {
                  configService.setMonthlyBudget(null);
                } else {
                  configService.setMonthlyBudget(double.parse(text));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  } finally {
    textController.dispose();
  }
}
