import 'dart:math';

import '../models/Transaction.dart';
import '../models/TransactionTag.dart';

class TransactionService {
  List<Transaction> generateMonthlyTransactions(
      DateTime currentDate, int monthsAgo) {
    List<Transaction> transactions = [];

    List<String> paymentMethods = ['Cash', 'Card/UPI'];
    Random random = Random();

    for (int i = 0; i < 12; i++) {
      final tag= TransactionTag.getRandomTag();
      String randomTagId = tag.id;

      double amount = random.nextInt(11001) - 1000;
      String paymentMethod = paymentMethods[i % paymentMethods.length];

      transactions.add(Transaction(
        id: null,
        date: DateTime(
          currentDate.year,
          currentDate.month - monthsAgo,
          currentDate.day - i,
          currentDate.hour,
          currentDate.minute,
        ),
        amount: amount,
        isExpense: amount<=0,
        isStarred: false,
        description: tag.name,
        tag: randomTagId,
        paymentMethod: paymentMethod,
      ));
    }

    return transactions;
  }

  List<Transaction> getTransactionList() {
    List<Transaction> transactions = [];
    DateTime currentDate = DateTime.now();

    for (int monthsAgo = 0; monthsAgo <= 6; monthsAgo++) {
      transactions += generateMonthlyTransactions(currentDate, monthsAgo);
    }
    return transactions;
  }
}
