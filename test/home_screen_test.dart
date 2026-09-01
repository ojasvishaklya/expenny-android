import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/screens/HomeScreen.dart';
import 'package:expenny/widgets/BottomNavBarWidget.dart';

/// Proves the app shell opens on Transactions (index 1) rather than the
/// leftmost destination.
///
/// The real Dashboard, Transactions, and Preferences screens pull data and
/// build heavy widget trees, so this test injects three labelled stand-ins in
/// their canonical order via [HomeScreen.screens]. Only the initially selected
/// page is laid out with a non-zero size by `PageView`, which lets us assert
/// which destination the shell lands on without depending on private state.
void main() {
  testWidgets('HomeScreen opens on the Transactions page', (tester) async {
    const dashboardKey = Key('stub-dashboard');
    const transactionsKey = Key('stub-transactions');
    const preferencesKey = Key('stub-preferences');

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          screens: <Widget>[
            Center(key: dashboardKey, child: Text('Dashboard page')),
            Center(key: transactionsKey, child: Text('Transactions page')),
            Center(key: preferencesKey, child: Text('Preferences page')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The Transactions stand-in (index 1) is the visible page: it is laid out
    // with a non-zero size. `PageView` only realises the landing page and its
    // immediate neighbours, so the leftmost Dashboard stand-in is either
    // absent from the tree or collapsed off-screen — never the visible page.
    expect(tester.getSize(find.byKey(transactionsKey)).width,
        greaterThan(0.0));

    final dashboard = find.byKey(dashboardKey);
    if (dashboard.evaluate().isNotEmpty) {
      expect(tester.getSize(dashboard).width, equals(0.0));
    }
    final preferences = find.byKey(preferencesKey);
    if (preferences.evaluate().isNotEmpty) {
      expect(tester.getSize(preferences).width, equals(0.0));
    }
  });

  testWidgets('shell navigation stays synchronized across taps and swipes',
      (tester) async {
    const dashboardKey = Key('smoke-dashboard');
    const transactionsKey = Key('smoke-transactions');
    const preferencesKey = Key('smoke-preferences');

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          screens: <Widget>[
            Center(key: dashboardKey, child: Text('Dashboard content')),
            Center(key: transactionsKey, child: Text('Transactions content')),
            Center(key: preferencesKey, child: Text('Preferences content')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    BottomNavBarWidget nav() =>
        tester.widget<BottomNavBarWidget>(find.byType(BottomNavBarWidget));

    expect(nav().currentIndex, 1);
    expect(tester.getSize(find.byKey(transactionsKey)).width, greaterThan(0));
    expect(find.text('Search'), findsNothing);
    expect(find.text('Settings'), findsNothing);

    await tester.tap(
      find.byIcon(Icons.dashboard_outlined).first,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(nav().currentIndex, 0);
    expect(tester.getSize(find.byKey(dashboardKey)).width, greaterThan(0));

    await tester.tap(find.byIcon(Icons.tune).first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(nav().currentIndex, 2);
    expect(tester.getSize(find.byKey(preferencesKey)).width, greaterThan(0));

    await tester.drag(find.byType(PageView), const Offset(700, 0));
    await tester.pumpAndSettle();
    expect(nav().currentIndex, 1);
    expect(tester.getSize(find.byKey(transactionsKey)).width, greaterThan(0));

    await tester.drag(find.byType(PageView), const Offset(700, 0));
    await tester.pumpAndSettle();
    expect(nav().currentIndex, 0);
    expect(tester.getSize(find.byKey(dashboardKey)).width, greaterThan(0));
  });
}
