# Design Patterns

TrueCash leverages several design patterns to maintain clean, testable, and maintainable code.

## Repository Pattern

The **Repository Pattern** abstracts data access logic and provides a clean API for the domain layer.

### Purpose

- Decouple business logic from data access implementation
- Provide a single source of truth for data operations
- Enable easy testing with mock implementations
- Allow swapping data sources without affecting business logic

### Implementation

```dart
// Domain Layer: Interface
abstract class IFinancialRepository {
  Future<List<Budget>> getBudgets();
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(int id, int monthlyLimit);
  Future<void> deleteBudget(int id);
}

// Data Layer: Implementation
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
  
  // ... other implementations
}
```

### Benefits

- **Testability**: Easy to mock for unit tests
- **Flexibility**: Swap SQLite for another database
- **Separation**: Business logic doesn't know about database details

## Use Case Pattern

The **Use Case Pattern** encapsulates a single business operation.

### Purpose

- Single Responsibility: One use case = one operation
- Reusability: Use cases can be composed
- Testability: Easy to test business logic in isolation
- Clear intent: Use case name describes what it does

### Implementation

```dart
// Base class
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

// Concrete use case
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

// Usage
final useCase = GetBudgetsUseCase(repository);
final result = await useCase(NoParams());
```

### Benefits

- **Clear boundaries**: Each use case has a single purpose
- **Composable**: Use cases can call other use cases
- **Testable**: Mock repository, test business logic

## Result Pattern

The **Result Pattern** provides type-safe error handling without exceptions.

### Purpose

- Make errors explicit in the type system
- Avoid hidden exceptions
- Force error handling at compile time
- Provide better error information

### Implementation

```dart
// Result type
sealed class Result<T> {
  const Result();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T get getOrThrow;
  AppFailure get failureOrThrow;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
  
  @override
  T get getOrThrow => value;
  
  @override
  AppFailure get failureOrThrow => throw StateError('Not a failure');
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
  
  @override
  T get getOrThrow => throw failure;
  
  @override
  AppFailure get failureOrThrow => failure;
}

// Failure types
abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure(String message) : super(message);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(String message) : super(message);
}
```

### Usage

```dart
// Return Result
Future<Result<Budget>> getBudget(int id) async {
  try {
    final budget = await repository.getBudget(id);
    return Success(budget);
  } catch (e) {
    return Failure(DatabaseFailure(e.toString()));
  }
}

// Handle Result
final result = await getBudget(1);

if (result.isSuccess) {
  final budget = result.getOrThrow;
  print('Budget: ${budget.category}');
} else {
  final failure = result.failureOrThrow;
  print('Error: ${failure.message}');
}
```

### Benefits

- **Type safety**: Errors are visible in type signatures
- **Explicit**: Cannot ignore errors
- **Testable**: Easy to test error cases

## Provider Pattern

The **Provider Pattern** (via Riverpod) handles dependency injection and state management.

### Purpose

- Dependency injection without boilerplate
- State management with compile-time safety
- Scoped rebuilds for performance
- Easy testing with overrides

### Implementation

```dart
// Level 1: Repository Provider
final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return FinancialRepositoryImpl();
});

// Level 2: Use Case Provider
final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  return GetBudgetsUseCase(ref.watch(financialRepositoryProvider));
});

// Level 3: State Provider
final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final useCase = ref.watch(getBudgetsUseCaseProvider);
  final result = await useCase(NoParams());
  return result.getOrThrow;
});

// Level 4: UI
class BudgetsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    
    return budgetsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (budgets) => BudgetsList(budgets: budgets),
    );
  }
}
```

### Benefits

- **No boilerplate**: No manual dependency injection
- **Compile-time safety**: Errors caught at compile time
- **Testability**: Easy to override providers in tests
- **Performance**: Fine-grained rebuilds

## Summary

TrueCash uses these patterns to achieve:

- **Clean Architecture**: Repository, Use Case, Result patterns
- **Dependency Injection**: Provider pattern
- **Error Handling**: Result pattern
- **State Management**: Observer pattern (via Riverpod)

Each pattern serves a specific purpose and works together to create a maintainable, testable codebase.

## Next Steps

- [Architecture Overview](../architecture/overview.md) - See how patterns fit together
- [Adding Features](adding-features.md) - Apply patterns in practice
- [Error Handling](error-handling.md) - Deep dive into Result pattern
