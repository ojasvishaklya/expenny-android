import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The large, `₹`-prefixed amount input at the top of the create/edit screen.
///
/// Presentational: the caller owns the value. The field accepts only a
/// non-negative number (digits and a single decimal point — the input
/// formatter makes a leading `-` impossible), and reports the parsed magnitude
/// via [onChanged] (null when empty/incomplete). Its colour follows [isExpense]
/// so it always agrees with the sign toggle.
class AmountHeroField extends StatefulWidget {
  const AmountHeroField({
    super.key,
    required this.isExpense,
    required this.onChanged,
    this.initialAmount,
    this.autofocus = false,
  });

  final bool isExpense;
  final ValueChanged<double?> onChanged;

  /// Seeds the field; the sign is ignored (the magnitude is shown).
  final double? initialAmount;
  final bool autofocus;

  static const Color expenseColor = Color(0xFFBA1A1A);
  static const Color incomeColor = Color(0xFF2E7D32);

  @override
  State<AmountHeroField> createState() => _AmountHeroFieldState();
}

class _AmountHeroFieldState extends State<AmountHeroField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAmount;
    _controller = TextEditingController(
      text: (initial == null || initial == 0) ? '' : _trim(initial.abs()),
    );
  }

  /// Renders a whole number without a trailing `.0`, otherwise as-entered.
  String _trim(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isExpense ? AmountHeroField.expenseColor : AmountHeroField.incomeColor;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '₹',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        IntrinsicWidth(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            inputFormatters: [
              // Digits and a single decimal point only — no sign, no letters.
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              _SingleDecimalFormatter(),
            ],
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: color,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            onChanged: (text) {
              final parsed = double.tryParse(text);
              widget.onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}

/// Rejects a second decimal point so the text always parses.
class _SingleDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if ('.'.allMatches(newValue.text).length > 1) return oldValue;
    return newValue;
  }
}
