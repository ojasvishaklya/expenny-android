import 'package:flutter/material.dart';

/// A segmented Expense / Income control, mirroring the create-transaction
/// mockup's sign toggle.
///
/// [value] is `true` for expense, `false` for income. Presentational only —
/// it holds no state and calls [onChanged] with the newly selected sign.
class SignToggle extends StatelessWidget {
  const SignToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  static const Color _expense = Color(0xFFBA1A1A);
  static const Color _income = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegButton(
            label: 'Expense',
            icon: Icons.south,
            selected: isExpense,
            selectedColor: _expense,
            onTap: () => onChanged(true),
          ),
          _SegButton(
            label: 'Income',
            icon: Icons.north,
            selected: !isExpense,
            selectedColor: _income,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  const _SegButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? selectedColor : colors.onSurfaceVariant;

    return Material(
      color: selected ? colors.surface : Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
