import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';

import '../constants/routes.dart';

/// A single compact ledger row, matching the redesigned Transactions mockup:
/// a rounded category-icon tile tinted by the transaction's tag, the
/// description with a `Tag · PaymentMethod` meta line, and a right-aligned
/// signed amount above the time of day.
///
/// Tapping the row opens the transaction for editing, unchanged from before.
class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction})
      : super(key: key);

  /// Income green, expense red — driven by the signed amount so it always
  /// agrees with the leading `+`/`−` on the figure.
  static const Color _incomeColor = Color(0xFF2E7D32);
  static const Color _expenseColor = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = TransactionTag.getTagById(transaction.tag);
    final isIncome = transaction.amount >= 0;
    final amountColor = isIncome ? _incomeColor : _expenseColor;

    // formatRupees already prefixes '−' for negatives; add an explicit '+' for
    // income so the sign is unambiguous, matching the mockup's "+₹25,500".
    final amountText =
        '${isIncome ? '+' : ''}${formatRupees(transaction.amount)}';

    return InkWell(
      onTap: () {
        Get.toNamed(RouteClass.createTransaction, arguments: transaction);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _CategoryIconTile(color: tag.color, icon: tag.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.description.isEmpty
                        ? tag.name
                        : transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tag.name} · ${transaction.paymentMethod}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateService.formatTime(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The rounded 36px tile holding a tag's icon, tinted with the tag colour over
/// a soft wash of the same hue.
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
