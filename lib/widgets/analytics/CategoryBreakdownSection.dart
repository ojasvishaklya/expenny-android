import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Where the month's money went, as a compact ranked list.
///
/// Each row echoes a Transactions-ledger row — a tag-tinted icon tile, the
/// category name over a thin share bar, and the amount above its percentage —
/// so the dashboard and the ledger read as one language. Rows are ordered
/// highest spend first, and the share bar is drawn relative to the largest
/// category so the leader fills the track.
///
/// The list is decorative for assistive tech: every group's label, amount, and
/// share is also written into one semantic summary on the section, so the
/// breakdown is fully readable without interpreting bar length or colour.
class CategoryBreakdownSection extends StatelessWidget {
  const CategoryBreakdownSection({super.key, required this.breakdown});

  final CategoryBreakdown breakdown;

  /// Icon and colour identity for a group. `Other` has no single tag, so it
  /// takes a neutral theme colour rather than a category identity.
  static _GroupIdentity identityFor(CategoryGroup group, ColorScheme colors) {
    if (group.isOther) {
      return _GroupIdentity(Icons.more_horiz, colors.onSurfaceVariant);
    }
    // A named group holds exactly one tag; fall back defensively rather than
    // throwing if that ever stops holding.
    final tag =
        TransactionTag.getTagById(group.singleTagId ?? group.tagIds.first);
    return _GroupIdentity(tag.icon, tag.color);
  }

  /// Share-bar fill fraction for [group], relative to the largest group.
  ///
  /// Groups are ordered highest first, so the leader always fills the track
  /// (fraction 1.0) and the rest are drawn in proportion to it. Returns 0 when
  /// there is nothing to scale against.
  static double barFraction(CategoryBreakdown breakdown, CategoryGroup group) {
    if (breakdown.groups.isEmpty) return 0;
    final max = breakdown.groups.first.percent;
    if (max <= 0) return 0;
    return (group.percent / max).clamp(0.0, 1.0);
  }

  /// The complete spoken equivalent of the list.
  static String semanticSummary(CategoryBreakdown breakdown) {
    final parts = breakdown.groups
        .map((group) => '${group.label}, ${formatRupees(group.amount)}, '
            '${formatPercent(group.percent)}');
    return 'Spending by category. ${parts.join('. ')}.';
  }

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return const AnalyticsSection(
        title: 'Spending by category',
        child: AnalyticsEmptyHint(
          message: 'No spending recorded this month.',
        ),
      );
    }

    return AnalyticsSection(
      title: 'Spending by category',
      semanticLabel: semanticSummary(breakdown),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < breakdown.groups.length; i++)
              _CategoryRow(
                group: breakdown.groups[i],
                fraction: barFraction(breakdown, breakdown.groups[i]),
                // The panel already frames the list, so the final row carries
                // no divider — dividers separate rows, they don't underline the
                // block.
                showDivider: i != breakdown.groups.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupIdentity {
  const _GroupIdentity(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// One ranked row: tag-tinted icon tile, name over a share bar, amount over
/// percentage. Mirrors the Transactions ledger row treatment.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.group,
    required this.fraction,
    required this.showDivider,
  });

  final CategoryGroup group;
  final double fraction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final identity = CategoryBreakdownSection.identityFor(group, colors);

    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outlineVariant))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _CategoryIconTile(color: identity.color, icon: identity.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  group.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _ShareBar(fraction: fraction, color: identity.color),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grouped amounts contain no break opportunities, so scale them
              // down within their slot rather than clipping or overflowing.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatRupees(group.amount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatPercent(group.percent),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The rounded 36px tile holding a category's icon, tinted with the tag colour
/// over a soft wash of the same hue — identical to the ledger's tile.
class _CategoryIconTile extends StatelessWidget {
  const _CategoryIconTile({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// A thin proportional share track: a low-contrast rail with a category-tinted
/// fill spanning [fraction] of the width.
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 4,
        color: colors.surfaceContainerHighest,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}
