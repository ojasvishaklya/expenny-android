import 'dart:io';

import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/TransactionController.dart';

class DataServiceResponse {
  bool isError;
  String response;

  DataServiceResponse({required this.isError, required this.response});
}

class DataService {
  final _controller = Get.find<TransactionController>();

  Future<DataServiceResponse> exportToExcel() async {
    try {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        return DataServiceResponse(
            isError: true, response: 'Storage permission is required');
      }

      final transactionList =
          await _controller.getTransactionsBetweenDates(tagSet: null);

      if (transactionList.isEmpty) {
        return DataServiceResponse(
            isError: true, response: 'There are no transactions');
      }
      Directory? destinationFolder = Directory('/storage/emulated/0/Download');

      // Create a new Excel file
      final excel = Excel.createExcel();

      // Add a worksheet
      final sheet = excel['Sheet1'];

      // Add headers to the Excel sheet
      sheet.cell(CellIndex.indexByString("A1")).value = "ID";
      sheet.cell(CellIndex.indexByString("B1")).value = "Date";
      sheet.cell(CellIndex.indexByString("C1")).value = "Amount";
      sheet.cell(CellIndex.indexByString("D1")).value = "Is Expense";
      sheet.cell(CellIndex.indexByString("E1")).value = "Is Starred";
      sheet.cell(CellIndex.indexByString("F1")).value = "Description";
      sheet.cell(CellIndex.indexByString("G1")).value = "Tag";
      sheet.cell(CellIndex.indexByString("H1")).value = "Payment Method";

      // Add data from the list of transactions to the Excel sheet
      for (int i = 0; i < transactionList.length; i++) {
        final transaction = transactionList[i];
        sheet.cell(CellIndex.indexByString("A${i + 2}")).value = transaction.id;
        sheet.cell(CellIndex.indexByString("B${i + 2}")).value =
            transaction.date.toLocal().toString();
        sheet.cell(CellIndex.indexByString("C${i + 2}")).value =
            transaction.amount;
        sheet.cell(CellIndex.indexByString("D${i + 2}")).value =
            transaction.isExpense ? "Yes" : "No";
        sheet.cell(CellIndex.indexByString("E${i + 2}")).value =
            transaction.isStarred ? "Yes" : "No";
        sheet.cell(CellIndex.indexByString("F${i + 2}")).value =
            transaction.description;
        sheet.cell(CellIndex.indexByString("G${i + 2}")).value =
            transaction.tag;
        sheet.cell(CellIndex.indexByString("H${i + 2}")).value =
            transaction.paymentMethod;
        // Add more columns as needed
      }

      // Save the Excel file to the selected destination folder
      final excelFile = File('${destinationFolder.path}/transaction_data.xlsx');
      await excelFile.writeAsBytes(excel.encode()!);

      // Provide feedback to the user
      return DataServiceResponse(
          isError: false,
          response: 'Excel file exported to the downloads folder');
    } catch (e) {
      print('Error exporting to Excel: $e');
      return DataServiceResponse(
          isError: true, response: 'Error exporting to Excel: $e');
    }
  }

  deleteAllTransactions() async {
    try {
      _controller.deleteAllTransactions();
      return DataServiceResponse(
          isError: false, response: 'All transactions deleted');
    } catch (e) {
      return DataServiceResponse(
          isError: true, response: 'Error deleting transactions: $e');
    }
  }
}
