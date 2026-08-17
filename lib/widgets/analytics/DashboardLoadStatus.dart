import 'package:flutter/material.dart';
import 'package:expenny/service/DateService.dart';

/// The dashboard's single source of period attribution.
///
/// While a new month is loading the previous month's values stay on screen, so
/// something must state which month those values belong to. This component is
/// that statement: it names the month being loaded and the month being shown,
/// and it never relabels visible values as the newly selected month.
///
/// It uses a linear indicator rather than a blocking spinner so the dashboard
/// stays readable and interactive during a refresh.
class DashboardLoadStatus extends StatelessWidget {
  const DashboardLoadStatus({
    super.key,
    required this.selectedMonth,
    required this.displayedMonth,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  /// The month the user has asked for.
  final DateTime selectedMonth;

  /// The month the visible values belong to, or null before the first load.
  final DateTime? displayedMonth;

  final bool isLoading;

  /// Present when the most recent load failed.
  final Object? error;

  final VoidCallback? onRetry;

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// The visible status sentence for the current combination of state.
  ///
  /// Kept pure and static so the wording is directly testable.
  static String statusLabel({
    required DateTime selectedMonth,
    required DateTime? displayedMonth,
    required bool isLoading,
    required bool hasError,
  }) {
    final selected = DateService.monthYear(selectedMonth);
    final displayed =
        displayedMonth == null ? null : DateService.monthYear(displayedMonth);

    if (hasError) {
      if (displayed == null) return "Couldn't load $selected";
      return "Couldn't load $selected · Showing $displayed";
    }

    if (isLoading) {
      if (displayed == null) return 'Loading $selected';
      if (_isSameMonth(selectedMonth, displayedMonth!)) {
        return 'Refreshing $displayed';
      }
      return 'Loading $selected · Showing $displayed';
    }

    if (displayed == null) return 'Loading $selected';
    return 'Showing $displayed';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = error != null;

    final label = statusLabel(
      selectedMonth: selectedMonth,
      displayedMonth: displayedMonth,
      isLoading: isLoading,
      hasError: hasError,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (hasError && onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
