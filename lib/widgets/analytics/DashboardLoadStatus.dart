import 'package:flutter/material.dart';
import 'package:expenny/service/DateService.dart';

/// The dashboard's transient load and error status line.
///
/// It only speaks up while a month is loading or after a load has failed:
/// during a load it names the month being fetched (or reports a same-month
/// refresh), and on failure it reports which month could not be loaded and
/// offers a retry. When settled it renders nothing.
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

  /// The visible status sentence for the current combination of state.
  ///
  /// Only loading and error states have wording; a settled state has none, so
  /// this returns an empty string. Kept pure and static so the wording is
  /// directly testable.
  static String statusLabel({
    required DateTime selectedMonth,
    required DateTime? displayedMonth,
    required bool isLoading,
    required bool hasError,
  }) {
    final selected = DateService.monthYear(selectedMonth);

    if (hasError) {
      return "Couldn't load $selected";
    }

    if (isLoading) {
      if (displayedMonth != null &&
          DateService.isSameMonth(selectedMonth, displayedMonth)) {
        return 'Refreshing ${DateService.monthYear(displayedMonth)}';
      }
      return 'Loading $selected';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = error != null;

    // Nothing to announce or attribute once settled, so render no widget
    // rather than an empty padded row.
    if (!isLoading && !hasError) {
      return const SizedBox.shrink();
    }

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
