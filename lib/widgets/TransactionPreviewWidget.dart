import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';

import '../constants/routes.dart';
import '../controllers/TransactionController.dart';
import 'PopupWidget.dart';

List<Flex> buildTransactionPreview(
    BuildContext context, Transaction transaction) {
  final _controller = Get.find<TransactionController>();
  print(transaction);
  return [
    Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomListTile(
                iconData: TransactionTag.getTagById(transaction.tag).icon,
                text: transaction.description,
                onTap: () {},
                flex: 3),
            Expanded(
              flex: 1,
              child: Icon(
                transaction.isStarred ? Icons.star : Icons.star_border,
                color: transaction.isStarred
                    ? Colors.amber
                    : null, // Apply color if starred
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomListTile(
                iconData: Icons.calendar_today,
                text: transaction.humanReadableDate(),
                onTap: () {},
                flex: 1),
            CustomListTile(
                iconData: transaction.isExpense
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                text: transaction.amount.toString(),
                onTap: () {},
                flex: 1),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed(RouteClass.createTransaction,
                    arguments: transaction);
              },
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _controller.deleteTransaction(transaction);
                Navigator.of(context).pop();
                showSnackBar(context, transaction.tag + 'transaction deleted',
                    Colors.redAccent);
              },
              child: Text('Delete'),
            ),
          ],
        ),
      ],
    ),
  ];
}

class CustomListTile extends StatelessWidget {
  CustomListTile(
      {Key? key,
      required this.iconData,
      required this.text,
      required this.onTap,
      required this.flex})
      : super(key: key);

  IconData iconData;
  String text;
  Function() onTap;
  int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(iconData),
            SizedBox(
              width: 10,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
