/// Central Route Path & Name definitions linked with Stitch Screen IDs
abstract class AppRoutes {
  // Auth & Onboarding
  static const splash = '/splash'; // 430bf5042514410ead8045a6c8f42019
  static const onboarding = '/onboarding'; // 2b72cbe1978c43188223ca9b3fe3e3bd
  static const occupation = '/onboarding/occupation'; // 0ea6d6b84162412682f8b2d96948ecac
  static const priority = '/onboarding/priority'; // f57fbdc263134b53ae17e48e973fa84e
  static const income = '/onboarding/income'; // 372dbb84bf0047ddb9bbd53f15b9b73e
  static const incomeSources = '/onboarding/income-sources'; // 1b366b7108964f2c973eb299baa59533
  static const expenses = '/onboarding/expenses'; // e146669d9ce144de944d9bc407dbb24b
  static const savings = '/onboarding/savings'; // 180c0717889a45518e0e4325267762ce
  static const debts = '/onboarding/debts'; // b24d6e6b926b4879a72e39d40b7266b6
  static const goalSelection = '/onboarding/goal-selection'; // d9ccb8b5b74b45958aa7d33d39b9b06b
  static const goalTarget = '/onboarding/goal-target'; // 4500bf00d9d34b38ae1b895c6f3f031b
  static const onboardingSummary = '/onboarding/summary';
  static const login = '/login'; // 29d2277949ac4bdfae8ad7ed96072c93

  // Main Dashboard
  static const dashboard = '/dashboard'; // a3fdf44abc214993be7b3ff7c049ba8f
  static const commandCenter = '/dashboard/command-center'; // 5e3c0ff7910847e6898bfa050d24d93e
  static const netWorthCompact = '/dashboard/net-worth/compact'; // 2a0e25a4b2204d4da8443620340eeeb8
  static const netWorth = '/dashboard/net-worth'; // 501d98453a634c0a92d0eb85f03a5eb6
  static const cashFlow = '/dashboard/cash-flow'; // b40e26ef5a404b92902eae7575d07d9b
  static const spendingAnalysis = '/dashboard/spending-analysis'; // 140797d4b2d44b70b8cb995a53b53047
  static const alerts = '/dashboard/alerts'; // 891aa3c34ba14bb2b42f1f99d8a35686

  // Transactions & Accounts
  static const transactions = '/transactions'; // bd0569afc65c4931b8cdb0bbe1abb907
  static const transactionDetails = '/transactions/:id'; // 1c6466e3ad3b406cbee38fae4a622b4a
  static const addExpense = '/transactions/add'; // 4403a1a291be467993075f2d047b048a
  static const scanReceipt = '/transactions/scan'; // ca85f8bb2c654498a70de0a6351736fc
  static const scanUpi = '/transactions/scan-upi';
  static const scanReceiptAdvanced = '/transactions/scan-advanced'; // 656215ccf46f4a0b99092d1521e4e504
  static const scanResult = '/transactions/scan-result'; // 25a88ab65be140529a5a5d4a08416ddf
  static const reviewExpense = '/transactions/review';
  static const scanResultSummary = '/transactions/scan-result-summary'; // bb2e30310535400ea3aacf9074338ea2
  static const upiSetup = '/accounts/upi-setup'; // afce4e7c66354d1ea25218c049885689
  static const paymentMethods = '/accounts/payment-methods'; // 07cc6e59a89c43038737825c1643efaf
  static const wallets = '/accounts/wallets'; // bfdffc8425ed4c67b1fb170832e9d348
  static const walletsDetailed = '/accounts/wallets-detailed'; // 49e278025d534b97b7ea4f28513d51c7
  static const addWalletSelection = '/accounts/add-wallet'; // eb77d61880b1468ead4d89cb0ec159be
  static const addMoney = '/accounts/add-money';
  static const connectBank = '/accounts/connect-bank'; // f1ab89767f66421bb33626ad09b078dd
  static const trackingSetup = '/accounts/tracking-setup';
  static const trackingSetupAlt = '/transactions/tracking/setup';
  static const trackingSettings = '/accounts/tracking-settings';
  static const trackingSettingsAlt = '/transactions/tracking/settings';
  static const scanReceiptAlt = '/transactions/scan-receipt';
  static const transactionDetailsAlt = '/transactions/details';
  static const weeklyBriefing = '/reports/weekly-briefing';
  static const financialAnalysis = '/reports/financial-analysis';
  static const spendingAnalysisReports = '/reports/spending-analysis';
  static const incomeAnalysis = '/reports/income-analysis';
  static const cashFlowReports = '/reports/cash-flow';
  static const financialHealthInsights = '/reports/health-insights';
  static const categoryAnalysis = '/reports/category-analysis';





  // Budgets & Goals
  static const goals = '/goals'; // 5fd7790aed8846e4b2a843a2a2a01e71
  static const goalsDetailed = '/goals/detailed'; // b5a5ed25efbb4daf88e3cce7882f67e4
  static const goalsSummary = '/goals/summary'; // abfa5aa039594394a5a49eecc991f943
  static const goalDetails = '/goals/:id'; // faa8362de6b341f4acc51fdc758d9123
  static const goalAnalysis = '/goals/:id/analysis'; // 4b66c7165ced4a69a0eb7f61431e014e
  static const goalsPerformance = '/goals/performance'; // 5c1f58707ce441d4b5f70c17cb4fdb69
  static const goalContribution = '/goals/contribute'; // 7fe7f213db67482e8bb3b3e765bc9637
  static const smartPlanner = '/goals/smart-planner'; // cc69b1a800344e968fd9b9b3522f1ad9
  static const emergencyFund = '/goals/emergency-fund'; // 2f98b34527584508b179b1919618edd4
  static const debtPayoff = '/goals/debt-payoff'; // ece236af73cf4a25ac85ea30be1c817e
  static const budgetPerformance = '/budgets/performance'; // f4857574177d404f91b4264a439859ae
  static const budgetDetails = '/budgets/:category'; // 0ef038f996c44c5dbd8d889d6eb9c1dd

  // Bills & Subscriptions
  static const bills = '/bills'; // 54ac90426fb44659a5bdbbbb568bc37e
  static const billsDashboard = '/bills/dashboard'; // 9fd1c821bb7741ffa143d533eb1597b2
  static const billDetails = '/bills/:id'; // 7577ae7baef34cdfa6075c0976f25c6d
  static const billDetailsFull = '/bills/:id/full'; // 6c2d74ce1a444bd4a334fd430415f0ed
  static const addBill = '/bills/add'; // 78b51de5ce3b4df98a13bbae0f3906d5
  static const recurringPayment = '/bills/recurring';
  static const upcomingPayments = '/bills/upcoming';
  static const billConfirmation = '/bills/confirmation'; // a5f01ddba9c14184b27ca22b2098feb4
  static const subscriptionDetails = '/subscriptions/:id'; // ea8e156aeee947a5bd035a99547fe750
  static const goalDetailsAlt = '/goals/details';
  static const moneyHealthAlt = '/ai/health';
  static const reportsAnalyticsAlt = '/reports/analytics';


  // AI Intelligence Engine
  static const aiAssistant = '/ai-assistant'; // 124a564290fe4a03b13db2feb7a9bb38
  static const aiAssistantCompact = '/ai-assistant/compact'; // f91f7b16770d4994a1444278e9c3a22d
  static const aiAdvisor = '/ai-assistant/advisor'; // 38b5afb665e84ac6b96888ed5d40bbfc
  static const aiChat = '/ai-assistant/chat'; // 697f99717f164fa882d53ed4ef537263
  static const aiHealthScore = '/ai-assistant/health-score'; // 7847e73e28d244fbbb50f80fc6d2f078
  static const aiHealthScoreSummary = '/ai-assistant/health-score-summary'; // a3b6be15fa9c476286ddfd0a27537c92
  static const aiHealthActionPlan = '/ai-assistant/health-action-plan'; // 6767cb3ed87f415191d30e79af6a3acc
  static const aiActionPlan = '/ai-assistant/action-plan'; // 71ff9933d1bb4e48817a265fa111b69e
  static const aiHealthCheck = '/ai-assistant/health-check'; // 56a45fe1d5f24734aebf6f65418fc504
  static const aiGoalPlanning = '/ai-assistant/goal-planning'; // e7ade8b9e52a4878abee80c39e339018
  static const aiGoalPlanner = '/ai-assistant/goal-planner'; // bcf3e6f033e241f6906aff8844fd9659
  static const aiGoalPlannerExtended = '/ai-assistant/goal-planner-extended'; // 778a3d4b94e1499daaad318d000a67de
  static const aiGoalPlannerSimple = '/ai-assistant/goal-planner-simple'; // 49b960aa0e6a4334b4f41ce03b06b000
  static const aiGoalProgress = '/ai-assistant/goal-progress'; // c56e164c88f8427fa300993e0c788018
  static const aiGoalOptimizer = '/ai-assistant/goal-optimizer'; // 17a8737eb6834b79bd9ec9fe05c01d7b
  static const aiGoalRecovery = '/ai-assistant/goal-recovery'; // 52d578e5d0214389a35deaafc0fe0aa9
  static const aiSavingsOptimizer = '/ai-assistant/savings-optimizer'; // dd2c9a68be2a4608ab99c3a32f7e2e29
  static const aiSpendingCoach = '/ai-assistant/spending-coach'; // f477166b87a840e4affca69f3712c357
  static const aiSpendingControl = '/ai-assistant/spending-control'; // a626a949a4b24c5d9bd00b784a95815f
  static const aiBudgetOptimizer = '/ai-assistant/budget-optimizer'; // e1a96b8d3caa401cb47b4bf023e3ec20
  static const aiCashFlowPredictor = '/ai-assistant/cash-flow-predictor'; // 9495441aad124983be27c9982864ba3e
  static const aiCashFlowForecast = '/ai-assistant/cash-flow-forecast'; // 1629ee1608ae4ea79642bcdcdb8baea3
  static const aiExpensePredictor = '/ai-assistant/expense-predictor'; // e9301a07c5c74e7489b94c3a8536944a
  static const aiSubscriptionManager = '/ai-assistant/subscription-manager'; // 42d8ceefd5ec42f2b99096dc929aa0b7
  static const aiSubscriptionManagerDetailed = '/ai-assistant/subscription-manager-detailed'; // 3a757c34c7874f819de63f46e77dcb35
  static const aiBillSubscriptionManager = '/ai-assistant/bill-subscription-manager'; // 04c179bbd3ad4f82a05b36fb7449e835
  static const aiBillRenewalOptimizer = '/ai-assistant/bill-renewal-optimizer'; // 79da268687d14d66b0c6c01d22b98922
  static const aiBillPaymentOptimizer = '/ai-assistant/bill-payment-optimizer'; // 24d8121bbeac4fcc8efa58ef25b9d2d9
  static const aiFinancialInsights = '/ai-assistant/financial-insights'; // 421a0abea4d44948a310b0047e134abd
  static const aiFinancialPlanning = '/ai-assistant/financial-planning'; // 84213091b9ce48ea8fcdd77de2412e87
  static const aiMonthlyReview = '/ai-assistant/monthly-review'; // e84e9dbd20b3452a92d4e92be951219e
  static const aiPersonalizedPlan = '/ai-assistant/personalized-plan'; // 854a68b4e5724832b75dbfc854f81f4d
  static const aiRecommendations = '/ai-assistant/recommendations'; // 631f79436c474521b9ba1c4f2e5b11a6

  // Reports, Settings & Meta
  static const reports = '/reports'; // 51dbf8bbf1e94044870b74ddab643c3e
  static const reportsDetailed = '/reports/detailed'; // 9d3f0e403fd143a2aeec71424b62e4b9
  static const reportsSummary = '/reports/summary'; // 1fab2b80e6e94b4ea1f5bcd5256f0e63
  static const reportsCompact = '/reports/compact'; // 56e18511ad71466fbbf9f45ebe360275
  static const reportsAnimated = '/reports/animated'; // 77c5652b5e61414aba3619eaaff09aa5
  static const reportGenerator = '/reports/generator'; // f1effb78ed3d4b1385891d693c1de3e4
  static const settings = '/settings'; // 5274b8189d4b4ef4b699011cda4bea28
  static const financialProfile = '/settings/financial-profile';
  static const privacyDataCenter = '/settings/privacy'; // f8222a17e970411b94b75302fa4c577f
  static const helpSupportCenter = '/settings/help'; // 41a889412a294624aee8bfc4e3322eda
  static const helpSupport = '/settings/support'; // ab44ab38d7674271a17cdc444b8bfe29
  static const aboutLegalCenter = '/settings/about'; // 727ca22f4f224586be25d67d2510447a
}
