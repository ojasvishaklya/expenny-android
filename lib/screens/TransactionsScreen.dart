import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../controllers/TransactionController.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            DisplayCard(),
            Expanded(
              child: GetX<TransactionController>(builder: (controller) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: controller.transactionList.length,
                    itemBuilder: (context, index) {
                      var transactionList = controller.transactionList;
                      return TransactionCard(
                          transaction: transactionList[index]);
                    });
              }),
            ),
          ],
        ),
        Positioned(
          // right: 16.0,
          bottom: 10,
          child: buildFloatingActionButton(() {
            Get.toNamed(RouteClass.createTransaction,
                arguments: Transaction.defaults());
          }, 'Add Transaction'),
        ),
      ],
    );
  }
}
