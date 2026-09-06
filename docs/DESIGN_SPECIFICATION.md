# MoneyMateX Design Specification

**Stitch Project:** `MoneyMateX Splash Screen Design`  
**Stitch Resource Name:** `projects/3450659407615287589`  
**Design System Theme:** Aura Metric (Architectural Fintech / Minimalist AI Financial Platform)  
**Target Platform:** Mobile (iOS & Android) — Flutter / Dart

---

## 1. Project Overview

### 1.1 Product Name
**MoneyMateX** — Next-Generation AI-Driven Personal Finance & Net Worth Management Platform.

### 1.2 Purpose
MoneyMateX is a comprehensive personal finance ecosystem that combines automated expense tracking, smart budget planning, subscription management, emergency fund optimization, and deep AI-powered financial advisory (K2i AI Engine). The platform aims to provide clarity, calm control, and actionable financial health guidance without visual clutter.

### 1.3 Target Platform
- **Primary:** Mobile Applications (iOS and Android).
- **Design Resolution Baseline:** 390 × 844 dp viewport (rendered at 780 × 1768 px @2x high-density Retina scale).
- **Target Tech Stack:** Flutter (Dart), Riverpod (State Management), GoRouter (Declarative Routing), Dio (HTTP Client).

### 1.4 Design Source of Truth
The Stitch MCP project `MoneyMateX Splash Screen Design` (`projects/3450659407615287589`) is the **SINGLE SOURCE OF TRUTH** for all visual layouts, color tokens, typography, component hierarchies, and design spacing.

---

## 2. Complete Screen Inventory

The catalog contains **100 screens** representing all user flows, onboarding steps, dashboards, tools, AI assistants, and setting centers.

| # | Screen Name | Stitch Screen ID | Canvas Dimensions | Module | Suggested Flutter Route |
|---|---|---|---|---|---|
| 1 | MoneyMateX Splash Screen | `430bf5042514410ead8045a6c8f42019` | 780 × 1768 | Auth & Onboarding | `/splash` |
| 2 | MoneyMateX Onboarding Introduction | `2b72cbe1978c43188223ca9b3fe3e3bd` | 780 × 2112 | Auth & Onboarding | `/onboarding` |
| 3 | MoneyMateX Occupation Screen | `0ea6d6b84162412682f8b2d96948ecac` | 780 × 1768 | Auth & Onboarding | `/onboarding/occupation` |
| 4 | MoneyMateX Financial Priority Screen | `f57fbdc263134b53ae17e48e973fa84e` | 780 × 2814 | Auth & Onboarding | `/onboarding/priority` |
| 5 | MoneyMateX Monthly Income Screen | `372dbb84bf0047ddb9bbd53f15b9b73e` | 780 × 1768 | Auth & Onboarding | `/onboarding/income` |
| 6 | MoneyMateX Other Income Sources Screen | `1b366b7108964f2c973eb299baa59533` | 780 × 2224 | Auth & Onboarding | `/onboarding/income-sources` |
| 7 | MoneyMateX Monthly Expenses Screen | `e146669d9ce144de944d9bc407dbb24b` | 780 × 1842 | Auth & Onboarding | `/onboarding/expenses` |
| 8 | MoneyMateX Current Savings Screen | `180c0717889a45518e0e4325267762ce` | 780 × 1768 | Auth & Onboarding | `/onboarding/savings` |
| 9 | MoneyMateX Existing Debt / Loans Screen | `b24d6e6b926b4879a72e39d40b7266b6` | 780 × 2614 | Auth & Onboarding | `/onboarding/debts` |
| 10 | MoneyMateX Financial Goal Selection Screen | `d9ccb8b5b74b45958aa7d33d39b9b06b` | 780 × 1966 | Auth & Onboarding | `/onboarding/goal-selection` |
| 11 | MoneyMateX Goal Amount & Target Date Screen | `4500bf00d9d34b38ae1b895c6f3f031b` | 780 × 2212 | Auth & Onboarding | `/onboarding/goal-target` |
| 12 | MoneyMateX Login Screen | `29d2277949ac4bdfae8ad7ed96072c93` | 780 × 1768 | Auth & Onboarding | `/login` |
| 13 | MoneyMateX Sign Up Screen | `3e521ee7dfc642b3b81fc7dd64ef9b2a` | 780 × 1768 | Auth & Onboarding | `/signup` |
| 14 | MoneyMateX Forgot Password Screen | `94f5fa48271242a3b09a13f1d9ad4ed4` | 780 × 1768 | Auth & Onboarding | `/forgot-password` |
| 15 | MoneyMateX Reset Password Screen | `6834f5e77a5449449ce50287e6f6d1d8` | 780 × 1768 | Auth & Onboarding | `/reset-password` |
| 16 | MoneyMateX Main Financial Dashboard | `a3fdf44abc214993be7b3ff7c049ba8f` | 780 × 4946 | Dashboard & Overview | `/dashboard` |
| 17 | MoneyMateX Financial Command Center | `5e3c0ff7910847e6898bfa050d24d93e` | 780 × 2316 | Dashboard & Overview | `/dashboard/command-center` |
| 18 | MoneyMateX Net Worth Tracker (Compact) | `2a0e25a4b2204d4da8443620340eeeb8` | 832 × 1768 | Dashboard & Overview | `/dashboard/net-worth/compact` |
| 19 | MoneyMateX Net Worth Tracker (Detailed) | `501d98453a634c0a92d0eb85f03a5eb6` | 780 × 3292 | Dashboard & Overview | `/dashboard/net-worth` |
| 20 | MoneyMateX Income & Cash Flow Analysis | `b40e26ef5a404b92902eae7575d07d9b` | 780 × 3844 | Dashboard & Overview | `/dashboard/cash-flow` |
| 21 | MoneyMateX Detailed Spending Analysis | `140797d4b2d44b70b8cb995a53b53047` | 780 × 1768 | Dashboard & Overview | `/dashboard/spending-analysis` |
| 22 | MoneyMateX Financial Alerts Center | `891aa3c34ba14bb2b42f1f99d8a35686` | 780 × 3636 | Dashboard & Overview | `/dashboard/alerts` |
| 23 | MoneyMateX Transactions Screen | `bd0569afc65c4931b8cdb0bbe1abb907` | 780 × 2554 | Transactions & Accounts | `/transactions` |
| 24 | MoneyMateX Transaction Details Screen | `1c6466e3ad3b406cbee38fae4a622b4a` | 780 × 3504 | Transactions & Accounts | `/transactions/:id` |
| 25 | MoneyMateX Add Expense Screen | `4403a1a291be467993075f2d047b048a` | 780 × 2084 | Transactions & Accounts | `/transactions/add` |
| 26 | MoneyMateX Scan Receipt Screen (View A) | `ca85f8bb2c654498a70de0a6351736fc` | 780 × 1768 | Transactions & Accounts | `/transactions/scan` |
| 27 | MoneyMateX Scan Receipt Screen (View B) | `656215ccf46f4a0b99092d1521e4e504` | 780 × 3052 | Transactions & Accounts | `/transactions/scan-advanced` |
| 28 | MoneyMateX Receipt Scan Result Screen (View A) | `25a88ab65be140529a5a5d4a08416ddf` | 780 × 4396 | Transactions & Accounts | `/transactions/scan-result` |
| 29 | MoneyMateX Receipt Scan Result Screen (View B) | `bb2e30310535400ea3aacf9074338ea2` | 780 × 3080 | Transactions & Accounts | `/transactions/scan-result-summary` |
| 30 | MoneyMateX UPI Automatic Tracking Setup | `afce4e7c66354d1ea25218c049885689` | 780 × 3542 | Transactions & Accounts | `/accounts/upi-setup` |
| 31 | MoneyMateX Payment Methods Screen | `07cc6e59a89c43038737825c1643efaf` | 780 × 2180 | Transactions & Accounts | `/accounts/payment-methods` |
| 32 | MoneyMateX Wallets Overview (View A) | `bfdffc8425ed4c67b1fb170832e9d348` | 780 × 4462 | Transactions & Accounts | `/accounts/wallets` |
| 33 | MoneyMateX Wallets Overview (View B) | `49e278025d534b97b7ea4f28513d51c7` | 780 × 4030 | Transactions & Accounts | `/accounts/wallets-detailed` |
| 34 | MoneyMateX Add Wallet: Selection | `eb77d61880b1468ead4d89cb0ec159be` | 814 × 3144 | Transactions & Accounts | `/accounts/add-wallet` |
| 35 | MoneyMateX Add Wallet: Connect Bank | `f1ab89767f66421bb33626ad09b078dd` | 780 × 1862 | Transactions & Accounts | `/accounts/connect-bank` |
| 36 | MoneyMateX Saving Goals Overview (View A) | `5fd7790aed8846e4b2a843a2a2a01e71` | 780 × 1768 | Budgets & Goals | `/goals` |
| 37 | MoneyMateX Saving Goals Overview (View B) | `b5a5ed25efbb4daf88e3cce7882f67e4` | 780 × 4182 | Budgets & Goals | `/goals/detailed` |
| 38 | MoneyMateX Saving Goals Overview (View C) | `abfa5aa039594394a5a49eecc991f943` | 780 × 1768 | Budgets & Goals | `/goals/summary` |
| 39 | MoneyMateX Saving Goal Details: New Phone (View A) | `faa8362de6b341f4acc51fdc758d9123` | 780 × 5266 | Budgets & Goals | `/goals/:id` |
| 40 | MoneyMateX Saving Goal Details: New Phone (View B) | `4b66c7165ced4a69a0eb7f61431e014e` | 780 × 4548 | Budgets & Goals | `/goals/:id/analysis` |
| 41 | MoneyMateX Saving Goals Performance Analysis | `5c1f58707ce441d4b5f70c17cb4fdb69` | 780 × 1768 | Budgets & Goals | `/goals/performance` |
| 42 | MoneyMateX Goal Contribution Screen | `7fe7f213db67482e8bb3b3e765bc9637` | 780 × 2900 | Budgets & Goals | `/goals/contribute` |
| 43 | MoneyMateX Smart Goal Planner | `cc69b1a800344e968fd9b9b3522f1ad9` | 780 × 3260 | Budgets & Goals | `/goals/smart-planner` |
| 44 | MoneyMateX Emergency Fund Planner | `2f98b34527584508b179b1919618edd4` | 780 × 3734 | Budgets & Goals | `/goals/emergency-fund` |
| 45 | MoneyMateX Debt Management & Payoff Planner | `ece236af73cf4a25ac85ea30be1c817e` | 780 × 2954 | Budgets & Goals | `/goals/debt-payoff` |
| 46 | MoneyMateX Budget Performance Analysis | `f4857574177d404f91b4264a439859ae` | 780 × 2874 | Budgets & Goals | `/budgets/performance` |
| 47 | MoneyMateX Budget Details: Food & Dining | `0ef038f996c44c5dbd8d889d6eb9c1dd` | 880 × 4320 | Budgets & Goals | `/budgets/:category` |
| 48 | MoneyMateX Bills & Reminders Overview | `54ac90426fb44659a5bdbbbb568bc37e` | 780 × 3844 | Bills & Subscriptions | `/bills` |
| 49 | MoneyMateX Bills & Reminders Dashboard | `9fd1c821bb7741ffa143d533eb1597b2` | 780 × 3150 | Bills & Subscriptions | `/bills/dashboard` |
| 50 | MoneyMateX Bill Details: Electricity (View A) | `7577ae7baef34cdfa6075c0976f25c6d` | 780 × 4840 | Bills & Subscriptions | `/bills/:id` |
| 51 | MoneyMateX Bill Details: Electricity (View B) | `6c2d74ce1a444bd4a334fd430415f0ed` | 780 × 6126 | Bills & Subscriptions | `/bills/:id/full` |
| 52 | MoneyMateX Add Bill / Create Reminder | `78b51de5ce3b4df98a13bbae0f3906d5` | 780 × 4424 | Bills & Subscriptions | `/bills/add` |
| 53 | MoneyMateX Bill Payment Confirmation | `a5f01ddba9c14184b27ca22b2098feb4` | 780 × 2682 | Bills & Subscriptions | `/bills/confirmation` |
| 54 | MoneyMateX Recurring Payment Details: Netflix | `ea8e156aeee947a5bd035a99547fe750` | 780 × 3168 | Bills & Subscriptions | `/subscriptions/:id` |
| 55 | MoneyMateX K2i AI Assistant (View A) | `124a564290fe4a03b13db2feb7a9bb38` | 780 × 3078 | AI Intelligence Engine | `/ai-assistant` |
| 56 | MoneyMateX K2i AI Assistant (View B) | `f91f7b16770d4994a1444278e9c3a22d` | 780 × 2514 | AI Intelligence Engine | `/ai-assistant/compact` |
| 57 | MoneyMateX AI Advisor Home | `38b5afb665e84ac6b96888ed5d40bbfc` | 780 × 3084 | AI Intelligence Engine | `/ai-assistant/advisor` |
| 58 | MoneyMateX AI Advisor Chat | `697f99717f164fa882d53ed4ef537263` | 780 × 2826 | AI Intelligence Engine | `/ai-assistant/chat` |
| 59 | MoneyMateX AI Financial Health Score (View A) | `7847e73e28d244fbbb50f80fc6d2f078` | 780 × 3786 | AI Intelligence Engine | `/ai-assistant/health-score` |
| 60 | MoneyMateX AI Financial Health Score (View B) | `a3b6be15fa9c476286ddfd0a27537c92` | 780 × 1840 | AI Intelligence Engine | `/ai-assistant/health-score-summary` |
| 61 | MoneyMateX AI Financial Health Action Plan | `6767cb3ed87f415191d30e79af6a3acc` | 780 × 1768 | AI Intelligence Engine | `/ai-assistant/health-action-plan` |
| 62 | MoneyMateX AI Financial Action Plan | `71ff9933d1bb4e48817a265fa111b69e` | 780 × 4832 | AI Intelligence Engine | `/ai-assistant/action-plan` |
| 63 | MoneyMateX AI Financial Health Check | `56a45fe1d5f24734aebf6f65418fc504` | 780 × 2684 | AI Intelligence Engine | `/ai-assistant/health-check` |
| 64 | MoneyMateX AI Advisor Goal Planning | `e7ade8b9e52a4878abee80c39e339018` | 780 × 3134 | AI Intelligence Engine | `/ai-assistant/goal-planning` |
| 65 | MoneyMateX AI Financial Goal Planner (View A) | `bcf3e6f033e241f6906aff8844fd9659` | 780 × 5372 | AI Intelligence Engine | `/ai-assistant/goal-planner` |
| 66 | MoneyMateX AI Financial Goal Planner (View B) | `778a3d4b94e1499daaad318d000a67de` | 780 × 5502 | AI Intelligence Engine | `/ai-assistant/goal-planner-extended` |
| 67 | MoneyMateX AI Goal Planner | `49b960aa0e6a4334b4f41ce03b06b000` | 864 × 1768 | AI Intelligence Engine | `/ai-assistant/goal-planner-simple` |
| 68 | MoneyMateX AI Goal Progress Tracker | `c56e164c88f8427fa300993e0c788018` | 780 × 5306 | AI Intelligence Engine | `/ai-assistant/goal-progress` |
| 69 | MoneyMateX AI Goal Optimizer | `17a8737eb6834b79bd9ec9fe05c01d7b` | 780 × 5100 | AI Intelligence Engine | `/ai-assistant/goal-optimizer` |
| 70 | MoneyMateX AI Goal Recovery Planner | `52d578e5d0214389a35deaafc0fe0aa9` | 780 × 2844 | AI Intelligence Engine | `/ai-assistant/goal-recovery` |
| 71 | MoneyMateX AI Savings Optimizer | `dd2c9a68be2a4608ab99c3a32f7e2e29` | 780 × 2314 | AI Intelligence Engine | `/ai-assistant/savings-optimizer` |
| 72 | MoneyMateX AI Spending Coach | `f477166b87a840e4affca69f3712c357` | 780 × 1822 | AI Intelligence Engine | `/ai-assistant/spending-coach` |
| 73 | MoneyMateX AI Spending Control Center | `a626a949a4b24c5d9bd00b784a95815f` | 780 × 2434 | AI Intelligence Engine | `/ai-assistant/spending-control` |
| 74 | MoneyMateX AI Budget Optimizer | `e1a96b8d3caa401cb47b4bf023e3ec20` | 780 × 3646 | AI Intelligence Engine | `/ai-assistant/budget-optimizer` |
| 75 | MoneyMateX AI Cash Flow Predictor | `9495441aad124983be27c9982864ba3e` | 780 × 4520 | AI Intelligence Engine | `/ai-assistant/cash-flow-predictor` |
| 76 | MoneyMateX AI Cash Flow Forecast | `1629ee1608ae4ea79642bcdcdb8baea3` | 780 × 5670 | AI Intelligence Engine | `/ai-assistant/cash-flow-forecast` |
| 77 | MoneyMateX AI Expense Predictor | `e9301a07c5c74e7489b94c3a8536944a` | 818 × 1984 | AI Intelligence Engine | `/ai-assistant/expense-predictor` |
| 78 | MoneyMateX AI Subscription Manager (View A) | `42d8ceefd5ec42f2b99096dc929aa0b7` | 780 × 2110 | AI Intelligence Engine | `/ai-assistant/subscription-manager` |
| 79 | MoneyMateX AI Subscription Manager (View B) | `3a757c34c7874f819de63f46e77dcb35` | 780 × 3982 | AI Intelligence Engine | `/ai-assistant/subscription-manager-detailed` |
| 80 | MoneyMateX AI Bill & Subscription Manager | `04c179bbd3ad4f82a05b36fb7449e835` | 780 × 1768 | AI Intelligence Engine | `/ai-assistant/bill-subscription-manager` |
| 81 | MoneyMateX AI Bill & Renewal Optimizer | `79da268687d14d66b0c6c01d22b98922` | 780 × 4210 | AI Intelligence Engine | `/ai-assistant/bill-renewal-optimizer` |
| 82 | MoneyMateX AI Bill & Payment Optimizer | `24d8121bbeac4fcc8efa58ef25b9d2d9` | 780 × 1768 | AI Intelligence Engine | `/ai-assistant/bill-payment-optimizer` |
| 83 | MoneyMateX AI Financial Insights | `421a0abea4d44948a310b0047e134abd` | 780 × 4018 | AI Intelligence Engine | `/ai-assistant/financial-insights` |
| 84 | MoneyMateX AI Financial Planning | `84213091b9ce48ea8fcdd77de2412e87` | 780 × 2934 | AI Intelligence Engine | `/ai-assistant/financial-planning` |
| 85 | MoneyMateX AI Monthly Financial Review | `e84e9dbd20b3452a92d4e92be951219e` | 780 × 1986 | AI Intelligence Engine | `/ai-assistant/monthly-review` |
| 86 | MoneyMateX Personalized Financial Plan Screen | `854a68b4e5724832b75dbfc854f81f4d` | 780 × 2714 | AI Intelligence Engine | `/ai-assistant/personalized-plan` |
| 87 | MoneyMateX Personalized Financial Recommendations | `631f79436c474521b9ba1c4f2e5b11a6` | 780 × 2292 | AI Intelligence Engine | `/ai-assistant/recommendations` |
| 88 | MoneyMateX Reports & Analytics Overview (View A) | `51dbf8bbf1e94044870b74ddab643c3e` | 780 × 6290 | Reports, Settings & Meta | `/reports` |
| 89 | MoneyMateX Reports & Analytics Overview (View B) | `9d3f0e403fd143a2aeec71424b62e4b9` | 780 × 5928 | Reports, Settings & Meta | `/reports/detailed` |
| 90 | MoneyMateX Reports & Analytics Overview (View C) | `1fab2b80e6e94b4ea1f5bcd5256f0e63` | 780 × 4918 | Reports, Settings & Meta | `/reports/summary` |
| 91 | MoneyMateX Reports & Analytics Overview (View D) | `56e18511ad71466fbbf9f45ebe360275` | 780 × 1768 | Reports, Settings & Meta | `/reports/compact` |
| 92 | MoneyMateX Reports & Analytics (Animated) | `77c5652b5e61414aba3619eaaff09aa5` | 780 × 3340 | Reports, Settings & Meta | `/reports/animated` |
| 93 | MoneyMateX Financial Report Generator | `f1effb78ed3d4b1385891d693c1de3e4` | 780 × 3390 | Reports, Settings & Meta | `/reports/generator` |
| 94 | MoneyMateX Settings Screen | `5274b8189d4b4ef4b699011cda4bea28` | 780 × 1838 | Reports, Settings & Meta | `/settings` |
| 95 | MoneyMateX Privacy & Data Center | `f8222a17e970411b94b75302fa4c577f` | 780 × 2646 | Reports, Settings & Meta | `/settings/privacy` |
| 96 | MoneyMateX Help & Support Center | `41a889412a294624aee8bfc4e3322eda` | 780 × 6054 | Reports, Settings & Meta | `/settings/help` |
| 97 | MoneyMateX Help & Support Screen | `ab44ab38d7674271a17cdc444b8bfe29` | 780 × 4552 | Reports, Settings & Meta | `/settings/support` |
| 98 | MoneyMateX About & Legal Center | `727ca22f4f224586be25d67d2510447a` | 780 × 2412 | Reports, Settings & Meta | `/settings/about` |
| 99 | MoneyMateX Logo | `f62efec0ca1f41908bf158184dd9672f` | 1024 × 1024 | Brand Asset | Asset Node |
| 100 | MoneyMateX Project Brief | `0f1bbbe0bacc4ac38e704fa49482d456` | 0 × 0 | Documentation | Brief Node |

---

## 3. Module Structure

The application is structured into 7 core functional modules:

### Module 1: Authentication & Financial Setup Survey (15 Screens)
- Handlers for splash screen, onboarding slides, financial profile setup (occupation, income sources, existing debts, goal targets), user registration, authentication, and password recovery.

### Module 2: Dashboard & Net Worth Center (7 Screens)
- Core app homepage presenting total net worth, real-time command center metrics, cash flow breakdowns, spending analysis, and urgent financial alerts.

### Module 3: Transactions, Accounts & Wallets (13 Screens)
- Multi-account management (bank accounts, UPI setup, digital wallets), transaction lists, transaction details, manual expense addition, receipt OCR camera scanner, and OCR result verification.

### Module 4: Budgets & Savings Goal Planners (12 Screens)
- Goal tracking for specific targets (e.g., New Phone, Emergency Fund, Debt Payoff), progress contributions, category budget allocation (Food & Dining), and performance breakdown charts.

### Module 5: Bills, Subscriptions & Reminders (7 Screens)
- Tracking for recurring bills (Electricity, Internet) and digital subscriptions (Netflix), bill creation, payment confirmation, and renewal optimization.

### Module 6: AI Intelligence Engine & K2i Assistant (33 Screens)
- Conversational financial advisor (K2i AI Chat), AI Financial Health Score, automated action plan generator, spending coach, cash flow predictor, subscription optimizer, and personalized recommendations.

### Module 7: Reports, Settings & Meta (13 Screens)
- PDF/CSV report generator, animated analytics overviews, privacy & data vault settings, help center, legal agreements, and app metadata.

---

## 4. Navigation Map

```
Splash Screen (/splash)
  │
  ├──► Onboarding Intro (/onboarding)
  │     │
  │     ├──► Financial Survey Steps (/onboarding/occupation -> /priority -> /income -> /expenses -> /savings -> /debts -> /goal-selection)
  │     │     │
  │     │     └──► Auth Choice Screen (/login or /signup)
  │     │
  │     └──► Main Application Shell (Stateful Shell Route with Bottom Nav)
  │
  └──► Main Application Shell (If already authenticated)
        │
        ├── Tab 1: Dashboard & Net Worth (/dashboard)
        │     ├── Command Center (/dashboard/command-center)
        │     ├── Net Worth Details (/dashboard/net-worth)
        │     ├── Cash Flow Analysis (/dashboard/cash-flow)
        │     └── Alerts Center (/dashboard/alerts)
        │
        ├── Tab 2: Transactions & Wallets (/transactions)
        │     ├── Add Expense Form (/transactions/add)
        │     ├── Camera Receipt Scanner (/transactions/scan -> /scan-result)
        │     ├── Transaction Detail Sheet (/transactions/:id)
        │     ├── Wallets Overview (/accounts/wallets)
        │     └── Bank & UPI Setup (/accounts/connect-bank & /upi-setup)
        │
        ├── Tab 3: Budgets & Goals (/goals)
        │     ├── Goal Detail View (/goals/:id)
        │     ├── Goal Contribution Modal (/goals/contribute)
        │     ├── Smart Goal / Emergency Planner (/goals/smart-planner & /emergency-fund)
        │     ├── Debt Payoff Planner (/goals/debt-payoff)
        │     └── Category Budget Details (/budgets/:category)
        │
        ├── Tab 4: Bills & Subscriptions (/bills)
        │     ├── Bill Details (/bills/:id)
        │     ├── Add Bill Reminder (/bills/add)
        │     ├── Payment Confirmation (/bills/confirmation)
        │     └── Subscription Details (/subscriptions/:id)
        │
        └── Tab 5: K2i AI Assistant Hub (/ai-assistant)
              ├── AI Chat Session (/ai-assistant/chat)
              ├── AI Health Score & Action Plan (/ai-assistant/health-score & /action-plan)
              ├── AI Cash Flow Forecast (/ai-assistant/cash-flow-forecast)
              ├── AI Spending Coach (/ai-assistant/spending-coach)
              └── AI Subscription & Renewal Manager (/ai-assistant/subscription-manager)
```

> [!NOTE]
> **Navigation Unclarities:**  
> Screen #87 (`Personalized Financial Recommendations`) and Screen #92 (`Reports & Analytics Animated`) are standalone visual variants. Deep links from push notifications to specific AI action items should fall back to stack navigation pushing on top of the active shell route tab.

---

## 5. Design System

### 5.1 Color Tokens (Aura Metric Palette)

```yaml
Colors:
  Primary: '#4f378a'             # Deep Purple Navy (Main CTAs, Brand Headers)
  PrimaryContainer: '#6750a4'    # Medium Purple Accent (Selected state fills)
  PrimaryFixed: '#e9ddff'        # Soft Violet Tint
  OnPrimary: '#ffffff'           # Text on Primary Button
  OnPrimaryContainer: '#e0d2ff'   # Text on Primary Container

  Secondary: '#63597c'           # Muted Slate Purple (Subtitles, metadata)
  SecondaryContainer: '#e1d4fd'  # Light Slate Tint
  OnSecondary: '#ffffff'

  Tertiary: '#765b00'            # Financial Amber/Gold (Growth, targets, rewards)
  TertiaryContainer: '#c9a74d'   # Accent Gold Container
  TertiaryFixed: '#ffdf93'       # Soft Gold Highlight

  Background: '#fdf7ff'          # Clean Canvas Background
  OnBackground: '#1d1b20'        # Main Body Text
  
  Surface: '#fdf7ff'             # Main View Surface
  SurfaceContainerLowest: '#ffffff' # Pure White Container Fills
  SurfaceContainerLow: '#f8f2fa'    # Off-White Card Fills
  SurfaceContainer: '#f2ecf4'       # Input Fills & Secondary Cards
  SurfaceContainerHigh: '#ece6ee'   # Divider Layers
  SurfaceContainerHighest: '#e6e0e9'# Card Borders

  Outline: '#7a7582'             # Structural Borders & Active Inputs
  OutlineVariant: '#cbc4d2'      # Light Card & List Separator Borders

  Error: '#ba1a1a'               # Debt Warning, Over-Budget Status
  ErrorContainer: '#ffdad6'      # Warning Banner Fills
  OnError: '#ffffff'
```

### 5.2 Typography System

The typography strictly uses **Hanken Grotesk** for headings, subtitles, and standard body text, and **Geist** for technical data, monetary figures, timestamps, percentages, and table labels.

```yaml
Typography:
  display:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: 700 (Bold)
    lineHeight: 1.1
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: 600 (SemiBold)
    lineHeight: 1.2
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: 600 (SemiBold)
    lineHeight: 1.2
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: 600 (SemiBold)
    lineHeight: 1.4
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: 400 (Regular)
    lineHeight: 1.6
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: 400 (Regular)
    lineHeight: 1.6
  label-sm:
    fontFamily: Geist # Technical Monospace Data
    fontSize: 13px
    fontWeight: 500 (Medium)
    lineHeight: 1.2
    letterSpacing: 0.02em
  tagline:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: 300 (Light)
    lineHeight: 1.4
    letterSpacing: 0.05em
```

### 5.3 Shape & Elevation Tokens
- **Elevation Strategy:** Flat Tonal Minimalism. 0px drop shadow across standard elements. Depth is established purely via 1px solid outlines (`#cbc4d2`) and background color contrasts (`#ffffff` vs `#f8f2fa`).
- **Corner Radii:**
  - Standard Inputs & Cards: `4dp` (`0.25rem`)
  - Medium Containers: `6dp` (`0.375rem`)
  - Large Dialog Modals: `8dp` (`0.50rem`)
  - Pill Badges & Chips: `9999dp` (Full Rounding)

### 5.4 Spacing & Padding
- Base Grid Unit: `4dp`
- Stack Small: `8dp`
- Stack Medium: `16dp`
- Stack Large: `32dp`
- Mobile Screen Side Margin: `16dp`
- Card Internal Padding: `24dp`

---

## 6. Reusable Components List

| Component Name | Locations of Appearance | Visual & Functional Specification |
|---|---|---|
| `MMAppBar` | All top level & detail screens | Top bar with back button / title / action bell |
| `MMBottomNavBar` | Main Shell Routes (5 tabs) | 5 item bar with 1.5px stroke icons & purple active tint |
| `MMPrimaryButton` | Forms, Onboarding, CTAs | 48dp height, #4f378a fill, white Hanken Grotesk text |
| `MMOutlinedButton` | Secondary actions | 48dp height, 1px #4f378a border, purple text |
| `MMCard` | Dashboard, Budgets, Goals | White or off-white box with 1px #cbc4d2 outline, 0 shadow |
| `MMTextField` | Onboarding, Add Expense | 48dp height, #f8f2fa fill, 1px border, Geist 13px label above |
| `MMCategoryChip` | Filter bars, transaction lists | Pill-shaped badge with light container fill |
| `MMProgressBar` | Budgets, Savings goals | Thin linear bar with Teal/Purple progress indicator |
| `MMMetricTile` | Net worth, Cash flow | Large Geist number with subtitle and trend pill |
| `MMTransactionRow` | Transactions, Dashboard | Category icon, title, subtitle, Geist currency amount |
| `MMAIChatBubble` | K2i AI Chat screen | User right bubble vs AI left response card with sparkle badge |
| `MMAIInsightCard` | AI Advisor, Forecasts | Purple tinted container with sparkle header & action button |
| `MMBottomSheet` | Filters, Category selector | Drag handle, 16dp top radius, full-width content |
| `MMLoadingState` | Data loading views | Minimal linear progress or skeleton shimmer card |
| `MMEmptyState` | No transactions / goals | Center aligned icon, muted title, primary action button |

---

## 7. Assets Management

### 7.1 Brand Assets & Logos
- **MoneyMateX App Logo:** `MoneyMateX Logo` node (`projects/3450659407615287589/screens/f62efec0ca1f41908bf158184dd9672f`) — Needs high-resolution PNG & SVG export.

### 7.2 Integration Partner & Category Logos
- **Bank Provider Logos:** HDFC Bank, ICICI Bank, SBI, Axis Bank, UPI logo.
- **Subscription Logos:** Netflix, Spotify, Amazon Prime, Apple Music, Electricity Utility Provider.
- **Category Vectors:** Food & Dining, Groceries, Shopping, Transportation, Rent, Salary, Investments.

### 7.3 Iconography Strategy
- **Icon Set:** Outline stroke icons (1.5px to 2.0px stroke width) using **Lucide Icons** or **Material Symbols (Outlined)** in Flutter.

---

## 8. Flutter Architecture Recommendations

The target Flutter application will be built using **Feature-First Clean Architecture**:

- **Flutter & Dart:** Minimum Dart 3.x, Flutter 3.x.
- **Riverpod (flutter_riverpod & riverpod_annotation):** Declarative state management, caching, async value handling for API responses.
- **GoRouter:** Type-safe declarative routing with StatefulShellRoute to preserve bottom navigation tab state across navigation.
- **Dio:** HTTP client configured with logging interceptors, authorization bearer headers, and central error handling.

---

## 9. Feature Module Division

```
lib/
├── app/
│   ├── app.dart
│   └── config/
├── core/
│   ├── constants/
│   ├── network/
│   ├── router/
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth_onboarding/
    ├── dashboard/
    ├── transactions/
    ├── budgets_savings/
    ├── bills_subscriptions/
    ├── ai_assistant/
    └── settings_support/
```

---

## 10. Design-to-Code Rules

1. **Stitch is the visual source of truth.**
2. **Do not redesign the UI.**
3. **Do not randomly change colors.**
4. **Do not randomly change typography.**
5. **Do not duplicate reusable components.**
6. **Prefer reusable Flutter widgets.**
7. **Preserve the visual hierarchy of the Stitch designs.**
8. **Preserve spacing and dimensions as closely as practical.**
9. **Do not invent missing UI behavior.**
10. **When behavior is unclear, mark it as requiring clarification.**

---

## 11. Implementation Strategy

To systematically implement all 100 screens, execution should follow 6 logical phases:

1. **Phase 1: Core Foundation & Design System (Sprint 1)**
   - Setup `AppTheme`, `AppColors`, `AppTypography` (Hanken Grotesk + Geist), core `MMWidgets`.
2. **Phase 2: Auth & Onboarding Module (Sprint 2)**
   - Implement Screens #1–#15.
3. **Phase 3: Core Shell & Main Dashboard (Sprint 3)**
   - Implement StatefulShellRoute and Screens #16–#22.
4. **Phase 4: Transactions & Accounts Module (Sprint 4)**
   - Implement Screens #23–#35.
5. **Phase 5: Budgets, Goals, Bills & Subscriptions (Sprint 5)**
   - Implement Screens #36–#54.
6. **Phase 6: K2i AI Engine & Analytics Reports (Sprint 6)**
   - Implement Screens #55–#100.

---

## 12. Uncertainties & Required Clarifications

1. **Camera Scanner Integration:** Screen #26 (`Scan Receipt Screen`) requires integration with a native mobile OCR camera scanner or Google ML Kit.
2. **Bank Sync API Provider:** Screen #30 (`UPI Automatic Tracking`) and Screen #35 (`Connect Bank`) rely on external financial aggregator APIs (e.g., Plaid / Setu / Account Aggregator framework). Mock fallbacks should be defined.
3. **K2i AI Engine Integration:** Screens #55–#87 require backend integration with an LLM service (e.g., Gemini API via Dio) for generating financial health action plans and natural language chat advice.

---
