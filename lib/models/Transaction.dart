import 'package:expenny/models/PaymentMethod.dart';

class Transaction {
  int? id;
  DateTime date;
  double amount;
  bool isExpense;
  bool isStarred;
  String description;
  String tag;
  String paymentMethod;
  String? smsId;       // SMS message ID for deduplication (null for manual)
  String? source;      // 'manual' | 'sms'
  String? bank;        // Bank/sender name from SMS (null for manual)
  String? rawSms;      // Original SMS body for user verification (null for manual)

  // Default constructor
  Transaction({
    this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.isExpense,
    required this.isStarred,
    required this.tag,
    required this.paymentMethod,
    this.smsId,
    this.source,
    this.bank,
    this.rawSms,
  });

  setAmount(double amount) {
    if (isExpense) {
      this.amount = -1 * amount.abs();
    } else {
      this.amount = amount;
    }
  }

  // Named constructor to create a Transaction with default values
  Transaction.defaults()
      : id = null,
        date = DateTime.now(),
        amount = 0.0,
        description = '',
        isStarred = false,
        isExpense = true,
        tag = 'miscellaneous',
        paymentMethod = PaymentMethod.CASH.name,
        smsId = null,
        source = 'manual',
        bank = null,
        rawSms = null;

  // Convert a JSON map to a Transaction object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      description: json['description'],
      isExpense: json['isExpense'],
      isStarred: json['isStarred'],
      tag: json['tag'],
      paymentMethod: json['paymentMethod'],
      smsId: json['smsId'],
      source: json['source'] ?? 'manual',
      bank: json['bank'],
      rawSms: json['rawSms'],
    );
  }

  // Convert a Transaction object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'isExpense': isExpense,
      'isStarred': isStarred,
      'tag': tag,
      'paymentMethod': paymentMethod,
      'smsId': smsId,
      'source': source,
      'bank': bank,
      'rawSms': rawSms,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'isStarred': isStarred ? 1 : 0,
      'description': description,
      'tag': tag,
      'paymentMethod': paymentMethod,
      'smsId': smsId,
      'source': source,
      'bank': bank,
      'rawSms': rawSms,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      isExpense: map['isExpense'] == 1,
      isStarred: map['isStarred'] == 1,
      description: map['description'],
      tag: map['tag'],
      paymentMethod: map['paymentMethod'],
      smsId: map['smsId'],
      source: map['source'] ?? 'manual',
      bank: map['bank'],
      rawSms: map['rawSms'],
    );
  }

  @override
  String toString() {
    return '''
{
  "id": $id,
  "date": "$date",
  "amount": $amount,
  "description": "$description",
  "isExpense": $isExpense,
  "isStarred": $isStarred,
  "tag": "$tag",
  "paymentMethod": "$paymentMethod",
  "smsId": "$smsId",
  "source": "$source",
  "bank": "$bank",
  "rawSms": "$rawSms"
}
    ''';
  }
}
