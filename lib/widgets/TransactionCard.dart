import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String transactionName;
  final String money;
  final String expenseOrIncome;

  const TransactionCard({Key? key, 
    required this.transactionName,
    required this.money,
    required this.expenseOrIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        margin: EdgeInsets.symmetric(horizontal: 5),
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Center(
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(transactionName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    )),
              ],
            ),
            Column(
              children: [
                Text(DateTime.now().toIso8601String().substring(0,10)),
                SizedBox(height: 10,),
                Text(
                  (expenseOrIncome == 'expense' ? '-' : '+') + '\$' + money,
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:
                    expenseOrIncome == 'expense' ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}