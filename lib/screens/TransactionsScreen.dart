import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/service/DateService.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../controllers/TransactionController.dart';
import '../widgets/FetchMoreButtonWidget.dart';
import '../widgets/LoadingWidget.dart';

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
                if (controller.transactionList.isEmpty) {
                  return LoadingWidget(animationName: 'home_screen_loader');
                }
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: controller.transactionList.length + 1,
                    itemBuilder: (context, index) {
                      List<Transaction> transactionList =
                          controller.transactionList;
                      if (index == transactionList.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 60.0, horizontal: 60),
                          child: buildFetchMoreButton(
                              context: context,
                              text: 'Fetch transactions for previous month',
                              onTap: () async {
                                final lastTransaction =
                                    transactionList[index - 1];
                                final newList = await controller
                                    .getTransactionsBetweenDates(
                                        startDate: DateTime(
                                            lastTransaction.date.year,
                                            lastTransaction.date.month-1,
                                            1),
                                        endDate: DateTime(
                                            lastTransaction.date.year,
                                            lastTransaction.date.month,
                                            0),
                                        tagSet: null);
                                controller.addMultipleTransactionsToUI(newList);
                              }),
                        );
                      }
                      Transaction currentTransaction = transactionList[index];

                      bool isFirstItem = index == 0;
                      bool isDifferentMonth = !isFirstItem &&
                          transactionList[index - 1].date.month !=
                              currentTransaction.date.month;

                      List<Widget> children = [];

                      if (isFirstItem || isDifferentMonth) {
                        children.add(
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            width: 150,
                            child: Center(
                              child: Text(
                                DateService.getFormattedPeriodString(
                                    currentTransaction.date),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        );
                      }
                      children.add(
                          TransactionCard(transaction: currentTransaction));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      );
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
