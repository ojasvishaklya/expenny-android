/// Output of our validity-gated parser wrapper.
/// Maps from the package's TransactionInfo to our domain needs.
class ParseResult {
  final String type;           // 'debit' or 'credit'
  final double amount;         // transaction amount (always positive)
  final String? accountNumber; // last 4 digits
  final String? merchant;      // merchant name or UPI ID
  final String? referenceNo;   // transaction reference
  final double? availableBalance;

  const ParseResult({
    required this.type,
    required this.amount,
    this.accountNumber,
    this.merchant,
    this.referenceNo,
    this.availableBalance,
  });
}
