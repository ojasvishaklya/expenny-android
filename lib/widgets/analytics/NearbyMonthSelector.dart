import 'package:flutter/material.dart';
import 'package:expenny/service/DateService.dart';

/// A chronological strip of nearby months centred on the selection.
///
/// Six months are offered — three before the selection through two after it —
/// which keeps recent comparison within one tap without introducing a year
/// picker. Selecting a month recentres the strip on the next build.
///
/// Months later than [currentMonth] are shown but disabled: they exist so the
/// strip stays chronologically continuous, and they carry no tap action.
class NearbyMonthSelector extends StatelessWidget {
  const NearbyMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.currentMonth,
    required this.onMonthSelected,
  });

  /// The month whose data is requested. Normalised internally.
  final DateTime selectedMonth;

  /// The device's current month, used to disable future chips.
  final DateTime currentMonth;

  /// Called only when an enabled month other than [selectedMonth] is chosen.
  final ValueChanged<DateTime> onMonthSelected;

  /// Months offered relative to the selection, oldest first.
  static const int monthsBefore = 3;
  static const int monthsAfter = 2;
  static const int chipCount = monthsBefore + 1 + monthsAfter;

  /// The six chronological first-of-month values shown for [selected].
  static List<DateTime> nearbyMonths(DateTime selected) {
    final base = DateTime(selected.year, selected.month, 1);
    return List.generate(
      chipCount,
      (index) => DateTime(base.year, base.month - monthsBefore + index, 1),
    );
  }

  /// Whether [month] is later than [current] by calendar month.
  static bool isFutureMonth(DateTime month, DateTime current) {
    final a = DateTime(month.year, month.month);
    final b = DateTime(current.year, current.month);
    return a.isAfter(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = nearbyMonths(selectedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a period',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final month in months)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _MonthChip(
                    month: month,
                    isSelected: DateService.isSameMonth(month, selectedMonth),
                    isFuture: isFutureMonth(month, currentMonth),
                    onSelected: onMonthSelected,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.month,
    required this.isSelected,
    required this.isFuture,
    required this.onSelected,
  });

  final DateTime month;
  final bool isSelected;
  final bool isFuture;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      selected: isSelected,
      // A null callback both disables the chip and removes its tap action, so
      // a future month cannot be activated by touch or by assistive tech.
      onSelected: isFuture
          ? null
          : (_) {
              if (!isSelected) onSelected(month);
            },
      label: Text(
        DateService.shortMonthYear(month),
        // Visible text stays compact; assistive tech hears the full month.
        semanticsLabel: DateService.monthYear(month),
      ),
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      // Guarantees a 48 logical pixel minimum touch target.
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
