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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Date'),
                  subtitle: Text(transaction.date.toString()),
                ),
                ListTile(
                  leading: Icon(transaction.isExpense
                      ? Icons.arrow_downward
                      : Icons.arrow_upward),
                  title: Text('Amount'),
                  subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                ),
                ListTile(
                  leading: Icon(
                    transaction.isStarred ? Icons.star : Icons.star_border,
                    color: transaction.isStarred
                        ? Colors.amber
                        : null, // Apply color if starred
                  ),
                  title: Text('Starred'),
                  subtitle: Text(transaction.isStarred ? 'Yes' : 'No'),
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Description'),
                  subtitle: Text(transaction.description),
                ),
                ListTile(
                  leading: Icon(Icons.label),
                  title: Text('Tag'),
                  subtitle: Chip(label: Text(transaction.tag)),
                ),
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Payment Method'),
                  subtitle: Text(transaction.paymentMethod),
                ),
              ],
            ),
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
                        context,
                        transaction.tag + 'transaction deleted',
                        Colors.redAccent);
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
                  Text(transaction.humanReadableDate()),
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
