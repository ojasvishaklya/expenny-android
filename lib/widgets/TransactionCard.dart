import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';
import 'package:journal/widgets/PopupWidget.dart';

import '../controllers/TransactionController.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final _controller = Get.find<TransactionController>();

  TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () {
          print(transaction);
        },
        onLongPress: () {
          showAlert(context, transaction, [
            Text(transaction.toString()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _controller.deleteTransaction(transaction);
                    Navigator.of(context).pop();
                    showSnackBar(
                        context, transaction.tag + 'transaction deleted', Colors.redAccent);
                  },
                  child: Text('Delete'),
                ),
              ],
            )
          ]);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(10), // Adjust the radius value as needed
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Center(
                    child: Icon(
                      TransactionTag.getTagById(transaction.tag).icon,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(transaction.description,
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ],
              ),
              Column(
                children: [
                  Text(DateTime.now().toIso8601String().substring(0, 10)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    transaction.amount.toString(),
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transaction.amount < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
