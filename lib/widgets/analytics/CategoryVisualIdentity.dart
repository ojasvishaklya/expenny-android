import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';

/// The icon and colour a category is drawn with across the dashboard.
///
/// Shared so the ranked breakdown list and the segmented budget bar tint a
/// given category identically, rather than each re-deriving the tag lookup and
/// colour. A single source of truth keeps the two surfaces speaking the same
/// visual language.
class CategoryVisualIdentity {
  const CategoryVisualIdentity(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// Resolves the visual identity for [group].
///
/// The synthetic `Other` bucket has no single tag, so it takes a neutral theme
/// colour and a generic icon. A named group holds exactly one tag; its tag
/// supplies the icon and colour, with a defensive fall-back to the first id
/// rather than throwing if that invariant ever stops holding.
CategoryVisualIdentity categoryIdentityFor(
  CategoryGroup group,
  ColorScheme colors,
) {
  if (group.isOther) {
    return CategoryVisualIdentity(Icons.more_horiz, colors.onSurfaceVariant);
  }
  final tag =
      TransactionTag.getTagById(group.singleTagId ?? group.tagIds.first);
  return CategoryVisualIdentity(tag.icon, tag.color);
}
