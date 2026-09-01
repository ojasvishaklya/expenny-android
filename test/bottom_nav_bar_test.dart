import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/BottomNavBarWidget.dart';

/// Guards the destination order and labels of the bottom navigation.
///
/// Destinations run Dashboard, Transactions, Preferences left to right.
/// Transactions is the app's landing destination at index 1, and `HomeScreen`
/// keys its initial page off that same index, so a reorder here without
/// updating that index would silently change which screen the app opens on.
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

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);

      // The standalone Search destination has been folded into Transactions,
      // and the old Settings tab is now Preferences.
      expect(find.text('Search'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('orders destinations left to right', (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      final dashboard = tester.getCenter(find.text('Dashboard')).dx;
      final transactions = tester.getCenter(find.text('Transactions')).dx;
      final preferences = tester.getCenter(find.text('Preferences')).dx;

      expect(dashboard, lessThan(transactions));
      expect(transactions, lessThan(preferences));
    });

    testWidgets('renders the Preferences destination with the tune icon',
        (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      expect(find.byIcon(Icons.tune), findsWidgets);
    });

    testWidgets('marks the supplied index as selected', (tester) async {
      await tester.pumpWidget(wrap(currentIndex: 1));

      // Transactions sits at index 1, the app's landing destination.
      expect(find.byIcon(Icons.receipt_long), findsWidgets);
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
      await tester.tap(find.byIcon(Icons.dashboard_outlined).first,
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, [0]);

      await tester.tap(find.byIcon(Icons.receipt_long).first,
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, [0, 1]);

      await tester.tap(find.byIcon(Icons.tune).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, [0, 1, 2]);
    });
  });
}
