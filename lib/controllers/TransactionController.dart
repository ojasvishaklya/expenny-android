import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';

import '../repository/TransactionRepository.dart';

class TransactionController extends GetxController {
  final TransactionRepository transactionRepository;

  TransactionController(this.transactionRepository);

  var transactionList = List<Transaction>.empty().obs;

  double get balance =>
      transactionList.fold(0, (sum, transaction) => sum + transaction.amount);

  double get income => transactionList.fold(0, (sum, transaction) {
        if (transaction.amount > 0) return sum + transaction.amount;
        return sum;
      });

  double get expense => transactionList.fold(0, (sum, transaction) {
        if (transaction.amount <= 0) return sum + transaction.amount;
        return sum;
      });

  @override
  void onInit() async {
    super.onInit();
    transactionList.value = await transactionRepository.getTransactions();
  }


  void deleteTransaction(Transaction transaction) async {
    await transactionRepository.deleteTransaction(transaction.id!);
    transactionList.removeWhere((item) => item.id == transaction.id);
    refreshTransactionList();
  }

  void addTransaction(Transaction transaction) async {
    transaction.setAmount(transaction.amount);
    transaction.id = await transactionRepository.insertTransaction(transaction);

    int existingIndex = transactionList.indexWhere((existing) => existing.id == transaction.id);

    if (existingIndex != -1) {
      transactionList.removeAt(existingIndex);
    }
    print(transaction);
    transactionList.add(transaction);
    refreshTransactionList();
  }

  void refreshTransactionList(){
    transactionList.sort((a, b) => b.date.compareTo(a.date));
    transactionList.refresh();
  }
}
