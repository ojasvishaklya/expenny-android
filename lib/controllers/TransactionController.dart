import 'package:get/get.dart';
import 'package:expenny/models/Transaction.dart';

import '../models/TransactionTag.dart';
import '../repository/TransactionRepository.dart';
import '../service/TransactionService.dart';

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
    final date = DateTime.now();

    // fetching current months transactions only
    transactionList.value = await getTransactionsBetweenDates(
        startDate: DateTime(date.year, date.month, 1),
        endDate: DateTime(date.year, date.month + 1, 0),
        tagSet: null);
  }

  void insertRandomData() {
    TransactionService().getTransactionList().forEach((element) async {
      await transactionRepository.insertTransaction(element);
    });
  }

  Future<List<Transaction>> searchTransaction(String searchString) async {
    return await transactionRepository.getTransactionsRawQuery('''
    SELECT * FROM tableName
    WHERE description LIKE ?
  ''', ['%$searchString%']);
  }

  Future<List<Transaction>> getTransactionsBetweenDates({
    DateTime? startDate, // older date
    DateTime? endDate, // newer date
    String? searchString,
    required Set<TransactionTag>? tagSet,
  }) async {
    String sqlQuery = 'SELECT * FROM tableName WHERE 1=1';
    List<dynamic> params = [];

    if (startDate != null && endDate != null) {
      sqlQuery += ' AND date BETWEEN ? AND ?';
      params.add(startDate.toIso8601String());
      params.add(endDate.toIso8601String());
    }

    if (searchString != null && searchString.isNotEmpty) {
      // Search with description matching searchString
      sqlQuery += ' AND Description LIKE ?';
      searchString = '%$searchString%';
      params.add(searchString);
    }

    List<Transaction> transactions =
        await transactionRepository.getTransactionsRawQuery(sqlQuery, params);
    if (tagSet == null || tagSet.isEmpty) {
      return transactions;
    }
    return transactions
        .where((transaction) =>
            tagSet.contains(TransactionTag.getTagById(transaction.tag)))
        .toList();
  }

  void deleteTransaction(Transaction transaction) async {
    await transactionRepository.deleteTransaction(transaction.id!);
    transactionList.removeWhere((item) => item.id == transaction.id);
    refreshTransactionList();
  }

  void deleteAllTransactions() async {
    await transactionRepository.deleteAllTransactions();
    transactionList.value = await transactionRepository.getTransactions();
    refreshTransactionList();
  }

  void addTransaction(Transaction transaction) async {
    transaction.setAmount(transaction.amount);
    transaction.id = await transactionRepository.insertTransaction(transaction);

    int existingIndex =
        transactionList.indexWhere((existing) => existing.id == transaction.id);

    if (existingIndex != -1) {
      transactionList.removeAt(existingIndex);
    }
    transactionList.add(transaction);
    refreshTransactionList();
  }

  addMultipleTransactionsToUI(List<Transaction> transactions){
    transactionList+=transactions;
    refreshTransactionList();
  }
  void refreshTransactionList() {
    transactionList.sort((a, b) => b.date.compareTo(a.date));
    transactionList.refresh();
  }
}
