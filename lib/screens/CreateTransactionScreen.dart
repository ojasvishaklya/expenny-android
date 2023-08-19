import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/Constants.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/widgets/AppBarWidget.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/FabWidget.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../controllers/TransactionController.dart';
import '../models/Transaction.dart';

class CreateTransactionScreen extends StatelessWidget {
  CreateTransactionScreen({Key? key}) : super(key: key);

  Transaction transaction = Get.arguments['transaction'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(() {
        Get.offNamed(RouteClass.home);
      },
      'Submit'),
      appBar: buildAppBar(homePage),
      body: TransactionForm()
    );

  }
}

class TransactionForm extends StatefulWidget {
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final Transaction _transaction = Transaction.defaults();
  DateTime _selectedDate = DateTime.now(); // Default to current date

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _transaction.date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Amount'),
            initialValue: _transaction.amount?.toString(),
            keyboardType: TextInputType.number,
            onSaved: (value) {
              // _transaction.amount = double.tryParse(value ?? '');
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Description'),
            initialValue: _transaction.description,
            onSaved: (value) {
              // _transaction.description = value;
            },
          ),
          // Repeat similar fields for other properties...
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Do something with the _transaction object
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
