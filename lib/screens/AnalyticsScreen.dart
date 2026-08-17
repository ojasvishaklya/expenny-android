import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';

import '../controllers/TransactionController.dart';
import '../service/AnalyticsService.dart';
import '../service/DateService.dart';
import '../widgets/BudgetProgressWidget.dart';
import '../widgets/ScreenHeaderWidget.dart';
import '../widgets/analytics/CategoryBreakdownSection.dart';
import '../widgets/analytics/MonthComparisonSection.dart';
import '../widgets/analytics/MonthTrendSection.dart';
import '../widgets/analytics/MonthlySummarySection.dart';

/// The month's money story: what came in and went out, how it tracks against
/// the budget, where it went, how it compares with recent months, and what
/// changed since last month.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _controller = Get.find<TransactionController>();

  /// First day of the month currently being shown.
  late DateTime _selectedMonth;

  _AnalyticsData? _data;
  bool _isLoading = true;

  /// Incremented on every load so a slow earlier request cannot overwrite the
  /// results of a newer one when the user steps through months quickly.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _load();
  }

  /// True when the selected month is the current calendar month, meaning there
  /// is no later month worth showing.
  bool get _isAtCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    final month = _selectedMonth;

    setState(() => _isLoading = true);

    // The six-month trend window starts five months before the selected month;
    // the previous month is included in it, so one query covers the trend and
    // the comparison baseline.
    final trendStart = DateTime(month.year, month.month - 5, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);

    final rangeTransactions = await _controller.getTransactionsBetweenDates(
      startDate: trendStart,
      endDate: monthEnd,
      tagSet: null,
    );

    // Discard a stale response: the user moved to a different month while this
    // query was in flight.
    if (!mounted || requestId != _requestId) return;

    final selected = _transactionsIn(rangeTransactions, month);
    final previousMonth = DateTime(month.year, month.month - 1, 1);
    final previous = _transactionsIn(rangeTransactions, previousMonth);

    setState(() {
      _isLoading = false;
      _data = _AnalyticsData(
        summary: AnalyticsService.summarize(selected),
        breakdown: AnalyticsService.categoryBreakdown(selected),
        trend: AnalyticsService.trend(
          year: month.year,
          month: month.month,
          transactions: rangeTransactions,
        ),
        comparison: AnalyticsService.compare(
          current: selected,
          previous: previous,
        ),
      );
    });
  }

  /// Filters [transactions] down to the calendar month starting at [month].
  ///
  /// The repository query uses an inclusive upper bound, so the exclusive end
  /// of the month is enforced here: a transaction timestamped exactly at the
  /// first instant of the next month belongs to that next month.
  List<Transaction> _transactionsIn(
    List<Transaction> transactions,
    DateTime month,
  ) {
    return transactions
        .where((transaction) =>
            transaction.date.year == month.year &&
            transaction.date.month == month.month)
        .toList();
  }

  void _stepMonth(int offset) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ScreenHeaderWidget(text: 'Analytics'),
            ],
          ),
          const SizedBox(height: 16),
          _MonthSelector(
            month: _selectedMonth,
            canGoForward: !_isAtCurrentMonth,
            onPrevious: () => _stepMonth(-1),
            onNext: () => _stepMonth(1),
          ),
          if (_isLoading && data == null)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data != null)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  MonthlySummarySection(summary: data.summary),
                  BudgetProgressWidget(expense: data.summary.expense),
                  CategoryBreakdownSection(breakdown: data.breakdown),
                  MonthTrendSection(series: data.trend),
                  MonthComparisonSection(comparison: data.comparison),
                ],
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// Everything the screen renders for one selected month, computed together so
/// all five sections always describe the same period.
class _AnalyticsData {
  final MonthlySummary summary;
  final CategoryBreakdown breakdown;
  final TrendSeries trend;
  final MonthComparison comparison;

  const _AnalyticsData({
    required this.summary,
    required this.breakdown,
    required this.trend,
    required this.comparison,
  });
}

/// Month stepper. Moving past the current month is disabled because there is
/// no future data to show.
class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
        ),
        Expanded(
          child: Text(
            '${DateService.monthNames[month.month]} ${month.year}',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: canGoForward ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
        ),
      ],
    );
  }
}
