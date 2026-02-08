import 'package:trueledger/domain/models/models.dart';

abstract class IFinancialRepository {
  Future<MonthlySummary> getMonthlySummary();
  Future<List<Map<String, dynamic>>> getSpendingTrend();
  Future<List<Map<String, dynamic>>> getUpcomingBills();
  Future<List<Map<String, dynamic>>> getCategorySpending();
  Future<List<SavingGoal>> getSavingGoals();
  Future<List<Budget>> getBudgets();
  Future<void> addEntry(
      String type, double amount, String category, String note, String date);
  Future<void> checkAndProcessRecurring();
  Future<List<Map<String, dynamic>>> getMonthlyHistory([int? year]);
  Future<List<int>> getAvailableYears();
  Future<List<Loan>> getLoans();
  Future<List<Subscription>> getSubscriptions();
  Future<List<CreditCard>> getCreditCards();
  Future<void> deleteItem(String table, int id);
  Future<void> addBudget(String category, double monthlyLimit);
  Future<void> updateBudget(int id, double monthlyLimit);
  Future<void> markBudgetAsReviewed(int id);
  Future<List<Map<String, dynamic>>> getAllValues(String table);
  Future<void> seedRoadmapData();
  Future<void> seedHealthyProfile();
  Future<void> seedAtRiskProfile();
  Future<void> seedLargeData(int count);
  Future<void> clearData();
  Future<void> addCreditCard(
      String bank,
      double creditLimit,
      double statementBalance,
      double minDue,
      String dueDate,
      String statementDate);
  Future<void> updateCreditCard(
      int id,
      String bank,
      double creditLimit,
      double statementBalance,
      double minDue,
      String dueDate,
      String statementDate);
  Future<void> payCreditCardBill(int id, double amount);
  Future<void> addGoal(String name, double targetAmount);
  Future<void> updateGoal(
      int id, String name, double targetAmount, double currentAmount);
  Future<void> addLoan(String name, String type, double total, double remaining,
      double emi, double rate, String due, String date);
  Future<void> updateLoan(int id, String name, String type, double total,
      double remaining, double emi, double rate, String due,
      [String? lastPaymentDate]);
  Future<void> addSubscription(String name, double amount, String billingDate);
  Future<void> updateEntry(String type, int id, Map<String, dynamic> values);
  Future<List<LedgerItem>> getMonthDetails(String month);
  Future<List<LedgerItem>> getTransactionsForRange(
      DateTime start, DateTime end);
  Future<void> restoreBackup(Map<String, dynamic> data);
  Future<double> getTodaySpend();
  Future<int> getTodayTransactionCount();
  Future<Map<String, double>> getWeeklySummary();
  Future<Map<String, dynamic>> generateBackup();
  Future<int> getActiveStreak();
  Future<List<TransactionCategory>> getCategories(String type);
  Future<void> addCategory(String name, String type);
  Future<void> deleteCategory(int id);
  Future<List<Map<String, dynamic>>> getCategorySpendingForRange(
      DateTime start, DateTime end);
  Future<String?> getRecommendedCategory(String note);
  Future<Map<String, int>> getDatabaseStats();
  Future<List<String>> getPaidBillLabels(String monthStr);
  Future<void> recordLoanAudit({
    required int loanId,
    required String date,
    required double openingBalance,
    required double interestRate,
    required double paymentAmount,
    required int daysAccrued,
    required double interestAccrued,
    required double principalApplied,
    required double closingBalance,
    required int engineVersion,
    required String type,
  });
  Future<List<Map<String, dynamic>>> getLoanAuditLog(int loanId);
}
