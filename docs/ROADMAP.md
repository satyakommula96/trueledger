# Product Success Roadmap (TrueLedger)

This roadmap focuses on features that drive **retention, trust, and habit formation**.
We implement these phases sequentially.

## Phase 1: Retention (Goal: Daily Usage Hook)

- [ ] **"Today" Screen / Widget on Dashboard**
    - [ ] Show today's total spend (large, bold).
    - [ ] Show remaining budget for today (if applicable) or month.
    - [ ] Simple daily summary text: "You’ve spent ₹820 today."

- [ ] **One-Tap Expense Entry**
    - [ ] Floating Action Button (FAB) visible on all main tabs.
    - [ ] Simplified "Quick Add" dialog:
        - [ ] Amount keypad opens immediately.
        - [ ] Category defaults to last used or "General".
        - [ ] "Save" button is easily reachable.
        - [ ] No full-screen navigation for quick entry.

- [ ] **Budgets (Core Value)**
    - [ ] Create `Budget` model (Category-based).
    - [ ] "Add Budget" screen (Amount per Category).
    - [ ] Visual progress bars on Dashboard or a dedicated "Budgets" tab.
    - [ ] Colors: Green (Safe), Yellow (>75%), Red (>100%).

- [ ] **Smart Reminders**
    - [ ] "Daily Log" reminder (e.g., at 9 PM) *only if* no transaction added today.
    - [ ] Budget proximity warning notification.

## Phase 2: Trust (Goal: Reliability & Correction)

- [ ] **Search & Edit**
    - [ ] Search bar in Transactions list (Amount, Category, Note).
    - [ ] Edit/Delete capabilities for existing transactions.
    - [ ] Undo option for deletions.

- [ ] **Backup & Restore**
    - [ ] JSON Export/Import (Clean UI).
    - [ ] (Optional) Auto-backup to local file.

- [ ] **Weekly/Monthly Insights**
    - [ ] "You spent 12% more than last week" (Plain text insights).
    - [ ] "Food is your top expense this month".

## Phase 3: Delight (Goal: Polish & Engagement)

- [ ] **Streaks**
    - [ ] "5 Day Streak" counter on Dashboard.
    - [ ] Confetti animation for hitting streak milestones.

- [ ] **Performance Polish**
    - [ ] Ensure app opens < 1s.
    - [ ] Optimistic UI updates (don't wait for DB to update UI).

---

## What NOT to build (Yet)
- Bank Sync
- AI Categorization
- Multi-currency complexity
- Social Sharing
