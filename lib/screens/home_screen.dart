import 'package:flutter/material.dart';
import 'package:journal/constants/constants.dart';
import 'package:journal/widgets/AppBarWidget.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(() {}),
      appBar: buildAppBar(homePage),
      body: Column(
        children: const [
          DisplayCard(balance: '5000', expense: '1000', income: '4000'),
          TransactionCard(
              transactionName: 'Gym fee \nbeen converted by now?',
              money: '4500',
              expenseOrIncome: 'expense'),
          TransactionCard(
              transactionName: 'metro card recharge',
              money: '500',
              expenseOrIncome: 'expense')
        ],
      ),
    );
  }
}
