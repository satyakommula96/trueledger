class Schema {
  static const String incomeSourcesTable = 'income_sources';
  static const String fixedExpensesTable = 'fixed_expenses';
  static const String variableExpensesTable = 'variable_expenses';
  static const String investmentsTable = 'investments';
  static const String subscriptionsTable = 'subscriptions';
  static const String retirementContributionsTable = 'retirement_contributions';
  static const String creditCardsTable = 'credit_cards';
  static const String loansTable = 'loans';
  static const String savingGoalsTable = 'saving_goals';
  static const String budgetsTable = 'budgets';
  static const String customCategoriesTable = 'custom_categories';
  static const String loanAuditLogTable = 'loan_audit_log';
  static const String migrationsTable = '_migrations';

  // Common columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colAmount = 'amount';
  static const String colDate = 'date';
  static const String colCategory = 'category';
  static const String colActive = 'active';
  static const String colType = 'type';
  static const String colVersion = 'version';
  static const String colAppliedAt = 'applied_at';

  // Specific columns
  static const String colSource = 'source'; // income_sources
  static const String colNote = 'note'; // variable_expenses
  static const String colBillingDate = 'billing_date'; // subscriptions

  // Credit Cards
  static const String colBank = 'bank';
  static const String colCreditLimit = 'credit_limit';
  static const String colStatementBalance = 'statement_balance';
  static const String colMinDue = 'min_due';
  static const String colDueDate = 'due_date';
  static const String colStatementDate = 'statement_date';

  // Loans
  static const String colLoanType = 'loan_type';
  static const String colTotalAmount = 'total_amount';
  static const String colRemainingAmount = 'remaining_amount';
  static const String colEmi = 'emi';
  static const String colInterestRate = 'interest_rate';
  static const String colLastPaymentDate = 'last_payment_date';
  static const String colInterestEngineVersion = 'interest_engine_version';

  // Loan Audit
  static const String colLoanId = 'loan_id';
  static const String colOpeningBalance = 'opening_balance';
  static const String colInterestAccrued = 'interest_accrued';
  static const String colPrincipalApplied = 'principal_applied';
  static const String colClosingBalance = 'closing_balance';
  static const String colPaymentAmount = 'payment_amount';
  static const String colDaysAccrued = 'days_accrued';
  static const String colEngineVersion = 'engine_version';

  // Saving Goals
  static const String colTargetAmount = 'target_amount';
  static const String colCurrentAmount = 'current_amount';

  // Budgets
  static const String colMonthlyLimit = 'monthly_limit';
  static const String colLastReviewedAt = 'last_reviewed_at';
  static const String colPin =
      'app_pin'; // Stored in separate secure table or preferences but keeping simple
}
