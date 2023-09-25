import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';
import 'package:journal/service/DateService.dart';

import '../constants/routes.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteClass.createTransaction, arguments: transaction);
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
                  Text(DateService.humanReadableDate(transaction.date)),
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
