import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';

import '../controllers/TransactionController.dart';
import '../service/AnalyticsService.dart';
import '../widgets/BudgetProgressWidget.dart';
import '../widgets/DisplayCard.dart';
import '../widgets/analytics/CategoryBreakdownSection.dart';
import '../widgets/analytics/DashboardHeader.dart';
import '../widgets/analytics/DashboardLoadStatus.dart';
import '../widgets/analytics/MonthComparisonSection.dart';
import '../widgets/analytics/MonthTrendSection.dart';
import '../widgets/analytics/NearbyMonthSelector.dart';

/// Loads transactions for an inclusive start and exclusive end boundary.
///
/// Injectable so tests can control timing, ordering, and failure without
/// touching the controller or the database.
typedef AnalyticsTransactionsLoader = Future<List<Transaction>> Function({
  required DateTime startDate,
  required DateTime endDate,
});

/// The monthly dashboard: what came in and went out, how it tracks against the
/// budget, where it went, how it compares with recent months, and what changed
/// since last month.
///
/// The screen owns selected-month state, one bounded range load, request
/// ordering, and assembly of a single month-stamped snapshot. Child sections
/// receive already-computed models and never query or recalculate.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.transactionLoader,
    this.now,
  });

  /// Overrides the production controller-backed loader in tests.
  final AnalyticsTransactionsLoader? transactionLoader;

  /// Overrides the system clock in tests.
  final DateTime Function()? now;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// The month the user has asked for, normalised to the first of the month.
  late DateTime _selectedMonth;

  /// The month-stamped snapshot currently on screen, replaced atomically.
  _AnalyticsData? _data;

  bool _isLoading = true;
  Object? _loadError;

  /// Incremented per request. Only the latest token may mutate state, so a
  /// slow earlier response — success or failure — cannot overwrite newer data
  /// or clear a newer loading indicator.
  int _requestId = 0;

  /// The month the visible values belong to. Never the selected month while a
  /// different month is still loading.
  DateTime? get _displayedDataMonth => _data?.month;

  DateTime get _currentMonth {
    final now = widget.now?.call() ?? DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth = _currentMonth;
    _load(_selectedMonth);
  }

  Future<List<Transaction>> _loadTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final loader = widget.transactionLoader;
    if (loader != null) {
      return loader(startDate: startDate, endDate: endDate);
    }
    return Get.find<TransactionController>().getTransactionsBetweenDates(
      startDate: startDate,
      endDate: endDate,
      tagSet: null,
    );
  }

  Future<void> _load(DateTime month) async {
    final normalized = DateTime(month.year, month.month, 1);
    final token = ++_requestId;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    // One bounded range covers the six-month trend, the selected month, and
    // the previous-month comparison baseline, so every section is derived from
    // the same response.
    final rangeStart = DateTime(normalized.year, normalized.month - 5, 1);
    final rangeEnd = DateTime(normalized.year, normalized.month + 1, 1);

    try {
      final transactions = await _loadTransactions(
        startDate: rangeStart,
        endDate: rangeEnd,
      );

      if (!mounted || token != _requestId) return;

      final selected = _transactionsIn(transactions, normalized);
      final previousMonth = DateTime(normalized.year, normalized.month - 1, 1);
      final previous = _transactionsIn(transactions, previousMonth);

      setState(() {
        _isLoading = false;
        _loadError = null;
        _data = _AnalyticsData(
          month: normalized,
          summary: AnalyticsService.summarize(selected),
          breakdown: AnalyticsService.categoryBreakdown(selected),
          trend: AnalyticsService.trend(
            year: normalized.year,
            month: normalized.month,
            transactions: transactions,
          ),
          comparison: AnalyticsService.compare(
            current: selected,
            previous: previous,
          ),
        );
      });
    } catch (error) {
      if (!mounted || token != _requestId) return;

      // Keep any existing snapshot and its attribution; only report that the
      // requested month could not be loaded.
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  /// Narrows [transactions] to the calendar month beginning at [month].
  ///
  /// The repository range query uses an inclusive upper bound, so the exclusive
  /// end of the month is enforced here: anything timestamped at the first
  /// instant of the next month belongs to that next month.
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

  void _selectMonth(DateTime month) {
    setState(() => _selectedMonth = DateTime(month.year, month.month, 1));
    _load(_selectedMonth);
  }

  void _retry() => _load(_selectedMonth);

  /// The status line is shown only while loading or when a load has failed. A
  /// settled snapshot needs no status line, so it is not mounted merely because
  /// data is displayed.
  bool get _showStatus => _isLoading || _loadError != null;

  /// The month selector sits closer to the screen edge than the rest of the
  /// dashboard, so it carries its own narrow inset rather than the shared
  /// content inset.
  static const EdgeInsets _selectorInset = EdgeInsets.symmetric(horizontal: 6);

  /// Regular dashboard content shares a single, wider horizontal inset.
  static const EdgeInsets _contentInset = EdgeInsets.symmetric(horizontal: 16);

  Widget _selectorInsetOf(Widget child) =>
      Padding(padding: _selectorInset, child: child);

  Widget _contentInsetOf(Widget child) =>
      Padding(padding: _contentInset, child: child);

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _contentInsetOf(
          const DashboardHeader(subtitle: 'Where your money went'),
        ),
        _selectorInsetOf(
          NearbyMonthSelector(
            selectedMonth: _selectedMonth,
            currentMonth: _currentMonth,
            onMonthSelected: _selectMonth,
          ),
        ),
        if (_showStatus)
          _contentInsetOf(
            DashboardLoadStatus(
              selectedMonth: _selectedMonth,
              displayedMonth: _displayedDataMonth,
              isLoading: _isLoading,
              error: _loadError,
              onRetry: _retry,
            ),
          ),
        if (data == null)
          _contentInsetOf(_InitialState(isLoading: _isLoading))
        else ...[
          // The hero is attributed to the snapshot's own month, so any values
          // left visible while a different selected month loads or fails stay
          // honestly labelled with the month they describe.
          _contentInsetOf(
            DisplayCard(
              summary: data.summary,
              displayedMonth: data.month,
            ),
          ),
          _contentInsetOf(
            BudgetProgressWidget(
              expense: data.summary.expense,
              breakdown: data.breakdown,
            ),
          ),
          _contentInsetOf(
            CategoryBreakdownSection(breakdown: data.breakdown),
          ),
          _contentInsetOf(MonthTrendSection(series: data.trend)),
          _contentInsetOf(
            MonthComparisonSection(
              comparison: data.comparison,
              displayedMonth: data.month,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shown before the first snapshot exists. Presents no monetary values, so a
/// pending or failed initial load can never look like a zero-activity month.
class _InitialState extends StatelessWidget {
  const _InitialState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                'No dashboard data to show yet.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

/// One month's fully computed dashboard data.
///
/// Stamped with the month it describes and replaced as a unit, so every section
/// on screen always agrees about which period it represents.
class _AnalyticsData {
  const _AnalyticsData({
    required this.month,
    required this.summary,
    required this.breakdown,
    required this.trend,
    required this.comparison,
  });

  final DateTime month;
  final MonthlySummary summary;
  final CategoryBreakdown breakdown;
  final TrendSeries trend;
  final MonthComparison comparison;
}
