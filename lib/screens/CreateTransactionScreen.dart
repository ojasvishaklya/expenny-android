import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/PaymentMethod.dart';
import 'package:journal/widgets/ScreenHeaderWidget.dart';

import '../controllers/TransactionController.dart';
import '../models/Transaction.dart';
import '../widgets/TagSelectorWidget.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Transaction _transaction = Transaction.defaults();
  bool _paymentMethod = true;
  late String selectedTagId;

  late TransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransactionController>();
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
      border: InputBorder.none,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('saving form');
      _controller.addTransaction(_transaction);
    } else {
      print('error in form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar(),
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 16.0, right: 16, left: 16, top: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ScreenHeaderWidget(text: 'Create Transaction'),
            SingleChildScrollView(
              child: Form(
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
                          child: buildIsExpenseInput(),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    TagSelectorWidget(
                      updateTransactionTag: updateTransactionTag,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
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
                  child: Text('Submit'),
                ),
              ],
            )
          ],
        ),
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

  Switch buildIsExpenseInput() {
    return Switch(
      value: _transaction.isExpense,
      onChanged: (value) {
        setState(() {
          _transaction.isExpense = value;
        });
      },
    );
  }

  ToggleButtons buildPaymentMethodInput() {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          _paymentMethod = index == 0;
          _transaction.paymentMethod =
              index == 0 ? PaymentMethod.CASH.name : PaymentMethod.ONLINE.name;
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      isSelected: [_paymentMethod, !_paymentMethod],
      children: <Widget>[
        TextIconWidget(
          text: PaymentMethod.CASH.name,
          icon: Icons.money,
        ),
        TextIconWidget(
          text: PaymentMethod.ONLINE.name,
          icon: Icons.credit_card,
        ),
      ],
    );
  }

  TextFormField buildDescriptionInput() {
    return TextFormField(
      initialValue: _transaction.description,
      decoration: textFormFieldDecoration(
          labelText: 'Description', hintText: 'Transaction description',icon: Icons.description),
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
      initialValue: _transaction.amount.toString(),
      decoration: textFormFieldDecoration(
          labelText: 'Amount', hintText: 'Transaction amount',icon: Icons.numbers),
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
          _transaction.setAmount(double.tryParse(value)!);
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

class TextIconWidget extends StatelessWidget {
  final String text;
  final IconData icon;

  const TextIconWidget({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10), child: Text(text)),
          Icon(icon),
        ],
      ),
    );
  }
}
