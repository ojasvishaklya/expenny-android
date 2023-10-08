import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenny/controllers/TransactionController.dart';
import 'package:expenny/service/DateService.dart';

class DisplayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<TransactionController>(builder: (controller) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Text('B A L A N C E', style: TextStyle(fontSize: 14)),
          Text(
            controller.balance.toString(),
            style: TextStyle(fontSize: 32),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Income'),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.income.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expense'),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.expense.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
