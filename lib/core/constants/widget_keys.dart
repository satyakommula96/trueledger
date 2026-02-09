import 'package:flutter/material.dart';

class WidgetKeys {
  // Dashboard
  static const Key dashboardTrendSection = Key('dashboard_trend_section');
  static const Key dashboardInsightsSection = Key('dashboard_insights_section');
  static const Key dashboardCalendarSection = Key('dashboard_calendar_section');
  static const Key dashboardNetWorthValue = Key('dashboard_net_worth_value');
  static const Key dashboardAssetsButton = Key('dashboard_assets_button');

  // Recurring Transactions
  static const Key recurringList = Key('recurring_list');
  static const Key addRecurringFab = Key('add_recurring_fab');
  static const String recurringItemPrefix = 'recurring_item_';
  static Key recurringItem(int id) => Key('$recurringItemPrefix$id');
  static const Key recurringDeleteButton = Key('recurring_delete_button');

  // Analysis
  static const Key analysisTrendChart = Key('analysis_trend_chart');
  static const Key analysisCategoryDist = Key('analysis_category_dist');

  // Retirement
  static const Key retirementCorpusValue = Key('retirement_corpus_value');
  static const String retirementAccountPrefix = 'retirement_account_';
  static Key retirementAccountItem(int id) =>
      Key('$retirementAccountPrefix$id');

  // Common
  static const Key saveButton = Key('save_button');
  static const Key deleteButton = Key('delete_button');
}
