class Transaction {
  int? id; // ID from SQFlite
  DateTime date;
  double amount;
  String description;
  List<String> tags;
  String paymentMethod;

  // Default constructor
  Transaction({
    this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.tags,
    required this.paymentMethod,
  });

  // Named constructor to create a Transaction with default values
  Transaction.defaults()
      : id = null,
        date = DateTime.now(),
        amount = 0.0,
        description = '',
        tags = [],
        paymentMethod = 'CASH';

  // Convert Transaction object to a map (JSON representation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }

  // Create Transaction object from a map (JSON representation)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      paymentMethod: json['paymentMethod'],
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, date: $date, amount: $amount, description: $description, tags: $tags, paymentMethod: $paymentMethod}';
  }
}
