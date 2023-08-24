import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/service/TransactionService.dart';

class TransactionController extends GetxController {
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

  final TransactionService _transactionService = TransactionService();

  @override
  void onInit() async {
    super.onInit();
    transactionList.value = await _transactionService.getTransactionList();
  }

  void updateAlarm(Transaction transaction) {
    for (var element in transactionList) {
      if (element.id == transaction.id) {
        element = transaction;
      }
    }
    transactionList.refresh();
  }

  void deleteAlarm(Transaction transaction) {
    transactionList.removeWhere((item) => item.id == transaction.id);
    transactionList.refresh();
  }

  void addTransaction(Transaction transaction) {
    transactionList.add(transaction);
    transactionList.refresh();
  }
}
