import 'package:truecash/domain/models/models.dart';

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
  Future<List<Map<String, dynamic>>> getMonthlyHistory();
  Future<List<Loan>> getLoans();
  Future<List<Subscription>> getSubscriptions();
  Future<List<CreditCard>> getCreditCards();
  Future<void> deleteItem(String table, int id);
  Future<void> addBudget(String category, int monthlyLimit);
  Future<void> updateBudget(int id, int monthlyLimit);
  Future<List<Map<String, dynamic>>> getAllValues(String table);
  Future<void> seedData();
  Future<void> seedLargeData(int count);
  Future<void> clearData();
  Future<void> addCreditCard(String bank, int creditLimit, int statementBalance,
      int minDue, String dueDate, String generationDate);
  Future<void> updateCreditCard(int id, String bank, int creditLimit,
      int statementBalance, int minDue, String dueDate, String generationDate);
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
}
