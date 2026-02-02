import 'package:trueledger/domain/models/models.dart';

abstract class IFinancialRepository {
  Future<MonthlySummary> getMonthlySummary();
  Future<List<Map<String, dynamic>>> getSpendingTrend();
  Future<List<Map<String, dynamic>>> getUpcomingBills();
  Future<List<Map<String, dynamic>>> getCategorySpending();
  Future<List<SavingGoal>> getSavingGoals();
  Future<List<Budget>> getBudgets();
  Future<void> addEntry(
      String type, int amount, String category, String note, String date);
  Future<void> checkAndProcessRecurring();
  Future<List<Map<String, dynamic>>> getMonthlyHistory([int? year]);
  Future<List<int>> getAvailableYears();
  Future<List<Loan>> getLoans();
  Future<List<Subscription>> getSubscriptions();
  Future<List<CreditCard>> getCreditCards();
  Future<void> deleteItem(String table, int id);
  Future<void> addBudget(String category, int monthlyLimit);
  Future<void> updateBudget(int id, int monthlyLimit);
  Future<List<Map<String, dynamic>>> getAllValues(String table);
  Future<void> seedRoadmapData();
  Future<void> seedHealthyProfile();
  Future<void> seedAtRiskProfile();
  Future<void> seedLargeData(int count);
  Future<void> clearData();
  Future<void> addCreditCard(String bank, int creditLimit, int statementBalance,
      int minDue, String dueDate, String statementDate);
  Future<void> updateCreditCard(int id, String bank, int creditLimit,
      int statementBalance, int minDue, String dueDate, String statementDate);
  Future<void> payCreditCardBill(int id, int amount);
  Future<void> addGoal(String name, int targetAmount);
  Future<void> updateGoal(
      int id, String name, int targetAmount, int currentAmount);
  Future<void> addLoan(String name, String type, int total, int remaining,
      int emi, double rate, String due, String date);
  Future<void> updateLoan(int id, String name, String type, int total,
      int remaining, int emi, double rate, String due);
  Future<void> addSubscription(String name, int amount, String billingDate);
  Future<void> updateEntry(String type, int id, Map<String, dynamic> values);
  Future<List<LedgerItem>> getMonthDetails(String month);
  Future<List<LedgerItem>> getTransactionsForRange(
      DateTime start, DateTime end);
  Future<void> restoreBackup(Map<String, dynamic> data);
  Future<int> getTodaySpend();
  Future<int> getTodayTransactionCount();
  Future<Map<String, int>> getWeeklySummary();
  Future<Map<String, dynamic>> generateBackup();
  Future<int> getActiveStreak();
  Future<List<TransactionCategory>> getCategories(String type);
  Future<void> addCategory(String name, String type);
  Future<void> deleteCategory(int id);
  Future<List<Map<String, dynamic>>> getCategorySpendingForRange(
      DateTime start, DateTime end);
  Future<String?> getRecommendedCategory(String note);
  Future<Map<String, int>> getDatabaseStats();
}
