import '../models/PaymentMethod.dart';
import '../models/Transaction.dart';

class TransactionService {
  Future<List<Transaction>> getTransactionList() async {
    // await Future.delayed(Duration(seconds: 2));

    List<Transaction> dummyTransactions = [
      Transaction(
        id: 1,
        date: DateTime(2023, 8, 15),
        amount: 150.0,
        description: 'Groceries',
        isExpense: true,
        isStarred: false,
        tag: 'grocery',
        paymentMethod: PaymentMethod.ONLINE.name,
      ),
      Transaction(
        id: 2,
        date: DateTime(2023, 8, 18),
        amount: 50.0,
        description: 'Gasoline',
        isExpense: true,
        isStarred: true,
        tag: 'transportation',
        paymentMethod: PaymentMethod.CASH.name,
      ),
      Transaction(
        id: 3,
        date: DateTime(2023, 8, 10),
        amount: 200.0,
        description: 'Salary',
        isExpense: false,
        isStarred: false,
        tag: 'salary',
        paymentMethod: PaymentMethod.ONLINE.name,
      )
    ];
    return dummyTransactions ;
  }
}
