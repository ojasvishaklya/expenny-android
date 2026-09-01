import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/analytics/CategoryBreakdown.dart';
import '../service/ConfigService.dart';
import '../utils/CurrencyFormatter.dart';
import 'analytics/AnalyticsSection.dart';
import 'analytics/CategoryVisualIdentity.dart';

/// Progress of a period's spending against the configured monthly budget.
///
/// [expense] is the spend to measure, as a non-negative magnitude. It is passed
/// in rather than read from the controller so the widget can report any month
/// the dashboard has selected, not just the current one.
///
/// [breakdown] is the same category grouping the ledger and the "spending by
/// category" list use. The budget track is filled by these categories in order,
/// each tinted with its shared [CategoryVisualIdentity], so a glance shows not
/// only how much of the budget is gone but which categories consumed it.
///
/// The single budget applies to every month independently — there is no
/// rollover of unused budget or overspend between months.
class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({
    super.key,
    required this.expense,
    required this.breakdown,
  });

  final double expense;
  final CategoryBreakdown breakdown;

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
        child: _BudgetBody(
          expense: expense,
          budget: budget,
          breakdown: breakdown,
        ),
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
  const _BudgetBody({
    required this.expense,
    required this.budget,
    required this.breakdown,
  });

  final double expense;
  final double budget;
  final CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final over = isOverBudget(expense, budget);
    final usedPercent = budgetUsedPercent(expense, budget);
    final difference = budgetDifference(expense, budget);
    final segments = budgetSegments(breakdown, budget);

    // At exact equality the threshold is considered reached, so status styling
    // activates, while the remaining label still reads zero rather than an
    // overage. This preserves the existing isOverBudget contract without
    // surfacing a false-positive overage at expense == budget.
    final over0 = difference < 0;
    final statusLabel = over0
        ? 'Over budget by ${formatRupees(difference.abs())}'
        : '${formatRupees(remainingBudget(expense, budget))} left';

    // Under (and exactly at) budget the caption spells out the full intent:
    // {spent} of {budget} · {remaining} left. Genuine overspend swaps in the
    // error copy.
    final caption = over0
        ? statusLabel
        : '${formatRupees(expense)} of ${formatRupees(budget)} · $statusLabel';

    final statusColor = over ? colors.error : colors.onSurfaceVariant;

    // The spoken equivalent states the raw figures, the utilisation, and the
    // category splits, so the bar's colour and segmentation carry no
    // information that assistive tech cannot reach.
    final semanticLabel = _semanticLabel(
      expense: expense,
      budget: budget,
      usedPercent: usedPercent,
      statusLabel: statusLabel,
      segments: segments,
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _SegmentedBudgetBar(segments: segments),
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

  static String _semanticLabel({
    required double expense,
    required double budget,
    required double usedPercent,
    required String statusLabel,
    required List<BudgetSegment> segments,
  }) {
    final categorySplits = segments
        .where((s) => !s.isIdle)
        .map((s) => '${s.group!.label}, ${formatRupees(s.group!.amount)}');
    final splitClause =
        categorySplits.isEmpty ? '' : ' By category: ${categorySplits.join('. ')}.';
    return 'Monthly budget, ${formatRupees(expense)} spent of '
        '${formatRupees(budget)}, ${formatPercent(usedPercent)} used, '
        '$statusLabel.$splitClause';
  }
}

/// The category-segmented budget track: an ordered run of tag-tinted segments
/// followed, when under budget, by a neutral idle remainder — all inside one
/// rounded rail so the segments read as a single bar.
class _SegmentedBudgetBar extends StatelessWidget {
  const _SegmentedBudgetBar({required this.segments});

  final List<BudgetSegment> segments;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        // The rail colour shows through wherever no segment is drawn; for a
        // fully-consumed track no idle segment exists and nothing shows
        // through.
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: Row(
            children: [
              for (var index = 0; index < segments.length; index++) ...[
                if (index > 0) const SizedBox(width: 2),
                Expanded(
                  flex: segments[index].flex,
                  child: ColoredBox(
                    color: segments[index].isIdle
                        ? colors.surfaceContainerHighest
                        : categoryIdentityFor(
                            segments[index].group!,
                            colors,
                          ).color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One drawn portion of the budget track: either a category fill or the neutral
/// idle remainder. [fraction] is the share of the whole budget this portion
/// occupies, in [0, 1].
class BudgetSegment {
  const BudgetSegment.category(this.group, this.fraction) : isIdle = false;

  const BudgetSegment.idle(this.fraction)
      : group = null,
        isIdle = true;

  /// The category this fill represents, or null for the idle remainder.
  final CategoryGroup? group;

  /// Share of the whole budget this segment occupies, in [0, 1].
  final double fraction;

  final bool isIdle;

  /// Integer flex weight for laying the segment out in a [Row]. Scaled up from
  /// [fraction] so rounding does not collapse thin-but-present segments to
  /// nothing.
  int get flex {
    final scaled = (fraction * 10000).round();
    return scaled < 1 ? 1 : scaled;
  }
}

/// Pure computation: the ordered category fills plus, when under budget, a
/// neutral idle remainder, expressed as fractions of the whole [budget].
///
/// Categories are laid down in [breakdown] order. Each contributes
/// `group.amount / budget`, but the cumulative category fill is capped at 1.0
/// so a category that would spill past the end of the track is clipped to
/// exactly the remaining room and later categories contribute nothing — the
/// track never renders overflow. Any budget left unspent becomes a single
/// trailing idle segment; at or over budget there is no idle remainder.
///
/// Returns an empty list for a non-positive budget (the widget does not build a
/// bar in that case).
List<BudgetSegment> budgetSegments(CategoryBreakdown breakdown, double budget) {
  if (budget <= 0) return const [];

  final segments = <BudgetSegment>[];
  var cumulative = 0.0;
  for (final group in breakdown.groups) {
    if (cumulative >= 1.0) break;
    final raw = group.amount / budget;
    // Clip this segment to whatever room is left so the cumulative fill never
    // exceeds the track.
    final room = 1.0 - cumulative;
    final fraction = raw < room ? raw : room;
    if (fraction <= 0) continue;
    segments.add(BudgetSegment.category(group, fraction));
    cumulative += fraction;
  }

  // Append the neutral remainder only when the categories left the track
  // partly empty. A tiny epsilon absorbs floating-point dust so an exactly
  // full track shows no sliver of idle.
  final idle = 1.0 - cumulative;
  if (idle > 1e-9) {
    segments.add(BudgetSegment.idle(idle));
  }

  return segments;
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
/// The dashboard states this as `{amount} left` or `Over budget by {amount}`;
/// this returns the signed difference those labels are built from.
double budgetDifference(double expense, double budget) => budget - expense;

/// Pure computation: budget left to spend, floored at zero.
///
/// At or over budget this is zero rather than a negative value, so the
/// under-budget caption never shows a negative "left" figure. The signed
/// [budgetDifference] still drives the overspend copy.
double remainingBudget(double expense, double budget) {
  final diff = budget - expense;
  return diff > 0 ? diff : 0.0;
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
