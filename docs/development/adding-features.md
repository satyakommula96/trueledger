# Adding New Features

This guide walks you through adding new features to TrueCash following Clean Architecture principles.

## Development Workflow

When adding a new feature, follow this order:

```
1. Domain Layer (Business Logic)
   ↓
2. Data Layer (Implementation)
   ↓
3. Use Case Layer (Orchestration)
   ↓
4. Presentation Layer (UI)
   ↓
5. Tests (Verification)
```

## Step-by-Step Example: Recurring Transactions

Let's add a "Recurring Transactions" feature from scratch.

### Step 1: Define the Domain Model

**File**: `lib/domain/models/models.dart`

```dart
class RecurringTransaction {
  final int id;
  final String name;
  final int amount; // in cents
  final String category;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  
  RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });
  
  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
  
  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      frequency: RecurrenceFrequency.values.byName(map['frequency']),
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isActive: map['is_active'] == 1,
    );
  }
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}
```

### Step 2: Update Repository Interface

**File**: `lib/domain/repositories/i_financial_repository.dart`

```dart
abstract class IFinancialRepository {
  // ... existing methods
  
  // Recurring Transactions
  Future<List<RecurringTransaction>> getRecurringTransactions();
  Future<void> addRecurringTransaction(RecurringTransaction transaction);
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
  Future<void> deleteRecurringTransaction(int id);
  Future<void> toggleRecurringTransaction(int id, bool isActive);
}
```

### Step 3: Implement Repository

**File**: `lib/data/repositories/financial_repository_impl.dart`

```dart
class FinancialRepositoryImpl implements IFinancialRepository {
  // ... existing methods
  
  @override
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await AppDatabase.db;
    final results = await db.query(
      'recurring_transactions',
      orderBy: 'start_date DESC',
    );
    return results.map((r) => RecurringTransaction.fromMap(r)).toList();
  }
  
  @override
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    final db = await AppDatabase.db;
    await db.insert('recurring_transactions', transaction.toMap());
  }
  
  @override
  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    final db = await AppDatabase.db;
    await db.update(
      'recurring_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
  
  @override
  Future<void> deleteRecurringTransaction(int id) async {
    final db = await AppDatabase.db;
    await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  @override
  Future<void> toggleRecurringTransaction(int id, bool isActive) async {
    final db = await AppDatabase.db;
    await db.update(
      'recurring_transactions',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### Step 4: Create Database Migration

**File**: `lib/data/datasources/database_migrations.dart`

```dart
class Migration5 extends Migration {
  @override
  int get version => 5;
  
  @override
  Future<void> migrate(Database db) async {
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }
}

// Add to migrations list
final migrations = [
  Migration1(),
  Migration2(),
  Migration3(),
  Migration4(),
  Migration5(), // Add new migration
];
```

### Step 5: Create Use Cases

**File**: `lib/domain/usecases/recurring_transaction_usecases.dart`

```dart
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';

// Get all recurring transactions
class GetRecurringTransactionsUseCase 
    extends UseCase<List<RecurringTransaction>, NoParams> {
  final IFinancialRepository repository;
  
  GetRecurringTransactionsUseCase(this.repository);
  
  @override
  Future<Result<List<RecurringTransaction>>> call(NoParams params) async {
    try {
      final transactions = await repository.getRecurringTransactions();
      return Success(transactions);
    } catch (e) {
      return Failure(DatabaseFailure(e.toString()));
    }
  }
}

// Add recurring transaction
class AddRecurringTransactionUseCase 
    extends UseCase<void, RecurringTransaction> {
  final IFinancialRepository repository;
  
  AddRecurringTransactionUseCase(this.repository);
  
  @override
  Future<Result<void>> call(RecurringTransaction params) async {
    try {
      // Validation
      if (params.name.isEmpty) {
        return Failure(ValidationFailure('Name cannot be empty'));
      }
      if (params.amount <= 0) {
        return Failure(ValidationFailure('Amount must be positive'));
      }
      
      await repository.addRecurringTransaction(params);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure(e.toString()));
    }
  }
}

// Toggle active status
class ToggleRecurringTransactionUseCase 
    extends UseCase<void, ToggleRecurringTransactionParams> {
  final IFinancialRepository repository;
  
  ToggleRecurringTransactionUseCase(this.repository);
  
  @override
  Future<Result<void>> call(ToggleRecurringTransactionParams params) async {
    try {
      await repository.toggleRecurringTransaction(params.id, params.isActive);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure(e.toString()));
    }
  }
}

class ToggleRecurringTransactionParams {
  final int id;
  final bool isActive;
  
  ToggleRecurringTransactionParams({
    required this.id,
    required this.isActive,
  });
}
```

### Step 6: Create Providers

**File**: `lib/presentation/providers/recurring_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/usecases/recurring_transaction_usecases.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

// Use case providers
final getRecurringTransactionsUseCaseProvider = 
    Provider<GetRecurringTransactionsUseCase>((ref) {
  return GetRecurringTransactionsUseCase(
    ref.watch(financialRepositoryProvider),
  );
});

final addRecurringTransactionUseCaseProvider = 
    Provider<AddRecurringTransactionUseCase>((ref) {
  return AddRecurringTransactionUseCase(
    ref.watch(financialRepositoryProvider),
  );
});

final toggleRecurringTransactionUseCaseProvider = 
    Provider<ToggleRecurringTransactionUseCase>((ref) {
  return ToggleRecurringTransactionUseCase(
    ref.watch(financialRepositoryProvider),
  );
});

// State provider
final recurringTransactionsProvider = 
    FutureProvider<List<RecurringTransaction>>((ref) async {
  final useCase = ref.watch(getRecurringTransactionsUseCaseProvider);
  final result = await useCase(NoParams());
  return result.getOrThrow;
});
```

### Step 7: Create UI Screen

**File**: `lib/presentation/screens/recurring_transactions_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/presentation/providers/recurring_providers.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recurringTransactionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No recurring transactions yet'),
            );
          }
          
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _RecurringTransactionTile(transaction: transaction);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecurringTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringTransactionTile extends ConsumerWidget {
  final RecurringTransaction transaction;
  
  const _RecurringTransactionTile({required this.transaction});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        _getFrequencyIcon(transaction.frequency),
        color: transaction.isActive ? Colors.green : Colors.grey,
      ),
      title: Text(transaction.name),
      subtitle: Text(
        '${transaction.category} • ${transaction.frequency.name}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${(transaction.amount / 100).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Switch(
            value: transaction.isActive,
            onChanged: (value) async {
              final useCase = ref.read(toggleRecurringTransactionUseCaseProvider);
              await useCase(ToggleRecurringTransactionParams(
                id: transaction.id,
                isActive: value,
              ));
              ref.invalidate(recurringTransactionsProvider);
            },
          ),
        ],
      ),
    );
  }
  
  IconData _getFrequencyIcon(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return Icons.today;
      case RecurrenceFrequency.weekly:
        return Icons.date_range;
      case RecurrenceFrequency.monthly:
        return Icons.calendar_month;
      case RecurrenceFrequency.yearly:
        return Icons.calendar_today;
    }
  }
}
```

### Step 8: Write Tests

**File**: `test/unit/domain/usecases/get_recurring_transactions_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'package:truecash/domain/usecases/recurring_transaction_usecases.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late MockFinancialRepository mockRepo;
  late GetRecurringTransactionsUseCase useCase;
  
  setUp(() {
    mockRepo = MockFinancialRepository();
    useCase = GetRecurringTransactionsUseCase(mockRepo);
  });
  
  test('GetRecurringTransactionsUseCase returns transactions', () async {
    // Arrange
    final transactions = [
      RecurringTransaction(
        id: 1,
        name: 'Netflix',
        amount: 1599,
        category: 'Entertainment',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    ];
    
    when(() => mockRepo.getRecurringTransactions())
        .thenAnswer((_) async => transactions);
    
    // Act
    final result = await useCase(NoParams());
    
    // Assert
    expect(result.isSuccess, true);
    expect(result.getOrThrow.length, 1);
    expect(result.getOrThrow.first.name, 'Netflix');
    verify(() => mockRepo.getRecurringTransactions()).called(1);
  });
  
  test('GetRecurringTransactionsUseCase handles errors', () async {
    // Arrange
    when(() => mockRepo.getRecurringTransactions())
        .thenThrow(Exception('Database error'));
    
    // Act
    final result = await useCase(NoParams());
    
    // Assert
    expect(result.isFailure, true);
  });
}
```

## Best Practices

### 1. Follow the Dependency Rule

✅ **DO**: Depend on abstractions (interfaces)
```dart
class MyUseCase {
  final IFinancialRepository repository; // Interface
}
```

❌ **DON'T**: Depend on concrete implementations
```dart
class MyUseCase {
  final FinancialRepositoryImpl repository; // Concrete class
}
```

### 2. Keep Use Cases Single-Purpose

✅ **DO**: One use case per operation
```dart
class GetRecurringTransactionsUseCase { ... }
class AddRecurringTransactionUseCase { ... }
```

❌ **DON'T**: Combine multiple operations
```dart
class RecurringTransactionUseCase {
  Future<List> get() { ... }
  Future<void> add() { ... }
  Future<void> delete() { ... }
}
```

### 3. Use Result Pattern for Error Handling

✅ **DO**: Return `Result<T>`
```dart
Future<Result<List<Transaction>>> getTransactions() async {
  try {
    final data = await repository.getTransactions();
    return Success(data);
  } catch (e) {
    return Failure(DatabaseFailure(e.toString()));
  }
}
```

❌ **DON'T**: Throw exceptions
```dart
Future<List<Transaction>> getTransactions() async {
  return await repository.getTransactions(); // May throw
}
```

### 4. Test Every Layer

- ✅ Unit test use cases
- ✅ Widget test screens
- ✅ Integration test flows

### 5. Use Absolute Imports

✅ **DO**: Use package imports
```dart
import 'package:truecash/domain/models/models.dart';
```

❌ **DON'T**: Use relative imports
```dart
import '../../domain/models/models.dart';
```

## Checklist

Before submitting your feature:

- [ ] Domain model defined
- [ ] Repository interface updated
- [ ] Repository implementation added
- [ ] Database migration created (if needed)
- [ ] Use cases implemented
- [ ] Providers created
- [ ] UI screen implemented
- [ ] Unit tests written
- [ ] Widget tests written (if applicable)
- [ ] Integration tests written (if applicable)
- [ ] All tests passing (`flutter test`)
- [ ] No analyzer issues (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Documentation updated

## Next Steps

- [Testing Guide](testing.md) - Learn how to write tests
- [Design Patterns](design-patterns.md) - Common patterns used
- [Code Style](code-style.md) - Coding conventions
- [Architecture Overview](../architecture/overview.md) - Understand the architecture
