import '../models/Transaction.dart';
import '../models/TransactionTag.dart';

class TransactionService {
  Future<List<Transaction>> getTransactionList() async {
    // await Future.delayed(Duration(seconds: 2));

    List<Transaction> dummyTransactions = [
      Transaction(
        id: 1,
        date: DateTime(2023, 8, 15),
        amount: 25,
        description: 'Lunch at a restaurant',
        tags: [TransactionTag.getRandomTagId()],
        paymentMethod: 'Credit Card',
      ),
      Transaction(
        id: 2,
        date: DateTime(2023, 8, 16),
        amount: 10,
        description: 'Movie ticket',
        tags: [TransactionTag.getRandomTagId()],
        paymentMethod: 'Cash',
      ),
      Transaction(
        id: 3,
        date: DateTime(2023, 8, 17),
        amount: -50.0,
        description: 'Groceries',
        tags: [TransactionTag.getRandomTagId()],
        paymentMethod: 'Debit Card',
      ),
      Transaction(
        id: 4,
        date: DateTime(2023, 8, 18),
        amount: 8,
        description: 'Coffee',
        tags: [TransactionTag.getRandomTagId()],
        paymentMethod: 'Cash',
      ),
      Transaction(
        id: 5,
        date: DateTime(2023, 8, 18),
        amount: -30.0,
        description: 'Taxi ride',
        tags: [TransactionTag.getRandomTagId()],
        paymentMethod: 'Credit Card',
      ),
    ];
    return dummyTransactions + dummyTransactions + dummyTransactions;
  }
}
