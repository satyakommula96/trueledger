# Architecture Overview

TrueCash is built using **Clean Architecture** principles, ensuring a scalable, testable, and maintainable codebase.

## Core Principles

TrueCash is designed around these fundamental principles:

- ✅ **Privacy First**: All data stored locally with encryption (mobile) or secure storage (desktop)
- ✅ **Offline First**: No cloud dependencies, works completely offline
- ✅ **Clean Architecture**: Clear separation of concerns across layers
- ✅ **Testable**: Comprehensive unit, widget, and integration tests
- ✅ **Cross-Platform**: Single codebase for all platforms

## What is Clean Architecture?

Clean Architecture, introduced by Robert C. Martin (Uncle Bob), is a software design philosophy that separates concerns into distinct layers. Each layer has specific responsibilities and dependencies flow inward toward the business logic.

### Benefits

1. **Independence**: Business logic is independent of frameworks, UI, and databases
2. **Testability**: Business logic can be tested without UI, database, or external dependencies
3. **Maintainability**: Changes in one layer don't affect others
4. **Flexibility**: Easy to swap implementations (e.g., change database or UI framework)

## Architecture Layers

TrueCash implements Clean Architecture with four distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   Screens   │  │   Providers  │  │   Widgets     │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │ Uses
┌────────────────────────▼────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Use Cases  │  │   Entities   │  │  Interfaces   │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │ Implements
┌────────────────────────▼────────────────────────────────┐
│                     DATA LAYER                           │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │Repositories │  │ Data Sources │  │    Models     │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │ Uses
┌────────────────────────▼────────────────────────────────┐
│                      CORE LAYER                          │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   Utils     │  │   Services   │  │    Theme      │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Layer Descriptions

#### 1. Presentation Layer
**Location**: `lib/presentation/`

Handles all UI and user interactions. This layer is responsible for:
- Displaying data to users
- Capturing user input
- Managing UI state with Riverpod
- Delegating business logic to use cases

**Key Components**:
- **Screens**: Flutter widgets (Dashboard, Analysis, Settings, etc.)
- **Providers**: Riverpod state management
- **Widgets**: Reusable UI components

#### 2. Domain Layer
**Location**: `lib/domain/`

Contains the business logic and rules. This is the heart of the application:
- Defines what the app does
- Contains no framework-specific code (pure Dart)
- Defines interfaces for data access
- Encapsulates business operations in use cases

**Key Components**:
- **Use Cases**: Single-purpose business operations
- **Entities**: Core business models (Budget, Transaction, etc.)
- **Repository Interfaces**: Contracts for data access
- **Services**: Complex business logic (AI insights)

#### 3. Data Layer
**Location**: `lib/data/`

Handles data persistence and retrieval:
- Implements repository interfaces from the domain layer
- Manages database operations
- Handles data transformations

**Key Components**:
- **Repositories**: Implementations of domain interfaces
- **Data Sources**: SQLite database access
- **Migrations**: Database schema evolution

#### 4. Core Layer
**Location**: `lib/core/`

Provides cross-cutting concerns and utilities:
- Shared utilities used across all layers
- Platform-specific services
- App-wide configuration

**Key Components**:
- **Utils**: Helper functions, extensions
- **Services**: Notifications, platform-specific code
- **Theme**: App theming and styling
- **Error**: Error handling types

## Dependency Rule

The **Dependency Rule** is the most important principle in Clean Architecture:

> **Dependencies always point inward**

```
Presentation → Domain → Data → Core
     ↓           ↓        ↓
   (Uses)    (Defines)  (Implements)
```

**What this means**:
- ✅ Presentation can depend on Domain
- ✅ Domain defines interfaces (doesn't depend on Data)
- ✅ Data implements Domain interfaces
- ❌ Domain cannot depend on Presentation or Data
- ❌ Data cannot depend on Presentation

## Non-Negotiable Rules

These rules **must never be violated**. They prevent architectural degradation and ensure long-term maintainability.

### Rule 1: Domain Must Not Depend on Flutter

**Why**: Domain layer contains business logic that should be framework-independent.

```dart
// ❌ WRONG - Domain depending on Flutter
import 'package:flutter/material.dart';  // NO!

class Budget {
  final Color color;  // Flutter-specific type
}
```

```dart
// ✅ CORRECT - Pure Dart
class Budget {
  final int id;
  final String category;
  final int monthlyLimit;  // All pure Dart types
}
```

**Enforcement**: Domain layer (`lib/domain/`) must only import:
- `dart:core`, `dart:async`, `dart:collection`
- Other domain files
- Core utilities (pure Dart only)

### Rule 2: UI Must Not Contain Business Logic

**Why**: Business logic in UI makes it untestable and violates separation of concerns.

```dart
// ❌ WRONG - Business logic in widget
class AddBudgetScreen extends StatelessWidget {
  void saveBudget() {
    if (amount > 0 && category.isNotEmpty) {  // Validation logic!
      database.insert('budgets', {...});      // Database access!
    }
  }
}
```

```dart
// ✅ CORRECT - Delegate to use case
class AddBudgetScreen extends ConsumerWidget {
  void saveBudget(WidgetRef ref) {
    final useCase = ref.read(addBudgetUseCaseProvider);
    useCase(AddBudgetParams(amount: amount, category: category));
  }
}
```

**Enforcement**: Presentation layer must:
- Only handle UI rendering and user input
- Delegate all business operations to use cases
- Never directly access data layer

### Rule 3: Repositories Must Not Perform Validation

**Why**: Validation is business logic and belongs in the domain layer.

```dart
// ❌ WRONG - Validation in repository
class FinancialRepositoryImpl {
  Future<void> addBudget(Budget budget) async {
    if (budget.monthlyLimit <= 0) {  // NO! This is business logic
      throw Exception('Invalid amount');
    }
    await db.insert('budgets', budget.toMap());
  }
}
```

```dart
// ✅ CORRECT - Validation in use case
class AddBudgetUseCase {
  Future<Result<void>> call(AddBudgetParams params) async {
    // Validation here (domain layer)
    if (params.monthlyLimit <= 0) {
      return Failure(ValidationFailure('Amount must be positive'));
    }
    
    // Repository just persists
    return await repository.addBudget(params.toBudget());
  }
}
```

**Enforcement**: Repositories must:
- Only handle data persistence and retrieval
- Never validate business rules
- Never throw business exceptions

### Rule 4: All Failures Must Be Modeled

**Why**: Explicit error handling prevents runtime crashes and makes errors visible in the type system.

```dart
// ❌ WRONG - Throwing exceptions
Future<List<Budget>> getBudgets() async {
  final data = await db.query('budgets');
  if (data.isEmpty) {
    throw Exception('No budgets found');  // Invisible in type signature!
  }
  return data.map((e) => Budget.fromMap(e)).toList();
}
```

```dart
// ✅ CORRECT - Result type
Future<Result<List<Budget>>> getBudgets() async {
  try {
    final data = await db.query('budgets');
    final budgets = data.map((e) => Budget.fromMap(e)).toList();
    return Success(budgets);
  } catch (e) {
    return Failure(DatabaseFailure(e.toString()));
  }
}
```

**Enforcement**: All use cases and repositories must:
- Return `Result<T>` or `Future<Result<T>>`
- Never throw exceptions for business errors
- Model all failure cases explicitly

### Rule 5: Use Absolute Imports Only

**Why**: Relative imports break when files are moved and make refactoring difficult.

```dart
// ❌ WRONG - Relative imports
import '../../domain/models/models.dart';
import '../../../data/repositories/financial_repository_impl.dart';
```

```dart
// ✅ CORRECT - Absolute package imports
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/data/repositories/financial_repository_impl.dart';
```

**Enforcement**: All imports must use `package:truecash/...` format.

### Rule 6: One Use Case Per Operation

**Why**: Single Responsibility Principle - each use case should do one thing well.

```dart
// ❌ WRONG - Multiple operations in one use case
class BudgetUseCase {
  Future<List<Budget>> getAll() { ... }
  Future<void> add(Budget budget) { ... }
  Future<void> delete(int id) { ... }
}
```

```dart
// ✅ CORRECT - Separate use cases
class GetBudgetsUseCase extends UseCase<List<Budget>, NoParams> { ... }
class AddBudgetUseCase extends UseCase<void, AddBudgetParams> { ... }
class DeleteBudgetUseCase extends UseCase<void, int> { ... }
```

**Enforcement**: Each use case must:
- Extend `UseCase<T, Params>`
- Implement exactly one `call()` method
- Have a clear, single purpose

## Violation Detection

**How to check for violations**:

```bash
# Check for Flutter imports in domain layer
grep -r "import 'package:flutter" lib/domain/

# Check for database access in presentation layer
grep -r "AppDatabase.db" lib/presentation/

# Check for business logic in widgets
# (Manual code review required)

# Run analyzer
flutter analyze
```

**These rules are enforced through**:
- Code reviews
- Automated linting (where possible)
- Architecture documentation
- Team discipline

**Violating these rules will result in**:
- Pull request rejection
- Mandatory refactoring
- Technical debt accumulation
- Reduced testability and maintainability

## State Management

TrueCash uses **Riverpod** for state management and dependency injection.

### Why Riverpod?

1. **Compile-time safety**: Catch errors at compile time, not runtime
2. **No BuildContext**: Access providers anywhere
3. **Testability**: Easy to mock and test
4. **Scoped providers**: Fine-grained control over rebuilds

### Provider Hierarchy

```dart
// Level 1: Repository (singleton)
final financialRepositoryProvider = Provider<IFinancialRepository>(...);

// Level 2: Use Cases (depend on repositories)
final getDashboardDataUseCaseProvider = Provider<GetDashboardDataUseCase>(
  (ref) => GetDashboardDataUseCase(ref.watch(financialRepositoryProvider))
);

// Level 3: State Providers (depend on use cases)
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final useCase = ref.watch(getDashboardDataUseCaseProvider);
  return (await useCase(NoParams())).getOrThrow;
});

// Level 4: UI (watches state providers)
Widget build(BuildContext context, WidgetRef ref) {
  final dashboardAsync = ref.watch(dashboardProvider);
  return dashboardAsync.when(...);
}
```

## Data Flow Example

Let's trace how data flows when loading the dashboard:

```
1. User opens app
   ↓
2. DashboardScreen watches dashboardProvider
   ↓
3. dashboardProvider calls getDashboardDataUseCase
   ↓
4. Use case calls IFinancialRepository methods
   ↓
5. FinancialRepositoryImpl queries SQLite database
   ↓
6. Data flows back up through layers
   ↓
7. Provider updates state
   ↓
8. UI rebuilds with new data
```

**Code Implementation**:

```dart
// 1. UI Layer (Presentation)
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    
    return dashboardAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (dashboard) => DashboardView(dashboard),
    );
  }
}

// 2. Provider Layer (Presentation)
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final useCase = ref.watch(getDashboardDataUseCaseProvider);
  final result = await useCase(NoParams());
  return result.getOrThrow;
});

// 3. Use Case Layer (Domain)
class GetDashboardDataUseCase extends UseCase<DashboardData, NoParams> {
  final IFinancialRepository repository;
  
  @override
  Future<Result<DashboardData>> call(NoParams params) async {
    final summary = await repository.getMonthlySummary();
    final budgets = await repository.getBudgets();
    final goals = await repository.getSavingGoals();
    
    return Success(DashboardData(
      summary: summary,
      budgets: budgets,
      goals: goals,
    ));
  }
}

// 4. Repository Layer (Data)
class FinancialRepositoryImpl implements IFinancialRepository {
  @override
  Future<MonthlySummary> getMonthlySummary() async {
    final db = await AppDatabase.db;
    final income = await db.query('income_sources');
    final expenses = await db.query('variable_expenses');
    
    return MonthlySummary(
      totalIncome: _calculateTotal(income),
      totalExpenses: _calculateTotal(expenses),
    );
  }
}
```

## Key Design Patterns

TrueCash leverages several design patterns:

1. **[Repository Pattern](../development/design-patterns.md#repository-pattern)**: Abstracts data access
2. **[Use Case Pattern](../development/design-patterns.md#use-case-pattern)**: Encapsulates business operations
3. **[Result Pattern](../development/design-patterns.md#result-pattern)**: Type-safe error handling
4. **[Provider Pattern](../development/design-patterns.md#provider-pattern)**: Dependency injection

## Testing Strategy

The architecture enables comprehensive testing at every layer:

```
         ┌─────────────┐
         │ Integration │  (1 test)
         │   Tests     │  Full user flows
         └─────────────┘
        ┌───────────────┐
        │ Widget Tests  │  (1 test)
        │  UI Testing   │  Screen rendering
        └───────────────┘
       ┌─────────────────┐
       │   Unit Tests    │  (19 tests)
       │ Business Logic  │  Use cases, repositories
       └─────────────────┘
```

**All 21 tests pass**, ensuring code quality and reliability.

[Learn more about testing →](../development/testing.md)

## Next Steps

- [Clean Architecture Deep Dive](clean-architecture.md) - Detailed explanation
- [Project Structure](project-structure.md) - File organization
- [Data Flow](data-flow.md) - Detailed data flow examples
- [State Management](state-management.md) - Riverpod patterns
- [Adding Features](../development/adding-features.md) - Step-by-step guide
