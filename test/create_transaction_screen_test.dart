import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:expenny/controllers/TransactionController.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/screens/CreateTransactionScreen.dart';
import 'package:expenny/widgets/AmountHeroField.dart';

/// Records controller writes without touching the database.
class _FakeController extends TransactionController {
  _FakeController() : super(_FakeRepo());
  final added = <Transaction>[];
  final deleted = <Transaction>[];

  @override
  Future<void> addTransaction(Transaction transaction) async {
    added.add(transaction);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    deleted.add(transaction);
  }
}

class _FakeRepo extends TransactionRepository {}

/// Pushes the screen with [txn] as Get.arguments after the first frame, so
/// `Get.arguments` is populated exactly as in production navigation.
class _Launcher extends StatefulWidget {
  const _Launcher(this.txn);
  final Transaction txn;
  @override
  State<_Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<_Launcher> {
  bool? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await Get.to<bool>(
        () => const CreateTransactionScreen(),
        arguments: widget.txn,
      );
      if (mounted) setState(() => _result = result);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Text('Editor result: $_result'),
      );
}

Transaction newTxn() => Transaction.defaults();

Transaction editTxn() => Transaction(
      id: 5,
      date: DateTime(2026, 8, 12, 13, 24),
      amount: -860,
      description: 'Lunch',
      isExpense: true,
      isStarred: false,
      tag: 'food',
      paymentMethod: 'Card/UPI',
      smsId: 'sms-1',
      source: 'sms',
      bank: 'HDFC Bank',
      rawSms: 'Spent Rs.860.00 At LITTLE ITALY',
    );

Future<_FakeController> _pumpScreen(
    WidgetTester tester, Transaction txn) async {
  Get.testMode = true;
  // Tall surface so the lazily-built ListView renders every section (the SMS
  // card sits below the fold at the default height).
  tester.view.physicalSize = const Size(500, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = _FakeController();
  Get.put<TransactionController>(controller);
  addTearDown(Get.reset);

  await tester.pumpWidget(GetMaterialApp(home: _Launcher(txn)));
  await tester.pumpAndSettle();
  return controller;
}

Finder _amountField() => find.descendant(
      of: find.byType(AmountHeroField),
      matching: find.byType(TextField),
    );

void main() {
  group('CreateTransactionScreen — new', () {
    testWidgets('shows the new-transaction chrome', (tester) async {
      await _pumpScreen(tester, newTxn());
      expect(find.text('New transaction'), findsOneWidget);
      expect(find.text('Save transaction'), findsOneWidget);
      // No delete action for a new transaction.
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('creating fills a signed expense and calls addTransaction',
        (tester) async {
      final controller = await _pumpScreen(tester, newTxn());

      await tester.enterText(_amountField(), '860');
      await tester.enterText(find.byType(TextFormField), 'Lunch');
      await tester.pump();

      // Pick a tag.
      await tester.tap(find.text('Transport'));
      await tester.pump();

      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();

      expect(controller.added.length, 1);
      final t = controller.added.first;
      expect(t.description, 'Lunch');
      expect(t.amount, -860); // expense is stored negative
      expect(t.tag, 'transport');
    });

    testWidgets('a missing amount blocks save', (tester) async {
      final controller = await _pumpScreen(tester, newTxn());

      await tester.enterText(find.byType(TextFormField), 'Lunch');
      await tester.pump();
      await tester.tap(find.text('Save transaction'));
      await tester.pump();

      expect(controller.added, isEmpty);
      expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    });

    testWidgets('a missing description blocks save', (tester) async {
      final controller = await _pumpScreen(tester, newTxn());

      await tester.enterText(_amountField(), '500');
      await tester.pump();
      await tester.tap(find.text('Save transaction'));
      await tester.pump();

      expect(controller.added, isEmpty);
      expect(find.text('Please enter a description'), findsOneWidget);
    });

    testWidgets('income sign is applied on save', (tester) async {
      final controller = await _pumpScreen(tester, newTxn());

      await tester.enterText(_amountField(), '25500');
      await tester.enterText(find.byType(TextFormField), 'Salary');
      await tester.tap(find.text('Income'));
      await tester.pump();

      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();

      expect(controller.added.single.amount, 25500); // income positive
    });
  });

  group('CreateTransactionScreen — edit', () {
    testWidgets('shows edit chrome, the original SMS, and delete',
        (tester) async {
      await _pumpScreen(tester, editTxn());

      expect(find.text('Edit transaction'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      // Original message card renders the raw SMS verbatim.
      expect(find.text('Spent Rs.860.00 At LITTLE ITALY'), findsOneWidget);
    });

    testWidgets('updating persists changes and reports a mutation',
        (tester) async {
      final controller = await _pumpScreen(tester, editTxn());

      await tester.enterText(find.byType(TextFormField), 'Dinner');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(controller.added, hasLength(1));
      expect(controller.added.single.id, 5);
      expect(controller.added.single.description, 'Dinner');
      expect(find.text('Editor result: true'), findsOneWidget);
    });

    testWidgets('confirming delete calls deleteTransaction', (tester) async {
      final controller = await _pumpScreen(tester, editTxn());

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(controller.deleted.length, 1);
      expect(controller.deleted.first.id, 5);
      expect(find.text('Editor result: true'), findsOneWidget);
    });
  });
}
