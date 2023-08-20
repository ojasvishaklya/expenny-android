import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/widgets/AppBarWidget.dart';
import 'package:journal/widgets/FabWidget.dart';

import '../models/Transaction.dart';




class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  late DateTime selectedDate;
  late double amount;
  late String description;
  List<String> tags = [];
  late String paymentMethod;

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {

                return null;
              },
              onChanged: (value) {
                // amount = double.tryParse(value);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                // if (value.isEmpty) {
                //   return 'Please enter a description';
                // }
                return null;
              },
              onChanged: (value) {
                description = value;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Tags (comma-separated)'),
              onChanged: (value) {
                tags = value.split(',').map((tag) => tag.trim()).toList();
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Payment Method'),
              onChanged: (value) {
                paymentMethod = value;
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: (){},
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}





