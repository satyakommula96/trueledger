# State Management Strategy

TrueLedger uses **Riverpod** (specifically `flutter_riverpod`) for dependency injection and state management.

## Core Principles

1.  **Immutability**:
    -   State objects should be immutable (use `final` fields).
    -   Update state by creating new instances (`copyWith`).

2.  **Unidirectional Data Flow**:
    -   Data flows **down** from Providers to Widgets.
    -   Events flow **up** from Widgets to Providers/Controllers.

3.  **No Logic in UI**:
    -   Widgets should only handle **display** and **user input**.
    -   Business logic belongs in **UseCases**.
    -   Presentation logic belongs in **Providers/Notifiers**.

## Provider Organization

Providers are located in `lib/presentation/providers/`.

-   **Repository Providers** (`repository_providers.dart`):
    -   Provide instances of Repositories.
    -   Usually `Provider<IRepository>`.

-   **UseCase Providers** (`usecase_providers.dart`):
    -   Provide instances of UseCases.
    -   Depend on Repository Providers.
    -   Example: `final getSummaryUseCaseProvider = Provider((ref) => GetSummaryUseCase(ref.watch(repoProvider)));`

-   **Feature Providers** (e.g., `dashboard_provider.dart`):
    -   Hold the state for a specific screen or feature.
    -   Usually `FutureProvider` or `StateNotifierProvider`.
    -   Example: `dashboardProvider` fetches data via UseCases and exposes `DashboardData`.

## Rules

-   ❌ **DO NOT** use `setState` for complex state or business logic.
-   ❌ **DO NOT** access Repositories directly in Widgets.
-   ✅ **DO** use `ref.watch` in `build` methods.
-   ✅ **DO** use `ref.read` in callbacks (e.g., `onTap`).
