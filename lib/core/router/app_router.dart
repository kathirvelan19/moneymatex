import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/mm_bottom_nav_bar.dart';

import '../../features/auth_onboarding/presentation/pages/splash_page.dart';
import '../../features/auth_onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth_onboarding/presentation/pages/login_page.dart';
import '../../features/auth_onboarding/presentation/pages/onboarding_survey_screens.dart';
import '../../features/auth_onboarding/presentation/pages/financial_profile_page.dart';

import '../../features/dashboard/presentation/pages/dashboard_screens.dart' hide CashFlowAnalysisPage, SpendingAnalysisPage;

import '../../features/dashboard/presentation/pages/cash_flow_page.dart';
import '../../features/transactions/presentation/pages/transaction_screens.dart' hide WalletsDetailedPage, ScanReceiptPage, TransactionDetailsPage, PaymentMethodsPage, AddWalletSelectionPage, UpiSetupPage, TrackingSetupPage, ReviewExpensePage;
import '../../features/transactions/presentation/pages/add_money_page.dart';
import '../../features/accounts/presentation/pages/wallet_details_page.dart';
import '../../features/budgets_savings/presentation/pages/budget_goal_screens.dart' hide SmartGoalPlannerPage;
import '../../features/bills_subscriptions/presentation/pages/bill_subscription_screens.dart' hide AddBillPage, BillsOverviewPage, BillDetailsPage;


import '../../features/ai_assistant/presentation/pages/ai_screens.dart' hide AIAdvisorHomePage;
import '../../features/ai_assistant/presentation/pages/ai_health_score_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_advisor_page.dart';
import '../../features/settings_support/presentation/pages/reports_screens.dart';
import '../../features/settings_support/presentation/pages/report_setting_screens.dart' hide HelpSupportCenterPage, HelpSupportPage;
import '../../features/settings_support/presentation/pages/weekly_briefing_page.dart';
import '../../features/settings_support/presentation/pages/help_support_page.dart';

import '../../features/accounts/presentation/pages/add_wallet_selection_page.dart';
import '../../features/accounts/presentation/pages/upi_tracking_setup_page.dart';
import '../../features/accounts/presentation/pages/transaction_tracking_settings_page.dart';
import '../../features/accounts/presentation/pages/payment_methods_page.dart';
import '../../features/transactions/presentation/pages/scan_receipt_page.dart';
import '../../features/transactions/presentation/pages/scan_upi_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/transactions/presentation/pages/transaction_review_confirm_page.dart';
import '../../features/bills_subscriptions/presentation/pages/bills_reminders_page.dart';
import '../../features/bills_subscriptions/presentation/pages/add_bill_page.dart';
import '../../features/bills_subscriptions/presentation/pages/bill_details_page.dart';
import '../../features/bills_subscriptions/presentation/pages/upcoming_payments_page.dart';
import '../../features/budgets_savings/presentation/pages/goal_details_page.dart';
import '../../features/budgets_savings/presentation/pages/smart_goal_planner_page.dart';
import '../../features/settings_support/presentation/pages/money_health_page.dart';
import '../../features/settings_support/presentation/pages/financial_report_analysis_page.dart';
import '../../features/settings_support/presentation/pages/spending_analysis_page.dart';
import '../../features/settings_support/presentation/pages/income_analysis_page.dart';
import '../../features/settings_support/presentation/pages/financial_health_insights_page.dart';
import '../../features/settings_support/presentation/pages/category_analysis_page.dart';





import 'app_routes.dart';
import 'route_observer.dart';
import '../../features/auth_onboarding/presentation/providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Riverpod Provider exposing the central GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: AppRouter._rootNavigatorKey,
    refreshListenable: notifier,
    observers: [AppRouteObserver()],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final loc = state.matchedLocation;

      // While initial session is being checked, allow Splash screen to display
      if (!authState.isSessionChecked) {
        if (loc != AppRoutes.splash) {
          return AppRoutes.splash;
        }
        return null;
      }

      // Session checked: if currently on Splash screen, redirect to appropriate destination
      if (loc == AppRoutes.splash) {
        if (!authState.isAuthenticated) {
          return AppRoutes.login;
        }
        if (!authState.isOnboardingCompleted) {
          return AppRoutes.occupation;
        }
        return AppRoutes.dashboard;
      }

      // Unauthenticated users attempting to access protected screens -> redirect to login
      if (!authState.isAuthenticated) {
        if (loc != AppRoutes.login) {
          return AppRoutes.login;
        }
        return null;
      }

      // Authenticated users attempting to access login screen -> redirect to onboarding Question 1 or dashboard
      if (loc == AppRoutes.login) {
        if (!authState.isOnboardingCompleted) {
          return AppRoutes.occupation;
        } else {
          return AppRoutes.dashboard;
        }
      }

      // Authenticated users with incomplete onboarding trying to access protected main app screens -> redirect to onboarding Question 1
      if (!authState.isOnboardingCompleted && !loc.startsWith('/onboarding')) {
        return AppRoutes.occupation;
      }

      return null;
    },
    routes: AppRouter.routesList,
  );
});

/// MoneyMateX Central GoRouter Declarative Navigation Setup
abstract class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final routesList = [

      // Auth & Onboarding Stack Routes
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.occupation,
        builder: (context, state) => const OccupationPage(),
      ),
      GoRoute(
        path: AppRoutes.priority,
        builder: (context, state) => const PriorityPage(),
      ),
      GoRoute(
        path: AppRoutes.income,
        builder: (context, state) => const IncomePage(),
      ),
      GoRoute(
        path: AppRoutes.incomeSources,
        builder: (context, state) => const IncomeSourcesPage(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const ExpensesPage(),
      ),
      GoRoute(
        path: AppRoutes.savings,
        builder: (context, state) => const SavingsPage(),
      ),
      GoRoute(
        path: AppRoutes.debts,
        builder: (context, state) => const DebtsPage(),
      ),
      GoRoute(
        path: AppRoutes.goalSelection,
        builder: (context, state) => const GoalSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.goalTarget,
        builder: (context, state) => const GoalTargetPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSummary,
        builder: (context, state) => const OnboardingSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Main Stateful Shell Route for 5 Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: MMBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },
        branches: [
          // Tab 1: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const MainDashboardPage(),
              ),
            ],
          ),
          // Tab 2: Transactions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsPage(),
              ),
            ],
          ),
          // Tab 3: Budget
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgetPerformance,
                builder: (context, state) => const BudgetPerformancePage(),
              ),
            ],
          ),
          // Tab 4: Goals
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (context, state) => const SavingGoalsOverviewPage(),
              ),
            ],
          ),
          // Tab 5: More (Settings & Support)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Dashboard Detail Stack Routes
      GoRoute(
        path: AppRoutes.commandCenter,
        builder: (context, state) => const FinancialCommandCenterPage(),
      ),
      GoRoute(
        path: AppRoutes.netWorthCompact,
        builder: (context, state) => const NetWorthCompactPage(),
      ),
      GoRoute(
        path: AppRoutes.netWorth,
        builder: (context, state) => const NetWorthDetailedPage(),
      ),
      GoRoute(
        path: AppRoutes.cashFlow,
        builder: (context, state) => const CashFlowAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.spendingAnalysis,
        builder: (context, state) => const FinancialReportAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.alerts,
        builder: (context, state) => const AlertsCenterPage(),
      ),

      // Transaction Detail Stack Routes
      GoRoute(
        path: AppRoutes.addExpense,
        builder: (context, state) => const AddExpensePage(),
      ),
      GoRoute(
        path: AppRoutes.scanReceipt,
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: AppRoutes.scanUpi,
        builder: (context, state) => const ScanUpiPage(),
      ),
      GoRoute(
        path: AppRoutes.scanReceiptAlt,
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: AppRoutes.scanReceiptAdvanced,
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: AppRoutes.scanResult,
        builder: (context, state) => TransactionReviewConfirmPage(
          initialData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewExpense,
        builder: (context, state) => TransactionReviewConfirmPage(
          initialData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.scanResultSummary,
        builder: (context, state) => const ScanResultSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) => TransactionDetailsPage(
          id: state.pathParameters['id'] ?? '',
          initialData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionDetailsAlt,
        builder: (context, state) => TransactionDetailsPage(
          initialData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.upiSetup,
        builder: (context, state) => const UpiTrackingSetupPage(),
      ),
      GoRoute(
        path: AppRoutes.trackingSetupAlt,
        builder: (context, state) => const UpiTrackingSetupPage(),
      ),

      GoRoute(
        path: AppRoutes.paymentMethods,
        builder: (context, state) => const PaymentMethodsPage(),
      ),
      GoRoute(
        path: AppRoutes.wallets,
        builder: (context, state) => const WalletsPage(),
      ),
      GoRoute(
        path: AppRoutes.walletsDetailed,
        builder: (context, state) => const WalletsDetailedPage(),
      ),
      GoRoute(
        path: AppRoutes.addWalletSelection,
        builder: (context, state) => const AddWalletSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.addMoney,
        builder: (context, state) => const AddMoneyPage(),
      ),
      GoRoute(
        path: AppRoutes.connectBank,
        builder: (context, state) => const ConnectBankPage(),
      ),
      GoRoute(
        path: AppRoutes.trackingSetup,
        builder: (context, state) => const UpiTrackingSetupPage(),
      ),
      GoRoute(
        path: AppRoutes.trackingSettings,
        builder: (context, state) => const TransactionTrackingSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.trackingSettingsAlt,
        builder: (context, state) => const TransactionTrackingSettingsPage(),
      ),



      // Goals & Budgets Detail Stack Routes
      GoRoute(
        path: AppRoutes.goalsDetailed,
        builder: (context, state) => const SavingGoalsDetailedPage(),
      ),
      GoRoute(
        path: AppRoutes.goalsSummary,
        builder: (context, state) => const SavingGoalsSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.goalDetails,
        builder: (context, state) => GoalDetailsPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.goalDetailsAlt,
        builder: (context, state) => const GoalDetailsPage(),
      ),

      GoRoute(
        path: AppRoutes.goalAnalysis,
        builder: (context, state) => SavingGoalAnalysisPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.goalsPerformance,
        builder: (context, state) => const SavingGoalsPerformancePage(),
      ),
      GoRoute(
        path: AppRoutes.goalContribution,
        builder: (context, state) => const GoalContributionPage(),
      ),
      GoRoute(
        path: AppRoutes.smartPlanner,
        builder: (context, state) => const SmartGoalPlannerPage(),
      ),
      GoRoute(
        path: AppRoutes.emergencyFund,
        builder: (context, state) => const EmergencyFundPlannerPage(),
      ),
      GoRoute(
        path: AppRoutes.debtPayoff,
        builder: (context, state) => const DebtPayoffPlannerPage(),
      ),
      GoRoute(
        path: AppRoutes.budgetPerformance,
        builder: (context, state) => const BudgetPerformancePage(),
      ),
      GoRoute(
        path: AppRoutes.budgetDetails,
        builder: (context, state) => BudgetDetailsPage(category: state.pathParameters['category'] ?? ''),
      ),

      // Bills & Subscriptions Detail Stack Routes
      GoRoute(
        path: AppRoutes.bills,
        builder: (context, state) => const BillsRemindersPage(),
      ),
      GoRoute(
        path: AppRoutes.billsDashboard,
        builder: (context, state) => const BillsRemindersPage(),
      ),

      GoRoute(
        path: AppRoutes.billDetails,
        builder: (context, state) => BillDetailsPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.billDetailsFull,
        builder: (context, state) => BillDetailsFullPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.addBill,
        builder: (context, state) => const AddBillPage(),
      ),
      GoRoute(
        path: AppRoutes.recurringPayment,
        builder: (context, state) => const AddBillPage(),
      ),
      GoRoute(
        path: AppRoutes.upcomingPayments,
        builder: (context, state) => const UpcomingPaymentsPage(),
      ),
      GoRoute(
        path: AppRoutes.moneyHealthAlt,
        builder: (context, state) => const MoneyHealthPage(),
      ),
      GoRoute(
        path: AppRoutes.reportsAnalyticsAlt,
        builder: (context, state) => const FinancialReportAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.spendingAnalysisReports,
        builder: (context, state) => const SpendingAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.incomeAnalysis,
        builder: (context, state) => const IncomeAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.cashFlowReports,
        builder: (context, state) => const CashFlowAnalysisPage(),
      ),

      GoRoute(
        path: AppRoutes.financialHealthInsights,
        builder: (context, state) => const FinancialHealthInsightsPage(),
      ),
      GoRoute(
        path: AppRoutes.categoryAnalysis,
        builder: (context, state) => const CategoryAnalysisPage(),
      ),


      GoRoute(
        path: AppRoutes.billConfirmation,
        builder: (context, state) => const BillConfirmationPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionDetails,
        builder: (context, state) => SubscriptionDetailsPage(id: state.pathParameters['id'] ?? ''),
      ),

      // AI Intelligence Stack Routes
      GoRoute(
        path: AppRoutes.aiAssistantCompact,
        builder: (context, state) => const K2iAssistantCompactPage(),
      ),
      GoRoute(
        path: AppRoutes.aiAdvisor,
        builder: (context, state) => const AIAdvisorHomePage(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => const AIAdvisorChatPage(),
      ),
      GoRoute(
        path: AppRoutes.aiHealthScore,
        builder: (context, state) => const AIHealthScorePage(),
      ),
      GoRoute(
        path: AppRoutes.aiHealthScoreSummary,
        builder: (context, state) => const AIHealthScoreSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.aiHealthActionPlan,
        builder: (context, state) => const AIHealthActionPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.aiActionPlan,
        builder: (context, state) => const AIActionPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.aiHealthCheck,
        builder: (context, state) => const AIHealthCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalPlanning,
        builder: (context, state) => const AIGoalPlanningPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalPlanner,
        builder: (context, state) => const AIGoalPlannerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalPlannerExtended,
        builder: (context, state) => const AIGoalPlannerExtendedPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalPlannerSimple,
        builder: (context, state) => const AIGoalPlannerSimplePage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalProgress,
        builder: (context, state) => const AIGoalProgressPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalOptimizer,
        builder: (context, state) => const AIGoalOptimizerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiGoalRecovery,
        builder: (context, state) => const AIGoalRecoveryPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSavingsOptimizer,
        builder: (context, state) => const AISavingsOptimizerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSpendingCoach,
        builder: (context, state) => const AISpendingCoachPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSpendingControl,
        builder: (context, state) => const AISpendingControlPage(),
      ),
      GoRoute(
        path: AppRoutes.aiBudgetOptimizer,
        builder: (context, state) => const AIBudgetOptimizerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiCashFlowPredictor,
        builder: (context, state) => const AICashFlowPredictorPage(),
      ),
      GoRoute(
        path: AppRoutes.aiCashFlowForecast,
        builder: (context, state) => const AICashFlowForecastPage(),
      ),
      GoRoute(
        path: AppRoutes.aiExpensePredictor,
        builder: (context, state) => const AIExpensePredictorPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSubscriptionManager,
        builder: (context, state) => const AISubscriptionManagerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiSubscriptionManagerDetailed,
        builder: (context, state) => const AISubscriptionManagerDetailedPage(),
      ),
      GoRoute(
        path: AppRoutes.aiBillSubscriptionManager,
        builder: (context, state) => const AIBillSubscriptionManagerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiBillRenewalOptimizer,
        builder: (context, state) => const AIBillRenewalOptimizerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiBillPaymentOptimizer,
        builder: (context, state) => const AIBillPaymentOptimizerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiFinancialInsights,
        builder: (context, state) => const AIFinancialInsightsPage(),
      ),
      GoRoute(
        path: AppRoutes.aiFinancialPlanning,
        builder: (context, state) => const AIFinancialPlanningPage(),
      ),
      GoRoute(
        path: AppRoutes.aiMonthlyReview,
        builder: (context, state) => const AIMonthlyReviewPage(),
      ),
      GoRoute(
        path: AppRoutes.aiPersonalizedPlan,
        builder: (context, state) => const AIPersonalizedPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.aiRecommendations,
        builder: (context, state) => const AIRecommendationsPage(),
      ),

      // Reports & Settings Stack Routes
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const FinancialReportAnalysisPage(),
      ),
      GoRoute(
        path: AppRoutes.financialAnalysis,
        builder: (context, state) => const FinancialReportAnalysisPage(),
      ),

      GoRoute(
        path: AppRoutes.reportsDetailed,
        builder: (context, state) => const ReportsDetailedPage(),
      ),
      GoRoute(
        path: AppRoutes.reportsSummary,
        builder: (context, state) => const ReportsSummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.reportsCompact,
        builder: (context, state) => const ReportsCompactPage(),
      ),
      GoRoute(
        path: AppRoutes.reportsAnimated,
        builder: (context, state) => const ReportsAnimatedPage(),
      ),
      GoRoute(
        path: AppRoutes.reportGenerator,
        builder: (context, state) => const ReportGeneratorPage(),
      ),
      GoRoute(
        path: AppRoutes.weeklyBriefing,
        builder: (context, state) => const WeeklyBriefingPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.financialProfile,
        builder: (context, state) => const FinancialProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.privacyDataCenter,
        builder: (context, state) => const PrivacyDataCenterPage(),
      ),
      GoRoute(
        path: AppRoutes.helpSupportCenter,
        builder: (context, state) => const HelpSupportCenterPage(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: AppRoutes.aboutLegalCenter,
        builder: (context, state) => const AboutLegalCenterPage(),
      ),
    ];
  }

