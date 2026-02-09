# Dashboard Refresh Strategy

## Problem
When users add/edit/delete data (transactions, budgets, recurring items, etc.), the dashboard doesn't automatically refresh because it uses `FutureProvider` which caches results.

## Current Solutions

### Solution 1: Return-Based Refresh (Existing Pattern)
Screens return `true` when data is modified, and the caller checks for this:

```dart
// In dashboard_header.dart
final shouldReload = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SettingsScreen()),
);
if (shouldReload == true) onLoad();
```

**Pros:** Simple, explicit
**Cons:** Requires manual implementation in every screen, easy to forget

### Solution 2: Provider Invalidation (Recommended)
Directly invalidate the dashboard provider after data changes:

```dart
// After adding/editing/deleting data
ref.invalidate(dashboardProvider);
Navigator.pop(context);
```

**Pros:** Immediate, automatic refresh
**Cons:** Requires access to `WidgetRef`

## Recommended Approach

Use **Provider Invalidation** for all data modification screens. This ensures instant updates without relying on return values.

## Implementation Checklist

### ✅ Already Implemented
- [x] Recurring Transactions (add/delete)

### 🔄 Needs Implementation

#### High Priority (Affects Dashboard Directly)
- [ ] **Transactions**
  - [ ] `add_expense.dart` - After adding expense
  - [ ] `edit_entry.dart` - After editing/deleting transaction
  
- [ ] **Budgets**
  - [ ] `add_budget.dart` - After adding budget
  - [ ] `edit_budget.dart` - After editing/deleting budget
  
- [ ] **Goals**
  - [ ] `add_goal.dart` - After adding goal
  - [ ] `edit_goal.dart` - After editing/deleting goal
  
- [ ] **Credit Cards**
  - [ ] `add_card.dart` - After adding card
  - [ ] `edit_card.dart` - After editing/deleting card
  
- [ ] **Loans**
  - [ ] `add_loan.dart` - After adding loan
  - [ ] `edit_loan.dart` - After editing/deleting loan

#### Medium Priority (Affects Net Worth/Assets)
- [ ] **Assets**
  - [ ] `edit_asset.dart` - After editing/deleting asset
  
- [ ] **Subscriptions**
  - [ ] `add_subscription.dart` - After adding subscription
  
- [ ] **Investments**
  - [ ] `investments_screen.dart` - After adding/editing investment

- [ ] **Retirement**
  - [ ] `retirement_dashboard.dart` - After adding/editing retirement account

#### Low Priority (Indirect Impact)
- [ ] Settings screens (only if they modify financial data)

## Implementation Pattern

### For ConsumerWidget/ConsumerStatefulWidget

```dart
import 'package:trueledger/presentation/providers/dashboard_provider.dart';

// After saving data
await repository.saveData(...);

// Invalidate dashboard to trigger refresh
ref.invalidate(dashboardProvider);

// Navigate back
if (mounted) Navigator.pop(context);
```

### For StatefulWidget (Convert to ConsumerStatefulWidget)

If the widget is a `StatefulWidget`, convert it to `ConsumerStatefulWidget`:

```dart
// Before
class AddExpenseScreen extends StatefulWidget {
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // ...
}

// After
class AddExpenseScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  // Now has access to `ref`
  // ...
}
```

## Testing Considerations

When adding provider invalidation:
1. Ensure tests mock or override the dashboard provider
2. Verify that invalidation is called after data changes
3. Test that navigation still works correctly

## Alternative: Auto-Refresh Provider

For future consideration, we could create a self-refreshing provider:

```dart
final dashboardProvider = StreamProvider<DashboardData>((ref) {
  // Listen to data change events
  final dataChangeStream = ref.watch(dataChangeNotifierProvider);
  
  return dataChangeStream.asyncMap((_) async {
    final useCase = ref.watch(getDashboardDataUseCaseProvider);
    final result = await useCase(NoParams());
    return result.getOrThrow;
  });
});
```

This would eliminate the need for manual invalidation, but adds complexity.

## Summary

**Action:** Add `ref.invalidate(dashboardProvider)` to all screens that modify financial data, prioritizing those that directly affect the dashboard display.

**Timeline:** 
- High priority screens: Immediate
- Medium priority screens: Within 1 week
- Low priority screens: As needed

**Success Criteria:**
- Dashboard updates instantly after any data modification
- No need to manually refresh or navigate away and back
- Consistent user experience across all screens
