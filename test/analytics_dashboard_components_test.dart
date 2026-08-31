import 'package:expenny/constants/DesignTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';
import 'package:expenny/widgets/analytics/DashboardHeader.dart';
import 'package:expenny/widgets/analytics/DashboardLoadStatus.dart';
import 'package:expenny/widgets/analytics/NearbyMonthSelector.dart';

import 'support/dashboard_harness.dart';

final _august2026 = DateTime(2026, 8, 1);

void main() {
  group('DashboardHeader', () {
    testWidgets('shows the exact title without a subtitle', (tester) async {
      await tester.pumpWidget(wrapSection(const DashboardHeader()));

      expect(find.text('Dashboard'), findsOneWidget);
      // The subtitle was removed; the header is title-only now.
      expect(find.text('Your monthly money story'), findsNothing);
    });

    testWidgets('exposes the title as a header', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrapSection(const DashboardHeader()));

      expect(
        tester.getSemantics(find.text('Dashboard')),
        matchesSemantics(label: 'Dashboard', isHeader: true),
      );

      handle.dispose();
    });

    testWidgets('offers no actions', (tester) async {
      await tester.pumpWidget(wrapSection(const DashboardHeader()));

      // Out of scope: add-transaction, year picker, budget edit.
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('AnalyticsSection', () {
    testWidgets('renders the heading exactly as supplied', (tester) async {
      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(
          title: 'Spending by category',
          child: Text('body'),
        ),
      ));

      expect(find.text('Spending by category'), findsOneWidget);
      // No automatic uppercase transformation.
      expect(find.text('SPENDING BY CATEGORY'), findsNothing);
    });

    testWidgets('wraps content in an outlined panel by default',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(title: 'Budget', child: Text('body')),
      ));

      expect(find.byType(AnalyticsOutlinedPanel), findsOneWidget);
    });

    testWidgets('omits the panel when outlined is false', (tester) async {
      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(
          title: 'Summary',
          outlined: false,
          child: Text('body'),
        ),
      ));

      expect(find.byType(AnalyticsOutlinedPanel), findsNothing);
    });

    testWidgets('draws the panel from semantic theme roles without elevation',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(title: 'Budget', child: Text('body')),
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnalyticsOutlinedPanel),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final colors = testLightTheme().colorScheme;

      expect(decoration.color, colors.surface);
      expect(
        decoration.border,
        Border.all(
          color: colors.outlineVariant,
          width: kDesignBorderWidth,
        ),
      );
      expect(decoration.boxShadow, anyOf(isNull, isEmpty));
    });

    testWidgets('uses the dark scheme surface in the dark theme',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(title: 'Budget', child: Text('body')),
        dark: true,
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnalyticsOutlinedPanel),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, testDarkTheme().colorScheme.surface);
    });

    testWidgets('stacks heading and trailing at a large text scale',
        (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        const AnalyticsSection(
          title: 'Spending by category',
          trailing: Text('₹13,040 total'),
          child: Text('body'),
        ),
        textScale: 2.0,
      ));

      expect(tester.takeException(), isNull);

      final heading = tester.getTopLeft(find.text('Spending by category'));
      final trailing = tester.getTopLeft(find.text('₹13,040 total'));
      expect(trailing.dy, greaterThan(heading.dy));
    });
  });

  group('NearbyMonthSelector', () {
    Widget selector({
      required DateTime selected,
      required DateTime current,
      List<DateTime>? tapped,
    }) {
      return wrapSection(NearbyMonthSelector(
        selectedMonth: selected,
        currentMonth: current,
        onMonthSelected: (month) => tapped?.add(month),
      ));
    }

    test('generates six chronological months around the selection', () {
      final months = NearbyMonthSelector.nearbyMonths(_august2026);

      expect(months.length, 6);
      expect(
        months.map((m) => '${m.year}-${m.month}').toList(),
        ['2026-5', '2026-6', '2026-7', '2026-8', '2026-9', '2026-10'],
      );
    });

    test('crosses a year boundary chronologically', () {
      final months = NearbyMonthSelector.nearbyMonths(DateTime(2026, 2, 1));

      expect(
        months.map((m) => '${m.year}-${m.month}').toList(),
        ['2025-11', '2025-12', '2026-1', '2026-2', '2026-3', '2026-4'],
      );
    });

    test('identifies future months by calendar month', () {
      final current = DateTime(2026, 8, 1);

      expect(
        NearbyMonthSelector.isFutureMonth(DateTime(2026, 9, 1), current),
        isTrue,
      );
      expect(
        NearbyMonthSelector.isFutureMonth(DateTime(2026, 8, 31), current),
        isFalse,
      );
      expect(
        NearbyMonthSelector.isFutureMonth(DateTime(2026, 7, 1), current),
        isFalse,
      );
    });

    testWidgets('shows six chips carrying year context', (tester) async {
      await tester.pumpWidget(
        selector(selected: _august2026, current: _august2026),
      );

      expect(find.byType(ChoiceChip), findsNWidgets(6));
      // The 'Choose a period' label was removed; the chips stand alone.
      expect(find.text('Choose a period'), findsNothing);
      expect(find.text('Aug 2026'), findsOneWidget);
      expect(find.text('May 2026'), findsOneWidget);
    });

    testWidgets('distinguishes equal month names from different years',
        (tester) async {
      await tester.pumpWidget(
        selector(
          selected: DateTime(2026, 2, 1),
          current: DateTime(2026, 8, 1),
        ),
      );

      expect(find.text('Dec 2025'), findsOneWidget);
      expect(find.text('Nov 2025'), findsOneWidget);
      expect(find.text('Feb 2026'), findsOneWidget);
    });

    testWidgets('marks exactly one chip selected', (tester) async {
      await tester.pumpWidget(
        selector(selected: _august2026, current: _august2026),
      );

      final selectedChips = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .where((chip) => chip.selected);

      expect(selectedChips.length, 1);
    });

    testWidgets('reports an activated past month', (tester) async {
      final tapped = <DateTime>[];
      await tester.pumpWidget(selector(
        selected: _august2026,
        current: _august2026,
        tapped: tapped,
      ));

      await tester.tap(find.text('Jun 2026'));
      await tester.pumpAndSettle();

      expect(tapped, [DateTime(2026, 6, 1)]);
    });

    testWidgets('ignores re-activating the already selected month',
        (tester) async {
      final tapped = <DateTime>[];
      await tester.pumpWidget(selector(
        selected: _august2026,
        current: _august2026,
        tapped: tapped,
      ));

      await tester.tap(find.text('Aug 2026'));
      await tester.pumpAndSettle();

      expect(tapped, isEmpty);
    });

    testWidgets('disables future chips and gives them no tap action',
        (tester) async {
      final tapped = <DateTime>[];
      await tester.pumpWidget(selector(
        selected: _august2026,
        current: _august2026,
        tapped: tapped,
      ));

      final september = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Sep 2026'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(september.onSelected, isNull);
      expect(september.isEnabled, isFalse);

      await tester.tap(find.text('Sep 2026'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isEmpty);
    });

    testWidgets('labels chips with the full month name for assistive tech',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        selector(selected: _august2026, current: _august2026),
      );

      // Visible text stays compact; the semantic label spells the month out.
      expect(find.bySemanticsLabel('August 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('June 2026'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('keeps chips at least 48 logical pixels tall', (tester) async {
      await tester.pumpWidget(
        selector(selected: _august2026, current: _august2026),
      );

      for (final element in find.byType(ChoiceChip).evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });
  });

  group('DashboardLoadStatus', () {
    test('names only the selected month before any data exists', () {
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: _august2026,
          displayedMonth: null,
          isLoading: true,
          hasError: false,
        ),
        'Loading August 2026',
      );
    });

    test('names only the loading month while a different month loads', () {
      // The copy is intentionally minimal: it names the month being fetched
      // and no longer attributes the still-displayed month.
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: DateTime(2026, 9, 1),
          displayedMonth: _august2026,
          isLoading: true,
          hasError: false,
        ),
        'Loading September 2026',
      );
    });

    test('reports a same-month reload as a refresh', () {
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: _august2026,
          displayedMonth: _august2026,
          isLoading: true,
          hasError: false,
        ),
        'Refreshing August 2026',
      );
    });

    test('shows no status once settled', () {
      // A settled snapshot needs no status line, so the label is empty.
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: _august2026,
          displayedMonth: _august2026,
          isLoading: false,
          hasError: false,
        ),
        '',
      );
    });

    test('reports a failure naming only the selected month', () {
      // Failure copy names the month that failed and carries no 'Showing'
      // suffix, regardless of what is still displayed.
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: DateTime(2026, 9, 1),
          displayedMonth: _august2026,
          isLoading: false,
          hasError: true,
        ),
        "Couldn't load September 2026",
      );
      expect(
        DashboardLoadStatus.statusLabel(
          selectedMonth: DateTime(2026, 9, 1),
          displayedMonth: null,
          isLoading: false,
          hasError: true,
        ),
        "Couldn't load September 2026",
      );
    });

    testWidgets('shows a non-blocking indicator while loading', (tester) async {
      await tester.pumpWidget(wrapSection(
        DashboardLoadStatus(
          selectedMonth: DateTime(2026, 9, 1),
          displayedMonth: _august2026,
          isLoading: true,
        ),
      ));

      // Linear, not a blocking centred spinner.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loading September 2026'), findsOneWidget);
    });

    testWidgets('offers Retry only when a load failed', (tester) async {
      var retried = 0;

      await tester.pumpWidget(wrapSection(
        DashboardLoadStatus(
          selectedMonth: _august2026,
          displayedMonth: null,
          isLoading: false,
          error: Exception('boom'),
          onRetry: () => retried++,
        ),
      ));

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, 1);

      // The raw exception is never surfaced to the user.
      expect(find.textContaining('boom'), findsNothing);
    });

    testWidgets('omits Retry when there is no error', (tester) async {
      await tester.pumpWidget(wrapSection(
        DashboardLoadStatus(
          selectedMonth: _august2026,
          displayedMonth: _august2026,
          isLoading: false,
        ),
      ));

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('announces status as a live region', (tester) async {
      // A settled status renders no widget, so the live region is exercised
      // while loading, when there is a status to announce.
      await tester.pumpWidget(wrapSection(
        DashboardLoadStatus(
          selectedMonth: _august2026,
          displayedMonth: _august2026,
          isLoading: true,
        ),
      ));

      // The status text changes in place as loads start and finish, so it must
      // be declared a live region for it to be announced.
      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(DashboardLoadStatus),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(semantics.properties.liveRegion, isTrue);
    });
  });
}
