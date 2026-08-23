import 'package:flutter/material.dart';

/// The sticky bottom action bar: a ghost Cancel plus a primary action whose
/// label differs by mode (Save / Update).
class SaveBar extends StatelessWidget {
  const SaveBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: onPrimary,
              icon: const Icon(Icons.check, size: 18),
              label: Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
