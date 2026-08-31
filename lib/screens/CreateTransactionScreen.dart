import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/TransactionController.dart';
import '../models/Transaction.dart';
import '../widgets/AmountHeroField.dart';
import '../widgets/DateChip.dart';
import '../widgets/OriginalSmsCard.dart';
import '../widgets/PaymentMethodChips.dart';
import '../widgets/PopupWidget.dart';
import '../widgets/SaveBar.dart';
import '../widgets/SignToggle.dart';
import '../widgets/TagPicker.dart';

/// Create / edit a transaction.
///
/// One screen, two renderings off [_isNewTransaction]: a new entry uses the
/// flat, amount-first layout; an edit uses card-grouped sections and — for an
/// SMS-imported transaction — shows the original message. Both share the same
/// building-block widgets and the same save/validation logic.
class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Transaction _transaction = Get.arguments as Transaction;
  late final TransactionController _controller;
  late final bool _isNewTransaction;

  /// The entered magnitude (always non-negative); signed on save.
  double? _amount;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransactionController>();
    _isNewTransaction = _transaction.id == null;
    _amount = _isNewTransaction ? null : _transaction.amount.abs();
  }

  bool get _hasSms =>
      _transaction.rawSms != null && _transaction.rawSms!.isNotEmpty;

  void _submit() {
    final descriptionValid = _formKey.currentState?.validate() ?? false;
    final amountValid = _amount != null && _amount! > 0;
    if (!amountValid) {
      setState(() => _amountError = 'Enter an amount greater than zero');
    }
    if (!descriptionValid || !amountValid) return;

    // setAmount signs the magnitude by the current isExpense flag.
    _transaction.setAmount(_amount!);
    _controller.addTransaction(_transaction);

    showSnackBar(
      context: context,
      textContent:
          _isNewTransaction ? 'Transaction created' : 'Transaction updated',
      color: _isNewTransaction ? Colors.green : Colors.orange,
    );
    Navigator.of(context).pop();
  }

  void _confirmDelete() {
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
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: () {
                      _controller.deleteTransaction(_transaction);
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // close screen
                      showSnackBar(
                        context: context,
                        textContent: '${_transaction.tag} transaction deleted',
                        color: Colors.redAccent,
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewTransaction ? 'New transaction' : 'Edit transaction'),
        actions: [
          IconButton(
            tooltip: 'Star',
            icon: Icon(
              Icons.star,
              color: _transaction.isStarred ? Colors.amber : null,
            ),
            onPressed: () => setState(
                () => _transaction.isStarred = !_transaction.isStarred),
          ),
          if (!_isNewTransaction)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _amountAndSign(),
                  const SizedBox(height: 8),
                  if (_isNewTransaction) ..._flatBody() else ..._cardBody(),
                ],
              ),
            ),
          ),
          SaveBar(
            primaryLabel: _isNewTransaction ? 'Save transaction' : 'Update',
            onPrimary: _submit,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // --- shared building blocks -------------------------------------------------

  Widget _amountAndSign() {
    return Column(
      children: [
        const SizedBox(height: 6),
        AmountHeroField(
          isExpense: _transaction.isExpense,
          initialAmount: _transaction.amount,
          autofocus: _isNewTransaction,
          onChanged: (value) => setState(() {
            _amount = value;
            if (value != null && value > 0) _amountError = null;
          }),
        ),
        if (_amountError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _amountError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SignToggle(
          isExpense: _transaction.isExpense,
          onChanged: (isExpense) =>
              setState(() => _transaction.isExpense = isExpense),
        ),
      ],
    );
  }

  Widget _descriptionField() {
    return TextFormField(
      initialValue: _transaction.description,
      maxLength: 40,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Description',
        hintText: 'What was it for?',
        prefixIcon: const Icon(Icons.notes),
        filled: true,
        fillColor: Theme.of(context).hoverColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        } else if (value.length > 40) {
          return 'Description must not exceed 40 characters';
        }
        return null;
      },
      onChanged: (value) => _transaction.description = value,
    );
  }

  Widget _dateChip() => DateChip(
        date: _transaction.date,
        showTime: !_isNewTransaction,
        onChanged: (date) => setState(() => _transaction.date = date),
      );

  Widget _paymentChips() => PaymentMethodChips(
        value: _transaction.paymentMethod,
        onChanged: (method) =>
            setState(() => _transaction.paymentMethod = method),
      );

  Widget _tagPicker() => TagPicker(
        selectedTagId: _transaction.tag,
        onChanged: (id) => setState(() => _transaction.tag = id),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );

  // --- new-transaction flat layout (mockup A) --------------------------------

  List<Widget> _flatBody() {
    return [
      const SizedBox(height: 12),
      _descriptionField(),
      _sectionLabel('When & how'),
      Wrap(spacing: 7, runSpacing: 7, children: [_dateChip(), _paymentChips()]),
      _sectionLabel('Category'),
      _tagPicker(),
    ];
  }

  // --- edit card-sectioned layout (mockup C) ---------------------------------

  List<Widget> _cardBody() {
    return [
      _card('Details', Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _descriptionField(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [_dateChip(), _paymentChips()],
          ),
        ],
      )),
      _card('Category', _tagPicker()),
      if (_hasSms)
        _card(
          'Original message',
          OriginalSmsCard(rawSms: _transaction.rawSms!, bank: _transaction.bank),
        ),
    ];
  }

  Widget _card(String title, Widget child) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}
