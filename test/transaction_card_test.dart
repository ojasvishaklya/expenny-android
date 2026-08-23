import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/widgets/TransactionCard.dart';

Transaction card({
  required double amount,
  String description = 'Lunch at Little Italy',
  String tag = 'food',
  String paymentMethod = 'Card/UPI',
  DateTime? date,
}) {
  return Transaction(
    id: 1,
    date: date ?? DateTime(2026, 8, 12, 13, 24),
    amount: amount,
    description: description,
    isExpense: amount < 0,
    isStarred: false,
    tag: tag,
    paymentMethod: paymentMethod,
  );
}

Widget wrap(Transaction transaction) {
  return MaterialApp(
    home: Scaffold(
      body: TransactionCard(transaction: transaction),
    ),
  );
}

void main() {
  group('TransactionCard', () {
    testWidgets('renders description, meta line, amount and time', (tester) async {
      await tester.pumpWidget(wrap(card(amount: -860)));

      expect(find.text('Lunch at Little Italy'), findsOneWidget);
      // Meta = "<Tag name> · <paymentMethod>"; 'food' tag resolves to 'Food'.
      expect(find.text('Food · Card/UPI'), findsOneWidget);
      expect(find.text('-₹860'), findsOneWidget);
      expect(find.text('1:24 PM'), findsOneWidget);
    });

    testWidgets('expense amount is red', (tester) async {
      await tester.pumpWidget(wrap(card(amount: -860)));

      final text = tester.widget<Text>(find.text('-₹860'));
      expect(text.style?.color, const Color(0xFFBA1A1A));
    });

    testWidgets('income amount is green and prefixed with +', (tester) async {
      await tester.pumpWidget(wrap(
        card(amount: 25500, description: 'Monthly salary', tag: 'salary'),
      ));

      expect(find.text('+₹25,500'), findsOneWidget);
      final text = tester.widget<Text>(find.text('+₹25,500'));
      expect(text.style?.color, const Color(0xFF2E7D32));
    });

    testWidgets('falls back to tag name when description is empty', (tester) async {
      await tester.pumpWidget(wrap(card(amount: -100, description: '')));

      expect(find.text('Food'), findsWidgets);
    });
  });
}
