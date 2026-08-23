import 'package:expenny/models/Transaction.dart';

/// The orderings the Transactions ledger can be sorted by.
///
/// This is net-new UX: the app previously only ever showed transactions
/// newest-first. Date orderings compare by timestamp; amount orderings compare
/// by **magnitude** (absolute value), so the biggest transactions — whether a
/// large income or a large expense — sort to the top under [highestAmount],
/// and the smallest to the top under [lowestAmount]. Sign is ignored so a
/// −₹5,000 expense correctly outranks a −₹100 one.
enum TransactionSort {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

/// Human-readable labels for each sort, matching the mockup's sheet chips.
extension TransactionSortLabel on TransactionSort {
  String get label {
    switch (this) {
      case TransactionSort.newestFirst:
        return 'Newest first';
      case TransactionSort.oldestFirst:
        return 'Oldest first';
      case TransactionSort.highestAmount:
        return 'Highest amount';
      case TransactionSort.lowestAmount:
        return 'Lowest amount';
    }
  }
}

/// Returns a **new** list of [transactions] ordered by [sort]; the input list
/// is never mutated.
///
/// Amount orderings use the signed amount, so a +₹25,500 salary sorts above a
/// −₹860 lunch under [TransactionSort.highestAmount]. Ties are broken so the
/// result is deterministic regardless of input order: amount ties fall back to
/// newest date first, and date ties fall back to highest signed amount first,
/// with a final id tiebreaker.
List<Transaction> sortTransactions(
  List<Transaction> transactions,
  TransactionSort sort,
) {
  final sorted = List<Transaction>.of(transactions);

  int byDateDesc(Transaction a, Transaction b) =>
      b.date.compareTo(a.date);
  int byAmountDesc(Transaction a, Transaction b) =>
      b.amount.compareTo(a.amount);
  // Amount orderings compare magnitude, not sign: since expenses are stored
  // negative, a raw signed compare would rank a small −₹100 expense above a
  // large −₹5,000 one. Comparing |amount| makes "Highest" the biggest
  // transactions (income or expense) and "Lowest" the smallest.
  int byMagnitudeDesc(Transaction a, Transaction b) =>
      b.amount.abs().compareTo(a.amount.abs());
  int byMagnitudeAsc(Transaction a, Transaction b) =>
      a.amount.abs().compareTo(b.amount.abs());
  int byId(Transaction a, Transaction b) =>
      (a.id ?? 0).compareTo(b.id ?? 0);

  int compare(Transaction a, Transaction b) {
    int result;
    switch (sort) {
      case TransactionSort.newestFirst:
        result = byDateDesc(a, b);
        if (result == 0) result = byAmountDesc(a, b);
        break;
      case TransactionSort.oldestFirst:
        result = a.date.compareTo(b.date);
        if (result == 0) result = byAmountDesc(a, b);
        break;
      case TransactionSort.highestAmount:
        result = byMagnitudeDesc(a, b);
        if (result == 0) result = byDateDesc(a, b);
        break;
      case TransactionSort.lowestAmount:
        result = byMagnitudeAsc(a, b);
        if (result == 0) result = byDateDesc(a, b);
        break;
    }
    if (result == 0) result = byId(a, b);
    return result;
  }

  sorted.sort(compare);
  return sorted;
}
