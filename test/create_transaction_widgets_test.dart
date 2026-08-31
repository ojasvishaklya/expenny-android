import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/PaymentMethod.dart';
import 'package:expenny/widgets/DateChip.dart';
import 'package:expenny/widgets/OriginalSmsCard.dart';
import 'package:expenny/widgets/PaymentMethodChips.dart';
import 'package:expenny/widgets/SaveBar.dart';
import 'package:expenny/widgets/TagPicker.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PaymentMethodChips', () {
    testWidgets('reports the tapped method name', (tester) async {
      String? picked;
      await tester.pumpWidget(wrap(PaymentMethodChips(
        value: PaymentMethod.CASH.name,
        onChanged: (m) => picked = m,
      )));

      await tester.tap(find.text('Card / UPI'));
      await tester.pump();
      expect(picked, PaymentMethod.ONLINE.name); // 'Card/UPI'
    });
  });

  group('DateChip', () {
    testWidgets('renders humanReadableDate and adds time when showTime', (tester) async {
      final date = DateTime(2020, 8, 12, 13, 24); // fixed past date, different year
      await tester.pumpWidget(wrap(DateChip(
        date: date,
        showTime: true,
        onChanged: (_) {},
      )));

      expect(find.textContaining('August 12 2020'), findsOneWidget);
      expect(find.textContaining('1:24 PM'), findsOneWidget);
    });
  });

  group('TagPicker', () {
    testWidgets('marks the selected tag and reports taps', (tester) async {
      String? picked;
      await tester.pumpWidget(wrap(SingleChildScrollView(
        child: TagPicker(selectedTagId: 'food', onChanged: (id) => picked = id),
      )));

      expect(find.text('Food & Drink'), findsOneWidget);
      await tester.tap(find.text('Transport'));
      await tester.pump();
      expect(picked, 'transport');
    });

    testWidgets('resolves a legacy id onto its live pill', (tester) async {
      // 'metro_recharge' -> 'transport'; the Transport pill should be selected.
      await tester.pumpWidget(wrap(SingleChildScrollView(
        child: TagPicker(selectedTagId: 'metro_recharge', onChanged: (_) {}),
      )));
      expect(find.text('Transport'), findsOneWidget);
    });
  });

  group('OriginalSmsCard', () {
    testWidgets('renders the bank and raw message verbatim', (tester) async {
      await tester.pumpWidget(wrap(const OriginalSmsCard(
        bank: 'HDFC Bank',
        rawSms: 'Spent Rs.860.00 At LITTLE ITALY',
      )));
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Spent Rs.860.00 At LITTLE ITALY'), findsOneWidget);
    });
  });

  group('SaveBar', () {
    testWidgets('fires primary and cancel callbacks', (tester) async {
      var saved = false;
      var cancelled = false;
      await tester.pumpWidget(wrap(SaveBar(
        primaryLabel: 'Update',
        onPrimary: () => saved = true,
        onCancel: () => cancelled = true,
      )));

      expect(find.text('Update'), findsOneWidget);
      await tester.tap(find.text('Update'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(saved, isTrue);
      expect(cancelled, isTrue);
    });
  });
}
