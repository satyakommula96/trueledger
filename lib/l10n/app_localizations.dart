import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TrueLedger'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @variable.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get variable;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @investment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// No description provided for @monthlyHistory.
  ///
  /// In en, this message translates to:
  /// **'Monthly History'**
  String get monthlyHistory;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @billsDueToday.
  ///
  /// In en, this message translates to:
  /// **'{count} BILL DUE TODAY'**
  String billsDueToday(int count);

  /// No description provided for @billsDueTodayPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} BILLS DUE TODAY'**
  String billsDueTodayPlural(int count);

  /// No description provided for @todayLedger.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Ledger'**
  String get todayLedger;

  /// No description provided for @paymentCalendar.
  ///
  /// In en, this message translates to:
  /// **'Payment Calendar'**
  String get paymentCalendar;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month view'**
  String get monthView;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometrics;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID to unlock'**
  String get enableBiometrics;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @monthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get monthlyTrend;

  /// No description provided for @spendingAndIncome.
  ///
  /// In en, this message translates to:
  /// **'Spending & Income'**
  String get spendingAndIncome;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @momentum.
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get momentum;

  /// No description provided for @velocityIncreased.
  ///
  /// In en, this message translates to:
  /// **'Velocity increased by '**
  String get velocityIncreased;

  /// No description provided for @spendingDecreased.
  ///
  /// In en, this message translates to:
  /// **'Excellent. Spending decreased by '**
  String get spendingDecreased;

  /// No description provided for @relativeToLastPeriod.
  ///
  /// In en, this message translates to:
  /// **' relative to last period.'**
  String get relativeToLastPeriod;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @netPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'NET PORTFOLIO VALUE'**
  String get netPortfolioValue;

  /// No description provided for @allocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get allocation;

  /// No description provided for @assetClasses.
  ///
  /// In en, this message translates to:
  /// **'Asset Classes'**
  String get assetClasses;

  /// No description provided for @myAssets.
  ///
  /// In en, this message translates to:
  /// **'My Assets'**
  String get myAssets;

  /// No description provided for @fullList.
  ///
  /// In en, this message translates to:
  /// **'Full List'**
  String get fullList;

  /// No description provided for @noAssetsTracked.
  ///
  /// In en, this message translates to:
  /// **'NO ASSETS TRACKED'**
  String get noAssetsTracked;

  /// No description provided for @addFirstInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add your first investment to see analysis.'**
  String get addFirstInvestment;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @streakMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a roll! You\'ve logged transactions for {count} consecutive days.\n\nKeep tracking your expenses daily to build a healthy financial habit!'**
  String streakMessage(int count);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BALANCE'**
  String get currentBalance;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @personalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Experience adapts to your patterns'**
  String get personalizationDesc;

  /// No description provided for @privateAndLocal.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE & LOCAL'**
  String get privateAndLocal;

  /// No description provided for @privateAndLocalDesc.
  ///
  /// In en, this message translates to:
  /// **'All personalization data is stored only on your device. We never sync or upload your behavior patterns or sensitive financial identifiers.'**
  String get privateAndLocalDesc;

  /// No description provided for @dynamicAdaptation.
  ///
  /// In en, this message translates to:
  /// **'DYNAMIC ADAPTATION'**
  String get dynamicAdaptation;

  /// No description provided for @dynamicAdaptationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow experience to adapt to your patterns.'**
  String get dynamicAdaptationDesc;

  /// No description provided for @adaptiveBehavior.
  ///
  /// In en, this message translates to:
  /// **'ADAPTIVE BEHAVIOR'**
  String get adaptiveBehavior;

  /// No description provided for @rememberLastUsed.
  ///
  /// In en, this message translates to:
  /// **'REMEMBER LAST-USED'**
  String get rememberLastUsed;

  /// No description provided for @rememberLastUsedDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-fill category and payment method based on your last entry.'**
  String get rememberLastUsedDesc;

  /// No description provided for @timeOfDaySuggestions.
  ///
  /// In en, this message translates to:
  /// **'TIME-OF-DAY SUGGESTIONS'**
  String get timeOfDaySuggestions;

  /// No description provided for @timeOfDaySuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Suggest categories based on the time and your repetitions.'**
  String get timeOfDaySuggestionsDesc;

  /// No description provided for @shortcutSuggestions.
  ///
  /// In en, this message translates to:
  /// **'SHORTCUT SUGGESTIONS'**
  String get shortcutSuggestions;

  /// No description provided for @shortcutSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Prompt to create quick-add shortcuts for frequent transactions.'**
  String get shortcutSuggestionsDesc;

  /// No description provided for @baselineReflections.
  ///
  /// In en, this message translates to:
  /// **'BASELINE REFLECTIONS'**
  String get baselineReflections;

  /// No description provided for @baselineReflectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show comparisons locally (e.g. \'Higher than your usual Friday\').'**
  String get baselineReflectionsDesc;

  /// No description provided for @salaryCycle.
  ///
  /// In en, this message translates to:
  /// **'SALARY CYCLE'**
  String get salaryCycle;

  /// No description provided for @usualPayDay.
  ///
  /// In en, this message translates to:
  /// **'USUAL PAY DAY'**
  String get usualPayDay;

  /// No description provided for @dayNum.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayNum(int day);

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'NOT SET'**
  String get notSet;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'QUICK PRESETS'**
  String get quickPresets;

  /// No description provided for @noPresetsYet.
  ///
  /// In en, this message translates to:
  /// **'NO PRESETS CREATED YET.'**
  String get noPresetsYet;

  /// No description provided for @createNewPreset.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW PRESET'**
  String get createNewPreset;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get reminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'REMINDER TIME'**
  String get reminderTime;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @reminderTimeCleared.
  ///
  /// In en, this message translates to:
  /// **'REMINDER TIME CLEARED'**
  String get reminderTimeCleared;

  /// No description provided for @trustAndControl.
  ///
  /// In en, this message translates to:
  /// **'TRUST & CONTROL'**
  String get trustAndControl;

  /// No description provided for @resetPersonalization.
  ///
  /// In en, this message translates to:
  /// **'RESET PERSONALIZATION?'**
  String get resetPersonalization;

  /// No description provided for @resetPersonalizationDesc.
  ///
  /// In en, this message translates to:
  /// **'This will wipe all local learned behaviors. Your expense history will remain safe.'**
  String get resetPersonalizationDesc;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @personalizationResetCompleted.
  ///
  /// In en, this message translates to:
  /// **'PERSONALIZATION RESET COMPLETED'**
  String get personalizationResetCompleted;

  /// No description provided for @selectPayDay.
  ///
  /// In en, this message translates to:
  /// **'SELECT PAY DAY'**
  String get selectPayDay;

  /// No description provided for @createPreset.
  ///
  /// In en, this message translates to:
  /// **'CREATE PRESET'**
  String get createPreset;

  /// No description provided for @presetLabel.
  ///
  /// In en, this message translates to:
  /// **'LABEL (e.g. Coffee)'**
  String get presetLabel;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get deletePreset;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchLedger.
  ///
  /// In en, this message translates to:
  /// **'SEARCH LEDGER...'**
  String get searchLedger;

  /// No description provided for @typeTotal.
  ///
  /// In en, this message translates to:
  /// **'{type} TOTAL'**
  String typeTotal(String type);

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'NO ENTRIES YET'**
  String get noEntriesYet;

  /// No description provided for @noTransactionsFoundPeriod.
  ///
  /// In en, this message translates to:
  /// **'NO TRANSACTIONS FOUND FOR THIS PERIOD.'**
  String get noTransactionsFoundPeriod;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY SUMMARY'**
  String get weeklySummary;

  /// No description provided for @greatWorkWeek.
  ///
  /// In en, this message translates to:
  /// **'Great work this week.'**
  String get greatWorkWeek;

  /// No description provided for @reviewYourWeek.
  ///
  /// In en, this message translates to:
  /// **'Review your week.'**
  String get reviewYourWeek;

  /// No description provided for @underBudgetDays.
  ///
  /// In en, this message translates to:
  /// **'You stayed under budget {count} days.'**
  String underBudgetDays(int count);

  /// No description provided for @perfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect week! You stayed under budget every day.'**
  String get perfectWeek;

  /// No description provided for @heavyWeek.
  ///
  /// In en, this message translates to:
  /// **'It was a heavy week. Try to track closer next week.'**
  String get heavyWeek;

  /// No description provided for @spendingConsistency.
  ///
  /// In en, this message translates to:
  /// **'Spending Consistency'**
  String get spendingConsistency;

  /// No description provided for @dailyBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Daily Benchmark: ~{amount}'**
  String dailyBenchmark(String amount);

  /// No description provided for @spendingSpike.
  ///
  /// In en, this message translates to:
  /// **'Spending Spike'**
  String get spendingSpike;

  /// No description provided for @spikeMessage.
  ///
  /// In en, this message translates to:
  /// **'{category} increased by {amount} vs last week.'**
  String spikeMessage(String category, String amount);

  /// No description provided for @newCategoryExpenditure.
  ///
  /// In en, this message translates to:
  /// **'This is a new expenditure category for you.'**
  String get newCategoryExpenditure;

  /// No description provided for @eyeOnCategoryTrend.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on this category trend.'**
  String get eyeOnCategoryTrend;

  /// No description provided for @stableSpending.
  ///
  /// In en, this message translates to:
  /// **'Stable Spending'**
  String get stableSpending;

  /// No description provided for @noSpikesDetected.
  ///
  /// In en, this message translates to:
  /// **'Zero significant spending spikes detected compared to last week.'**
  String get noSpikesDetected;

  /// No description provided for @spendingStabilizing.
  ///
  /// In en, this message translates to:
  /// **'Your spending habits are stabilizing well.'**
  String get spendingStabilizing;

  /// No description provided for @volumeComparison.
  ///
  /// In en, this message translates to:
  /// **'Volume Comparison'**
  String get volumeComparison;

  /// No description provided for @reducedSpendingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success! You reduced spending by {amount}.'**
  String reducedSpendingSuccess(String amount);

  /// No description provided for @increasedSpendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Spending increased by {amount} vs last week.'**
  String increasedSpendingMessage(String amount);

  /// No description provided for @lastWeekVsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week: {last} | This Week: {current}'**
  String lastWeekVsThisWeek(String last, String current);

  /// No description provided for @primaryCategory.
  ///
  /// In en, this message translates to:
  /// **'Primary Category'**
  String get primaryCategory;

  /// No description provided for @largestExpenditureArea.
  ///
  /// In en, this message translates to:
  /// **'{category} was your largest expenditure area.'**
  String largestExpenditureArea(String category);

  /// No description provided for @alignWithPriorities.
  ///
  /// In en, this message translates to:
  /// **'Evaluate if this aligns with your current priorities.'**
  String get alignWithPriorities;

  /// No description provided for @weeklyFocus.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY FOCUS'**
  String get weeklyFocus;

  /// No description provided for @gentleGoal.
  ///
  /// In en, this message translates to:
  /// **'Gentle Goal'**
  String get gentleGoal;

  /// No description provided for @reductionTarget.
  ///
  /// In en, this message translates to:
  /// **'Target a 10% reduction in {category} spending.'**
  String reductionTarget(String category);

  /// No description provided for @stayUnderBudgetGoal.
  ///
  /// In en, this message translates to:
  /// **'Attempt to stay under budget for 5 days next week.'**
  String get stayUnderBudgetGoal;

  /// No description provided for @sustainableProgress.
  ///
  /// In en, this message translates to:
  /// **'Sustainable progress comes from consistent, small adjustments.'**
  String get sustainableProgress;

  /// No description provided for @reflectionFinancialIntuition.
  ///
  /// In en, this message translates to:
  /// **'Reflection builds financial intuition.'**
  String get reflectionFinancialIntuition;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'NEW LEDGER ENTRY'**
  String get newEntry;

  /// No description provided for @newTypeEntry.
  ///
  /// In en, this message translates to:
  /// **'NEW {type}'**
  String newTypeEntry(String type);

  /// No description provided for @entryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'ENTRY TYPE'**
  String get entryTypeLabel;

  /// No description provided for @transactionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION AMOUNT'**
  String get transactionAmountLabel;

  /// No description provided for @budgetImpact.
  ///
  /// In en, this message translates to:
  /// **'BUDGET IMPACT'**
  String get budgetImpact;

  /// No description provided for @exceedsBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'EXCEEDS BUDGET BY {amount}'**
  String exceedsBudgetBy(String amount);

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'REMAINING: {amount}'**
  String remainingLabel(String amount);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @categoryClassification.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY CLASSIFICATION'**
  String get categoryClassification;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'MANAGE CATEGORIES'**
  String get manageCategories;

  /// No description provided for @auditNotes.
  ///
  /// In en, this message translates to:
  /// **'AUDIT NOTES'**
  String get auditNotes;

  /// No description provided for @optionalDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details...'**
  String get optionalDetailsHint;

  /// No description provided for @commitToLedger.
  ///
  /// In en, this message translates to:
  /// **'COMMIT TO LEDGER'**
  String get commitToLedger;

  /// No description provided for @enterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get enterAmountError;

  /// No description provided for @validPositiveAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount'**
  String get validPositiveAmountError;

  /// No description provided for @budgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded: {category}'**
  String budgetExceededTitle(String category);

  /// No description provided for @budgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Warning: {category}'**
  String budgetWarningTitle(String category);

  /// No description provided for @budgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'You have spent 100% of your {category} budget.'**
  String budgetExceededBody(String category);

  /// No description provided for @budgetWarningBody.
  ///
  /// In en, this message translates to:
  /// **'You have reached {percentage}% of your {category} budget.'**
  String budgetWarningBody(String category, int percentage);

  /// No description provided for @editTypeEntry.
  ///
  /// In en, this message translates to:
  /// **'EDIT {type}'**
  String editTypeEntry(String type);

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'SOURCE'**
  String get sourceLabel;

  /// No description provided for @labelLabel.
  ///
  /// In en, this message translates to:
  /// **'LABEL'**
  String get labelLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get noteLabel;

  /// No description provided for @updateEntry.
  ///
  /// In en, this message translates to:
  /// **'UPDATE ENTRY'**
  String get updateEntry;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amountLabel;

  /// No description provided for @entryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get entryUpdated;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE ITEM?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteItemContent;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'KEEP'**
  String get keep;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @noResultsMatched.
  ///
  /// In en, this message translates to:
  /// **'NO RESULTS MATCHED'**
  String get noResultsMatched;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categoriesTitle;

  /// No description provided for @useCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use {category}'**
  String useCategoryTooltip(String category);

  /// No description provided for @addNewCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Add new category...'**
  String get addNewCategoryHint;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'NO CATEGORIES YET'**
  String get noCategoriesYet;

  /// No description provided for @addFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your first category for {type}'**
  String addFirstCategory(String type);

  /// No description provided for @categoryAddedTo.
  ///
  /// In en, this message translates to:
  /// **'{category} ADDED TO {type}'**
  String categoryAddedTo(String category, String type);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'{category} DELETED'**
  String categoryDeleted(String category);

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @scenarioModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Mode'**
  String get scenarioModeTitle;

  /// No description provided for @startLoggingToUseScenario.
  ///
  /// In en, this message translates to:
  /// **'Start logging to use Scenario Mode'**
  String get startLoggingToUseScenario;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'SIMULATION'**
  String get simulation;

  /// No description provided for @whatIfSavedMore.
  ///
  /// In en, this message translates to:
  /// **'What if you\nsaved more?'**
  String get whatIfSavedMore;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'SELECT CATEGORY'**
  String get selectCategory;

  /// No description provided for @reductionPercent.
  ///
  /// In en, this message translates to:
  /// **'REDUCTION PERCENT'**
  String get reductionPercent;

  /// No description provided for @projectedYearlySavings.
  ///
  /// In en, this message translates to:
  /// **'PROJECTED YEARLY SAVINGS'**
  String get projectedYearlySavings;

  /// No description provided for @scenarioImpactMessage.
  ///
  /// In en, this message translates to:
  /// **'Cutting your {category} bills by {percent}% frees up {amount} every single month.'**
  String scenarioImpactMessage(String category, int percent, String amount);

  /// No description provided for @wealthImpact.
  ///
  /// In en, this message translates to:
  /// **'WEALTH IMPACT'**
  String get wealthImpact;

  /// No description provided for @oneYearProgress.
  ///
  /// In en, this message translates to:
  /// **'1 Year Progress'**
  String get oneYearProgress;

  /// No description provided for @fiveYearMilestones.
  ///
  /// In en, this message translates to:
  /// **'5 Year Milestones'**
  String get fiveYearMilestones;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DUE'**
  String get totalDue;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @netWorthTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'NET WORTH TRACKING'**
  String get netWorthTrackingTitle;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'TREND'**
  String get trend;

  /// No description provided for @twelveMonthOverview.
  ///
  /// In en, this message translates to:
  /// **'12-MONTH OVERVIEW'**
  String get twelveMonthOverview;

  /// No description provided for @assetAllocation.
  ///
  /// In en, this message translates to:
  /// **'ASSET ALLOCATION'**
  String get assetAllocation;

  /// No description provided for @investmentPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Investment Portfolio'**
  String get investmentPortfolio;

  /// No description provided for @insight.
  ///
  /// In en, this message translates to:
  /// **'INSIGHT'**
  String get insight;

  /// No description provided for @simulationFailed.
  ///
  /// In en, this message translates to:
  /// **'Simulation failed: {error}'**
  String simulationFailed(String error);

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @savingGoals.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get savingGoals;

  /// No description provided for @trackYourMilestones.
  ///
  /// In en, this message translates to:
  /// **'Track your milestones'**
  String get trackYourMilestones;

  /// No description provided for @viewPastPerformance.
  ///
  /// In en, this message translates to:
  /// **'View past performance'**
  String get viewPastPerformance;

  /// No description provided for @automation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get automation;

  /// No description provided for @recurringTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions'**
  String get recurringTransactions;

  /// No description provided for @manageSpendingLimits.
  ///
  /// In en, this message translates to:
  /// **'Manage spending limits'**
  String get manageSpendingLimits;

  /// No description provided for @setUserName.
  ///
  /// In en, this message translates to:
  /// **'SET USER NAME'**
  String get setUserName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get nameLabel;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'SELECT CURRENCY'**
  String get selectCurrency;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency...'**
  String get searchCurrency;

  /// No description provided for @selectDataScenario.
  ///
  /// In en, this message translates to:
  /// **'SELECT DATA SCENARIO'**
  String get selectDataScenario;

  /// No description provided for @fictionalDataDemoOnly.
  ///
  /// In en, this message translates to:
  /// **'Fictional data for demonstration only.'**
  String get fictionalDataDemoOnly;

  /// No description provided for @completeDemo.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE DEMO'**
  String get completeDemo;

  /// No description provided for @allFeaturesStreaks.
  ///
  /// In en, this message translates to:
  /// **'All features, including Streaks'**
  String get allFeaturesStreaks;

  /// No description provided for @generatedScenarioData.
  ///
  /// In en, this message translates to:
  /// **'GENERATED {scenario} DATA SCENARIO'**
  String generatedScenarioData(String scenario);

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL DATA?'**
  String get deleteAllData;

  /// No description provided for @wipeAllDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All entries, budgets, and cards will be wiped.'**
  String get wipeAllDataWarning;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL'**
  String get deleteAll;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'RECORD PAYMENT'**
  String get recordPayment;

  /// No description provided for @dueBalance.
  ///
  /// In en, this message translates to:
  /// **'DUE BALANCE'**
  String get dueBalance;

  /// No description provided for @amountToRecord.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT TO RECORD'**
  String get amountToRecord;

  /// No description provided for @fullBalance.
  ///
  /// In en, this message translates to:
  /// **'FULL BALANCE'**
  String get fullBalance;

  /// No description provided for @minDueAmount.
  ///
  /// In en, this message translates to:
  /// **'MIN: {amount}'**
  String minDueAmount(String amount);

  /// No description provided for @noCardsRegistered.
  ///
  /// In en, this message translates to:
  /// **'NO CARDS REGISTERED'**
  String get noCardsRegistered;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'LIMIT: {amount}'**
  String limitLabel(String amount);

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get dueLabel;

  /// No description provided for @percentUtilized.
  ///
  /// In en, this message translates to:
  /// **'{percent}% UTILIZED'**
  String percentUtilized(String percent);

  /// No description provided for @availableAmount.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE: {amount}'**
  String availableAmount(String amount);

  /// No description provided for @totalCardsDebt.
  ///
  /// In en, this message translates to:
  /// **'TOTAL CARDS DEBT'**
  String get totalCardsDebt;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @initializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization Failed'**
  String get initializationFailed;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'WEEK'**
  String get week;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @remainingAmountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String remainingAmountLeft(String amount);

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'YOUR GOALS'**
  String get yourGoals;

  /// No description provided for @totalProgress.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PROGRESS'**
  String get totalProgress;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get savedLabel;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get targetLabel;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'NO GOALS YET'**
  String get noGoalsYet;

  /// No description provided for @setFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your first saving goal and start building your future!'**
  String get setFirstGoal;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'GOAL ACHIEVED! 🎉'**
  String get goalAchieved;

  /// No description provided for @toGoLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} TO GO'**
  String toGoLabel(String amount);

  /// No description provided for @archiveLabel.
  ///
  /// In en, this message translates to:
  /// **'ARCHIVE'**
  String get archiveLabel;

  /// No description provided for @reflectionLabel.
  ///
  /// In en, this message translates to:
  /// **'{year} Reflection'**
  String reflectionLabel(int year);

  /// No description provided for @goalTracking.
  ///
  /// In en, this message translates to:
  /// **'GOAL TRACKING'**
  String get goalTracking;

  /// No description provided for @retirementHealth.
  ///
  /// In en, this message translates to:
  /// **'Retirement Health'**
  String get retirementHealth;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'NO DATA AVAILABLE'**
  String get noDataAvailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'SELECT THEME'**
  String get selectTheme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'QUICK ADD'**
  String get quickAdd;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @whatWasThisFor.
  ///
  /// In en, this message translates to:
  /// **'What was this for?'**
  String get whatWasThisFor;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'SAVE EXPENSE'**
  String get saveExpense;

  /// No description provided for @presetsLabel.
  ///
  /// In en, this message translates to:
  /// **'PRESETS'**
  String get presetsLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethodLabel;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @netBanking.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get netBanking;

  /// No description provided for @genericCard.
  ///
  /// In en, this message translates to:
  /// **'Generic Card'**
  String get genericCard;

  /// No description provided for @saveAsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Save as shortcut?'**
  String get saveAsShortcut;

  /// No description provided for @suggestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggestedLabel;

  /// No description provided for @basedOnLastEntry.
  ///
  /// In en, this message translates to:
  /// **'Based on your last entry'**
  String get basedOnLastEntry;

  /// No description provided for @basedOnDailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Based on your daily routine'**
  String get basedOnDailyRoutine;

  /// No description provided for @dailyPattern.
  ///
  /// In en, this message translates to:
  /// **'Daily Pattern'**
  String get dailyPattern;

  /// No description provided for @basedOnLastRecord.
  ///
  /// In en, this message translates to:
  /// **'Based on last record'**
  String get basedOnLastRecord;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNow;

  /// No description provided for @shortcutSaved.
  ///
  /// In en, this message translates to:
  /// **'Shortcut saved!'**
  String get shortcutSaved;

  /// No description provided for @youLogOften.
  ///
  /// In en, this message translates to:
  /// **'You log \'{title}\' often.'**
  String youLogOften(String title);

  /// No description provided for @recordedBalanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recorded! {method} balance updated.'**
  String recordedBalanceUpdated(String method);

  /// No description provided for @validAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get validAmountError;

  /// No description provided for @transparencyCheck.
  ///
  /// In en, this message translates to:
  /// **'Transparency Check'**
  String get transparencyCheck;

  /// No description provided for @prefilledNotice.
  ///
  /// In en, this message translates to:
  /// **'We pre-filled some values locally to save you typing effort.'**
  String get prefilledNotice;

  /// No description provided for @localDataNotice.
  ///
  /// In en, this message translates to:
  /// **'This data never leaves your device.'**
  String get localDataNotice;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterdayLabel;

  /// No description provided for @otherLabel.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get otherLabel;

  /// No description provided for @intelligentInsights.
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENT INSIGHTS'**
  String get intelligentInsights;

  /// No description provided for @aiPoweredAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Analysis'**
  String get aiPoweredAnalysis;

  /// No description provided for @scenarioModeLabel.
  ///
  /// In en, this message translates to:
  /// **'SCENARIO MODE'**
  String get scenarioModeLabel;

  /// No description provided for @simulateFuture.
  ///
  /// In en, this message translates to:
  /// **'Simulate your financial future.'**
  String get simulateFuture;

  /// No description provided for @mindset.
  ///
  /// In en, this message translates to:
  /// **'MINDSET'**
  String get mindset;

  /// No description provided for @basedOnLocalHistory.
  ///
  /// In en, this message translates to:
  /// **'Based on local history.'**
  String get basedOnLocalHistory;

  /// No description provided for @excellentLabel.
  ///
  /// In en, this message translates to:
  /// **'EXCELLENT'**
  String get excellentLabel;

  /// No description provided for @goodLabel.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get goodLabel;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE'**
  String get averageLabel;

  /// No description provided for @calibrating.
  ///
  /// In en, this message translates to:
  /// **'CALIBRATING...'**
  String get calibrating;

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get atRisk;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @snooze7Days.
  ///
  /// In en, this message translates to:
  /// **'Snooze 7 days'**
  String get snooze7Days;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'MARK PAID'**
  String get markPaid;

  /// No description provided for @markedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as paid'**
  String markedAsPaid(String name);

  /// No description provided for @markPaidFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as paid: {error}'**
  String markPaidFailed(String error);

  /// No description provided for @retirement.
  ///
  /// In en, this message translates to:
  /// **'RETIREMENT'**
  String get retirement;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'MY ACCOUNTS'**
  String get myAccounts;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'BREAKDOWN'**
  String get breakdown;

  /// No description provided for @futureWealth.
  ///
  /// In en, this message translates to:
  /// **'FUTURE WEALTH'**
  String get futureWealth;

  /// No description provided for @projection.
  ///
  /// In en, this message translates to:
  /// **'PROJECTION'**
  String get projection;

  /// No description provided for @yearsLabel.
  ///
  /// In en, this message translates to:
  /// **'YEARS'**
  String get yearsLabel;

  /// No description provided for @retirementReady.
  ///
  /// In en, this message translates to:
  /// **'RETIREMENT READY'**
  String get retirementReady;

  /// No description provided for @totalRetirementCorpus.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RETIREMENT CORPUS'**
  String get totalRetirementCorpus;

  /// No description provided for @latency.
  ///
  /// In en, this message translates to:
  /// **'LATENCY: {time}'**
  String latency(String time);

  /// No description provided for @estimatedCorpus.
  ///
  /// In en, this message translates to:
  /// **'Estimated corpus at retirement: {amount}'**
  String estimatedCorpus(String amount);

  /// No description provided for @projectionSettings.
  ///
  /// In en, this message translates to:
  /// **'PROJECTION SETTINGS'**
  String get projectionSettings;

  /// No description provided for @currentAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Age'**
  String get currentAgeLabel;

  /// No description provided for @retirementAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Retirement Age'**
  String get retirementAgeLabel;

  /// No description provided for @expectedReturn.
  ///
  /// In en, this message translates to:
  /// **'Expected Return Rate'**
  String get expectedReturn;

  /// No description provided for @percentPa.
  ///
  /// In en, this message translates to:
  /// **'% p.a.'**
  String get percentPa;

  /// No description provided for @updateTargets.
  ///
  /// In en, this message translates to:
  /// **'UPDATE TARGETS'**
  String get updateTargets;

  /// No description provided for @wealthAdvisory.
  ///
  /// In en, this message translates to:
  /// **'WEALTH ADVISORY'**
  String get wealthAdvisory;

  /// No description provided for @optimalTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Your trajectory is optimal. Maintain current velocity to ensure capital preservation against inflation.'**
  String get optimalTrajectory;

  /// No description provided for @velocityAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Velocity adjustment recommended. Increasing monthly contributions by 10% will accelerate your goal timeline.'**
  String get velocityAdjustment;

  /// No description provided for @borrowingsAndLoans.
  ///
  /// In en, this message translates to:
  /// **'BORROWINGS & LOANS'**
  String get borrowingsAndLoans;

  /// No description provided for @noActiveBorrowings.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE BORROWINGS.'**
  String get noActiveBorrowings;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'REPAID'**
  String get repaid;

  /// No description provided for @percentRepaid.
  ///
  /// In en, this message translates to:
  /// **'{percent}% REPAID'**
  String percentRepaid(String percent);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'OF {amount}'**
  String ofAmount(String amount);

  /// No description provided for @totalBorrowings.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BORROWINGS'**
  String get totalBorrowings;

  /// No description provided for @strategy.
  ///
  /// In en, this message translates to:
  /// **'STRATEGY'**
  String get strategy;

  /// No description provided for @debtPayoffPlanner.
  ///
  /// In en, this message translates to:
  /// **'Debt Payoff Planner'**
  String get debtPayoffPlanner;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'FLEXIBLE'**
  String get flexible;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get recurring;

  /// No description provided for @dueTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get dueTodayLabel;

  /// No description provided for @dueTomorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'DUE TOMORROW'**
  String get dueTomorrowLabel;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'RECORD'**
  String get record;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'AGE'**
  String get age;

  /// No description provided for @emi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get emi;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get due;

  /// No description provided for @newBorrowing.
  ///
  /// In en, this message translates to:
  /// **'NEW BORROWING'**
  String get newBorrowing;

  /// No description provided for @loanClassification.
  ///
  /// In en, this message translates to:
  /// **'LOAN CLASSIFICATION'**
  String get loanClassification;

  /// No description provided for @creditorLoanName.
  ///
  /// In en, this message translates to:
  /// **'CREDITOR / LOAN NAME'**
  String get creditorLoanName;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'REMAINING BALANCE'**
  String get remainingBalance;

  /// No description provided for @totalLoan.
  ///
  /// In en, this message translates to:
  /// **'TOTAL LOAN'**
  String get totalLoan;

  /// No description provided for @monthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY EMI'**
  String get monthlyEmi;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'INTEREST RATE'**
  String get interestRate;

  /// No description provided for @expectedRepaymentDate.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED REPAYMENT DATE'**
  String get expectedRepaymentDate;

  /// No description provided for @dueDateDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE (DAY OF MONTH)'**
  String get dueDateDayOfMonth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @commitBorrowing.
  ///
  /// In en, this message translates to:
  /// **'COMMIT BORROWING'**
  String get commitBorrowing;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @remainingCannotExceedTotal.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance cannot exceed total loan'**
  String get remainingCannotExceedTotal;

  /// No description provided for @updateLoan.
  ///
  /// In en, this message translates to:
  /// **'UPDATE LOAN'**
  String get updateLoan;

  /// No description provided for @recordEmiPayment.
  ///
  /// In en, this message translates to:
  /// **'RECORD EMI PAYMENT'**
  String get recordEmiPayment;

  /// No description provided for @recordPrepayment.
  ///
  /// In en, this message translates to:
  /// **'RECORD PREPAYMENT'**
  String get recordPrepayment;

  /// No description provided for @updateBorrowing.
  ///
  /// In en, this message translates to:
  /// **'UPDATE BORROWING'**
  String get updateBorrowing;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT HISTORY'**
  String get paymentHistory;

  /// No description provided for @noRecordedPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'No recorded payment history found.'**
  String get noRecordedPaymentHistory;

  /// No description provided for @markAsEmi.
  ///
  /// In en, this message translates to:
  /// **'MARK AS EMI'**
  String get markAsEmi;

  /// No description provided for @notAPayment.
  ///
  /// In en, this message translates to:
  /// **'NOT A PAYMENT'**
  String get notAPayment;

  /// No description provided for @showAllWithCount.
  ///
  /// In en, this message translates to:
  /// **'SHOW ALL ({count} PAYMENTS)'**
  String showAllWithCount(int count);

  /// No description provided for @payoffQuote.
  ///
  /// In en, this message translates to:
  /// **'PAYOFF QUOTE'**
  String get payoffQuote;

  /// No description provided for @estimate.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATE'**
  String get estimate;

  /// No description provided for @validUntilToday.
  ///
  /// In en, this message translates to:
  /// **'Valid until today'**
  String get validUntilToday;

  /// No description provided for @reconcileWithBank.
  ///
  /// In en, this message translates to:
  /// **'RECONCILE WITH BANK'**
  String get reconcileWithBank;

  /// No description provided for @payoffBreakdown.
  ///
  /// In en, this message translates to:
  /// **'PAYOFF BREAKDOWN'**
  String get payoffBreakdown;

  /// No description provided for @principalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Principal Outstanding'**
  String get principalOutstanding;

  /// No description provided for @interestAccrued.
  ///
  /// In en, this message translates to:
  /// **'Interest Accrued'**
  String get interestAccrued;

  /// No description provided for @totalQuote.
  ///
  /// In en, this message translates to:
  /// **'Total Quote'**
  String get totalQuote;

  /// No description provided for @trustCenter.
  ///
  /// In en, this message translates to:
  /// **'TRUST CENTER'**
  String get trustCenter;

  /// No description provided for @ourGuarantees.
  ///
  /// In en, this message translates to:
  /// **'OUR GUARANTEES'**
  String get ourGuarantees;

  /// No description provided for @strictPolicies.
  ///
  /// In en, this message translates to:
  /// **'STRICT POLICIES'**
  String get strictPolicies;

  /// No description provided for @dataHealth.
  ///
  /// In en, this message translates to:
  /// **'DATA HEALTH'**
  String get dataHealth;

  /// No description provided for @backupConfidence.
  ///
  /// In en, this message translates to:
  /// **'BACKUP CONFIDENCE'**
  String get backupConfidence;

  /// No description provided for @localBackups.
  ///
  /// In en, this message translates to:
  /// **'LOCAL BACKUPS'**
  String get localBackups;

  /// No description provided for @viewFolder.
  ///
  /// In en, this message translates to:
  /// **'VIEW FOLDER'**
  String get viewFolder;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RECORDS'**
  String get totalRecords;

  /// No description provided for @localBackupStatus.
  ///
  /// In en, this message translates to:
  /// **'LOCAL BACKUP STATUS'**
  String get localBackupStatus;

  /// No description provided for @lastBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time}'**
  String lastBackupLabel(String time);

  /// No description provided for @nextAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Next automatic backup: At next application launch'**
  String get nextAutoBackup;

  /// No description provided for @noLocalBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'NO LOCAL BACKUPS FOUND YET.'**
  String get noLocalBackupsFound;

  /// No description provided for @sqlCipherEncryption.
  ///
  /// In en, this message translates to:
  /// **'TrueLedger uses SQLCipher AES-256 for database encryption on supported platforms.'**
  String get sqlCipherEncryption;

  /// No description provided for @productLevelPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT-LEVEL PRIVACY GUARANTEES.'**
  String get productLevelPrivacy;

  /// No description provided for @privacyPrinciple.
  ///
  /// In en, this message translates to:
  /// **'TrueLedger is built on the principle that your financial life is yours alone. We believe in absolute privacy, which is why your data never leaves your device.'**
  String get privacyPrinciple;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'NO ADS'**
  String get noAds;

  /// No description provided for @noAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'We never clutter your experience with advertisements or sponsored content.'**
  String get noAdsDesc;

  /// No description provided for @noTracking.
  ///
  /// In en, this message translates to:
  /// **'NO TRACKING'**
  String get noTracking;

  /// No description provided for @noTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'We don\'t track your behavior, location, or usage. You are not a data point.'**
  String get noTrackingDesc;

  /// No description provided for @noProfiling.
  ///
  /// In en, this message translates to:
  /// **'NO PROFILING'**
  String get noProfiling;

  /// No description provided for @noProfilingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your financial habits are private. We don\'t build profiles for targeting.'**
  String get noProfilingDesc;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'100% LOCAL'**
  String get localOnly;

  /// No description provided for @localOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your database exists only on your device. We have no access to your logs.'**
  String get localOnlyDesc;

  /// No description provided for @noAnalyticsSdk.
  ///
  /// In en, this message translates to:
  /// **'No analytics or tracking SDKs'**
  String get noAnalyticsSdk;

  /// No description provided for @noBehaviorProfiling.
  ///
  /// In en, this message translates to:
  /// **'No behavior profiling or scoring'**
  String get noBehaviorProfiling;

  /// No description provided for @noBankScraping.
  ///
  /// In en, this message translates to:
  /// **'No bank or SMS scraping'**
  String get noBankScraping;

  /// No description provided for @noCloudSync.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync or external storage'**
  String get noCloudSync;

  /// No description provided for @noSellingLogs.
  ///
  /// In en, this message translates to:
  /// **'No selling or sharing of user logs'**
  String get noSellingLogs;

  /// No description provided for @restoreDataTitle.
  ///
  /// In en, this message translates to:
  /// **'RESTORE DATA?'**
  String get restoreDataTitle;

  /// No description provided for @restoreDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will REPLACE all your current data with the data from this backup. This action cannot be undone.'**
  String get restoreDataWarning;

  /// No description provided for @restoreNow.
  ///
  /// In en, this message translates to:
  /// **'RESTORE NOW'**
  String get restoreNow;

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'RESTORE COMPLETED SUCCESSFULLY'**
  String get restoreCompleted;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'RESTORE FAILED: {error}'**
  String restoreFailed(String error);

  /// No description provided for @runwayMonths.
  ///
  /// In en, this message translates to:
  /// **'Your savings will last approx. {months} months'**
  String runwayMonths(int months);

  /// No description provided for @sustainableRunway.
  ///
  /// In en, this message translates to:
  /// **'Your financial path is sustainable'**
  String get sustainableRunway;

  /// No description provided for @deficitRunway.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BALANCE IN DEFICIT'**
  String get deficitRunway;

  /// No description provided for @calculatingRunway.
  ///
  /// In en, this message translates to:
  /// **'Calculating runway...'**
  String get calculatingRunway;

  /// No description provided for @failedToLoadLoans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load loans: {error}'**
  String failedToLoadLoans(String error);

  /// No description provided for @loanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC Gold Loan'**
  String get loanNameHint;

  /// No description provided for @engineReducingBalance.
  ///
  /// In en, this message translates to:
  /// **'Engine: Reducing balance (daily)'**
  String get engineReducingBalance;

  /// No description provided for @bankType.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankType;

  /// No description provided for @individualType.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualType;

  /// No description provided for @goldType.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get goldType;

  /// No description provided for @carType.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carType;

  /// No description provided for @homeType.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeType;

  /// No description provided for @educationType.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationType;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectDueDay.
  ///
  /// In en, this message translates to:
  /// **'Select Due Day'**
  String get selectDueDay;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'DATA EXPORT'**
  String get dataExport;

  /// No description provided for @dangerousTerritory.
  ///
  /// In en, this message translates to:
  /// **'DANGEROUS TERRITORY'**
  String get dangerousTerritory;

  /// No description provided for @dataSeeding.
  ///
  /// In en, this message translates to:
  /// **'DATA SEEDING'**
  String get dataSeeding;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL DATA'**
  String get resetAllData;

  /// No description provided for @appSecurity.
  ///
  /// In en, this message translates to:
  /// **'APP SECURITY'**
  String get appSecurity;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @personalizationHeader.
  ///
  /// In en, this message translates to:
  /// **'PERSONALIZATION'**
  String get personalizationHeader;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @dataTools.
  ///
  /// In en, this message translates to:
  /// **'DATA TOOLS'**
  String get dataTools;

  /// No description provided for @trustCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explicit guarantees & data health'**
  String get trustCenterSubtitle;

  /// No description provided for @appSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN for access'**
  String get appSecuritySubtitle;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between Light, Dark, or System theme'**
  String get appearanceSubtitle;

  /// No description provided for @dataExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-tap export (history, budgets, insights)'**
  String get dataExportSubtitle;

  /// No description provided for @resetApplicationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data and start fresh'**
  String get resetApplicationSubtitle;

  /// No description provided for @seedDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Populate app with demo entries'**
  String get seedDataSubtitle;

  /// No description provided for @ritualComplete.
  ///
  /// In en, this message translates to:
  /// **'Ritual complete. Rest well.'**
  String get ritualComplete;

  /// No description provided for @dayRitual.
  ///
  /// In en, this message translates to:
  /// **'DAY RITUAL'**
  String get dayRitual;

  /// No description provided for @dailyReview.
  ///
  /// In en, this message translates to:
  /// **'Daily Review'**
  String get dailyReview;

  /// No description provided for @loggedEntriesToday.
  ///
  /// In en, this message translates to:
  /// **'You\'ve logged {count} entries today.'**
  String loggedEntriesToday(Object count);

  /// No description provided for @underTarget.
  ///
  /// In en, this message translates to:
  /// **'{amount} under target'**
  String underTarget(Object amount);

  /// No description provided for @overTarget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over target'**
  String overTarget(Object amount);

  /// No description provided for @finishDailyReview.
  ///
  /// In en, this message translates to:
  /// **'Finish Daily Review'**
  String get finishDailyReview;

  /// No description provided for @stillDay.
  ///
  /// In en, this message translates to:
  /// **'Still Day?'**
  String get stillDay;

  /// No description provided for @noTransactionsTodayDescription.
  ///
  /// In en, this message translates to:
  /// **'No transactions logged today. If you\'re all set, we\'ll see you tomorrow.'**
  String get noTransactionsTodayDescription;

  /// No description provided for @closeDay.
  ///
  /// In en, this message translates to:
  /// **'Close Day'**
  String get closeDay;

  /// No description provided for @dataSovereignty.
  ///
  /// In en, this message translates to:
  /// **'DATA SOVEREIGNTY'**
  String get dataSovereignty;

  /// No description provided for @dataSovereigntyDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete data portability. Export your entire history in open formats anytime you want.'**
  String get dataSovereigntyDescription;

  /// No description provided for @oneTapArchive.
  ///
  /// In en, this message translates to:
  /// **'ONE-TAP ARCHIVE'**
  String get oneTapArchive;

  /// No description provided for @oneTapArchiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a complete snapshot of your financial history, budgets, and AI insights in a secure JSON format.'**
  String get oneTapArchiveDescription;

  /// No description provided for @exportNow.
  ///
  /// In en, this message translates to:
  /// **'EXPORT NOW'**
  String get exportNow;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'RESTORE BACKUP'**
  String get restoreBackup;

  /// No description provided for @restoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from a previous export'**
  String get restoreBackupSubtitle;

  /// No description provided for @individualReports.
  ///
  /// In en, this message translates to:
  /// **'INDIVIDUAL REPORTS (CSV / PDF)'**
  String get individualReports;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTIONS'**
  String get transactions;

  /// No description provided for @transactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses, income (CSV)'**
  String get transactionsSubtitle;

  /// No description provided for @pdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF REPORT'**
  String get pdfReport;

  /// No description provided for @pdfReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Printable financial report'**
  String get pdfReportSubtitle;

  /// No description provided for @budgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limits and targets (CSV)'**
  String get budgetsSubtitle;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHTS'**
  String get aiInsights;

  /// No description provided for @aiInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Health analysis (CSV)'**
  String get aiInsightsSubtitle;

  /// No description provided for @loansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowing details (CSV)'**
  String get loansSubtitle;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'DATE RANGE'**
  String get dateRange;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @dataOwnershipNotice.
  ///
  /// In en, this message translates to:
  /// **'TrueLedger never retains a copy of your data on its servers. You are the sole custodian of your financial history.'**
  String get dataOwnershipNotice;

  /// No description provided for @encryptBackup.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPT BACKUP'**
  String get encryptBackup;

  /// No description provided for @encryptBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to encrypt this file.'**
  String get encryptBackupSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @decrypt.
  ///
  /// In en, this message translates to:
  /// **'DECRYPT'**
  String get decrypt;

  /// No description provided for @decryptBackup.
  ///
  /// In en, this message translates to:
  /// **'DECRYPT BACKUP'**
  String get decryptBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'CREATE BACKUP'**
  String get backupCreated;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'EXPORT SAVED TO {path}'**
  String exportSaved(Object path);

  /// No description provided for @fullDataExportCompleted.
  ///
  /// In en, this message translates to:
  /// **'FULL DATA EXPORT COMPLETED'**
  String get fullDataExportCompleted;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'EXPORT FAILED: {error}'**
  String exportFailed(Object error);

  /// No description provided for @noDataFoundToExport.
  ///
  /// In en, this message translates to:
  /// **'NO DATA FOUND TO EXPORT'**
  String get noDataFoundToExport;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'{type} EXPORTED SUCCESSFUL'**
  String exportSuccessful(Object type);

  /// No description provided for @pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'PDF REPORT GENERATED SUCCESSFULLY'**
  String get pdfGenerated;

  /// No description provided for @restoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'RESTORE SUCCESSFUL'**
  String get restoreSuccessful;

  /// No description provided for @restoreFailedDetailed.
  ///
  /// In en, this message translates to:
  /// **'RESTORE FAILED: {error}'**
  String restoreFailedDetailed(Object error);

  /// No description provided for @restoreUndone.
  ///
  /// In en, this message translates to:
  /// **'RESTORE UNDONE'**
  String get restoreUndone;

  /// No description provided for @errorDuringRestore.
  ///
  /// In en, this message translates to:
  /// **'ERROR DURING RESTORE: {error}'**
  String errorDuringRestore(Object error);

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will REPLACE all your current data with the backup file.'**
  String get restoreReplaceWarning;

  /// No description provided for @restoreAutoBackupNotice.
  ///
  /// In en, this message translates to:
  /// **'• Current state will be AUTO-BACKUPED.\n• Action can be UNDONE immediately.'**
  String get restoreAutoBackupNotice;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get restore;

  /// No description provided for @saveEncryptedExport.
  ///
  /// In en, this message translates to:
  /// **'Save Encrypted Export'**
  String get saveEncryptedExport;

  /// No description provided for @saveFullExport.
  ///
  /// In en, this message translates to:
  /// **'Save Full Export'**
  String get saveFullExport;

  /// No description provided for @saveCsvExport.
  ///
  /// In en, this message translates to:
  /// **'Save CSV Export'**
  String get saveCsvExport;

  /// No description provided for @introTrueLedger.
  ///
  /// In en, this message translates to:
  /// **'TrueLedger'**
  String get introTrueLedger;

  /// No description provided for @introTagline.
  ///
  /// In en, this message translates to:
  /// **'Your private financial companion.'**
  String get introTagline;

  /// No description provided for @trackYourWealth.
  ///
  /// In en, this message translates to:
  /// **'Track Your Wealth'**
  String get trackYourWealth;

  /// No description provided for @trackYourWealthDesc.
  ///
  /// In en, this message translates to:
  /// **'See exactly where your money goes with crystal-clear insights.'**
  String get trackYourWealthDesc;

  /// No description provided for @smartBudgeting.
  ///
  /// In en, this message translates to:
  /// **'Smart Budgeting'**
  String get smartBudgeting;

  /// No description provided for @smartBudgetingDesc.
  ///
  /// In en, this message translates to:
  /// **'Set goals and spending limits to save without the sacrifice.'**
  String get smartBudgetingDesc;

  /// No description provided for @secureAndPrivate.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get secureAndPrivate;

  /// No description provided for @secureAndPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device. No cloud uploads, no tracking.'**
  String get secureAndPrivateDesc;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatShouldWeCallYou;

  /// No description provided for @enterYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourNameHint;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long (max 20 characters)'**
  String get nameTooLong;

  /// No description provided for @quickAddNote.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddNote;

  /// No description provided for @netWorthIncreased.
  ///
  /// In en, this message translates to:
  /// **'Great progress! Your net worth has '**
  String get netWorthIncreased;

  /// No description provided for @netWorthDecreased.
  ///
  /// In en, this message translates to:
  /// **'Your net worth has '**
  String get netWorthDecreased;

  /// No description provided for @increasedLabel.
  ///
  /// In en, this message translates to:
  /// **'increased'**
  String get increasedLabel;

  /// No description provided for @decreasedLabel.
  ///
  /// In en, this message translates to:
  /// **'decreased'**
  String get decreasedLabel;

  /// No description provided for @byLabel.
  ///
  /// In en, this message translates to:
  /// **' by '**
  String get byLabel;

  /// No description provided for @overLast12Months.
  ///
  /// In en, this message translates to:
  /// **' over the last 12 months.'**
  String get overLast12Months;

  /// No description provided for @failedToRefreshDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh dashboard'**
  String get failedToRefreshDashboard;

  /// No description provided for @logFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Log First Expense'**
  String get logFirstExpense;

  /// No description provided for @logFirstExpenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Track where your money goes'**
  String get logFirstExpenseDesc;

  /// No description provided for @setABudget.
  ///
  /// In en, this message translates to:
  /// **'Set a Budget'**
  String get setABudget;

  /// No description provided for @setABudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your spending in check'**
  String get setABudgetDesc;

  /// No description provided for @seeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'See Analysis'**
  String get seeAnalysis;

  /// No description provided for @seeAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Identify spending patterns'**
  String get seeAnalysisDesc;

  /// No description provided for @personalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adaptive defaults & presets'**
  String get personalizationSubtitle;

  /// No description provided for @currencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get currencySubtitle;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit or delete your own categories'**
  String get manageCategoriesSubtitle;

  /// No description provided for @inrRupeeName.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get inrRupeeName;

  /// No description provided for @usdDollarName.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usdDollarName;

  /// No description provided for @eurEuroName.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get eurEuroName;

  /// No description provided for @gbpPoundName.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get gbpPoundName;

  /// No description provided for @jpyYenName.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get jpyYenName;

  /// No description provided for @cadDollarName.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get cadDollarName;

  /// No description provided for @audDollarName.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get audDollarName;

  /// No description provided for @sgdDollarName.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get sgdDollarName;

  /// No description provided for @aedDirhamName.
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham'**
  String get aedDirhamName;

  /// No description provided for @sarRiyalName.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get sarRiyalName;

  /// No description provided for @cnyYuanName.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get cnyYuanName;

  /// No description provided for @krwWonName.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get krwWonName;

  /// No description provided for @brlRealName.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Real'**
  String get brlRealName;

  /// No description provided for @mxnPesoName.
  ///
  /// In en, this message translates to:
  /// **'Mexican Peso'**
  String get mxnPesoName;

  /// No description provided for @yearReview.
  ///
  /// In en, this message translates to:
  /// **'{year} REVIEW'**
  String yearReview(Object year);

  /// No description provided for @annualReflection.
  ///
  /// In en, this message translates to:
  /// **'Annual Reflection'**
  String get annualReflection;

  /// No description provided for @annualVolume.
  ///
  /// In en, this message translates to:
  /// **'Annual Volume'**
  String get annualVolume;

  /// No description provided for @totalSpendingReached.
  ///
  /// In en, this message translates to:
  /// **'Total spending reached {amount}.'**
  String totalSpendingReached(Object amount);

  /// No description provided for @spendingIncrease.
  ///
  /// In en, this message translates to:
  /// **'This is a increase of {amount} ({percentage}%) vs {previousYear}.'**
  String spendingIncrease(
      Object amount, Object percentage, Object previousYear);

  /// No description provided for @spendingDecrease.
  ///
  /// In en, this message translates to:
  /// **'This is a decrease of {amount} ({percentage}%) vs {previousYear}.'**
  String spendingDecrease(
      Object amount, Object percentage, Object previousYear);

  /// No description provided for @noDataForPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'No data available for {year} to compare.'**
  String noDataForPreviousYear(Object year);

  /// No description provided for @peakSpending.
  ///
  /// In en, this message translates to:
  /// **'Peak Spending'**
  String get peakSpending;

  /// No description provided for @highestSpendingMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} was the year\'s highest spending month.'**
  String highestSpendingMonth(Object month);

  /// No description provided for @noSignificantPeaks.
  ///
  /// In en, this message translates to:
  /// **'No significant spending peaks found.'**
  String get noSignificantPeaks;

  /// No description provided for @averageMonthlySpendStabilized.
  ///
  /// In en, this message translates to:
  /// **'Average monthly spend stabilized at {amount}.'**
  String averageMonthlySpendStabilized(Object amount);

  /// No description provided for @keepTrackingTrends.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking to see long-term trends.'**
  String get keepTrackingTrends;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get topCategory;

  /// No description provided for @primaryExpenditureCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} was the primary expenditure category.'**
  String primaryExpenditureCategory(Object category);

  /// No description provided for @categoryHabitNote.
  ///
  /// In en, this message translates to:
  /// **'High volume in this category often suggests recurring fixed costs or lifestyle habits.'**
  String get categoryHabitNote;

  /// No description provided for @categoryStability.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY STABILITY'**
  String get categoryStability;

  /// No description provided for @stabilityCategory.
  ///
  /// In en, this message translates to:
  /// **'STABILITY: {category}'**
  String stabilityCategory(Object category);

  /// No description provided for @spendingStable.
  ///
  /// In en, this message translates to:
  /// **'Spending on {category} remained remarkably consistent throughout {year}.'**
  String spendingStable(Object category, Object year);

  /// No description provided for @spendingFluctuated.
  ///
  /// In en, this message translates to:
  /// **'Spending on {category} showed significant fluctuation.'**
  String spendingFluctuated(Object category);

  /// No description provided for @annualReflectionOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Annual reflection generated from your private,\non-device financial history.'**
  String get annualReflectionOnDevice;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'TRENDS'**
  String get trends;

  /// No description provided for @spending.
  ///
  /// In en, this message translates to:
  /// **'SPENDING'**
  String get spending;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @janShort.
  ///
  /// In en, this message translates to:
  /// **'JAN'**
  String get janShort;

  /// No description provided for @febShort.
  ///
  /// In en, this message translates to:
  /// **'FEB'**
  String get febShort;

  /// No description provided for @marShort.
  ///
  /// In en, this message translates to:
  /// **'MAR'**
  String get marShort;

  /// No description provided for @aprShort.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get aprShort;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get mayShort;

  /// No description provided for @junShort.
  ///
  /// In en, this message translates to:
  /// **'JUN'**
  String get junShort;

  /// No description provided for @julShort.
  ///
  /// In en, this message translates to:
  /// **'JUL'**
  String get julShort;

  /// No description provided for @augShort.
  ///
  /// In en, this message translates to:
  /// **'AUG'**
  String get augShort;

  /// No description provided for @sepShort.
  ///
  /// In en, this message translates to:
  /// **'SEP'**
  String get sepShort;

  /// No description provided for @octShort.
  ///
  /// In en, this message translates to:
  /// **'OCT'**
  String get octShort;

  /// No description provided for @novShort.
  ///
  /// In en, this message translates to:
  /// **'NOV'**
  String get novShort;

  /// No description provided for @decShort.
  ///
  /// In en, this message translates to:
  /// **'DEC'**
  String get decShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
