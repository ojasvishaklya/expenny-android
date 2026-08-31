import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/service/TransactionSortService.dart';

/// The selection made in the filter & sort sheet, handed back on Apply.
class TransactionFilterResult {
  const TransactionFilterResult({required this.sort, required this.tags});

  final TransactionSort sort;
  final Set<TransactionTag> tags;
}

/// A bottom sheet holding the full sort options and tag toggles, matching the
/// redesigned Transactions mockup. The controls-row chips are quick toggles for
/// the same [TransactionSort] state; this sheet mirrors the complete set and
/// adds tag filtering.
///
/// Selections are staged locally and only committed when Apply is tapped, at
/// which point [onApply] fires with the chosen sort and tag set and the sheet
/// is dismissed. The sheet reflects the current selection when opened.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    required this.initialSort,
    required this.initialTags,
    required this.onApply,
  });

  final TransactionSort initialSort;
  final Set<TransactionTag> initialTags;
  final void Function(TransactionFilterResult result) onApply;

  /// Presents the sheet via [showModalBottomSheet], invoking [onApply] when the
  /// user applies a selection.
  static Future<void> show(
    BuildContext context, {
    required TransactionSort sort,
    required Set<TransactionTag> tags,
    required void Function(TransactionFilterResult result) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => TransactionFilterSheet(
        initialSort: sort,
        initialTags: tags,
        onApply: onApply,
      ),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionSort _sort;
  late Set<TransactionTag> _tags;

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
    // Copy so staged toggles don't mutate the screen's set until Apply.
    _tags = {...widget.initialTags};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter & sort',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _SectionLabel('Sort by'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sort in TransactionSort.values)
                    ChoiceChip(
                      label: Text(sort.label),
                      selected: _sort == sort,
                      onSelected: (_) => setState(() => _sort = sort),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionLabel('Tags'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in TransactionTag.tags)
                    FilterChip(
                      avatar: Icon(tag.icon, size: 16),
                      label: Text(tag.name),
                      selected: _tags.contains(tag),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _tags.add(tag);
                        } else {
                          _tags.remove(tag);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(
                      TransactionFilterResult(sort: _sort, tags: {..._tags}),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
