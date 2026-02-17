// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TrueLedger';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get budgets => 'Budgets';

  @override
  String get investments => 'Investments';

  @override
  String get loans => 'Loans';

  @override
  String get fixed => 'Fixed';

  @override
  String get variable => 'Variable';

  @override
  String get subscription => 'Subscription';

  @override
  String get investment => 'Investment';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get monthlyHistory => 'Monthly History';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'DELETE';

  @override
  String get edit => 'Edit';

  @override
  String billsDueToday(int count) {
    return '$count BILL DUE TODAY';
  }

  @override
  String billsDueTodayPlural(int count) {
    return '$count BILLS DUE TODAY';
  }

  @override
  String get todayLedger => 'Today\'s Ledger';

  @override
  String get paymentCalendar => 'Payment Calendar';

  @override
  String get monthView => 'Month view';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get biometrics => 'Biometric Authentication';

  @override
  String get enableBiometrics => 'Use fingerprint or face ID to unlock';

  @override
  String get analysis => 'Analysis';

  @override
  String get monthlyTrend => 'Monthly Trend';

  @override
  String get spendingAndIncome => 'Spending & Income';

  @override
  String get distribution => 'Distribution';

  @override
  String get byCategory => 'By Category';

  @override
  String get momentum => 'Momentum';

  @override
  String get velocityIncreased => 'Velocity increased by ';

  @override
  String get spendingDecreased => 'Excellent. Spending decreased by ';

  @override
  String get relativeToLastPeriod => ' relative to last period.';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get netPortfolioValue => 'NET PORTFOLIO VALUE';

  @override
  String get allocation => 'Allocation';

  @override
  String get assetClasses => 'Asset Classes';

  @override
  String get myAssets => 'My Assets';

  @override
  String get fullList => 'Full List';

  @override
  String get noAssetsTracked => 'NO ASSETS TRACKED';

  @override
  String get addFirstInvestment => 'Add your first investment to see analysis.';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get dailyStreak => 'Daily Streak';

  @override
  String streakMessage(int count) {
    return 'You\'re on a roll! You\'ve logged transactions for $count consecutive days.\n\nKeep tracking your expenses daily to build a healthy financial habit!';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get currentBalance => 'CURRENT BALANCE';

  @override
  String get personalization => 'Personalization';

  @override
  String get personalizationDesc => 'Experience adapts to your patterns';

  @override
  String get privateAndLocal => 'PRIVATE & LOCAL';

  @override
  String get privateAndLocalDesc =>
      'All personalization data is stored only on your device. We never sync or upload your behavior patterns or sensitive financial identifiers.';

  @override
  String get dynamicAdaptation => 'DYNAMIC ADAPTATION';

  @override
  String get dynamicAdaptationDesc =>
      'Allow experience to adapt to your patterns.';

  @override
  String get adaptiveBehavior => 'ADAPTIVE BEHAVIOR';

  @override
  String get rememberLastUsed => 'REMEMBER LAST-USED';

  @override
  String get rememberLastUsedDesc =>
      'Pre-fill category and payment method based on your last entry.';

  @override
  String get timeOfDaySuggestions => 'TIME-OF-DAY SUGGESTIONS';

  @override
  String get timeOfDaySuggestionsDesc =>
      'Suggest categories based on the time and your repetitions.';

  @override
  String get shortcutSuggestions => 'SHORTCUT SUGGESTIONS';

  @override
  String get shortcutSuggestionsDesc =>
      'Prompt to create quick-add shortcuts for frequent transactions.';

  @override
  String get baselineReflections => 'BASELINE REFLECTIONS';

  @override
  String get baselineReflectionsDesc =>
      'Show comparisons locally (e.g. \'Higher than your usual Friday\').';

  @override
  String get salaryCycle => 'SALARY CYCLE';

  @override
  String get usualPayDay => 'USUAL PAY DAY';

  @override
  String dayNum(int day) {
    return 'Day $day';
  }

  @override
  String get notSet => 'NOT SET';

  @override
  String get quickPresets => 'QUICK PRESETS';

  @override
  String get noPresetsYet => 'NO PRESETS CREATED YET.';

  @override
  String get createNewPreset => 'CREATE NEW PRESET';

  @override
  String get reminders => 'REMINDERS';

  @override
  String get reminderTime => 'REMINDER TIME';

  @override
  String get off => 'OFF';

  @override
  String get reminderTimeCleared => 'REMINDER TIME CLEARED';

  @override
  String get trustAndControl => 'TRUST & CONTROL';

  @override
  String get resetPersonalization => 'RESET PERSONALIZATION?';

  @override
  String get resetPersonalizationDesc =>
      'This will wipe all local learned behaviors. Your expense history will remain safe.';

  @override
  String get reset => 'RESET';

  @override
  String get personalizationResetCompleted => 'PERSONALIZATION RESET COMPLETED';

  @override
  String get selectPayDay => 'SELECT PAY DAY';

  @override
  String get createPreset => 'CREATE PRESET';

  @override
  String get presetLabel => 'LABEL (e.g. Coffee)';

  @override
  String get amount => 'AMOUNT';

  @override
  String get category => 'CATEGORY';

  @override
  String get deletePreset => 'Delete Preset';

  @override
  String get all => 'All';

  @override
  String get searchLedger => 'SEARCH LEDGER...';

  @override
  String typeTotal(String type) {
    return '$type TOTAL';
  }

  @override
  String get noEntriesYet => 'NO ENTRIES YET';

  @override
  String get noTransactionsFoundPeriod =>
      'NO TRANSACTIONS FOUND FOR THIS PERIOD.';

  @override
  String get weeklySummary => 'WEEKLY SUMMARY';

  @override
  String get greatWorkWeek => 'Great work this week.';

  @override
  String get reviewYourWeek => 'Review your week.';

  @override
  String underBudgetDays(int count) {
    return 'You stayed under budget $count days.';
  }

  @override
  String get perfectWeek => 'Perfect week! You stayed under budget every day.';

  @override
  String get heavyWeek => 'It was a heavy week. Try to track closer next week.';

  @override
  String get spendingConsistency => 'Spending Consistency';

  @override
  String dailyBenchmark(String amount) {
    return 'Daily Benchmark: ~$amount';
  }

  @override
  String get spendingSpike => 'Spending Spike';

  @override
  String spikeMessage(String category, String amount) {
    return '$category increased by $amount vs last week.';
  }

  @override
  String get newCategoryExpenditure =>
      'This is a new expenditure category for you.';

  @override
  String get eyeOnCategoryTrend => 'Keep an eye on this category trend.';

  @override
  String get stableSpending => 'Stable Spending';

  @override
  String get noSpikesDetected =>
      'Zero significant spending spikes detected compared to last week.';

  @override
  String get spendingStabilizing =>
      'Your spending habits are stabilizing well.';

  @override
  String get volumeComparison => 'Volume Comparison';

  @override
  String reducedSpendingSuccess(String amount) {
    return 'Success! You reduced spending by $amount.';
  }

  @override
  String increasedSpendingMessage(String amount) {
    return 'Spending increased by $amount vs last week.';
  }

  @override
  String lastWeekVsThisWeek(String last, String current) {
    return 'Last Week: $last | This Week: $current';
  }

  @override
  String get primaryCategory => 'Primary Category';

  @override
  String largestExpenditureArea(String category) {
    return '$category was your largest expenditure area.';
  }

  @override
  String get alignWithPriorities =>
      'Evaluate if this aligns with your current priorities.';

  @override
  String get weeklyFocus => 'WEEKLY FOCUS';

  @override
  String get gentleGoal => 'Gentle Goal';

  @override
  String reductionTarget(String category) {
    return 'Target a 10% reduction in $category spending.';
  }

  @override
  String get stayUnderBudgetGoal =>
      'Attempt to stay under budget for 5 days next week.';

  @override
  String get sustainableProgress =>
      'Sustainable progress comes from consistent, small adjustments.';

  @override
  String get reflectionFinancialIntuition =>
      'Reflection builds financial intuition.';

  @override
  String get newEntry => 'NEW LEDGER ENTRY';

  @override
  String newTypeEntry(String type) {
    return 'NEW $type';
  }

  @override
  String get entryTypeLabel => 'ENTRY TYPE';

  @override
  String get transactionAmountLabel => 'TRANSACTION AMOUNT';

  @override
  String get budgetImpact => 'BUDGET IMPACT';

  @override
  String exceedsBudgetBy(String amount) {
    return 'EXCEEDS BUDGET BY $amount';
  }

  @override
  String remainingLabel(String amount) {
    return 'REMAINING: $amount';
  }

  @override
  String get today => 'TODAY';

  @override
  String get categoryClassification => 'CATEGORY CLASSIFICATION';

  @override
  String get manageCategories => 'MANAGE CATEGORIES';

  @override
  String get auditNotes => 'AUDIT NOTES';

  @override
  String get optionalDetailsHint => 'Optional details...';

  @override
  String get commitToLedger => 'COMMIT TO LEDGER';

  @override
  String get enterAmountError => 'Please enter an amount';

  @override
  String get validPositiveAmountError => 'Please enter a valid positive amount';

  @override
  String budgetExceededTitle(String category) {
    return 'Budget Exceeded: $category';
  }

  @override
  String budgetWarningTitle(String category) {
    return 'Budget Warning: $category';
  }

  @override
  String budgetExceededBody(String category) {
    return 'You have spent 100% of your $category budget.';
  }

  @override
  String budgetWarningBody(String category, int percentage) {
    return 'You have reached $percentage% of your $category budget.';
  }

  @override
  String editTypeEntry(String type) {
    return 'EDIT $type';
  }

  @override
  String get sourceLabel => 'SOURCE';

  @override
  String get labelLabel => 'LABEL';

  @override
  String get noteLabel => 'NOTE';

  @override
  String get updateEntry => 'UPDATE ENTRY';

  @override
  String get amountLabel => 'AMOUNT';

  @override
  String get entryUpdated => 'Entry updated';

  @override
  String get deleteItemTitle => 'DELETE ITEM?';

  @override
  String get deleteItemContent => 'This action cannot be undone.';

  @override
  String get keep => 'KEEP';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get noResultsMatched => 'NO RESULTS MATCHED';

  @override
  String get categoriesTitle => 'CATEGORIES';

  @override
  String useCategoryTooltip(String category) {
    return 'Use $category';
  }

  @override
  String get addNewCategoryHint => 'Add new category...';

  @override
  String get noCategoriesYet => 'NO CATEGORIES YET';

  @override
  String addFirstCategory(String type) {
    return 'Add your first category for $type';
  }

  @override
  String categoryAddedTo(String category, String type) {
    return '$category ADDED TO $type';
  }

  @override
  String categoryDeleted(String category) {
    return '$category DELETED';
  }

  @override
  String get assets => 'Assets';

  @override
  String get liabilities => 'Liabilities';

  @override
  String get scenarioModeTitle => 'Scenario Mode';

  @override
  String get startLoggingToUseScenario => 'Start logging to use Scenario Mode';

  @override
  String get simulation => 'SIMULATION';

  @override
  String get whatIfSavedMore => 'What if you\nsaved more?';

  @override
  String get selectCategory => 'SELECT CATEGORY';

  @override
  String get reductionPercent => 'REDUCTION PERCENT';

  @override
  String get projectedYearlySavings => 'PROJECTED YEARLY SAVINGS';

  @override
  String scenarioImpactMessage(String category, int percent, String amount) {
    return 'Cutting your $category bills by $percent% frees up $amount every single month.';
  }

  @override
  String get wealthImpact => 'WEALTH IMPACT';

  @override
  String get oneYearProgress => '1 Year Progress';

  @override
  String get fiveYearMilestones => '5 Year Milestones';

  @override
  String get totalDue => 'TOTAL DUE';

  @override
  String get paid => 'PAID';

  @override
  String get netWorthTrackingTitle => 'NET WORTH TRACKING';

  @override
  String get trend => 'TREND';

  @override
  String get twelveMonthOverview => '12-MONTH OVERVIEW';

  @override
  String get assetAllocation => 'ASSET ALLOCATION';

  @override
  String get investmentPortfolio => 'Investment Portfolio';

  @override
  String get insight => 'INSIGHT';

  @override
  String simulationFailed(String error) {
    return 'Simulation failed: $error';
  }

  @override
  String get accounts => 'Accounts';

  @override
  String get cards => 'Cards';

  @override
  String get more => 'More';

  @override
  String get savingGoals => 'Saving Goals';

  @override
  String get trackYourMilestones => 'Track your milestones';

  @override
  String get viewPastPerformance => 'View past performance';

  @override
  String get automation => 'Automation';

  @override
  String get recurringTransactions => 'Recurring transactions';

  @override
  String get manageSpendingLimits => 'Manage spending limits';

  @override
  String get setUserName => 'SET USER NAME';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get nameLabel => 'NAME';

  @override
  String get selectCurrency => 'SELECT CURRENCY';

  @override
  String get searchCurrency => 'Search currency...';

  @override
  String get selectDataScenario => 'SELECT DATA SCENARIO';

  @override
  String get fictionalDataDemoOnly => 'Fictional data for demonstration only.';

  @override
  String get completeDemo => 'COMPLETE DEMO';

  @override
  String get allFeaturesStreaks => 'All features, including Streaks';

  @override
  String generatedScenarioData(String scenario) {
    return 'GENERATED $scenario DATA SCENARIO';
  }

  @override
  String get deleteAllData => 'DELETE ALL DATA?';

  @override
  String get wipeAllDataWarning =>
      'This action cannot be undone. All entries, budgets, and cards will be wiped.';

  @override
  String get deleteAll => 'DELETE ALL';

  @override
  String get recordPayment => 'RECORD PAYMENT';

  @override
  String get dueBalance => 'DUE BALANCE';

  @override
  String get amountToRecord => 'AMOUNT TO RECORD';

  @override
  String get fullBalance => 'FULL BALANCE';

  @override
  String minDueAmount(String amount) {
    return 'MIN: $amount';
  }

  @override
  String get noCardsRegistered => 'NO CARDS REGISTERED';

  @override
  String limitLabel(String amount) {
    return 'LIMIT: $amount';
  }

  @override
  String get dueLabel => 'DUE';

  @override
  String percentUtilized(String percent) {
    return '$percent% UTILIZED';
  }

  @override
  String availableAmount(String amount) {
    return 'AVAILABLE: $amount';
  }

  @override
  String get totalCardsDebt => 'TOTAL CARDS DEBT';

  @override
  String get initializing => 'Initializing...';

  @override
  String get initializationFailed => 'Initialization Failed';

  @override
  String get week => 'WEEK';

  @override
  String get stable => 'Stable';

  @override
  String remainingAmountLeft(String amount) {
    return '$amount left';
  }

  @override
  String get yourGoals => 'YOUR GOALS';

  @override
  String get totalProgress => 'TOTAL PROGRESS';

  @override
  String get savedLabel => 'SAVED';

  @override
  String get targetLabel => 'TARGET';

  @override
  String get noGoalsYet => 'NO GOALS YET';

  @override
  String get setFirstGoal =>
      'Set your first saving goal and start building your future!';

  @override
  String get goalAchieved => 'GOAL ACHIEVED! 🎉';

  @override
  String toGoLabel(String amount) {
    return '$amount TO GO';
  }

  @override
  String get archiveLabel => 'ARCHIVE';

  @override
  String reflectionLabel(int year) {
    return '$year Reflection';
  }

  @override
  String get goalTracking => 'GOAL TRACKING';

  @override
  String get retirementHealth => 'Retirement Health';

  @override
  String get noDataAvailable => 'NO DATA AVAILABLE';

  @override
  String get retry => 'RETRY';

  @override
  String get selectTheme => 'SELECT THEME';

  @override
  String get systemDefault => 'System Default';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get quickAdd => 'QUICK ADD';

  @override
  String get change => 'CHANGE';

  @override
  String get whatWasThisFor => 'What was this for?';

  @override
  String get saveExpense => 'SAVE EXPENSE';

  @override
  String get presetsLabel => 'PRESETS';

  @override
  String get paymentMethodLabel => 'PAYMENT METHOD';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get netBanking => 'Net Banking';

  @override
  String get genericCard => 'Generic Card';

  @override
  String get saveAsShortcut => 'Save as shortcut?';

  @override
  String get suggestedLabel => 'Suggested';

  @override
  String get basedOnLastEntry => 'Based on your last entry';

  @override
  String get basedOnDailyRoutine => 'Based on your daily routine';

  @override
  String get dailyPattern => 'Daily Pattern';

  @override
  String get basedOnLastRecord => 'Based on last record';

  @override
  String get notNow => 'NOT NOW';

  @override
  String get shortcutSaved => 'Shortcut saved!';

  @override
  String youLogOften(String title) {
    return 'You log \'$title\' often.';
  }

  @override
  String recordedBalanceUpdated(String method) {
    return 'Recorded! $method balance updated.';
  }

  @override
  String get validAmountError => 'Please enter a valid amount';

  @override
  String get transparencyCheck => 'Transparency Check';

  @override
  String get prefilledNotice =>
      'We pre-filled some values locally to save you typing effort.';

  @override
  String get localDataNotice => 'This data never leaves your device.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get dateLabel => 'DATE';

  @override
  String get yesterdayLabel => 'YESTERDAY';

  @override
  String get otherLabel => 'OTHER';

  @override
  String get intelligentInsights => 'INTELLIGENT INSIGHTS';

  @override
  String get aiPoweredAnalysis => 'AI Powered Analysis';

  @override
  String get scenarioModeLabel => 'SCENARIO MODE';

  @override
  String get simulateFuture => 'Simulate your financial future.';

  @override
  String get mindset => 'MINDSET';

  @override
  String get basedOnLocalHistory => 'Based on local history.';

  @override
  String get excellentLabel => 'EXCELLENT';

  @override
  String get goodLabel => 'GOOD';

  @override
  String get averageLabel => 'AVERAGE';

  @override
  String get calibrating => 'CALIBRATING...';

  @override
  String get atRisk => 'AT RISK';

  @override
  String get healthScore => 'Health Score';

  @override
  String get snooze7Days => 'Snooze 7 days';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get markPaid => 'MARK PAID';

  @override
  String markedAsPaid(String name) {
    return '$name marked as paid';
  }

  @override
  String markPaidFailed(String error) {
    return 'Failed to mark as paid: $error';
  }

  @override
  String get retirement => 'RETIREMENT';

  @override
  String get myAccounts => 'MY ACCOUNTS';

  @override
  String get breakdown => 'BREAKDOWN';

  @override
  String get futureWealth => 'FUTURE WEALTH';

  @override
  String get projection => 'PROJECTION';

  @override
  String get yearsLabel => 'YEARS';

  @override
  String get retirementReady => 'RETIREMENT READY';

  @override
  String get totalRetirementCorpus => 'TOTAL RETIREMENT CORPUS';

  @override
  String latency(String time) {
    return 'LATENCY: $time';
  }

  @override
  String estimatedCorpus(String amount) {
    return 'Estimated corpus at retirement: $amount';
  }

  @override
  String get projectionSettings => 'PROJECTION SETTINGS';

  @override
  String get currentAgeLabel => 'Current Age';

  @override
  String get retirementAgeLabel => 'Retirement Age';

  @override
  String get expectedReturn => 'Expected Return Rate';

  @override
  String get percentPa => '% p.a.';

  @override
  String get updateTargets => 'UPDATE TARGETS';

  @override
  String get wealthAdvisory => 'WEALTH ADVISORY';

  @override
  String get optimalTrajectory =>
      'Your trajectory is optimal. Maintain current velocity to ensure capital preservation against inflation.';

  @override
  String get velocityAdjustment =>
      'Velocity adjustment recommended. Increasing monthly contributions by 10% will accelerate your goal timeline.';

  @override
  String get borrowingsAndLoans => 'BORROWINGS & LOANS';

  @override
  String get noActiveBorrowings => 'NO ACTIVE BORROWINGS.';

  @override
  String get remaining => 'REMAINING';

  @override
  String get repaid => 'REPAID';

  @override
  String percentRepaid(String percent) {
    return '$percent% REPAID';
  }

  @override
  String ofAmount(String amount) {
    return 'OF $amount';
  }

  @override
  String get totalBorrowings => 'TOTAL BORROWINGS';

  @override
  String get strategy => 'STRATEGY';

  @override
  String get debtPayoffPlanner => 'Debt Payoff Planner';

  @override
  String get flexible => 'FLEXIBLE';

  @override
  String get recurring => 'RECURRING';

  @override
  String get dueTodayLabel => 'DUE TODAY';

  @override
  String get dueTomorrowLabel => 'DUE TOMORROW';

  @override
  String get record => 'RECORD';

  @override
  String get age => 'AGE';

  @override
  String get emi => 'EMI';

  @override
  String get due => 'DUE';

  @override
  String get newBorrowing => 'NEW BORROWING';

  @override
  String get loanClassification => 'LOAN CLASSIFICATION';

  @override
  String get creditorLoanName => 'CREDITOR / LOAN NAME';

  @override
  String get remainingBalance => 'REMAINING BALANCE';

  @override
  String get totalLoan => 'TOTAL LOAN';

  @override
  String get monthlyEmi => 'MONTHLY EMI';

  @override
  String get interestRate => 'INTEREST RATE';

  @override
  String get expectedRepaymentDate => 'EXPECTED REPAYMENT DATE';

  @override
  String get dueDateDayOfMonth => 'DUE DATE (DAY OF MONTH)';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDay => 'Select Day';

  @override
  String get commitBorrowing => 'COMMIT BORROWING';

  @override
  String get pleaseFillRequiredFields => 'Please fill required fields';

  @override
  String get remainingCannotExceedTotal =>
      'Remaining balance cannot exceed total loan';

  @override
  String get updateLoan => 'UPDATE LOAN';

  @override
  String get recordEmiPayment => 'RECORD EMI PAYMENT';

  @override
  String get recordPrepayment => 'RECORD PREPAYMENT';

  @override
  String get updateBorrowing => 'UPDATE BORROWING';

  @override
  String get paymentHistory => 'PAYMENT HISTORY';

  @override
  String get noRecordedPaymentHistory => 'No recorded payment history found.';

  @override
  String get markAsEmi => 'MARK AS EMI';

  @override
  String get notAPayment => 'NOT A PAYMENT';

  @override
  String showAllWithCount(int count) {
    return 'SHOW ALL ($count PAYMENTS)';
  }

  @override
  String get payoffQuote => 'PAYOFF QUOTE';

  @override
  String get estimate => 'ESTIMATE';

  @override
  String get validUntilToday => 'Valid until today';

  @override
  String get reconcileWithBank => 'RECONCILE WITH BANK';

  @override
  String get payoffBreakdown => 'PAYOFF BREAKDOWN';

  @override
  String get principalOutstanding => 'Principal Outstanding';

  @override
  String get interestAccrued => 'Interest Accrued';

  @override
  String get totalQuote => 'Total Quote';

  @override
  String get trustCenter => 'TRUST CENTER';

  @override
  String get ourGuarantees => 'OUR GUARANTEES';

  @override
  String get strictPolicies => 'STRICT POLICIES';

  @override
  String get dataHealth => 'DATA HEALTH';

  @override
  String get backupConfidence => 'BACKUP CONFIDENCE';

  @override
  String get localBackups => 'LOCAL BACKUPS';

  @override
  String get viewFolder => 'VIEW FOLDER';

  @override
  String get totalRecords => 'TOTAL RECORDS';

  @override
  String get localBackupStatus => 'LOCAL BACKUP STATUS';

  @override
  String lastBackupLabel(String time) {
    return 'Last backup: $time';
  }

  @override
  String get nextAutoBackup =>
      'Next automatic backup: At next application launch';

  @override
  String get noLocalBackupsFound => 'NO LOCAL BACKUPS FOUND YET.';

  @override
  String get sqlCipherEncryption =>
      'TrueLedger uses SQLCipher AES-256 for database encryption on supported platforms.';

  @override
  String get productLevelPrivacy => 'PRODUCT-LEVEL PRIVACY GUARANTEES.';

  @override
  String get privacyPrinciple =>
      'TrueLedger is built on the principle that your financial life is yours alone. We believe in absolute privacy, which is why your data never leaves your device.';

  @override
  String get noAds => 'NO ADS';

  @override
  String get noAdsDesc =>
      'We never clutter your experience with advertisements or sponsored content.';

  @override
  String get noTracking => 'NO TRACKING';

  @override
  String get noTrackingDesc =>
      'We don\'t track your behavior, location, or usage. You are not a data point.';

  @override
  String get noProfiling => 'NO PROFILING';

  @override
  String get noProfilingDesc =>
      'Your financial habits are private. We don\'t build profiles for targeting.';

  @override
  String get localOnly => '100% LOCAL';

  @override
  String get localOnlyDesc =>
      'Your database exists only on your device. We have no access to your logs.';

  @override
  String get noAnalyticsSdk => 'No analytics or tracking SDKs';

  @override
  String get noBehaviorProfiling => 'No behavior profiling or scoring';

  @override
  String get noBankScraping => 'No bank or SMS scraping';

  @override
  String get noCloudSync => 'No cloud sync or external storage';

  @override
  String get noSellingLogs => 'No selling or sharing of user logs';

  @override
  String get restoreDataTitle => 'RESTORE DATA?';

  @override
  String get restoreDataWarning =>
      'This will REPLACE all your current data with the data from this backup. This action cannot be undone.';

  @override
  String get restoreNow => 'RESTORE NOW';

  @override
  String get restoreCompleted => 'RESTORE COMPLETED SUCCESSFULLY';

  @override
  String restoreFailed(String error) {
    return 'RESTORE FAILED: $error';
  }

  @override
  String runwayMonths(int months) {
    return 'Your savings will last approx. $months months';
  }

  @override
  String get sustainableRunway => 'Your financial path is sustainable';

  @override
  String get calculatingRunway => 'Calculating runway...';

  @override
  String failedToLoadLoans(String error) {
    return 'Failed to load loans: $error';
  }

  @override
  String get loanNameHint => 'e.g. HDFC Gold Loan';

  @override
  String get engineReducingBalance => 'Engine: Reducing balance (daily)';

  @override
  String get bankType => 'Bank';

  @override
  String get individualType => 'Individual';

  @override
  String get goldType => 'Gold';

  @override
  String get carType => 'Car';

  @override
  String get homeType => 'Home';

  @override
  String get educationType => 'Education';

  @override
  String get settings => 'Settings';

  @override
  String get selectDueDay => 'Select Due Day';
}
