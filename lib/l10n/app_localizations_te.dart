// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'ట్రూలెడ్జర్';

  @override
  String get dashboard => 'డ్యాష్‌బోర్డ్';

  @override
  String get netWorth => 'నికర విలువ';

  @override
  String get income => 'ఆదాయం';

  @override
  String get expenses => 'ఖర్చులు';

  @override
  String get budgets => 'బడ్జెట్లు';

  @override
  String get investments => 'పెట్టుబడులు';

  @override
  String get loans => 'రుణాలు';

  @override
  String get fixed => 'స్థిరమైన';

  @override
  String get variable => 'మారేవి';

  @override
  String get subscription => 'సబ్‌స్క్రిప్షన్';

  @override
  String get investment => 'పెట్టుబడి';

  @override
  String get totalBalance => 'మొత్తం బ్యాలెన్స్';

  @override
  String get monthlySummary => 'నెలవారీ సారాంశం';

  @override
  String get monthlyHistory => 'నెలవారీ చరిత్ర';

  @override
  String get addTransaction => 'లావాదేవీని జోడించండి';

  @override
  String get recentTransactions => 'ఇటీవలి లావాదేవీలు';

  @override
  String get noTransactions => 'లావాదేవీలు ఏవీ కనుగొనబడలేదు';

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get delete => 'తొలగించు';

  @override
  String get edit => 'సవరించు';

  @override
  String billsDueToday(int count) {
    return '$count బిల్లు నేడు చెల్లించాలి';
  }

  @override
  String billsDueTodayPlural(int count) {
    return '$count బిల్లులు నేడు చెల్లించాలి';
  }

  @override
  String get todayLedger => 'నేటి లెడ్జర్';

  @override
  String get paymentCalendar => 'పేమెంట్ క్యాలెండర్';

  @override
  String get monthView => 'నెలవారీ వీక్షణ';

  @override
  String get language => 'భాష';

  @override
  String get chooseLanguage => 'మీకు నచ్చిన భాషను ఎంచుకోండి';

  @override
  String get biometrics => 'బయోమెట్రిక్ ప్రమాణీకరణ';

  @override
  String get enableBiometrics =>
      'అన్‌లాక్ చేయడానికి వేలిముద్ర లేదా ఫేస్ ఐడిని ఉపయోగించండి';

  @override
  String get analysis => 'విశ్లేషణ';

  @override
  String get monthlyTrend => 'నెలవారీ ధోరణి';

  @override
  String get spendingAndIncome => 'ఖర్చులు & ఆదాయం';

  @override
  String get distribution => 'పంపిణీ';

  @override
  String get byCategory => 'వర్గం వారీగా';

  @override
  String get momentum => 'మొమెంటం';

  @override
  String get velocityIncreased => 'వేగం పెరిగింది: ';

  @override
  String get spendingDecreased => 'అద్భుతం. ఖర్చు తగ్గింది: ';

  @override
  String get relativeToLastPeriod => ' గత కాలంతో పోలిస్తే.';

  @override
  String get portfolio => 'పోర్ట్‌ఫోలియో';

  @override
  String get netPortfolioValue => 'నికర పోర్ట్‌ఫోలియో విలువ';

  @override
  String get allocation => 'కేటాయింపు';

  @override
  String get assetClasses => 'ఆస్తి తరగతులు';

  @override
  String get myAssets => 'నా ఆస్తులు';

  @override
  String get fullList => 'పూర్తి జాబితా';

  @override
  String get noAssetsTracked => 'ఆస్తులు ఏవీ ట్రాక్ చేయబడలేదు';

  @override
  String get addFirstInvestment =>
      'విశ్లేషణ చూడటానికి మీ మొదటి పెట్టుబడిని జోడించండి.';

  @override
  String get goodMorning => 'శుభోదయం';

  @override
  String get goodAfternoon => 'శుభ మధ్యాహ్నం';

  @override
  String get goodEvening => 'శుభ సాయంత్రం';

  @override
  String get dailyStreak => 'రోజువారీ స్ట్రీక్';

  @override
  String streakMessage(int count) {
    return 'మీరు అద్భుతంగా పని చేస్తున్నారు! మీరు వరుసగా $count రోజులుగా లావాదేవీలను నమోదు చేశారు.\n\nఆరోగ్యకరమైన ఆర్థిక అలవాటును నిర్మించడానికి ప్రతిరోజూ మీ ఖర్చులను ట్రాక్ చేస్తూ ఉండండి!';
  }

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get currentBalance => 'ప్రస్తుత బ్యాలెన్స్';

  @override
  String get personalization => 'వ్యక్తిగతీకరణ';

  @override
  String get personalizationDesc => 'అనుభవం మీ నమూనాలకు అనుగుణంగా మారుతుంది';

  @override
  String get privateAndLocal => 'ప్రైవేట్ & లోకల్';

  @override
  String get privateAndLocalDesc =>
      'అన్ని వ్యక్తిగతీకరణ డేటా మీ పరికరంలో మాత్రమే నిల్వ చేయబడుతుంది. మేము మీ ప్రవర్తన నమూనాలు లేదా సున్నితమైన ఆర్థిక గుర్తింపులను ఎప్పుడూ సర్వర్‌కు పంపము.';

  @override
  String get dynamicAdaptation => 'డైనమిక్ అడాప్టేషన్';

  @override
  String get dynamicAdaptationDesc =>
      'అనుభవం మీ నమూనాలకు అనుగుణంగా మారడానికి అనుమతించండి.';

  @override
  String get adaptiveBehavior => 'అడాప్టివ్ బిహేవియర్';

  @override
  String get rememberLastUsed => 'చివరిగా ఉపయోగించినవి గుర్తుంచుకో';

  @override
  String get rememberLastUsedDesc =>
      'మీ చివరి ఎంట్రీ ఆధారంగా వర్గం మరియు చెల్లింపు విధానాన్ని ముందే పూరించండి.';

  @override
  String get timeOfDaySuggestions => 'సమయం ఆధారిత సూచనలు';

  @override
  String get timeOfDaySuggestionsDesc =>
      'సమయం మరియు మీ పునరావృతాల ఆధారంగా వర్గాలను సూచించండి.';

  @override
  String get shortcutSuggestions => 'షార్ట్‌కట్ సూచనలు';

  @override
  String get shortcutSuggestionsDesc =>
      'తరచుగా చేసే లావాదేవీల కోసం త్వరిత-జోడింపు షార్ట్‌కట్‌లను రూపొందించమని అడగండి.';

  @override
  String get baselineReflections => 'బేస్‌లైన్ ప్రతిబింబాలు';

  @override
  String get baselineReflectionsDesc =>
      'పోలికలను స్థానికంగా చూపండి (ఉదా. \'మీ సాధారణ శుక్రవారం కంటే ఎక్కువ\').';

  @override
  String get salaryCycle => 'జీతం చక్రం';

  @override
  String get usualPayDay => 'సాధారణ జీతం వచ్చే రోజు';

  @override
  String dayNum(int day) {
    return '$dayవ రోజు';
  }

  @override
  String get notSet => 'సెట్ చేయలేదు';

  @override
  String get quickPresets => 'త్వరిత ప్రీసెట్లు';

  @override
  String get noPresetsYet => 'ఇంకా ప్రీసెట్లు సృష్టించబడలేదు.';

  @override
  String get createNewPreset => 'కొత్త ప్రీసెట్‌ను సృష్టించండి';

  @override
  String get reminders => 'రిమైండర్లు';

  @override
  String get reminderTime => 'రిమైండర్ సమయం';

  @override
  String get off => 'ఆఫ్';

  @override
  String get reminderTimeCleared => 'రిమైండర్ సమయం క్లియర్ చేయబడింది';

  @override
  String get trustAndControl => 'నమ్మకం & నియంత్రణ';

  @override
  String get resetPersonalization => 'వ్యక్తిగతీకరణను రీసెట్ చేయాలా?';

  @override
  String get resetPersonalizationDesc =>
      'ఇది అన్ని లోకల్ ప్రవర్తనలను తుడిచివేస్తుంది. మీ ఖర్చు చరిత్ర సురక్షితంగా ఉంటుంది.';

  @override
  String get reset => 'రీసెట్';

  @override
  String get personalizationResetCompleted => 'వ్యక్తిగతీకరణ రీసెట్ పూర్తయింది';

  @override
  String get selectPayDay => 'జీతం రోజును ఎంచుకోండి';

  @override
  String get createPreset => 'ప్రీసెట్‌ను సృష్టించండి';

  @override
  String get presetLabel => 'లేబుల్ (ఉదా. కాఫీ)';

  @override
  String get amount => 'మొత్తం';

  @override
  String get category => 'వర్గం';

  @override
  String get deletePreset => 'ప్రీసెట్‌ను తొలగించండి';

  @override
  String get all => 'అన్నీ';

  @override
  String get searchLedger => 'లెడ్జర్‌లో వెతకండి...';

  @override
  String typeTotal(String type) {
    return '$type మొత్తం';
  }

  @override
  String get noEntriesYet => 'ఇంకా ఎంట్రీలు ఏవీ లేవు';

  @override
  String get noTransactionsFoundPeriod =>
      'ఈ కాలానికి లావాదేవీలు ఏవీ కనుగొనబడలేదు.';

  @override
  String get weeklySummary => 'వారపు సారాంశం';

  @override
  String get greatWorkWeek => 'ఈ వారం మీరు అద్భుతంగా పనిచేశారు.';

  @override
  String get reviewYourWeek => 'మీ వారాన్ని సమీక్షించండి.';

  @override
  String underBudgetDays(int count) {
    return 'మీరు $count రోజులు బడ్జెట్ కంటే తక్కువ ఖర్చు చేశారు.';
  }

  @override
  String get perfectWeek =>
      'పర్ఫెక్ట్ వీక్! మీరు ప్రతిరోజూ బడ్జెట్ కంటే తక్కువగా ఉన్నారు.';

  @override
  String get heavyWeek =>
      'ఇది భారమైన వారం. వచ్చే వారం మరింత జాగ్రత్తగా ఉండటానికి ప్రయత్నించండి.';

  @override
  String get spendingConsistency => 'ఖర్చుల స్థిరత్వం';

  @override
  String dailyBenchmark(String amount) {
    return 'రోజువారీ బెంచ్‌మార్క్: ~$amount';
  }

  @override
  String get spendingSpike => 'ఖర్చులో పెరుగుదల';

  @override
  String spikeMessage(String category, String amount) {
    return 'గత వారంతో పోలిస్తే $category $amount పెరిగింది.';
  }

  @override
  String get newCategoryExpenditure => 'ఇది మీకు కొత్త ఖర్చు వర్గం.';

  @override
  String get eyeOnCategoryTrend => 'ఈ వర్గ ధోరణిపై దృష్టి పెట్టండి.';

  @override
  String get stableSpending => 'స్థిరమైన ఖర్చులు';

  @override
  String get noSpikesDetected =>
      'గత వారంతో పోలిస్తే గణనీయమైన ఖర్చు పెరుగుదలలు ఏవీ కనుగొనబడలేదు.';

  @override
  String get spendingStabilizing => 'మీ ఖర్చు అలవాట్లు బాగా స్థిరపడుతున్నాయి.';

  @override
  String get volumeComparison => 'పరిమాణ పోలిక';

  @override
  String reducedSpendingSuccess(String amount) {
    return 'విజయం! మీరు ఖర్చును $amount తగ్గించారు.';
  }

  @override
  String increasedSpendingMessage(String amount) {
    return 'గత వారంతో పోలిస్తే ఖర్చు $amount పెరిగింది.';
  }

  @override
  String lastWeekVsThisWeek(String last, String current) {
    return 'గత వారం: $last | ఈ వారం: $current';
  }

  @override
  String get primaryCategory => 'ప్రధాన వర్గం';

  @override
  String largestExpenditureArea(String category) {
    return '$category మీ అతిపెద్ద ఖర్చు ప్రాంతం.';
  }

  @override
  String get alignWithPriorities =>
      'ఇది మీ ప్రస్తుత ప్రాధాన్యతలతో సరిపోతుందో లేదో అంచనా వేయండి.';

  @override
  String get weeklyFocus => 'వారపు ఫోకస్';

  @override
  String get gentleGoal => 'సున్నితమైన లక్ష్యం';

  @override
  String reductionTarget(String category) {
    return '$category ఖర్చులో 10% తగ్గింపును లక్ష్యంగా పెట్టుకోండి.';
  }

  @override
  String get stayUnderBudgetGoal =>
      'వచ్చే వారం 5 రోజుల పాటు బడ్జెట్ కంటే తక్కువగా ఉండటానికి ప్రయత్నించండి.';

  @override
  String get sustainableProgress =>
      'స్థిరమైన పురోగతి చిన్న చిన్న సర్దుబాట్ల నుండి వస్తుంది.';

  @override
  String get reflectionFinancialIntuition =>
      'ప్రతిబింబం ఆర్థిక అంతర్దృష్టిని నిర్మిస్తుంది.';

  @override
  String get newEntry => 'కొత్త లెడ్జర్ ఎంట్రీ';

  @override
  String newTypeEntry(String type) {
    return 'కొత్త $type';
  }

  @override
  String get entryTypeLabel => 'ఎంట్రీ రకం';

  @override
  String get transactionAmountLabel => 'లావాదేవీ మొత్తం';

  @override
  String get budgetImpact => 'బడ్జెట్ ప్రభావం';

  @override
  String exceedsBudgetBy(String amount) {
    return 'బడ్జెట్ కంటే $amount ఎక్కువ';
  }

  @override
  String remainingLabel(String amount) {
    return 'మిగిలి ఉన్నది: $amount';
  }

  @override
  String get today => 'నేడు';

  @override
  String get categoryClassification => 'వర్గీకరణ';

  @override
  String get manageCategories => 'వర్గాలను నిర్వహించండి';

  @override
  String get auditNotes => 'ఆడిట్ గమనికలు';

  @override
  String get optionalDetailsHint => 'ఐచ్ఛిక వివరాలు...';

  @override
  String get commitToLedger => 'లెడ్జర్‌కు జోడించు';

  @override
  String get enterAmountError => 'దయచేసి మొత్తాన్ని నమోదు చేయండి';

  @override
  String get validPositiveAmountError =>
      'దయచేసి చెల్లుబాటు అయ్యే సానుకూల మొత్తాన్ని నమోదు చేయండి';

  @override
  String budgetExceededTitle(String category) {
    return 'బడ్జెట్ మించిపోయింది: $category';
  }

  @override
  String budgetWarningTitle(String category) {
    return 'బడ్జెట్ హెచ్చరిక: $category';
  }

  @override
  String budgetExceededBody(String category) {
    return 'మీరు మీ $category బడ్జెట్‌లో 100% ఉపయోగించారు.';
  }

  @override
  String budgetWarningBody(String category, int percentage) {
    return 'మీరు మీ $category బడ్జెట్‌లో $percentage% చేరుకున్నారు.';
  }

  @override
  String editTypeEntry(String type) {
    return '$type సవరించండి';
  }

  @override
  String get sourceLabel => 'మూలం';

  @override
  String get labelLabel => 'లేబుల్';

  @override
  String get noteLabel => 'గమనిక';

  @override
  String get updateEntry => 'ఎంట్రీని నవీకరించండి';

  @override
  String get amountLabel => 'మొత్తం';

  @override
  String get entryUpdated => 'ఎంట్రీ నవీకరించబడింది';

  @override
  String get deleteItemTitle => 'అంశాన్ని తొలగించాలా?';

  @override
  String get deleteItemContent => 'ఈ చర్యను రద్దు చేయలేము.';

  @override
  String get keep => 'ఉంచు';

  @override
  String get itemDeleted => 'అంశం తొలగించబడింది';

  @override
  String get undo => 'రద్దు చేయి';

  @override
  String get noResultsMatched => 'ఫలితాలు ఏవీ సరిపోలలేదు';

  @override
  String get categoriesTitle => 'వర్గాలు';

  @override
  String useCategoryTooltip(String category) {
    return '$category ఉపయోగించండి';
  }

  @override
  String get addNewCategoryHint => 'కొత్త వర్గాన్ని జోడించండి...';

  @override
  String get noCategoriesYet => 'ఇంకా వర్గాలు ఏవీ లేవు';

  @override
  String addFirstCategory(String type) {
    return '$type కోసం మీ మొదటి వర్గాన్ని జోడించండి';
  }

  @override
  String categoryAddedTo(String category, String type) {
    return '$category $typeకు జోడించబడింది';
  }

  @override
  String categoryDeleted(String category) {
    return '$category తొలగించబడింది';
  }

  @override
  String get assets => 'ఆస్తులు';

  @override
  String get liabilities => 'అప్పులు';

  @override
  String get scenarioModeTitle => 'సినారియో మోడ్';

  @override
  String get startLoggingToUseScenario =>
      'సినారియో మోడ్ ఉపయోగించడానికి లాగింగ్ ప్రారంభించండి';

  @override
  String get simulation => 'సిమ్యులేషన్';

  @override
  String get whatIfSavedMore => 'మీరు మరింత ఎక్కువ\nపొదుపు చేస్తే?';

  @override
  String get selectCategory => 'వర్గాన్ని ఎంచుకోండి';

  @override
  String get reductionPercent => 'తగ్గింపు శాతం';

  @override
  String get projectedYearlySavings => 'అంచనా వేయబడిన వార్షిక పొదుపు';

  @override
  String scenarioImpactMessage(String category, int percent, String amount) {
    return 'మీ $category బిల్లులను $percent% తగ్గించడం ద్వారా ప్రతి నెలా $amount ఆదా అవుతుంది.';
  }

  @override
  String get wealthImpact => 'సంపద ప్రభావం';

  @override
  String get oneYearProgress => '1 సంవత్సరం పురోగతి';

  @override
  String get fiveYearMilestones => '5 సంవత్సరాల మైలురాళ్ళు';

  @override
  String get totalDue => 'మొత్తం బకాయి';

  @override
  String get paid => 'చెల్లించినవి';

  @override
  String get netWorthTrackingTitle => 'నికర విలువ ట్రాకింగ్';

  @override
  String get trend => 'ధోరణి';

  @override
  String get twelveMonthOverview => '12-నెలల సారాంశం';

  @override
  String get assetAllocation => 'ఆస్తి కేటాయింపు';

  @override
  String get investmentPortfolio => 'పెట్టుబడి పోర్ట్‌ఫోలియో';

  @override
  String get insight => 'అంతర్దృష్టి';

  @override
  String simulationFailed(String error) {
    return 'సిమ్యులేషన్ విఫలమైంది: $error';
  }

  @override
  String get accounts => 'ఖాతాలు';

  @override
  String get cards => 'కార్డులు';

  @override
  String get more => 'మరిన్ని';

  @override
  String get savingGoals => 'పొదుపు లక్ష్యాలు';

  @override
  String get trackYourMilestones => 'మీ మైలురాళ్లను ట్రాక్ చేయండి';

  @override
  String get viewPastPerformance => 'గత పనితీరును వీక్షించండి';

  @override
  String get automation => 'ఆటోమేషన్';

  @override
  String get recurringTransactions => 'పునరావృత లావాదేవీలు';

  @override
  String get manageSpendingLimits => 'ఖర్చు పరిమితులను నిర్వహించండి';

  @override
  String get setUserName => 'వినియోగదారు పేరును సెట్ చేయండి';

  @override
  String get enterYourName => 'మీ పేరును నమోదు చేయండి';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get selectCurrency => 'కరెన్సీని ఎంచుకోండి';

  @override
  String get searchCurrency => 'కరెన్సీని వెతకండి...';

  @override
  String get selectDataScenario => 'డేటా దృశ్యాన్ని ఎంచుకోండి';

  @override
  String get fictionalDataDemoOnly => 'ప్రదర్శన కోసం మాత్రమే కల్పిత డేటా.';

  @override
  String get completeDemo => 'పూర్తి డెమో';

  @override
  String get allFeaturesStreaks => 'స్ట్రీక్స్‌తో సహా అన్ని ఫీచర్లు';

  @override
  String generatedScenarioData(String scenario) {
    return '$scenario డేటా దృశ్యం రూపొందించబడింది';
  }

  @override
  String get deleteAllData => 'మొత్తం డేటాను తొలగించాలా?';

  @override
  String get wipeAllDataWarning =>
      'ఈ చర్యను రద్దు చేయలేము. అన్ని ఎంట్రీలు, బడ్జెట్లు మరియు కార్డులు తుడిచివేయబడతాయి.';

  @override
  String get deleteAll => 'మొత్తం తొలగించండి';

  @override
  String get recordPayment => 'చెల్లింపును రికార్డ్ చేయండి';

  @override
  String get dueBalance => 'బకాయి మొత్తం';

  @override
  String get amountToRecord => 'రికార్డ్ చేయాల్సిన మొత్తం';

  @override
  String get fullBalance => 'పూర్తి నిల్వ';

  @override
  String minDueAmount(String amount) {
    return 'కనిష్ట: $amount';
  }

  @override
  String get noCardsRegistered => 'కార్డులు ఏవీ నమోదు కాలేదు';

  @override
  String limitLabel(String amount) {
    return 'పరిమితి: $amount';
  }

  @override
  String get dueLabel => 'బకాయి';

  @override
  String percentUtilized(String percent) {
    return '$percent% ఉపయోగించబడింది';
  }

  @override
  String availableAmount(String amount) {
    return 'అందుబాటులో ఉంది: $amount';
  }

  @override
  String get totalCardsDebt => 'మొత్తం కార్డ్ అప్పు';

  @override
  String get initializing => 'ప్రారంభిస్తోంది...';

  @override
  String get initializationFailed => 'ప్రారంభం విఫలమైంది';

  @override
  String get week => 'వారం';

  @override
  String get stable => 'స్థిరంగా ఉంది';

  @override
  String remainingAmountLeft(String amount) {
    return '$amount మిగిలి ఉంది';
  }

  @override
  String get yourGoals => 'మీ లక్ష్యాలు';

  @override
  String get totalProgress => 'మొత్తం పురోగతి';

  @override
  String get savedLabel => 'పొదుపు చేసినవి';

  @override
  String get targetLabel => 'లక్ష్యం';

  @override
  String get noGoalsYet => 'ఇంకా లక్ష్యాలు లేవు';

  @override
  String get setFirstGoal =>
      'మీ మొదటి పొదుపు లక్ష్యాన్ని నిర్దేశించుకోండి మరియు మీ భవిష్యత్తును నిర్మించుకోవడం ప్రారంభించండి!';

  @override
  String get goalAchieved => 'లక్ష్యం నెరవేరింది! 🎉';

  @override
  String toGoLabel(String amount) {
    return '$amount మిగిలి ఉంది';
  }

  @override
  String get archiveLabel => 'ఆర్కైవ్';

  @override
  String reflectionLabel(int year) {
    return '$year ప్రతిబింబం';
  }

  @override
  String get goalTracking => 'లక్ష్యాల ట్రాకింగ్';

  @override
  String get retirementHealth => 'పదవీ విరమణ ఆరోగ్యం';

  @override
  String get noDataAvailable => 'డేటా అందుబాటులో లేదు';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించు';

  @override
  String get selectTheme => 'థీమ్‌ను ఎంచుకోండి';

  @override
  String get systemDefault => 'సిస్టమ్ డిఫాల్ట్';

  @override
  String get lightMode => 'లైట్ మోడ్';

  @override
  String get darkMode => 'డార్క్ మోడ్';

  @override
  String get quickAdd => 'త్వరిత జోడింపు';

  @override
  String get change => 'మార్చు';

  @override
  String get whatWasThisFor => 'ఇది దేనికోసం?';

  @override
  String get saveExpense => 'ఖర్చును సేవ్ చేయి';

  @override
  String get presetsLabel => 'ప్రీసెట్లు';

  @override
  String get paymentMethodLabel => 'చెల్లింపు విధానం';

  @override
  String get cash => 'నగదు';

  @override
  String get upi => 'UPI';

  @override
  String get netBanking => 'నెట్ బ్యాంకింగ్';

  @override
  String get genericCard => 'సాధారణ కార్డ్';

  @override
  String get saveAsShortcut => 'షార్ట్‌కట్‌గా సేవ్ చేయాలా?';

  @override
  String get suggestedLabel => 'సూచించబడినవి';

  @override
  String get basedOnLastEntry => 'మీ చివరి ఎంట్రీ ఆధారంగా';

  @override
  String get basedOnDailyRoutine => 'మీ రోజువారీ దినచర్య ఆధారంగా';

  @override
  String get dailyPattern => 'రోజువారీ నమూనా';

  @override
  String get basedOnLastRecord => 'చివరి రికార్డ్ ఆధారంగా';

  @override
  String get notNow => 'ఇప్పుడు కాదు';

  @override
  String get shortcutSaved => 'షార్ట్‌కట్ సేవ్ చేయబడింది!';

  @override
  String youLogOften(String title) {
    return 'మీరు తరచుగా \'$title\' నమోదు చేస్తారు.';
  }

  @override
  String recordedBalanceUpdated(String method) {
    return 'రికార్డ్ చేయబడింది! $method బ్యాలెన్స్ అప్‌డేట్ చేయబడింది.';
  }

  @override
  String get validAmountError => 'దయచేసి సరైన మొత్తాన్ని నమోదు చేయండి';

  @override
  String get transparencyCheck => 'పారదర్శకత తనిఖీ';

  @override
  String get prefilledNotice =>
      'మీ టైపింగ్ శ్రమను తగ్గించడానికి మేము కొన్ని విలువలను స్థానికంగా ముందే పూరించాము.';

  @override
  String get localDataNotice =>
      'ఈ డేటా మీ పరికరం నుండి ఎప్పటికీ బయటకు వెళ్లదు.';

  @override
  String get categoryLabel => 'వర్గం';

  @override
  String get paymentLabel => 'చెల్లింపు';

  @override
  String get dateLabel => 'తేదీ';

  @override
  String get yesterdayLabel => 'నిన్న';

  @override
  String get otherLabel => 'ఇతర';

  @override
  String get intelligentInsights => 'మేధోపరమైన అంతర్దృష్టులు';

  @override
  String get aiPoweredAnalysis => 'AI ఆధారిత విశ్లేషణ';

  @override
  String get scenarioModeLabel => 'సినారియో మోడ్';

  @override
  String get simulateFuture => 'మీ ఆర్థిక భవిష్యత్తును అనుకరించండి.';

  @override
  String get mindset => 'మనస్తత్వం';

  @override
  String get basedOnLocalHistory => 'స్థానిక చరిత్ర ఆధారంగా.';

  @override
  String get excellentLabel => 'అద్భుతం';

  @override
  String get goodLabel => 'బాగుంది';

  @override
  String get averageLabel => 'సగటు';

  @override
  String get calibrating => 'క్యాలిబ్రేట్ అవుతోంది...';

  @override
  String get atRisk => 'ప్రమాదంలో ఉంది';

  @override
  String get healthScore => 'ఆరోగ్య స్కోర్';

  @override
  String get snooze7Days => '7 రోజులు వాయిదా వేయి';

  @override
  String get dismiss => 'తీసివేయి';

  @override
  String get markPaid => 'చెల్లించినట్లు గుర్తించు';

  @override
  String markedAsPaid(String name) {
    return '$name చెల్లించినట్లు గుర్తించబడింది';
  }

  @override
  String markPaidFailed(String error) {
    return 'చెల్లించినట్లు గుర్తించడంలో విఫలమైంది: $error';
  }

  @override
  String get retirement => 'రిటైర్మెంట్';

  @override
  String get myAccounts => 'నా ఖాతాలు';

  @override
  String get breakdown => 'వివరాలు';

  @override
  String get futureWealth => 'భవిష్యత్తు సంపద';

  @override
  String get projection => 'అంచనా';

  @override
  String get yearsLabel => 'సంవత్సరాలు';

  @override
  String get retirementReady => 'రిటైర్మెంట్ సిద్ధం';

  @override
  String get totalRetirementCorpus => 'మొత్తం రిటైర్మెంట్ కార్పస్';

  @override
  String latency(String time) {
    return 'చివరి అప్‌డేట్: $time';
  }

  @override
  String estimatedCorpus(String amount) {
    return 'రిటైర్మెంట్ వద్ద అంచనా వేసిన కార్పస్: $amount';
  }

  @override
  String get projectionSettings => 'అంచనా సెట్టింగులు';

  @override
  String get currentAgeLabel => 'ప్రస్తుత వయస్సు';

  @override
  String get retirementAgeLabel => 'రిటైర్మెంట్ వయస్సు';

  @override
  String get expectedReturn => 'ఆశించిన రాబడి రేటు';

  @override
  String get percentPa => '% ఏటా';

  @override
  String get updateTargets => 'లక్ష్యాలను అప్‌డేట్ చేయి';

  @override
  String get wealthAdvisory => 'సంపద సలహా';

  @override
  String get optimalTrajectory =>
      'మీ పథం సరైనది. ద్రవ్యోల్బణానికి వ్యతిరేకంగా మూలధన పరిరక్షణను నిర్ధారించడానికి ప్రస్తుత వేగాన్ని కొనసాగించండి.';

  @override
  String get velocityAdjustment =>
      'వేగం సర్దుబాటు సిఫార్సు చేయబడింది. నెలవారీ విరాళాలను 10% పెంచడం వల్ల మీ లక్ష్య కాలక్రమం వేగవంతం అవుతుంది.';

  @override
  String get borrowingsAndLoans => 'రుణాలు & అప్పులు';

  @override
  String get noActiveBorrowings => 'క్రియాశీల రుణాలు ఏవీ లేవు.';

  @override
  String get remaining => 'మిగిలి ఉన్నది';

  @override
  String get repaid => 'చెల్లించినవి';

  @override
  String percentRepaid(String percent) {
    return '$percent% చెల్లించారు';
  }

  @override
  String ofAmount(String amount) {
    return '$amount లో';
  }

  @override
  String get totalBorrowings => 'మొత్తం రుణాలు';

  @override
  String get strategy => 'వ్యూహం';

  @override
  String get debtPayoffPlanner => 'అప్పు తీర్చే ప్లానర్';

  @override
  String get flexible => 'ఫ్లెక్సిబుల్';

  @override
  String get recurring => 'పునరావృతమయ్యేవి';

  @override
  String get dueTodayLabel => 'నేడు చెల్లించాల్సి ఉంది';

  @override
  String get dueTomorrowLabel => 'రేపు చెల్లించాల్సి ఉంది';

  @override
  String get record => 'రికార్డ్';

  @override
  String get age => 'వయస్సు';

  @override
  String get emi => 'ఈఎంఐ (EMI)';

  @override
  String get due => 'బకాయి';

  @override
  String get newBorrowing => 'కొత్త అప్పు';

  @override
  String get loanClassification => 'రుణ వర్గీకరణ';

  @override
  String get creditorLoanName => 'రుణదాత / రుణ పేరు';

  @override
  String get remainingBalance => 'మిగిలిన బ్యాలెన్స్';

  @override
  String get totalLoan => 'మొత్తం రుణం';

  @override
  String get monthlyEmi => 'నెలవారీ ఈఎంఐ (EMI)';

  @override
  String get interestRate => 'వడ్డీ రేటు';

  @override
  String get expectedRepaymentDate => 'ఆశించిన తిరిగి చెల్లింపు తేదీ';

  @override
  String get dueDateDayOfMonth => 'చెల్లింపు తేదీ (నెలలో రోజు)';

  @override
  String get selectDate => 'తేదీని ఎంచుకోండి';

  @override
  String get selectDay => 'రోజును ఎంచుకోండి';

  @override
  String get commitBorrowing => 'అప్పును జోడించు';

  @override
  String get pleaseFillRequiredFields =>
      'దయచేసి అవసరమైన అన్ని వివరాలను నింపండి';

  @override
  String get remainingCannotExceedTotal =>
      'మిగిలిన బ్యాలెన్స్ మొత్తం రుణం కంటే ఎక్కువగా ఉండకూడదు';

  @override
  String get updateLoan => 'రుణం అప్‌డేట్';

  @override
  String get recordEmiPayment => 'ఈఎంఐ (EMI) చెల్లింపు రికార్డ్';

  @override
  String get recordPrepayment => 'ముందస్తు చెల్లింపు రికార్డ్';

  @override
  String get updateBorrowing => 'అప్పు అప్‌డేట్';

  @override
  String get paymentHistory => 'చెల్లింపుల చరిత్ర';

  @override
  String get noRecordedPaymentHistory =>
      'ఎటువంటి చెల్లింపుల చరిత్ర కనుగొనబడలేదు.';

  @override
  String get markAsEmi => 'อีఎంఐ (EMI)గా గుర్తించు';

  @override
  String get notAPayment => 'చెల్లింపు కాదు';

  @override
  String showAllWithCount(int count) {
    return 'అన్నీ చూపించు ($count చెల్లింపులు)';
  }

  @override
  String get payoffQuote => 'తుది చెల్లింపు అంచనా';

  @override
  String get estimate => 'అంచనా';

  @override
  String get validUntilToday => 'ఈ రోజు వరకు మాత్రమే వర్తిస్తుంది';

  @override
  String get reconcileWithBank => 'బ్యాంకుతో సరిపోల్చుకోండి';

  @override
  String get payoffBreakdown => 'చెల్లింపు వివరాలు';

  @override
  String get principalOutstanding => 'అసలు బ్యాలెన్స్';

  @override
  String get interestAccrued => 'జమ అయిన వడ్డీ';

  @override
  String get totalQuote => 'మొత్తం అంచనా';

  @override
  String get trustCenter => 'ట్రస్ట్ సెంటర్ (నమ్మక కేంద్రం)';

  @override
  String get ourGuarantees => 'మా హామీలు';

  @override
  String get strictPolicies => 'కఠినమైన నిబంధనలు';

  @override
  String get dataHealth => 'డేటా స్థితి';

  @override
  String get backupConfidence => 'బ్యాకప్ భద్రత';

  @override
  String get localBackups => 'లోకల్ బ్యాకప్‌లు';

  @override
  String get viewFolder => 'ఫోల్డర్ చూడండి';

  @override
  String get totalRecords => 'మొత్తం రికార్డులు';

  @override
  String get localBackupStatus => 'లోకల్ బ్యాకప్ స్థితి';

  @override
  String lastBackupLabel(String time) {
    return 'చివరి బ్యాకప్: $time';
  }

  @override
  String get nextAutoBackup => 'తదుపరి బ్యాకప్: యాప్ మళ్ళీ తెరిచినప్పుడు';

  @override
  String get noLocalBackupsFound => 'ఇంకా ఎటువంటి లోకల్ బ్యాకప్‌లు లేవు.';

  @override
  String get sqlCipherEncryption =>
      'TrueLedger మీ డేటాను సురక్షితంగా ఉంచడానికి SQLCipher AES-256 ఎన్‌క్రిప్షన్‌ను ఉపయోగిస్తుంది.';

  @override
  String get productLevelPrivacy => 'ఉత్పత్తి-స్థాయి గోప్యతా హామీలు';

  @override
  String get privacyPrinciple =>
      'మీ ఆర్థిక సమాచారం మీది మాత్రమే అనే సూత్రంపై TrueLedger నిర్మించబడింది. మేము సంపూర్ణ గోప్యతను నమ్ముతాము, అందుకే మీ డేటా మీ పరికరాన్ని వదిలి వెళ్ళదు.';

  @override
  String get noAds => 'ప్రకటనలు లేవు';

  @override
  String get noAdsDesc =>
      'మేము ఎప్పుడూ ప్రకటనలు లేదా ప్రాయోజిత కంటెంట్‌తో మీకు అసౌకర్యం కలిగించము.';

  @override
  String get noTracking => 'ట్రాకింగ్ లేదు';

  @override
  String get noTrackingDesc =>
      'మేము మీ ప్రవర్తనను, స్థానాన్ని లేదా వినియోగాన్ని ట్రాక్ చేయము. మీరు మాకు కేవలం డేటా పాయింట్ కాదు.';

  @override
  String get noProfiling => 'ప్రొఫైలింగ్ లేదు';

  @override
  String get noProfilingDesc =>
      'మీ ఆర్థిక అలవాట్లు వ్యక్తిగతం. మేము ఎవరినీ టార్గెట్ చేయడానికి ప్రొఫైల్‌లను రూపొందించము.';

  @override
  String get localOnly => '100% లోకల్';

  @override
  String get localOnlyDesc =>
      'మీ డేటాబేస్ మీ పరికరంలో మాత్రమే ఉంటుంది. మీ లాగ్‌లకు మాకు ఎటువంటి యాక్సెస్ ఉండదు.';

  @override
  String get noAnalyticsSdk => 'ఎటువంటి విశ్లేషణ లేదా ట్రాకింగ్ SDKలు లేవు';

  @override
  String get noBehaviorProfiling => 'ప్రవర్తనా వివరణలు లేదా స్కోరింగ్ లేదు';

  @override
  String get noBankScraping => 'బ్యాంక్ లేదా SMS స్క్రాపింగ్ లేదు';

  @override
  String get noCloudSync => 'క్లౌడ్ సింక్ లేదా బాహ్య స్టోరేజ్ లేదు';

  @override
  String get noSellingLogs =>
      'వినియోగదారు లాగ్‌లను అమ్మడం లేదా పంచుకోవడం జరగదు';

  @override
  String get restoreDataTitle => 'డేటాను పునరుద్ధరించాలా?';

  @override
  String get restoreDataWarning =>
      'ఇది మీ ప్రస్తుత డేటాను ఈ బ్యాకప్‌తో భర్తీ చేస్తుంది. ఇది తిరిగి మార్చబడదు.';

  @override
  String get restoreNow => 'ఇప్పుడే పునరుద్ధరించు';

  @override
  String get restoreCompleted => 'డేటా పునరుద్ధరణ విజయవంతమైంది';

  @override
  String restoreFailed(String error) {
    return 'పునరుద్ధరణ విఫలమైంది: $error';
  }

  @override
  String runwayMonths(int months) {
    return 'మీ పొదుపు సుమారు $months నెలలు సరిపోతుంది';
  }

  @override
  String get sustainableRunway => 'మీ ఆర్థిక ప్రయాణం నిలకడగా ఉంది';

  @override
  String get calculatingRunway => 'రన్ వే లెక్కిస్తోంది...';

  @override
  String failedToLoadLoans(String error) {
    return 'రుణాలను లోడ్ చేయడం విఫలమైంది: $error';
  }

  @override
  String get loanNameHint => 'ఉదాహరణ: HDFC గోల్డ్ లోన్';

  @override
  String get engineReducingBalance => 'ఇంజిన్: తగ్గించే బ్యాలెన్స్ (రోజువారీ)';

  @override
  String get bankType => 'బ్యాంక్';

  @override
  String get individualType => 'వ్యక్తిగత';

  @override
  String get goldType => 'బంగారం';

  @override
  String get carType => 'కారు';

  @override
  String get homeType => 'ఇల్లు';

  @override
  String get educationType => 'చదువు';

  @override
  String get settings => 'సెట్టింగులు';

  @override
  String get selectDueDay => 'చెల్లింపు రోజును ఎంచుకోండి';
}
