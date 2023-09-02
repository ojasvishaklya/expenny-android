import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/PaymentMethod.dart';
import 'package:journal/widgets/ScreenHeaderWidget.dart';

import '../controllers/TransactionController.dart';
import '../models/Transaction.dart';
import '../widgets/AppBarWidget.dart';
import '../widgets/PopupWidget.dart';
import '../widgets/TagSelectorWidget.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Transaction _transaction = Get.arguments as Transaction;
  late String selectedTagId = _transaction.tag;
  late bool isNewTransaction;

  late TransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransactionController>();
    isNewTransaction = _transaction.id == null;
  }

  updateTransactionTag(String selectedTagId) {
    setState(() {
      _transaction.tag = selectedTagId;
    });
  }

  textFormFieldDecoration(
      {labelText = 'labelText',
      icon = Icons.info_outline,
      hintText = 'hintText'}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).hoverColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _controller.addTransaction(_transaction);
      if (isNewTransaction) {
        showSnackBar(
            context: context,
            textContent: 'Transaction created',
            color: Colors.green);
      } else {
        showSnackBar(
            context: context,
            textContent: 'Transaction updated',
            color: Colors.orange);
      }
    } else {
      print('error in form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
          actions: isNewTransaction
              ? [Container()]
              : [buildTransactionDeleteButton(context)]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ScreenHeaderWidget(
                  text: isNewTransaction
                      ? 'Create Transaction'
                      : 'Update Transaction'),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: buildDescriptionInput(),
                        ),
                        Expanded(
                          flex: 1,
                          child: buildIsStarredInput(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: buildAmountInput(),
                        ),
                        Expanded(
                          flex: 1,
                          child: buildDatePicker(context),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _transaction.isExpense = true;
                            });
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              // color: Theme.of(context).hoverColor,
                              border: Border.all(
                                color: _transaction.isExpense
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the BorderRadius
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _transaction.isExpense
                                      ? Colors.redAccent
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8.0),
                                Text('Expense'),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _transaction.isExpense = false;
                            });
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: !_transaction.isExpense
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the BorderRadius
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: !_transaction.isExpense
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8.0),
                                Text('Income'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _transaction.paymentMethod =
                                  PaymentMethod.CASH.name;
                            });
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              // color: Theme.of(context).hoverColor,
                              border: Border.all(
                                color: _transaction.paymentMethod ==
                                        PaymentMethod.CASH.name
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the BorderRadius
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.money,
                                  color: _transaction.paymentMethod ==
                                          PaymentMethod.CASH.name
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8.0),
                                Text('Cash'),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _transaction.paymentMethod =
                                  PaymentMethod.ONLINE.name;
                            });
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _transaction.paymentMethod ==
                                        PaymentMethod.ONLINE.name
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the BorderRadius
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: _transaction.paymentMethod ==
                                          PaymentMethod.ONLINE.name
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8.0),
                                Text('Online'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TagSelectorWidget(
                      updateTransactionTag: updateTransactionTag,
                      transaction: _transaction,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm();
                      Navigator.of(context).pop();
                    },
                    child: Text(isNewTransaction ? 'Create' : 'Update'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  IconButton buildTransactionDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        showAlert(
          context: context,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to delete this transaction?',
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 16.0),
                  // Add spacing between the message and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 16.0), // Add spacing between the buttons
                      TextButton(
                        onPressed: () {
                          _controller.deleteTransaction(_transaction);
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context).pop(); // Close update screen
                          showSnackBar(
                              context: context,
                              textContent:
                                  _transaction.tag + ' transaction deleted',
                              color: Colors.redAccent);
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      icon: Icon(
        Icons.delete,
      ),
    );
  }

  IconButton buildIsStarredInput() {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: _transaction.isStarred ? Colors.amber : null,
      ),
      onPressed: () {
        setState(() {
          _transaction.isStarred = !_transaction.isStarred;
        });
      },
    );
  }

  TextFormField buildDescriptionInput() {
    return TextFormField(
      initialValue: _transaction.description,
      decoration: textFormFieldDecoration(
          labelText: 'Description',
          hintText: 'Transaction description',
          icon: Icons.description),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        } else if (value.length > 40) {
          return 'Description must not exceed 40 characters';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _transaction.description = value;
        });
      },
    );
  }

  TextFormField buildAmountInput() {
    return TextFormField(
      initialValue:
          isNewTransaction ? null : _transaction.amount.abs().toString(),
      decoration: textFormFieldDecoration(
          labelText: 'Amount',
          hintText: 'Transaction amount',
          icon: Icons.numbers),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount.';
        }
        double? amount = double.tryParse(value);
        if (amount == null || amount < 0) {
          return 'Amount must be a positive number.';
        }
        return null; // Return null if the input is valid
      },
      onChanged: (value) {
        setState(() {
          _transaction.amount = double.tryParse(value)!;
        });
      },
    );
  }

  IconButton buildDatePicker(BuildContext context) {
    return IconButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              _transaction.date = pickedDate;
            });
          }
        },
        icon: Icon(Icons.calendar_today));
  }
}
