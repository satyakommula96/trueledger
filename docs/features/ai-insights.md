# AI-Powered Insights

TrueLedger features a built-in, local **Intelligence Service** that algorithmically analyzes your daily and monthly financial behaviors. It uses pattern matching and linear prediction to surface actionable, personalized financial advice directly to your dashboard without sending your data to any external server.

## 🧬 Core Capabilities

TrueLedger automatically generates and prioritizes insights based on your recent activity:

- **📈 Wealth Projections (Prediction)**: If you possess a high savings rate, the engine calculates your projected yearly net-worth growth, benchmarking it against recommended financial models.
- **⚠️ Critical Overspending**: Detects monthly outflow deficits (spending more than you earn) and measures the percentage variance against your 3-month trailing average to spot abnormal surges.
- **📊 Spending Forecasts**: Runs linear regression on your past spending paths to calculate velocity and warn you if next month's outflow is on track to surge dramatically.
- **🛡️ Budget Discipline**: Computes total "budget overflow" across all tracked categories, immediately warning you of how much cash is leaking past your set limitations.
- **🧟 Subscription Leakage & Burn Rate**:
  - Highlights when recurring services consume a disproportionate percentage (e.g., >10%) of your income.
  - Generates a "Burn Rate Warning" representing exactly how many days your liquid assets will last if your income suddenly stops, based on your absolute fixed mandatory obligations.
- **⏳ True Cost Analysis**: Automatically cross-references your largest spending category against your effective hourly working wage, translating expenditures into the jarring metric of "hours of your life worked".
- **✨ Guilt-Free Allowance (Gamification)**: Positively reinforces excellent behavior by detecting high savings rates (>20%), explicitly granting you permission to spend the remaining baseline amount guilt-free.

## ⚙️ Insight Prioritization Engine

To prevent "notification fatigue", TrueLedger enforces strict display rules:
- **High Priority** (Deficits, Burn Rates, Major Projections): Exactly *one* is allowed to interrupt your dashboard view per day.
- **Medium Priority** (General Forecasts, Budget Overflows): Capped at *two* concurrent displays if no high-priority insight exists.
- **Cooldowns**: Each unique insight class has a psychological cooldown (ranging from 1 day to 30 days) ensuring you aren't nagged repeatedly about the same metric until adequate time passes for your behavior to change.

## 🚀 Upcoming AI Features
- **Natural Language Query**: Look forward to interacting with a local model asking "How much did I spend on coffee last month?"
- **Auto-Categorization**: Heuristics and small-model prediction to pre-fill categorizations for your transactions.
