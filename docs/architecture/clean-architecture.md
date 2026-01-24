# Clean Architecture

A deep dive into Clean Architecture principles as implemented in TrueCash.

## What is Clean Architecture?

Clean Architecture is a software design philosophy introduced by Robert C. Martin (Uncle Bob) that emphasizes:

1. **Independence of Frameworks**: Business logic doesn't depend on external libraries
2. **Testability**: Business logic can be tested without UI, database, or external dependencies
3. **Independence of UI**: UI can change without affecting business logic
4. **Independence of Database**: Database can be swapped without affecting business logic
5. **Independence of External Agencies**: Business logic doesn't know about the outside world

## The Dependency Rule

The overriding rule that makes this architecture work:

> **Source code dependencies must point only inward, toward higher-level policies.**

```
┌─────────────────────────────────────┐
│        Presentation Layer           │  ← Frameworks & Drivers
│  (UI, Providers, Widgets)           │     (Most volatile)
└──────────────┬──────────────────────┘
               │ depends on
┌──────────────▼──────────────────────┐
│         Domain Layer                │  ← Business Rules
│  (Use Cases, Entities, Interfaces)  │     (Most stable)
└──────────────┬──────────────────────┘
               │ implemented by
┌──────────────▼──────────────────────┐
│          Data Layer                 │  ← Interface Adapters
│  (Repositories, Data Sources)       │     (Medium volatility)
└─────────────────────────────────────┘
```

## Layers in Detail

### Presentation Layer (Outermost)

**Purpose**: Handle user interface and user interactions

**Components**:
- Screens (Flutter widgets)
- Providers (Riverpod state management)
- UI components

**Rules**:
- Can depend on Domain layer
- Cannot depend on Data layer directly
- No business logic
- Delegates all operations to use cases

**Example**:
```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider (from Presentation layer)
    final dashboardAsync = ref.watch(dashboardProvider);
    
    return dashboardAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorView(err),
      data: (dashboard) => DashboardView(dashboard),
    );
  }
}
```

### Domain Layer (Core)

**Purpose**: Contain all business logic and rules

**Components**:
- **Entities**: Core business models (Budget, Transaction, etc.)
- **Use Cases**: Single-purpose business operations
- **Repository Interfaces**: Contracts for data access
- **Services**: Complex business logic (e.g., AI insights)

**Rules**:
- Pure Dart (no Flutter dependencies)
- No implementation details
- Defines interfaces, doesn't implement them
- Most stable layer (changes least frequently)

**Example**:
```dart
// Entity
class Budget {
  final int id;
  final String category;
  final int monthlyLimit;
  
  Budget({required this.id, required this.category, required this.monthlyLimit});
}

// Repository Interface
abstract class IFinancialRepository {
  Future<List<Budget>> getBudgets();
  Future<void> addBudget(Budget budget);
}

// Use Case
class GetBudgetsUseCase extends UseCase<List<Budget>, NoParams> {
  final IFinancialRepository repository;
  
  GetBudgetsUseCase(this.repository);
  
  @override
  Future<Result<List<Budget>>> call(NoParams params) async {
    try {
      final budgets = await repository.getBudgets();
      return Success(budgets);
    } catch (e) {
      return Failure(DatabaseFailure(e.toString()));
    }
  }
}
```

### Data Layer (Infrastructure)

**Purpose**: Implement data access and persistence

**Components**:
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Data Sources**: SQLite database, file system, etc.
- **Migrations**: Database schema evolution

**Rules**:
- Implements Domain interfaces
- Handles all data persistence
- No business logic
- Can use platform-specific code

**Example**:
```dart
class FinancialRepositoryImpl implements IFinancialRepository {
  @override
  Future<List<Budget>> getBudgets() async {
    final db = await AppDatabase.db;
    final results = await db.query('budgets');
    return results.map((r) => Budget.fromMap(r)).toList();
  }
  
  @override
  Future<void> addBudget(Budget budget) async {
    final db = await AppDatabase.db;
    await db.insert('budgets', budget.toMap());
  }
}
```

## Benefits of Clean Architecture

### 1. Testability

Each layer can be tested independently:

```dart
// Test use case without UI or database
test('GetBudgetsUseCase returns budgets', () async {
  final mockRepo = MockFinancialRepository();
  final useCase = GetBudgetsUseCase(mockRepo);
  
  when(() => mockRepo.getBudgets())
      .thenAnswer((_) async => [Budget(...)]);
  
  final result = await useCase(NoParams());
  
  expect(result.isSuccess, true);
});
```

### 2. Flexibility

Easy to swap implementations:

```dart
// Development: Use in-memory repository
final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return InMemoryFinancialRepository();
});

// Production: Use SQLite repository
final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return FinancialRepositoryImpl();
});
```

### 3. Maintainability

Changes are isolated to specific layers:

- UI redesign? Only touch Presentation layer
- Change database? Only touch Data layer
- New business rule? Only touch Domain layer

### 4. Scalability

Easy to add new features without affecting existing code:

```
New Feature:
1. Add entity to Domain
2. Add methods to repository interface
3. Implement in Data layer
4. Create use case
5. Add UI in Presentation layer
```

## Common Patterns

### Repository Pattern

Abstracts data access:

```dart
// Domain defines the contract
abstract class IFinancialRepository {
  Future<List<Transaction>> getTransactions();
}

// Data implements the contract
class FinancialRepositoryImpl implements IFinancialRepository {
  @override
  Future<List<Transaction>> getTransactions() async {
    // Implementation details
  }
}
```

### Use Case Pattern

Encapsulates business operations:

```dart
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

class GetTransactionsUseCase extends UseCase<List<Transaction>, NoParams> {
  final IFinancialRepository repository;
  
  GetTransactionsUseCase(this.repository);
  
  @override
  Future<Result<List<Transaction>>> call(NoParams params) async {
    // Business logic here
  }
}
```

### Result Pattern

Type-safe error handling:

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
```

## Anti-Patterns to Avoid

### ❌ Skipping Layers

```dart
// DON'T: UI directly accessing database
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = await AppDatabase.db; // ❌ Wrong!
    final data = await db.query('transactions');
    return ListView(...);
  }
}
```

### ❌ Business Logic in UI

```dart
// DON'T: Business logic in widget
class MyScreen extends StatelessWidget {
  void addTransaction() {
    if (amount > 0 && category.isNotEmpty) { // ❌ Business logic!
      // Save to database
    }
  }
}
```

### ❌ Domain Depending on Data

```dart
// DON'T: Use case depending on concrete repository
class MyUseCase {
  final FinancialRepositoryImpl repository; // ❌ Concrete implementation!
}

// DO: Use case depending on interface
class MyUseCase {
  final IFinancialRepository repository; // ✅ Interface!
}
```

## Next Steps

- [Project Structure](project-structure.md) - File organization
- [Data Flow](data-flow.md) - How data moves through layers
- [State Management](state-management.md) - Riverpod patterns
- [Adding Features](../development/adding-features.md) - Practical guide
