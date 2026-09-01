# Whole-App Redesign Implementation Tracker

This tracker records implementation, validation, and commit evidence for the confirmed Material 3 whole-app redesign. Tasks are executed and committed in order. No changes are pushed.

| Task | Status | Acceptance | Validation | Commit |
|---|---|---|---|---|
| 1. App-shell navigation contract | Done | Dashboard → Transactions → Preferences; Transactions opens by default; Preferences uses `Icons.tune`; no Settings/Search destination | `flutter test test/bottom_nav_bar_test.dart test/home_screen_test.dart` → All tests passed (6/6); `flutter analyze` on changed files → 0 errors/warnings (4 pre-existing info lints only); `flutter build apk --release` → Built app-release.apk | `d6550b0` |
| 2. Grouped Preferences | Done | Five scrollable groups (Appearance, Planning, Automation, Data, Danger zone); dark-mode drives `ConfigService.toggleDarkMode`; budget row opens shared `showMonthlyBudgetDialog`; honest SMS status (`Last synced …` / `Not synced yet`); Import data disabled with `Coming soon` + disabled semantics + no snackbar; destructive delete confirmation; layout scrolls without overflow at 320dp/short viewport/2.0x text; SmsSync/export/delete/ConfigService persistence preserved | `flutter test test/preferences_screen_test.dart` → All tests passed (17/17); `flutter test` on relevant existing suites (preferences + budget_progress + date_service + bottom_nav_bar + home_screen) → All tests passed (58/58); `flutter analyze test/preferences_screen_test.dart` → No issues found; `flutter build apk --release` → Built app-release.apk (54.7MB) | See Task 2 note |
| 3. DisplayCard net hero | Done | Month-attributed net hero, income/expense tiles, savings rate, header/subtitle and month-first layout; duplicate summary widget removed | `flutter test test/display_card_test.dart test/analytics_dashboard_components_test.dart test/analytics_summary_category_test.dart test/analytics_screen_test.dart` → All tests passed (74/74); `flutter test` → All tests passed (255/255, no regressions); `flutter analyze` on changed files → 0 errors/warnings (only pre-existing file_names + one pre-existing test private-type info lint); `flutter build apk --release` → Built app-release.apk (54.7MB) | `7faaaf4` |
| 4. Segmented budget | Done (widget tests deferred) | Category segments, idle remainder, exact/over/no-budget states, shared category identity and semantics | `flutter test test/budget_progress_test.dart` → All active tests passed (36/36); rendered/platform-backed widget scenarios remain documented as TODOs; `flutter analyze` → 0 errors/warnings (4 filename-style info lints); `flutter build apk --release` → Built app-release.apk (54.7MB) | `a58e7b7`, `682a903` |
| 5. Dashboard composition | Done | Header → month selector → hero → segmented budget → ranked categories → six-month trend → retained MonthComparison; one bounded load and request-ordering behavior preserved | `flutter test test/analytics_screen_test.dart` → All tests passed (17/17); focused Dashboard regressions → All tests passed (91/91); `flutter analyze test/analytics_screen_test.dart` → No issues found; `flutter build apk --release` → Built app-release.apk (54.7MB) | `4a5bfc9` |
| 6. Transactions validation | Done | Selected-month search/sort/filter and stale-request behavior preserved; signed rows use `ColorScheme.tertiary/error`; header, controls, date groups, FAB, narrow width and large text validated | `flutter test test/transaction_card_test.dart test/transactions_screen_test.dart` → All tests passed (12/12); `flutter analyze` → 0 errors/warnings (one filename-style info); `flutter build apk --release` → Built app-release.apk (54.7MB) | See Task 6 note |
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
- Commit: `7faaaf4` — Task 3 DisplayCard net hero.

### Task 4 — Segmented budget
- Status: Done (platform-backed widget tests deferred by user)
- Approach: The budget bar becomes category-aware. `BudgetProgressWidget` now
  consumes the same `CategoryBreakdown` the ledger and "spending by category"
  list use, and fills a single rounded rail with an ordered run of tag-tinted
  segments (`group.amount / budget` each), cumulative fill capped at `1.0` so an
  overspending category is clipped to the remaining room and later categories
  contribute nothing — the track never overflows. Under budget, a single
  neutral idle remainder trails the categories; at or over budget no idle is
  drawn. Category tint/icon are resolved through a new shared
  `CategoryVisualIdentity`, which both the budget segments and the ranked
  breakdown rows now call, so the two surfaces speak one visual language.
- Changed files:
  - `lib/widgets/analytics/CategoryVisualIdentity.dart` — new. `CategoryVisualIdentity`
    (icon + colour) and `categoryIdentityFor(group, colors)`: neutral theme
    colour + generic icon for the synthetic `Other` bucket; otherwise the single
    tag's icon/colour with a defensive fall-back to the first id.
  - `lib/widgets/BudgetProgressWidget.dart` — `BudgetProgressWidget` gains a
    required `breakdown`; new pure `budgetSegments(breakdown, budget)` allocator
    and `BudgetSegment` (category/idle, `fraction`, integer `flex`); new
    `_SegmentedBudgetBar` renders the ordered tinted segments + idle remainder
    inside one `ClipRRect` rail, with fixed 2px inter-segment gaps that are
    deducted by Flex layout rather than added beyond the track. Positive
    fractions receive a minimum flex of 1 so tiny segments cannot trigger a
    zero-flex assertion. Caption: `{spent} of {budget} · {remaining} left` under/at budget,
    `Over budget by {amount}` with `colorScheme.error` when genuinely over.
    Exact equality (`expense == budget`) shows `100.0% used` and `₹0 left`
    with no false overage (`isOverBudget` contract preserved). Semantics state
    spent/budget/utilisation/category splits; the decorative bar is wrapped in
    `ExcludeSemantics`. All pre-existing helpers (`computeProgress`,
    `isOverBudget`, `budgetUsedPercent`, `budgetDifference`, `remainingBudget`,
    `validateBudgetInput`), the shared `showMonthlyBudgetDialog`, the `Obx`
    reactive budget read, the no-budget hint, and the Edit action are preserved.
  - `lib/widgets/analytics/CategoryBreakdownSection.dart` — removed the private
    `_GroupIdentity`/`identityFor`; the ranked rows now call the shared
    `categoryIdentityFor`. Row layout and semantic summary unchanged.
  - `lib/screens/DashboardScreen.dart` — passes `breakdown: data.breakdown` into
    `BudgetProgressWidget` (the only Task 4 change). Request-state ordering
    (`_requestId`, bounded `_load`, retry/status), month attribution, trend,
    category, and `MonthComparison` composition are untouched. Task 5 dashboard
    re-composition is NOT implemented.
  - `test/budget_progress_test.dart` — kept the deterministic pure `test(...)`
    groups (`computeProgress`, `isOverBudget`, `budgetUsedPercent`,
    `budgetDifference`, `remainingBudget`, `validateBudgetInput`, and the pure
    `budgetSegments` allocation contract). The `BudgetProgressWidget rendering`
    `testWidgets` group is commented out (preserved, not deleted) behind a
    per-scenario TODO block, because it needs platform-channel setup
    (`registerConfigService` mocks `path_provider` + inits `GetStorage`; the
    Edit case drives `showMonthlyBudgetDialog` with `pumpAndSettle`) — exactly
    the problematic widget/platform setup the user deferred.
- Out of scope (not implemented): Task 5 dashboard composition.
- Test status: The active deterministic helper/allocation suite was run and
  passed: `flutter test test/budget_progress_test.dart` → `All tests passed!`
  (36/36, including the tiny-positive-segment flex regression). Per user
  direction, the platform-backed `BudgetProgressWidget rendering` group remains
  commented out because its timeout handling was unreliable. Deferred /
  unverified rendered scenarios (from the preserved TODO group):
  1. no-budget hint + Edit action when unset (no " left" copy);
  2. all-idle bar + `₹0 of ₹1,000 · ₹1,000 left` + `0.0% used` when nothing spent;
  3. one category segment + idle remainder (`₹250 of ₹1,000 · ₹750 left`, `25.0% used`);
  4. multiple segments in supplied order with shared identity colours (`₹600 of ₹1,000 · ₹400 left`, `60.0% used`);
  5. over budget: cumulative fill capped, no idle, `Over budget by ₹200`, `120.0% used`, no " left", error semantics;
  6. exact budget: full track, `₹1,000 of ₹1,000 · ₹0 left`, `100.0% used`, no false overage, `isOverBudget(1000,1000)==true`;
  7. large-amount Indian grouping in caption/used line;
  8. semantics include spent/budget/utilisation/category splits, decorative bar excluded;
  9. renders at 320dp without overflow;
  10. renders at 2.0x text scale without overflow;
  11. renders in dark theme without error;
  12. Edit action opens the shared `showMonthlyBudgetDialog`.
  The active pure tests verify allocation, capping, remainder, equality,
  overspend math, validation, and nonzero flex behavior; only the rendered /
  semantic surface and dialog wiring remain unverified until the widget group
  is re-enabled.
- Validation evidence:
  - `flutter test test/budget_progress_test.dart` → `All tests passed!`
    (36 active deterministic tests).
  - `flutter analyze lib/widgets/analytics/CategoryVisualIdentity.dart lib/widgets/BudgetProgressWidget.dart lib/widgets/analytics/CategoryBreakdownSection.dart lib/screens/DashboardScreen.dart test/budget_progress_test.dart`
    → `4 issues found`, all pre-existing `file_names` info lints (project-wide
    PascalCase filenames); 0 errors/warnings, and no new lints from the new file
    or the commented-out test block.
  - `flutter build apk --release` →
    `✓ Built build/app/outputs/flutter-apk/app-release.apk (54.7MB)`.
- Commit: `a58e7b7` — `feat(dashboard): Add segmented category budget bar`;
  `682a903` — `fix(dashboard): Harden budget segments`.

### Task 5 — Dashboard composition
- Status: Done
- Approach: The production Dashboard composition established in Tasks 3 and 4
  already matched the agreed order, so this task locks that integration down
  rather than adding duplicate layout code. The composition test now asserts
  the vertical order Dashboard header → month selector → month-attributed hero
  → monthly budget → ranked category rows → six-month trend → retained
  MonthComparison.
- Changed files:
  - `test/analytics_screen_test.dart` — added explicit vertical-order
    assertions to the one-response integration test and made the test-only
    Dashboard builder private, clearing the prior private-type analyzer info.
  - `.kiro/specs/app-redesign/whole-app-redesign-todo.md` — recorded Task 4's
    primary and hardening commits and this Task 5 evidence.
- Preserved behavior:
  - One bounded six-month transaction request still feeds every section.
  - `_requestId` still prevents stale success/failure replacement.
  - Initial loads expose no monetary values; retry and retained-snapshot
    attribution remain covered.
  - Future month chips remain disabled.
  - `MonthComparisonSection` remains visible after `MonthTrendSection`.
- Validation evidence:
  - `flutter test test/analytics_screen_test.dart` → `All tests passed!`
    (17/17).
  - `flutter test test/analytics_screen_test.dart test/analytics_trend_comparison_test.dart test/analytics_summary_category_test.dart test/budget_progress_test.dart`
    → `All tests passed!` (91/91).
  - `flutter analyze test/analytics_screen_test.dart` → `No issues found!`.
  - `flutter build apk --release` →
    `✓ Built build/app/outputs/flutter-apk/app-release.apk (54.7MB)`.
- Commit: `4a5bfc9` — `test(dashboard): Lock section composition`.

### Task 6 — Transactions validation
- Status: Done
- Approach: The selected-month Transactions architecture remains unchanged.
  Tests were strengthened around the complete redesigned surface, then used to
  drive the only production fixes: replace hardcoded amount colors with active
  Material theme roles and constrain/scale the trailing amount column so long
  signed values survive 320dp widths and 2.0x text.
- Changed files:
  - `lib/widgets/TransactionCard.dart` — expense amounts now use
    `colorScheme.error`, income uses `colorScheme.tertiary`, signed formatting
    and tap-to-edit remain unchanged, and the trailing amount/time column is
    bounded with a scale-down `FittedBox`; constructor uses a super parameter.
  - `test/transaction_card_test.dart` — asserts signed amounts and active
    `ColorScheme` roles rather than fixed hex values.
  - `test/transactions_screen_test.dart` — asserts header/subtitle, integrated
    search and sort/filter controls, date labels, signed income/expense rows,
    Add Transaction affordance, selected-month query ranges, search/filter
    arguments, in-memory sorting, stale-response protection, and 320dp/2.0x
    text rendering. The test builder is private to avoid a private-type lint.
  - `.kiro/specs/app-redesign/whole-app-redesign-todo.md` — recorded Task 5
    commit and Task 6 evidence.
- Preserved behavior:
  - Current bounded selected-month loader and `NearbyMonthSelector`.
  - Integrated search, in-memory sort behavior, tag-filter reloads, and
    `_requestId` stale-response protection.
  - Date grouping, category identity, tap-to-edit, payment/time metadata, and
    Add Transaction navigation callback.
  - No Search destination, totals block, legacy fetch-more pagination, or
    alternate loading path was added.
- Validation evidence:
  - Test-first run failed exactly on hardcoded amount colors and a 135px
    narrow/large-text overflow, proving both production fixes were required.
  - `flutter test test/transaction_card_test.dart test/transactions_screen_test.dart`
    → `All tests passed!` (12/12) after the fixes.
  - `flutter analyze lib/widgets/TransactionCard.dart test/transaction_card_test.dart test/transactions_screen_test.dart`
    → 0 errors/warnings; one existing `file_names` info for
    `TransactionCard.dart`.
  - `flutter build apk --release` →
    `✓ Built build/app/outputs/flutter-apk/app-release.apk (54.7MB)`.
- Commit: recorded on commit (see git log for this Task 6 commit).

### Task 7 — Whole-app integration
- Status: Not started
- Validation evidence: Pending
- Commit: Pending
