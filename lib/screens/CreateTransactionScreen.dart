import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/PaymentMethod.dart';
import 'package:journal/widgets/AppBarWidget.dart';
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
  InputDecoration textFormFieldDecoration({
    labelText = 'labelText',
    icon = Icons.info_outline,
    hintText = 'hintText',
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      // prefixIcon: Icon(icon, color: Colors.blue),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.red),
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
        padding: const EdgeInsets.only(bottom: 16.0,right: 16,left: 16,top: 70),
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
                    buildDescriptionInput(),
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
                      height: 10,
                    ),
                    TagSelectorWidget(
                      updateTransactionTag: updateTransactionTag,
                    ),
                    buildPaymentMethodInput(),
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
                  },
                  child: Text('Submit'),
                ),
              ],
            )
          ],
        )
        ,
      ),
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
      decoration: textFormFieldDecoration(
          labelText: 'Description', hintText: 'Transaction description'),
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
      decoration: textFormFieldDecoration(
          labelText: 'Amount', hintText: 'Transaction amount'),
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

