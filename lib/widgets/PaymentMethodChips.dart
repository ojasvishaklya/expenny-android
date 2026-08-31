import 'package:flutter/material.dart';
import 'package:expenny/models/PaymentMethod.dart';

/// Selectable chips for the payment method — Card / UPI or Cash.
///
/// [value] is the stored payment-method name (`PaymentMethod.ONLINE.name` /
/// `PaymentMethod.CASH.name`); [onChanged] reports the newly chosen name.
class PaymentMethodChips extends StatelessWidget {
  const PaymentMethodChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _PaymentChip(
          label: 'Card / UPI',
          icon: Icons.credit_card,
          methodName: PaymentMethod.ONLINE.name,
          selected: value == PaymentMethod.ONLINE.name,
          onTap: onChanged,
        ),
        _PaymentChip(
          label: 'Cash',
          icon: Icons.payments_outlined,
          methodName: PaymentMethod.CASH.name,
          selected: value == PaymentMethod.CASH.name,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.methodName,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String methodName;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Material(
      color: selected ? colors.secondaryContainer : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => onTap(methodName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
