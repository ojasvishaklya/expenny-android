import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/service/TransactionService.dart';

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

  void updateAlarm(Transaction transaction) {
    for (var element in transactionList) {
      if (element.id == transaction.id) {
        element = transaction;
      }
    }
    transactionList.refresh();
  }

  void deleteTransaction(Transaction transaction) async {
    await transactionRepository.deleteTransaction(transaction.id!);
    transactionList.removeWhere((item) => item.id == transaction.id);
    transactionList.refresh();
  }

  void addTransaction(Transaction transaction) async {
    await transactionRepository.insertTransaction(transaction);
    transactionList.add(transaction);
    transactionList.refresh();
  }
}
