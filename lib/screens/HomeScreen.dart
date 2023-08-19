import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/Constants.dart';
import 'package:journal/widgets/AppBarWidget.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../constants/routes.dart';
import '../controllers/TransactionController.dart';
import '../models/Transaction.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final _transactionController = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(() {
        Get.toNamed(RouteClass.createTransaction,
            arguments: {'transaction': Transaction.defaults()});
      }, 'Add Transaction'),
      appBar: buildAppBar(homePage),
      body: Column(
        children: [
          DisplayCard(),
          Expanded(child: GetX<TransactionController>(builder: (controller) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _transactionController.transactionList.length,
                itemBuilder: (context, index) {
                  var transactionList = _transactionController.transactionList;
                  return TransactionCard(transaction: transactionList[index]);
                });
          }))
        ],
      ),
    );
  }
}
