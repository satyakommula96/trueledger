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
