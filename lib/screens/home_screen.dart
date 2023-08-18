import 'package:flutter/material.dart';
import 'package:journal/components/display_card.dart';
import 'package:journal/components/floating_button.dart';
import 'package:journal/components/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[500],
        onPressed: () {},
        child: const FloatingButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            DisplayCard(balance: ' 5000', expense: ' 2000', income: ' 3000'),
            Expanded(
              child: Container(
                child: Center(
                  child: Column(
                    children: const [
                      SizedBox(
                        height: 20,
                      ),
                      TransactionCard(
                        transactionName: "Transaction A",
                        money: '1000',
                        expenseOrIncome: 'expense',
                      ),
                      TransactionCard(
                        transactionName: "Transaction A",
                        money: '1000',
                        expenseOrIncome: 'expense',
                      ),
                      TransactionCard(
                        transactionName: "Transaction A",
                        money: '1000',
                        expenseOrIncome: '',
                      ),
                      TransactionCard(
                        transactionName: "Transaction A",
                        money: '1000',
                        expenseOrIncome: '',
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
