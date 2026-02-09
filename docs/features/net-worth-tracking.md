# Net Worth Tracking Feature

## Overview
The Net Worth Tracking feature provides users with a comprehensive view of their financial health by aggregating assets and liabilities over time. It offers visual trends and actionable insights to help users grow their wealth.

## Key Components

### 1. Net Worth Tracking Screen
- **Current Net Worth**: A prominent display of the user's total net worth (Assets - Liabilities).
- **Assets & Liabilities Breakdown**: Quick-access cards showing total assets and liabilities, with navigation to detailed breakup screens.
- **12-Month Trend Chart**: A visual representation of the net worth trajectory over the last year.
- **Financial Insights**: Dynamic text providing context on net worth changes and percentage growth.

### 2. Dashboard Integration
- The `AssetLiabilityCard` on the dashboard has been enhanced to show the total Net Worth.
- Tapping the Net Worth card navigates directly to the Tracking Screen.

## Technical Details

### Implementation Files
- `lib/presentation/screens/net_worth/net_worth_tracking_screen.dart`: The main tracking screen and custom chart painter.
- `lib/presentation/screens/dashboard/dashboard_components/asset_liability_card.dart`: Updated dashboard widget.

### Data Sources
- **Assets**: Calculated from `investments` (active only) and `retirement_contributions`.
- **Liabilities**: Calculated from `credit_cards` (statement balances) and `loans` (remaining amounts).

## Testing
Comprehensive widget tests have been implemented to ensure reliability:
- `test/widget/net_worth_tracking_screen_test.dart`:
    - Loading states.
    - Accurate net worth calculation (positive and negative).
    - Empty data handling (graceful state).
    - Navigation to details.
    - Filtering of inactive assets.
- `test/widget/asset_liability_card_test.dart`:
    - Rendering of net worth components on the dashboard.

## Future Enhancements
- Support for historical snapshots in the database to show real historical trends instead of simulated ones.
- Ability to set net worth goals.
- Comparison with benchmarks.
