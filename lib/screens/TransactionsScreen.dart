import 'package:expenny/constants/routes.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/service/TransactionSortService.dart';
import 'package:expenny/widgets/FabWidget.dart';
import 'package:expenny/widgets/TransactionCard.dart';
import 'package:expenny/widgets/LoadingWidget.dart';
import 'package:expenny/widgets/TransactionFilterSheet.dart';
import 'package:expenny/widgets/analytics/NearbyMonthSelector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/TransactionController.dart';

/// Loads transactions for a month range, optionally narrowed by a search
/// string and tag set. Injectable so tests can drive timing, ordering, and
/// failure without a controller or database.
typedef TransactionsLoader = Future<List<Transaction>> Function({
  required DateTime startDate,
  required DateTime endDate,
  String? searchString,
  required Set<TransactionTag>? tagSet,
});

/// Opens the create/edit transaction flow and reports whether persistence
/// changed. Injectable so widget tests can drive route completion without a
/// real navigator or database-backed editor.
typedef TransactionEditor = Future<bool?> Function(Transaction transaction);

/// The Transactions ledger: a compact, date-grouped activity list for one
/// selected month, with in-page search, a new sort capability, and a filter &
/// sort bottom sheet.
///
/// The screen owns its own month / search / sort / tag state and loads a
/// bounded single-month range, guarding stale responses with an incrementing
/// request token — mirroring [DashboardScreen]. It deliberately does **not**
/// touch the shared `TransactionController.transactionList` (which feeds SMS
/// sync and the home widget), keeping the two decoupled.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    this.transactionLoader,
    this.transactionEditor,
    this.now,
  });

  /// Overrides the production controller-backed loader in tests.
  final TransactionsLoader? transactionLoader;

  /// Overrides create/edit route navigation in tests.
  final TransactionEditor? transactionEditor;

  /// Overrides the system clock in tests.
  final DateTime Function()? now;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late DateTime _selectedMonth;
  final TextEditingController _searchController = TextEditingController();

  String _searchString = '';
  TransactionSort _sort = TransactionSort.newestFirst;
  Set<TransactionTag> _tagSet = {};

  /// The month's transactions currently on screen, replaced atomically.
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  Object? _loadError;

  /// Incremented per request. Only the latest token may mutate state, so a
  /// slow earlier response cannot overwrite newer data or clear a newer
  /// loading indicator.
  int _requestId = 0;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  DateTime get _currentMonth {
    final now = _now;
    return DateTime(now.year, now.month, 1);
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth = _currentMonth;
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Transaction>> _loadTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final loader = widget.transactionLoader;
    final tagSet = _tagSet.isEmpty ? null : _tagSet;
    final searchString = _searchString.isEmpty ? null : _searchString;
    if (loader != null) {
      return loader(
        startDate: startDate,
        endDate: endDate,
        searchString: searchString,
        tagSet: tagSet,
      );
    }
    return Get.find<TransactionController>().getTransactionsBetweenDates(
      startDate: startDate,
      endDate: endDate,
      searchString: searchString,
      tagSet: tagSet,
    );
  }

  /// Reloads the selected month. Called whenever a query input (month, search,
  /// tags) changes. Sort changes are applied in memory and do not reload.
  Future<void> _load() async {
    final month = _selectedMonth;
    final token = ++_requestId;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    // Inclusive-lower / exclusive-upper month window; the exclusive end is
    // enforced in memory below since the query's upper bound is inclusive.
    final rangeStart = DateTime(month.year, month.month, 1);
    final rangeEnd = DateTime(month.year, month.month + 1, 1);

    try {
      final loaded = await _loadTransactions(
        startDate: rangeStart,
        endDate: rangeEnd,
      );

      if (!mounted || token != _requestId) return;

      final inMonth = loaded
          .where(
              (t) => t.date.year == month.year && t.date.month == month.month)
          .toList();

      setState(() {
        _isLoading = false;
        _loadError = null;
        _transactions = inMonth;
      });
    } catch (error) {
      if (!mounted || token != _requestId) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  void _selectMonth(DateTime month) {
    setState(() => _selectedMonth = DateTime(month.year, month.month, 1));
    _load();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchString = value);
    _load();
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  /// The date chip cycles Newest ⇄ Oldest, jumping to Newest from an amount
  /// sort. In-memory only.
  void _toggleDateSort() {
    setState(() {
      _sort = _sort == TransactionSort.newestFirst
          ? TransactionSort.oldestFirst
          : TransactionSort.newestFirst;
    });
  }

  Future<bool?> _openEditor(Transaction transaction) async {
    final editor = widget.transactionEditor;
    if (editor != null) return editor(transaction);
    return await Get.toNamed<bool>(
      RouteClass.createTransaction,
      arguments: transaction,
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final changed = await _openEditor(transaction);
    if (!mounted || changed != true) return;
    await _load();
  }

  /// The amount chip cycles Highest ⇄ Lowest, jumping to Highest from a date
  /// sort. In-memory only.
  void _toggleAmountSort() {
    setState(() {
      _sort = _sort == TransactionSort.highestAmount
          ? TransactionSort.lowestAmount
          : TransactionSort.highestAmount;
    });
  }

  void _openFilterSheet() {
    TransactionFilterSheet.show(
      context,
      sort: _sort,
      tags: _tagSet,
      onApply: (result) {
        final tagsChanged = !_setEquals(result.tags, _tagSet);
        setState(() {
          _sort = result.sort;
          _tagSet = result.tags;
        });
        // Tags are a query parameter, so only a tag change needs a reload;
        // a sort-only change is applied in memory.
        if (tagsChanged) _load();
      },
    );
  }

  bool _setEquals(Set<TransactionTag> a, Set<TransactionTag> b) {
    return a.length == b.length && a.containsAll(b);
  }

  bool get _isDateSort =>
      _sort == TransactionSort.newestFirst ||
      _sort == TransactionSort.oldestFirst;

  bool get _isAmountSort => !_isDateSort;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _Header(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBox(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _buildControls(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: NearbyMonthSelector(
                selectedMonth: _selectedMonth,
                currentMonth: _currentMonth,
                onMonthSelected: _selectMonth,
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: buildFloatingActionButton(
            () => _editTransaction(Transaction.defaults()),
            'Add Transaction',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search transactions',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchString.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSearch,
              ),
        filled: true,
        fillColor: theme.hoverColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final dateLabel =
        _sort == TransactionSort.oldestFirst ? 'Oldest' : 'Newest';
    final amountLabel = _sort == TransactionSort.lowestAmount
        ? 'Lowest'
        : (_sort == TransactionSort.highestAmount ? 'Highest' : 'Amount');

    return Row(
      children: [
        // The sort chips can shrink/scroll on narrow screens so the Filter
        // chip stays pinned to the right and nothing overflows.
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  icon: Icons.swap_vert,
                  label: dateLabel,
                  active: _isDateSort,
                  onTap: _toggleDateSort,
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: amountLabel,
                  active: _isAmountSort,
                  onTap: _toggleAmountSort,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          hasActiveTags: _tagSet.isNotEmpty,
          onTap: _openFilterSheet,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _EmptyOrError(
        message: "Couldn't load transactions.",
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    if (_transactions.isEmpty) {
      return Semantics(
        container: true,
        label: 'No transactions for this month.',
        child: const ExcludeSemantics(
          child: LoadingWidget(
            animationName: 'home_screen_loader',
            size: 200,
          ),
        ),
      );
    }

    final sorted = sortTransactions(_transactions, _sort);
    return _buildGroupedList(sorted);
  }

  Widget _buildGroupedList(List<Transaction> sorted) {
    // Walk the already-sorted list, emitting a date heading whenever the
    // calendar day changes. This keeps headings in step with the active sort.
    final children = <Widget>[];
    String? currentKey;
    for (final transaction in sorted) {
      final key = DateService.dateGroupKey(transaction.date);
      if (key != currentKey) {
        currentKey = key;
        children.add(Padding(
          padding: EdgeInsets.only(
            left: 2,
            right: 2,
            top: children.isEmpty ? 6 : 14,
            bottom: 4,
          ),
          child: Text(
            DateService.dateGroupLabel(transaction.date, now: _now)
                .toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ));
      }
      children.add(TransactionCard(
        transaction: transaction,
        onTap: () => _editTransaction(transaction),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: children,
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          'Your complete activity',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// A quick-toggle sort chip in the controls row.
class _SortChip extends StatelessWidget {
  const _SortChip({
    this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground =
        active ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Material(
      color: active ? colors.secondaryContainer : Colors.transparent,
      shape: StadiumBorder(
        side:
            BorderSide(color: active ? colors.primary : colors.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: foreground),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.arrow_drop_down, size: 16, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Filter chip that opens the filter & sort sheet, carrying a dot when tag
/// filters are active.
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.hasActiveTags, required this.onTap});

  final bool hasActiveTags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = hasActiveTags;
    final foreground =
        active ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Material(
      color: active ? colors.secondaryContainer : Colors.transparent,
      shape: StadiumBorder(
        side:
            BorderSide(color: active ? colors.primary : colors.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 15, color: foreground),
              const SizedBox(width: 5),
              Text(
                'Filter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              if (hasActiveTags) ...[
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
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

class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
