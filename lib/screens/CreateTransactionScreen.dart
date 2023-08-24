import 'package:flutter/material.dart';
import 'package:journal/models/PaymentMethod.dart';

import '../models/Transaction.dart';
import '../widgets/TagSelectorWidget.dart';

showFormDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(5.0), // Customize the corner radius
        ),
        content: CreateTransactionScreen(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}

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
  Set<String> selectedTagIds = <String>{};

  updateTransactionTags(Set<String> selectedTagIds) {
    List<String> tags = [];

    for (String tagId in selectedTagIds) {
      tags.add(tagId);
    }

    // setState(() {
    //   _transaction.tags = tags;
    // });
  }

  textFormFieldDecoration(
      {labelText = 'labelText',
      icon = Icons.info_outline,
      hintText = 'hintText'}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      // prefixIcon: Icon(icon),
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
      // Form validation succeeded, perform form submission logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              updateTransactionTags: updateTransactionTags,
            ),
            buildPaymentMethodInput(),
            Spacer(),
            Text(_transaction.toString()),
          ],
        ),
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
