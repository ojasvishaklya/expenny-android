class Transaction {
  final int? id; // ID from SQFlite
  final DateTime date;
  final double amount;
  final String description;
  final List<String> tags; // Changed from String to List<String>
  final String paymentMethod;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.tags,
    required this.paymentMethod,
  });

  // Convert Transaction object to a map (JSON representation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'tags': tags, // Updated key to 'tags'
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
      // Parsing as a List<String>
      paymentMethod: json['paymentMethod'],
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, date: $date, amount: $amount, description: $description, tags: $tags, paymentMethod: $paymentMethod}';
  }
}
