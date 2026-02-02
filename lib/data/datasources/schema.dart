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

  // Common columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colAmount = 'amount';
  static const String colDate = 'date';
  static const String colCategory = 'category';
  static const String colActive = 'active';
  static const String colType = 'type';

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

  // Saving Goals
  static const String colTargetAmount = 'target_amount';
  static const String colCurrentAmount = 'current_amount';

  // Budgets
  static const String colMonthlyLimit = 'monthly_limit';
  static const String colPin =
      'app_pin'; // Stored in separate secure table or preferences but keeping simple
}
