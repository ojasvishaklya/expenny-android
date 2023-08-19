import 'package:flutter/material.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(transaction);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          color: Colors.black45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Center(
                    child: Icon(
                      TransactionTag.getTagById(transaction.tags.first).icon,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(transaction.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
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
