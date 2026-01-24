# Contributing Guidelines

Thank you for your interest in contributing to TrueCash! This document provides guidelines for contributing to the project.

## Code of Conduct

Please read and follow our [Code of Conduct](code-of-conduct.md).

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/truecash.git
   cd truecash
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/my-new-feature
   ```

## Development Workflow

### 1. Make Your Changes

Follow the [Adding Features](../development/adding-features.md) guide for implementing new features.

### 2. Write Tests

All new code must include tests:
- Unit tests for use cases and business logic
- Widget tests for UI components
- Integration tests for user flows (if applicable)

```bash
flutter test
```

### 3. Run Code Quality Checks

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

All checks must pass before submitting a PR.

### 4. Commit Your Changes

Use conventional commit messages:

```
feat: add recurring transactions feature
fix: resolve budget calculation error
docs: update architecture documentation
test: add tests for dashboard provider
refactor: simplify analysis screen logic
```

### 5. Push and Create Pull Request

```bash
git push origin feature/my-new-feature
```

Then create a pull request on GitHub.

## Pull Request Guidelines

### PR Title

Use conventional commit format:
- `feat: description` - New feature
- `fix: description` - Bug fix
- `docs: description` - Documentation
- `test: description` - Tests
- `refactor: description` - Code refactoring
- `chore: description` - Maintenance

### PR Description

Include:
1. **What**: What does this PR do?
2. **Why**: Why is this change needed?
3. **How**: How does it work?
4. **Testing**: How was it tested?
5. **Screenshots**: For UI changes

Example:
```markdown
## What
Adds recurring transactions feature

## Why
Users requested ability to track recurring expenses like subscriptions

## How
- Added RecurringTransaction entity
- Implemented CRUD operations in repository
- Created use cases and providers
- Built UI screen

## Testing
- Added unit tests for use cases
- Added widget tests for UI
- Manually tested on Android and Linux

## Screenshots
[Screenshot of recurring transactions screen]
```

### PR Checklist

- [ ] Code follows Clean Architecture principles
- [ ] All tests passing
- [ ] No analyzer warnings
- [ ] Code formatted with `dart format`
- [ ] Documentation updated
- [ ] Commit messages follow conventions
- [ ] PR description is complete

## Code Style

### Dart/Flutter Conventions

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables and methods
- Use `UpperCamelCase` for classes and types
- Use `lowercase_with_underscores` for file names
- Prefer `const` constructors when possible
- Use trailing commas for better formatting

### Project Conventions

1. **Absolute Imports**: Always use package imports
   ```dart
   // ✅ DO
   import 'package:truecash/domain/models/models.dart';
   
   // ❌ DON'T
   import '../../domain/models/models.dart';
   ```

2. **File Organization**: Follow the layer structure
   ```
   lib/
   ├── core/
   ├── data/
   ├── domain/
   └── presentation/
   ```

3. **Naming**: Use descriptive names
   ```dart
   // ✅ DO
   final getDashboardDataUseCase = ...;
   
   // ❌ DON'T
   final useCase1 = ...;
   ```

## Testing Guidelines

### Unit Tests

Test business logic in isolation:

```dart
test('GetBudgetsUseCase returns budgets', () async {
  // Arrange
  final mockRepo = MockFinancialRepository();
  final useCase = GetBudgetsUseCase(mockRepo);
  
  when(() => mockRepo.getBudgets())
      .thenAnswer((_) async => [Budget(...)]);
  
  // Act
  final result = await useCase(NoParams());
  
  // Assert
  expect(result.isSuccess, true);
  verify(() => mockRepo.getBudgets()).called(1);
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('Dashboard renders correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(home: Dashboard()),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.byType(Dashboard), findsOneWidget);
});
```

### Integration Tests

Test complete user flows:

```dart
testWidgets('User can add a budget', (tester) async {
  await tester.pumpWidget(ProviderScope(child: TrueCashApp()));
  
  // Navigate to budgets
  await tester.tap(find.text('Budgets'));
  await tester.pumpAndSettle();
  
  // Add budget
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byType(TextField).first, 'Groceries');
  await tester.enterText(find.byType(TextField).last, '500');
  
  // Save
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  // Verify
  expect(find.text('Groceries'), findsOneWidget);
});
```

## Documentation

### Code Documentation

Document public APIs:

```dart
/// Retrieves all budgets for the current month.
///
/// Returns a [Result] containing a list of [Budget] objects on success,
/// or a [Failure] if an error occurs.
Future<Result<List<Budget>>> getBudgets();
```

### Architecture Documentation

Update `docs/` when adding significant features:

- Update architecture diagrams if structure changes
- Add new pages for major features
- Update API reference

## Review Process

1. **Automated Checks**: CI runs tests and analysis
2. **Code Review**: Maintainer reviews code
3. **Feedback**: Address review comments
4. **Approval**: Once approved, PR is merged

## Questions?

- Check the [Architecture Documentation](../architecture/overview.md)
- Read the [Adding Features Guide](../development/adding-features.md)
- Open a [GitHub Discussion](https://github.com/satyakommula96/truecash/discussions)
- Create an [Issue](https://github.com/satyakommula96/truecash/issues)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing to TrueCash! 🎉
