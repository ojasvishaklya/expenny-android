import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/BottomNavBarWidget.dart';

/// Guards the destination order and labels of the bottom navigation.
///
/// Dashboard is the landing destination at index 1, with Transactions
/// immediately to its left and Settings to its right. `HomeScreen` keys its
/// initial page off the same index, so a reorder here without updating that
/// index would silently change which screen the app opens on.
void main() {
  Widget wrap({required int currentIndex, void Function(int)? onIndexChanged}) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavBarWidget(
          currentIndex: currentIndex,
          onIndexChanged: onIndexChanged ?? (_) {},
        ),
      ),
    );
  }

  group('BottomNavBarWidget', () {
    testWidgets('exposes the three destinations in order', (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // The standalone Search destination has been folded into Transactions,
      // and the old mislabelled tabs are gone.
      expect(find.text('Search'), findsNothing);
      expect(find.text('Preferences'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('orders destinations left to right', (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      final transactions = tester.getCenter(find.text('Transactions')).dx;
      final dashboard = tester.getCenter(find.text('Dashboard')).dx;
      final settings = tester.getCenter(find.text('Settings')).dx;

      expect(transactions, lessThan(dashboard));
      expect(dashboard, lessThan(settings));
    });

    testWidgets('marks the supplied index as selected', (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      // Dashboard sits at index 1, the app's landing destination.
      expect(find.byIcon(Icons.dashboard_outlined), findsWidgets);
    });

    testWidgets('reports the tapped destination index', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        wrap(currentIndex: 1, onIndexChanged: tapped.add),
      );

      // Tap the icon rather than the label: unselected tabs collapse their
      // text to zero width, so only the icon is a hittable target. GNav builds
      // each icon twice (inactive and active states), hence `.first`, and the
      // gesture is handled by an ancestor, hence `warnIfMissed: false`.
      await tester.tap(find.byIcon(Icons.receipt_long).first,
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, [0]);

      await tester.tap(find.byIcon(Icons.settings).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, [0, 2]);
    });
  });
}
