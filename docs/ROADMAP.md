# Product Success Roadmap (TrueLedger)

This roadmap focuses on features that drive **retention, trust, and habit formation**.
We implement these phases sequentially.

## Phase 1: Retention (Goal: Daily Usage Hook)

- [x] **"Today" Screen / Widget on Dashboard**
    - [x] Show today's total spend (large, bold).
    - [x] Show remaining budget for today (if applicable) or month.
    - [x] Simple daily summary text: "You've spent ₹820 today."

- [x] **One-Tap Expense Entry**
    - [x] Floating Action Button (FAB) visible on Dashboard.
    - [x] Simplified "Quick Add" dialog:
        - [x] Amount keypad opens immediately.
        - [x] Category defaults to last used or "General".
        - [x] "Save" button is easily reachable.
        - [x] No full-screen navigation for quick entry.

- [x] **Budgets (Core Value)**
    - [x] Create `Budget` model (Category-based).
    - [x] "Add Budget" screen (Amount per Category).
    - [x] Visual progress bars on a dedicated "Budgets" tab.
    - [x] Colors: Green (Safe), Yellow (>75%), Red (>100%).

- [x] **Smart Reminders**
    - [x] "Daily Log" reminder (e.g., at 9 PM) *only if* no transaction added today.
    - [x] Budget proximity warning notification.

## Phase 2: Trust (Goal: Reliability & Correction)

- [x] **Search & Edit**
    - [x] Search bar in Transactions list (Amount, Category, Note).
    - [x] Edit/Delete capabilities for existing transactions.
    - [x] Undo option for deletions.

- [x] **Backup & Restore**
    - [x] Encrypted JSON Export/Import.
    - [x] Auto-backup to local file (Desktop/Mobile).
    - [x] Web browser download support.

- [x] **Web Support**
    - [x] Full responsive dashboard.
    - [x] SQLite WASM persistence.

- [x] **Weekly/Monthly Insights**
    - [x] "You spent 12% more than last week" (Plain text insights).

## Phase 3: Delight (Goal: Polish & Engagement)

- [x] **Streaks**
    - [x] "Daily Streak" counter on Dashboard.
    - [x] Confetti animation for hitting streak milestones.

- [x] **Performance Polish**
    - [x] Ensure app opens < 1s.
    - [x] Optimistic UI updates (don't wait for DB to update UI).

## Phase 4: Intelligence (Goal: Actionable Data)

- [x] **Smart Insights Engine**
    - [x] Spending forensics (week-over-week, month-over-month, top categories).
    - [x] Budget proximity warnings based on velocity.
    - [x] Snooze & Dismiss capabilities (persistent).
- [x] **Financial Health Score**
    - [x] Habit-based analysis and visual health indicator.
- [x] **Scenario Mode (What If?)**
    - [x] Simulate future progress and wealth projections.

## Phase 5: Personalization Without Creep (Goal: Adaptive Utility)

> **Principle**: The app adapts to reduce effort — never to predict, judge, or manipulate behavior. [Full Spec & Principles](features/personalization.md)

- [x] **Phase 5.1: Zero Risk (Foundations)**
    - [x] **Last-Used Memory**
        - [x] Default to last category, payment method, and merchant with UI feedback.
    - [x] **Quick-Add Presets**
        - [x] User-authored amount + category combos (e.g., "₹120 · Coffee").
    - [x] **Explicit Reminder Time**
        - [x] User-selectable time with a first-class "Off" option.

- [x] **Phase 5.2: Gentle Adaptation (High Friction)**
    - [x] **Time-of-Day Defaults**
        - [x] Suggest AM/PM categories after ≥ 14 days and 5+ similar entries.
    - [x] **Salary Cycle Awareness**
        - [x] Explicit pay date prompt for budget resets and forecast framing.
    - [x] **Shortcut Suggestions**
        - [x] Suggest pinned shortcuts for frequent repeats; include 30-day cooldown on dismissal.

- [x] **Phase 5.3: Trust & Control (Crucial)**
    - [x] **Transparency Engine**
        - [x] "Why am I seeing this?" functionality for every adaptive choice.
    - [x] **Reset & Granular Toggles**
        - [x] One-tap personalization reset + per-feature opt-outs in Settings.
    - [x] **Personal Baseline Reflections**
        - [x] Comparison against 3-week local history (e.g., "Higher than your usual Friday").

---

## What NOT to build (Yet)
- Bank Sync
- AI Categorization
- Multi-currency complexity
- Social Sharing
