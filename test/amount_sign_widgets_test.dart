import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/AmountHeroField.dart';
import 'package:expenny/widgets/SignToggle.dart';

Widget wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('SignToggle', () {
    testWidgets('reports the tapped sign', (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(wrap(
        SignToggle(isExpense: true, onChanged: events.add),
      ));

      await tester.tap(find.text('Income'));
      await tester.pump();
      expect(events, [false]);

      await tester.tap(find.text('Expense'));
      await tester.pump();
      expect(events, [false, true]);
    });

    testWidgets('colours the selected side by sign', (tester) async {
      await tester.pumpWidget(wrap(
        SignToggle(isExpense: true, onChanged: (_) {}),
      ));

      Text label(String t) => tester.widget<Text>(find.text(t));
      // Expense selected -> red; Income unselected -> muted (not green).
      expect(label('Expense').style?.color, const Color(0xFFBA1A1A));
      expect(label('Income').style?.color, isNot(const Color(0xFF2E7D32)));
    });
  });

  group('AmountHeroField', () {
    testWidgets('shows the ₹ prefix and a 0 placeholder when empty', (tester) async {
      await tester.pumpWidget(wrap(
        AmountHeroField(isExpense: true, onChanged: (_) {}),
      ));
      expect(find.text('₹'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // hint
    });

    testWidgets('reports the parsed magnitude', (tester) async {
      double? reported;
      await tester.pumpWidget(wrap(
        AmountHeroField(isExpense: true, onChanged: (v) => reported = v),
      ));

      await tester.enterText(find.byType(TextField), '860');
      await tester.pump();
      expect(reported, 860.0);
    });

    testWidgets('filters out a leading minus and letters', (tester) async {
      double? reported;
      await tester.pumpWidget(wrap(
        AmountHeroField(isExpense: true, onChanged: (v) => reported = v),
      ));

      await tester.enterText(find.byType(TextField), '-12a3');
      await tester.pump();
      // '-', 'a' stripped -> '123'
      expect(find.text('123'), findsOneWidget);
      expect(reported, 123.0);
    });

    testWidgets('seeds from initialAmount magnitude and colours by sign', (tester) async {
      await tester.pumpWidget(wrap(
        AmountHeroField(isExpense: false, initialAmount: -500, onChanged: (_) {}),
      ));

      expect(find.text('500'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.color, const Color(0xFF2E7D32)); // income green
    });
  });
}
