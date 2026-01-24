# Error & Failure Handling

This guide explains how TrueCash handles errors using the **Result Pattern** for type-safe, explicit error handling.

## Overview

TrueCash uses a `Result<T>` type instead of throwing exceptions. This makes errors:
- **Visible** in the type signature
- **Explicit** and impossible to ignore
- **Type-safe** and caught at compile time
- **Testable** without try-catch blocks

## The Result Type

### Definition

```dart
// lib/core/utils/result.dart

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
```

### Usage

```dart
// Return a Result
Future<Result<Budget>> getBudget(int id) async {
  try {
    final budget = await repository.getBudget(id);
    return Success(budget);
  } catch (e) {
    return Failure(DatabaseFailure(e.toString()));
  }
}

// Handle a Result
final result = await getBudget(1);

if (result.isSuccess) {
  final budget = result.getOrThrow;
  print('Budget: ${budget.category}');
} else {
  final failure = result.failureOrThrow;
  print('Error: ${failure.message}');
}
```

## AppFailure Types

All failures in TrueCash extend `AppFailure`:

```dart
// lib/core/error/failure.dart

abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
  
  @override
  String toString() => message;
}

// Database errors
class DatabaseFailure extends AppFailure {
  const DatabaseFailure(String message) : super(message);
}

// Validation errors
class ValidationFailure extends AppFailure {
  const ValidationFailure(String message) : super(message);
}

// File system errors
class FileSystemFailure extends AppFailure {
  const FileSystemFailure(String message) : super(message);
}

// Parsing errors
class ParsingFailure extends AppFailure {
  const ParsingFailure(String message) : super(message);
}

// Generic errors
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(String message) : super(message);
}
```

## Where Failures Are Created

### 1. Repository Layer (Data)

Repositories catch exceptions and convert them to failures:

```dart
class FinancialRepositoryImpl implements IFinancialRepository {
  @override
  Future<Result<List<Budget>>> getBudgets() async {
    try {
      final db = await AppDatabase.db;
      final results = await db.query('budgets');
      final budgets = results.map((r) => Budget.fromMap(r)).toList();
      return Success(budgets);
    } on DatabaseException catch (e) {
      return Failure(DatabaseFailure('Failed to get budgets: ${e.message}'));
    } catch (e) {
      return Failure(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> addBudget(Budget budget) async {
    try {
      final db = await AppDatabase.db;
      await db.insert('budgets', budget.toMap());
      return const Success(null);
    } on DatabaseException catch (e) {
      return Failure(DatabaseFailure('Failed to add budget: ${e.message}'));
    } catch (e) {
      return Failure(UnexpectedFailure(e.toString()));
    }
  }
}
```

### 2. Use Case Layer (Domain)

Use cases add validation failures and pass through repository failures:

```dart
class AddBudgetUseCase extends UseCase<void, AddBudgetParams> {
  final IFinancialRepository repository;
  
  AddBudgetUseCase(this.repository);
  
  @override
  Future<Result<void>> call(AddBudgetParams params) async {
    // Validation (creates ValidationFailure)
    if (params.category.isEmpty) {
      return const Failure(ValidationFailure('Category cannot be empty'));
    }
    
    if (params.monthlyLimit <= 0) {
      return const Failure(ValidationFailure('Monthly limit must be positive'));
    }
    
    // Delegate to repository (may return DatabaseFailure)
    return await repository.addBudget(params.toBudget());
  }
}
```

### 3. Service Layer (Domain/Core)

Services can also create failures:

```dart
class NotificationService {
  Future<Result<void>> scheduleNotification(String title, String body) async {
    try {
      await flutterLocalNotificationsPlugin.show(...);
      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedFailure('Failed to schedule notification: $e'));
    }
  }
}
```

## How UI Must Handle Failures

### 1. In Providers (Presentation)

Providers can either:
- **Pass failures through** (let UI handle them)
- **Convert to exceptions** (for FutureProvider error state)

#### Option A: Pass Through (Recommended for StateNotifier)

```dart
class BudgetNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final GetBudgetsUseCase getBudgetsUseCase;
  
  BudgetNotifier(this.getBudgetsUseCase) : super(const AsyncValue.loading()) {
    loadBudgets();
  }
  
  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    
    final result = await getBudgetsUseCase(NoParams());
    
    state = result.isSuccess
        ? AsyncValue.data(result.getOrThrow)
        : AsyncValue.error(result.failureOrThrow, StackTrace.current);
  }
}
```

#### Option B: Throw (For FutureProvider)

```dart
final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final useCase = ref.watch(getBudgetsUseCaseProvider);
  final result = await useCase(NoParams());
  
  // Throws if failure, caught by FutureProvider
  return result.getOrThrow;
});
```

### 2. In Widgets (Presentation)

Widgets handle failures in the UI:

```dart
class BudgetsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    
    return budgetsAsync.when(
      loading: () => const CircularProgressIndicator(),
      
      // Handle errors
      error: (error, stack) {
        if (error is ValidationFailure) {
          return ErrorView(
            icon: Icons.warning,
            message: error.message,
            action: 'Fix Input',
          );
        } else if (error is DatabaseFailure) {
          return ErrorView(
            icon: Icons.error,
            message: 'Database error: ${error.message}',
            action: 'Retry',
            onAction: () => ref.refresh(budgetsProvider),
          );
        } else {
          return ErrorView(
            icon: Icons.error_outline,
            message: 'Unexpected error: $error',
            action: 'Report',
          );
        }
      },
      
      // Handle success
      data: (budgets) => BudgetsList(budgets: budgets),
    );
  }
}
```

### 3. User-Friendly Error Messages

Map technical failures to user-friendly messages:

```dart
String getUserMessage(AppFailure failure) {
  if (failure is ValidationFailure) {
    return failure.message; // Already user-friendly
  } else if (failure is DatabaseFailure) {
    return 'Unable to access your data. Please try again.';
  } else if (failure is FileSystemFailure) {
    return 'Unable to save file. Check storage permissions.';
  } else {
    return 'Something went wrong. Please try again later.';
  }
}
```

## Best Practices

### ✅ DO

1. **Always return Result from use cases and repositories**
   ```dart
   Future<Result<Budget>> getBudget(int id);
   ```

2. **Create specific failure types**
   ```dart
   class BudgetNotFoundFailure extends AppFailure {
     const BudgetNotFoundFailure(int id) : super('Budget $id not found');
   }
   ```

3. **Handle all failure cases in UI**
   ```dart
   error: (error, stack) {
     if (error is ValidationFailure) { ... }
     else if (error is DatabaseFailure) { ... }
     else { ... }
   }
   ```

4. **Provide user-friendly error messages**
   ```dart
   'Unable to save budget. Please check your input.'
   ```

5. **Log technical details for debugging**
   ```dart
   debugPrint('DatabaseFailure: ${failure.message}');
   ```

### ❌ DON'T

1. **Don't throw exceptions for business errors**
   ```dart
   // ❌ WRONG
   if (amount <= 0) throw Exception('Invalid amount');
   
   // ✅ CORRECT
   if (amount <= 0) return Failure(ValidationFailure('Amount must be positive'));
   ```

2. **Don't ignore failures**
   ```dart
   // ❌ WRONG
   final result = await getBudget(1);
   final budget = result.getOrThrow; // May throw!
   
   // ✅ CORRECT
   final result = await getBudget(1);
   if (result.isSuccess) {
     final budget = result.getOrThrow;
   }
   ```

3. **Don't create generic error messages**
   ```dart
   // ❌ WRONG
   return Failure(UnexpectedFailure('Error'));
   
   // ✅ CORRECT
   return Failure(DatabaseFailure('Failed to insert budget: ${e.message}'));
   ```

4. **Don't catch and rethrow**
   ```dart
   // ❌ WRONG
   try {
     return await repository.getBudget(id);
   } catch (e) {
     throw e; // Pointless
   }
   
   // ✅ CORRECT
   return await repository.getBudget(id); // Let it return Result
   ```

## Testing Failures

### Unit Tests

```dart
test('AddBudgetUseCase returns ValidationFailure for empty category', () async {
  final useCase = AddBudgetUseCase(mockRepo);
  
  final result = await useCase(AddBudgetParams(
    category: '',
    monthlyLimit: 500,
  ));
  
  expect(result.isFailure, true);
  expect(result.failureOrThrow, isA<ValidationFailure>());
  expect(result.failureOrThrow.message, contains('Category cannot be empty'));
});

test('GetBudgetsUseCase returns DatabaseFailure on error', () async {
  when(() => mockRepo.getBudgets())
      .thenAnswer((_) async => Failure(DatabaseFailure('Connection failed')));
  
  final useCase = GetBudgetsUseCase(mockRepo);
  final result = await useCase(NoParams());
  
  expect(result.isFailure, true);
  expect(result.failureOrThrow, isA<DatabaseFailure>());
});
```

### Widget Tests

```dart
testWidgets('Shows error message on DatabaseFailure', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        budgetsProvider.overrideWith((ref) async {
          throw DatabaseFailure('Connection failed');
        }),
      ],
      child: MaterialApp(home: BudgetsScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text('Unable to access your data'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
});
```

## Summary

- **Result Pattern**: Use `Result<T>` for all operations that can fail
- **AppFailure**: Create specific failure types for different error categories
- **Repositories**: Convert exceptions to failures
- **Use Cases**: Add validation failures
- **UI**: Handle all failure types with user-friendly messages
- **Never**: Throw exceptions for business errors

This approach makes errors explicit, type-safe, and impossible to ignore, leading to more robust and maintainable code.
