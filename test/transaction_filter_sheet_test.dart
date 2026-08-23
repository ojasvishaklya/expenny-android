import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/service/TransactionSortService.dart';
import 'package:expenny/widgets/TransactionFilterSheet.dart';

TransactionTag tagById(String id) => TransactionTag.getTagById(id);

void main() {
  group('TransactionFilterSheet', () {
    testWidgets('reflects the current sort and tag selection when opened',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionFilterSheet(
            initialSort: TransactionSort.highestAmount,
            initialTags: {tagById('food')},
            onApply: (_) {},
          ),
        ),
      ));

      ChoiceChip sortChip(String label) =>
          tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));
      expect(sortChip('Highest amount').selected, isTrue);
      expect(sortChip('Newest first').selected, isFalse);

      final foodChip = tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Food & Drink'));
      expect(foodChip.selected, isTrue);
    });

    testWidgets('Apply returns the chosen sort and toggled tags',
        (tester) async {
      TransactionFilterResult? applied;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionFilterSheet(
            initialSort: TransactionSort.newestFirst,
            initialTags: const {},
            onApply: (result) => applied = result,
          ),
        ),
      ));

      // Choose a different sort.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Oldest first'));
      await tester.pump();

      // Toggle two tags on.
      await tester.tap(find.widgetWithText(FilterChip, 'Food & Drink'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilterChip, 'Transport'));
      await tester.pump();

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pump();

      expect(applied, isNotNull);
      expect(applied!.sort, TransactionSort.oldestFirst);
      expect(applied!.tags, {tagById('food'), tagById('transport')});
    });

    testWidgets('toggling a tag off removes it from the result', (tester) async {
      TransactionFilterResult? applied;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionFilterSheet(
            initialSort: TransactionSort.newestFirst,
            initialTags: {tagById('food')},
            onApply: (result) => applied = result,
          ),
        ),
      ));

      await tester.tap(find.widgetWithText(FilterChip, 'Food & Drink'));
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Apply'));
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pump();

      expect(applied!.tags, isEmpty);
    });
  });
}
