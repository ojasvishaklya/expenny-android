import 'package:transaction_sms_parser/transaction_sms_parser.dart';

import '../models/ParseResult.dart';

/// Thin wrapper around the transaction_sms_parser package.
/// Applies a validity gate on the package output and maps to our ParseResult model.
/// No regex logic of its own — delegates all parsing to the package.
class SmsParserService {
  /// Parses a raw SMS body into structured transaction data.
  /// Returns null if the package output fails the validity gate
  /// (transaction type is null OR amount is null OR amount <= 0).
  ParseResult? parse(String body) {
    if (body.trim().isEmpty) return null;

    final info = TransactionEngine.getTransactionInfo(body);

    // Validity gate: type and amount must both be present
    final txnType = info.transaction.type;
    final amountStr = info.transaction.amount;

    if (txnType == null || amountStr == null) return null;

    final amount = double.tryParse(amountStr.replaceAll(',', ''));
    if (amount == null || amount <= 0) return null;

    final type = txnType == TransactionType.debit ? 'debit' : 'credit';

    double? availableBalance;
    if (info.balance?.available != null) {
      availableBalance = double.tryParse(
        info.balance!.available!.replaceAll(',', ''),
      );
    }

    return ParseResult(
      type: type,
      amount: amount,
      accountNumber: info.account.number,
      merchant: info.transaction.merchant,
      referenceNo: info.transaction.referenceNo,
      availableBalance: availableBalance,
    );
  }
}
