# Whole-App Redesign Implementation Tracker

This tracker records implementation, validation, and commit evidence for the confirmed Material 3 whole-app redesign. Tasks are executed and committed in order. No changes are pushed.

| Task | Status | Acceptance | Validation | Commit |
|---|---|---|---|---|
| 1. App-shell navigation contract | Done | Dashboard → Transactions → Preferences; Transactions opens by default; Preferences uses `Icons.tune`; no Settings/Search destination | `flutter test test/bottom_nav_bar_test.dart test/home_screen_test.dart` → All tests passed (6/6); `flutter analyze` on changed files → 0 errors/warnings (4 pre-existing info lints only); `flutter build apk --release` → Built app-release.apk | `d6550b0` |
| 2. Grouped Preferences | Done | Five scrollable groups (Appearance, Planning, Automation, Data, Danger zone); dark-mode drives `ConfigService.toggleDarkMode`; budget row opens shared `showMonthlyBudgetDialog`; honest SMS status (`Last synced …` / `Not synced yet`); Import data disabled with `Coming soon` + disabled semantics + no snackbar; destructive delete confirmation; layout scrolls without overflow at 320dp/short viewport/2.0x text; SmsSync/export/delete/ConfigService persistence preserved | `flutter test test/preferences_screen_test.dart` → All tests passed (17/17); `flutter test` on relevant existing suites (preferences + budget_progress + date_service + bottom_nav_bar + home_screen) → All tests passed (58/58); `flutter analyze test/preferences_screen_test.dart` → No issues found; `flutter build apk --release` → Built app-release.apk (54.7MB) | See Task 2 note |
| 3. DisplayCard net hero | Done | Month-attributed net hero, income/expense tiles, savings rate, header/subtitle and month-first layout; duplicate summary widget removed | `flutter test test/display_card_test.dart test/analytics_dashboard_components_test.dart test/analytics_summary_category_test.dart test/analytics_screen_test.dart` → All tests passed (74/74); `flutter test` → All tests passed (255/255, no regressions); `flutter analyze` on changed files → 0 errors/warnings (only pre-existing file_names + one pre-existing test private-type info lint); `flutter build apk --release` → Built app-release.apk (54.7MB) | See Task 3 note |
| 4. Segmented budget | Not started | Category segments, idle remainder, exact/over/no-budget states, shared category identity and semantics | Pending | Pending |
| 5. Dashboard composition | Not started | Final ordered composition with request guards preserved and MonthComparison retained after trend | Pending | Pending |
| 6. Transactions validation | Not started | Selected-month search/sort/filter behavior preserved; signed rows use theme roles; FAB and request guard remain | Pending | Pending |
| 7. Whole-app integration | Not started | Shell smoke coverage, accessibility/responsive audit, analyzer/tests/release build all green | Pending | Pending |

## Task notes

### Task 1 — App-shell navigation contract
- Status: Done
- Changed files:
  - `lib/widgets/BottomNavBarWidget.dart` — reordered tabs to Dashboard, Transactions, Preferences; Preferences uses `Icons.tune` (was Settings/`Icons.settings`).
  - `lib/screens/HomeScreen.dart` — reordered `_screens` to Dashboard, Transactions, Preferences; renamed landing constant `_dashboardIndex` → `_transactionsIndex` (value retained at 1); added optional `screens` injection seam for testing; PageController tap/swipe sync preserved.
  - `test/bottom_nav_bar_test.dart` — asserts exactly Dashboard, Transactions, Preferences in order; Settings/Search absent; tap mappings Dashboard=0, Transactions=1, Preferences=2; Preferences renders `Icons.tune`.
  - `test/home_screen_test.dart` — new focused widget test proving Transactions (index 1) is the initially visible page, via the screen-injection seam.
- Validation evidence:
  - `flutter test test/bottom_nav_bar_test.dart test/home_screen_test.dart` → `All tests passed!` (6 tests).
  - `flutter analyze lib/screens/HomeScreen.dart lib/widgets/BottomNavBarWidget.dart test/home_screen_test.dart test/bottom_nav_bar_test.dart` → 0 errors/warnings; only 4 pre-existing info lints (file_names, use_super_parameters).
  - `flutter build apk --release` → `✓ Built build/app/outputs/flutter-apk/app-release.apk`.
- Commit: `d6550b0` — `feat(nav): Reorder app shell navigation`.

### Task 2 — Grouped Preferences
- Status: Done
- Approach: The grouped Preferences screen already shipped with Task 1's redesign
  commit; Task 2 locks it down with a dedicated widget-test suite that pins every
  contract. The tests exposed no defects, so no source changes to
  `PreferencesScreen.dart` were required.
- Changed files:
  - `test/preferences_screen_test.dart` — new widget-test suite (17 tests)
    covering all five groups and every Task 2 contract.
  - `.kiro/specs/app-redesign/whole-app-redesign-todo.md` — tracker update
    (this file); recorded Task 1 commit `d6550b0`.
- Coverage (all five groups):
  - Scaffolding: all five section labels present in order (Appearance, Planning,
    Automation, Data, Danger zone) plus the expected row in each group.
  - Appearance: the Switch reflects the persisted `ConfigService.isDarkMode`;
    tapping the Switch and tapping the row each drive
    `ConfigService.toggleDarkMode` (real service, mocked GetStorage) and the
    reactive Switch re-renders to the flipped value.
  - Planning: the Monthly budget row opens the shared `showMonthlyBudgetDialog`
    (asserted via its distinctive `Monthly Budget` title, hint text, and
    Save/Cancel actions — not a bespoke copy); trailing shows `Set budget` when
    unset.
  - Automation: a real `lastSyncedAt` renders `Last synced <formatTime>`; both
    `null` and malformed (`not-a-timestamp`) values render `Not synced yet`.
  - Data: Import data is disabled, shows the `Coming soon` badge, exposes
    disabled semantics (`enabled: false`, `button: false`), hosts no `InkWell`,
    and tapping it produces no `SnackBar`.
  - Danger zone: tapping Delete all data opens the destructive
    `AlertDialog` (`Are you sure you want to delete all data?` with
    `delete`/`cancel`); the delete row carries button semantics and no toggle.
  - Layout: renders without overflow at 320dp width, scrolls to reveal the
    Danger zone on a short 360×480 viewport, and renders without overflow at
    2.0x text scale.
- Deletion copy inspection: `DataService.deleteAllTransactions()` calls
  `GetStorage().erase()`, which wipes ConfigService-persisted settings
  (dark mode, budget, lastSyncedAt) in addition to transactions. The row copy
  "Permanently remove every transaction and setting" is therefore accurate, so
  per the instruction (correct only if it does NOT remove settings) it was left
  unchanged.
- Preserved: `SmsSyncService` sync flow, `DataService` export/deletion,
  `ConfigService` persistence, and all unrelated behavior are untouched. No
  import-count persistence was added.
- Validation evidence:
  - `flutter test test/preferences_screen_test.dart` → `All tests passed!` (17 tests).
  - `flutter test test/preferences_screen_test.dart test/budget_progress_test.dart test/date_service_test.dart test/bottom_nav_bar_test.dart test/home_screen_test.dart` → `All tests passed!` (58 tests, no regressions).
  - `flutter analyze test/preferences_screen_test.dart` → `No issues found!`.
  - `flutter build apk --release` → `✓ Built build/app/outputs/flutter-apk/app-release.apk (54.7MB)`.
- Commit: `81c35f7` — `test(preferences): Lock down grouped Preferences`.

### Task 3 — DisplayCard net hero
- Status: Done
- Approach: The legacy `DisplayCard` (raw `B A L A N C E`/income/expense
  values) is replaced by the integrated, month-attributed net hero. The hero
  implementation previously lived in the duplicate, unmounted
  `MonthlySummarySection`; its behaviour and full test contract were migrated
  onto `DisplayCard`, income/expense tiles gained direction icons with
  `tertiary`/`error` semantics, and the orphaned widget was deleted.
- Changed files:
  - `lib/widgets/DisplayCard.dart` — rewritten to consume
    `MonthlySummary summary` + `DateTime displayedMonth`. Renders `{Month} net`
    label, signed rupee net via `formatRupees`, `primaryContainer` hero
    styling, Income/Expense tiles with `Icons.arrow_upward`/`arrow_downward` in
    `colorScheme.tertiary`/`error`, savings-rate text + clamped
    `LinearProgressIndicator`, an honest empty-month hint, a concise container
    semantic label stating net direction as a word, responsive stacking
    (`stackBelowWidth` / `kAnalyticsStackTextScale`) and `FittedBox` protection
    on every amount. Exposes `netStateLabel` and `stackBelowWidth`.
  - `lib/widgets/analytics/DashboardHeader.dart` — added optional `subtitle`;
    title stays the sole header, subtitle is plain supporting text.
  - `lib/screens/DashboardScreen.dart` — imports `DashboardHeader`; build order
    for this increment is header (subtitle `Where your money went`) → month
    selector → conditional load status → then, for settled data, the hero
    (`summary: data.summary`, `displayedMonth: data.month`) followed by
    budget/category/trend/MonthComparison. Initial state shows header +
    selector + status with no monetary values. Hero uses `data.month`, so old
    visible values stay honestly attributed while another selected month is
    loading or fails. `_selectedMonth`, the single bounded `_load`,
    `_requestId` ordering, status/retry, trend/category/budget, and
    MonthComparison computation/rendering are all preserved.
  - `lib/widgets/analytics/MonthlySummarySection.dart` — deleted (duplicate
    orphan; no remaining imports or references).
  - `test/display_card_test.dart` — new suite migrating the
    `MonthlySummarySection` contract onto `DisplayCard` (empty month; net/
    income/expense/savings; month attribution; positive/negative/zero net;
    direction icons; tertiary/error icon roles; semantic net direction; concise
    summary semantic; `primaryContainer` role; savings-bar boundary clamping;
    320dp stacking; doubled text scale; dark theme; `netStateLabel`).
  - `test/analytics_dashboard_components_test.dart` — added subtitle coverage
    (renders optional subtitle; subtitle is not a second header).
  - `test/analytics_summary_category_test.dart` — removed the migrated
    `MonthlySummarySection` group, its import, and now-unused fixtures; the
    `CategoryBreakdownSection` contract is untouched.
  - `test/analytics_screen_test.dart` — updated Dashboard assertions to the new
    hero contract (`{Month} net` + grouped rupee values, header + subtitle,
    header-first order, empty-month hero hint) while keeping every request-
    ordering, retry, attribution, responsive, and dark-theme scenario.
  - `.kiro/specs/app-redesign/whole-app-redesign-todo.md` — tracker update
    (this file); recorded Task 2 commit `81c35f7`.
- Out of scope (not implemented): Task 4 segmented budget. `BudgetProgressWidget`
  is mounted unchanged.
- Validation evidence:
  - `flutter test test/display_card_test.dart test/analytics_dashboard_components_test.dart test/analytics_summary_category_test.dart test/analytics_screen_test.dart`
    → `All tests passed!` (74 tests).
  - `flutter test` → `All tests passed!` (255 tests, no regressions).
  - `flutter analyze lib/widgets/DisplayCard.dart lib/widgets/analytics/DashboardHeader.dart lib/screens/DashboardScreen.dart test/display_card_test.dart test/analytics_dashboard_components_test.dart test/analytics_summary_category_test.dart test/analytics_screen_test.dart`
    → `4 issues found`, all pre-existing info lints (3 × `file_names`, 1 ×
    `library_private_types_in_public_api` in the existing test harness); 0
    errors/warnings.
  - `flutter build apk --release` →
    `✓ Built build/app/outputs/flutter-apk/app-release.apk (54.7MB)`.
- Commit: see git log for this Task 3 commit.

### Task 4 — Segmented budget
- Status: Not started
- Validation evidence: Pending
- Commit: Pending

### Task 5 — Dashboard composition
- Status: Not started
- Validation evidence: Pending
- Commit: Pending

### Task 6 — Transactions validation
- Status: Not started
- Validation evidence: Pending
- Commit: Pending

### Task 7 — Whole-app integration
- Status: Not started
- Validation evidence: Pending
- Commit: Pending
