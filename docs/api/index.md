# API Reference

API documentation for TrueCash.

## Domain Layer

### Models

#### Budget
```dart
class Budget {
  final int id;
  final String category;
  final int monthlyLimit;
}
```

#### Transaction
```dart
class Transaction {
  final int id;
  final int amount;
  final String category;
  final DateTime date;
  final String? note;
  final List<String>? tags;
}
```

#### SavingGoal
```dart
class SavingGoal {
  final int id;
  final String name;
  final int targetAmount;
  final int currentAmount;
}
```

### Use Cases

See individual use case files in `lib/domain/usecases/` for detailed API documentation.

### Repository Interfaces

See `lib/domain/repositories/i_financial_repository.dart` for the complete repository interface.

## Presentation Layer

### Providers

See individual provider files in `lib/presentation/providers/` for provider documentation.

## Data Layer

### Database Schema

See [Database Schema](../database/schema.md) for complete schema documentation.

---

**Note**: This is a placeholder. Complete API reference documentation will be generated automatically in the future using tools like `dartdoc`.
