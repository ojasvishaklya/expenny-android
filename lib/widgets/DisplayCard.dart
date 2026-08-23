import 'package:flutter/material.dart';

/// Presentational BALANCE / Income / Expense summary.
///
/// Pure and stateless: it renders exactly the values it is given and owns no
/// controller or subscription. Callers pass already-computed figures, and the
/// expense is passed as a signed value (negative for money out) so it reads the
/// same way the transaction totals do.
class DisplayCard extends StatelessWidget {
  const DisplayCard({
    Key? key,
    required this.balance,
    required this.income,
    required this.expense,
  }) : super(key: key);

  final double balance;
  final double income;
  final double expense;

  /// Available width below which the Income and Expense metrics stack instead
  /// of sharing a row, so neither value is squeezed. Mirrors the MonthlySummary
  /// hero's responsive threshold.
  static const double _stackBelowWidth = 360;

  /// Text scale beyond which the metrics stack, matching the analytics
  /// sections' `kAnalyticsStackTextScale`.
  static const double _stackTextScale = 1.3;

  /// Mirrors the previous controller getters: round to two decimals, then use
  /// the default numeric string form. Rounding first keeps snapshot
  /// floating-point values from surfacing artifacts like `12.340000000001`
  /// while preserving the old trailing-`.0` presentation.
  static String _format(double value) =>
      double.parse(value.toStringAsFixed(2)).toString();

  @override
  Widget build(BuildContext context) {
    final incomeMetric = _Metric(
      icon: Icons.arrow_upward,
      color: Colors.green,
      label: 'Income',
      value: _format(income),
    );
    final expenseMetric = _Metric(
      icon: Icons.arrow_downward,
      color: Colors.red,
      label: 'Expense',
      value: _format(expense),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text('B A L A N C E', style: TextStyle(fontSize: 14)),
        // The net amount shrinks to fit rather than clipping, so long signed
        // values stay whole and centred under the label.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _format(balance),
            style: const TextStyle(fontSize: 32),
          ),
        ),
        const SizedBox(height: 12),
        // Measure the full DisplayCard width here, before the details padding
        // removes 40px, so the stack decision reflects the card's own width
        // rather than the narrower padded content box.
        LayoutBuilder(
          builder: (context, constraints) {
            // Stack the metrics when the card is narrow or the text is
            // enlarged, otherwise share the row in equal bounded slots.
            final stack = constraints.maxWidth < _stackBelowWidth ||
                MediaQuery.textScalerOf(context).scale(1) > _stackTextScale;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: stack
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        incomeMetric,
                        const SizedBox(height: 12),
                        expenseMetric,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: incomeMetric),
                        const SizedBox(width: 12),
                        Expanded(child: expenseMetric),
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }
}

/// One labelled figure: a circular direction icon beside a label and its bold
/// value. The value scales down within its own bounded slot so long signed
/// amounts can never overflow the row or drop digits.
class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
