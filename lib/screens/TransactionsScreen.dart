import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../controllers/TransactionController.dart';
import 'CreateTransactionScreen.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          DisplayCard(),
          // buildFloatingActionButton((){
          //  showFormDialog(context);
          // }, 'Add Transaction'),
          Expanded(child: GetX<TransactionController>(builder: (controller) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: controller.transactionList.length,
                itemBuilder: (context, index) {
                  var transactionList = controller.transactionList;
                  return TransactionCard(transaction: transactionList[index]);
                });
          }),
          ),
        ],
      );
  }
}
