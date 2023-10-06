import 'package:flutter/material.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/service/AnalyticsService.dart';

import '../../models/TransactionTag.dart';

class TagTableWidget extends StatelessWidget {
  const TagTableWidget({
    Key? key,
    required List<Transaction> selectedTransactions,
  })  : _selectedTransactions = selectedTransactions,
        super(key: key);

  final List<Transaction> _selectedTransactions;

  @override
  Widget build(BuildContext context) {
    final aggregatedData =
        AnalyticsService.aggregateDataByTag(_selectedTransactions);

    return SizedBox(
      height: 250,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 10,
            columns: const [
              DataColumn(label: Text('Tag Name')),
              DataColumn(label: Text('Expense')),
              DataColumn(label: Text('Income')),
            ],
            rows: aggregatedData.map((e) {
              TransactionTag tag = e[0];
              return DataRow(
                cells: [
                  DataCell(Row(
                  children: [
                      Icon(tag.icon),
                      SizedBox(width: 20,),
                      Text(tag.name),
                    ],
                  )),
                  DataCell(Text(e[1].toString())),
                  DataCell(Text(e[2].toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}