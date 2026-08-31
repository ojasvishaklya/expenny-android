import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';

/// Single-select tag pills (icon + name) for the create/edit screen, replacing
/// the old icon-only grid.
///
/// [selectedTagId] is resolved through [TransactionTag.getTagById] so a stored
/// legacy id still highlights its current tag. [onChanged] reports the chosen
/// tag's id.
class TagPicker extends StatelessWidget {
  const TagPicker({
    super.key,
    required this.selectedTagId,
    required this.onChanged,
  });

  final String selectedTagId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Resolve aliases so legacy ids map onto a live pill.
    final resolvedId = TransactionTag.getTagById(selectedTagId).id;

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final tag in TransactionTag.tags)
          _TagPill(
            tag: tag,
            selected: tag.id == resolvedId,
            onTap: () => onChanged(tag.id),
          ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  final TransactionTag tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return Material(
      color: selected ? colors.secondaryContainer : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.primary : colors.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tag.icon, size: 15, color: selected ? tag.color : fg),
              const SizedBox(width: 6),
              Text(
                tag.name,
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
