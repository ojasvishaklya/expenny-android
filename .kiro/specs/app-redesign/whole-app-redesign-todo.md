# Whole-App Redesign Implementation Tracker

This tracker records implementation, validation, and commit evidence for the confirmed Material 3 whole-app redesign. Tasks are executed and committed in order. No changes are pushed.

| Task | Status | Acceptance | Validation | Commit |
|---|---|---|---|---|
| 1. App-shell navigation contract | Done | Dashboard → Transactions → Preferences; Transactions opens by default; Preferences uses `Icons.tune`; no Settings/Search destination | `flutter test test/bottom_nav_bar_test.dart test/home_screen_test.dart` → All tests passed (6/6); `flutter analyze` on changed files → 0 errors/warnings (4 pre-existing info lints only); `flutter build apk --release` → Built app-release.apk | See Task 1 note |
| 2. Grouped Preferences | Not started | Five scrollable groups; honest SMS status; disabled Import data; destructive delete semantics; existing actions preserved | Pending | Pending |
| 3. DisplayCard net hero | Not started | Month-attributed net hero, income/expense tiles, savings rate, header/subtitle and month-first layout; duplicate summary widget removed | Pending | Pending |
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
- Commit: recorded on commit (see git log for this Task 1 commit).

### Task 2 — Grouped Preferences
- Status: Not started
- Validation evidence: Pending
- Commit: Pending

### Task 3 — DisplayCard net hero
- Status: Not started
- Validation evidence: Pending
- Commit: Pending

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
