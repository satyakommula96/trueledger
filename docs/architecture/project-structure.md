# Project Structure & Architecture Conventions

TrueLedger follows a **Clean Architecture** approach with strict separation of concerns. This ensures scalability, testability, and maintainability.

## Directory Structure

We use a **Layer-First** organization (Standard Flutter Clean Arch), gradually moving towards Feature-First where possible.

```
lib/
├── core/                  # Infrastructure & Shared Utilities
│   ├── config/            # App-wide vars (Version, Constants)
│   ├── error/             # Failure/Exception classes
│   ├── services/          # External services (Notification, Intelligence)
│   ├── theme/             # AppTheme & AppColors
│   └── utils/             # Helpers (Date, Currency, Platform)
│
├── data/                  # Data Layer (Implements Domain Interfaces)
│   ├── datasources/       # Low-level data access (Database, SharedPreferences)
│   └── repositories/      # Implementation of Domain Repositories
│
├── domain/                # Business Logic (Pure Dart, No Flutter)
│   ├── models/            # Entities / Data Classes
│   ├── repositories/      # Interfaces (Contracts)
│   └── usecases/          # Business Logic Units (Single Responsibility)
│
├── presentation/          # UI Layer (Widgets & State)
│   ├── providers/         # Riverpod Providers (State Management)
│   ├── screens/           # Full-screen Widgets
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   └── ...
│   └── widgets/           # Shared/Reusable UI Components
│
└── main.dart              # Entry Point
```

## Architecture Rules

1.  **Dependency Rule**: Dependencies point **INWARDS**.
    -   `Presentation` depends on `Domain`.
    -   `Data` depends on `Domain`.
    -   `Domain` depends on **NOTHING** (pure Dart).

2.  **State Management**: **Riverpod**
    -   UI Widgets (`ConsumerWidget`) must **never** call Repositories directly.
    -   UI must watch **Providers**.
    -   Providers use **UseCases**.
    -   UseCases use **Repositories**.

3.  **Data Flow**:
    -   `UI` -> `Provider` -> `UseCase` -> `Repository` -> `DataSource` -> `Database`

4.  **Testing**:
    -   **Unit Tests**: Domain layer (UseCases, Models) and Logic.
    -   **Widget Tests**: Presentation layer (Screens, Widgets).
    -   **Integration Tests**: Data layer (Repositories with in-memory DB).

## Naming Conventions
-   **Files**: `snake_case.dart`
-   **Classes**: `PascalCase`
-   **Variables**: `camelCase`
-   **Repositories**: `IFinancialRepository` (Interface), `FinancialRepositoryImpl` (Impl).
-   **UseCases**: `VerbSubjectUseCase` (e.g., `GetMonthlySummaryUseCase`).
