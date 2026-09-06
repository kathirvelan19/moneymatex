const {
  getWallets,
  getTransactions,
  getGoals,
  getBills,
  getProfile
} = require('../db');

class FinancialContextService {
  static async getCurrentBalance(userId) {
    const wallets = await getWallets(userId);
    return wallets.reduce((sum, w) => sum + Number(w.balance), 0.0);
  }

  static async getMonthlyIncome(userId) {
    const transactions = await getTransactions(userId);
    const incomeTx = transactions.filter(t => !t.is_expense);
    const loggedIncome = incomeTx.reduce((sum, t) => sum + Number(t.amount), 0.0);
    if (loggedIncome > 0) return loggedIncome;

    const profile = await getProfile(userId);
    return profile && profile.monthly_income ? Number(profile.monthly_income) : 0.0;
  }

  static async getMonthlyExpenses(userId) {
    const transactions = await getTransactions(userId);
    const expenseTx = transactions.filter(t => t.is_expense);
    return expenseTx.reduce((sum, t) => sum + Number(t.amount), 0.0);
  }

  static async getNetCashFlow(userId) {
    const income = await this.getMonthlyIncome(userId);
    const expenses = await this.getMonthlyExpenses(userId);
    return income - expenses;
  }

  static async getSavingsRate(userId) {
    const income = await this.getMonthlyIncome(userId);
    const net = await this.getNetCashFlow(userId);
    if (income <= 0) return 0.0;
    return Math.min(Math.max((net / income) * 100, 0.0), 100.0);
  }

  static async getCategorySpending(userId, categoryFilter = null) {
    const transactions = await getTransactions(userId);
    const expenseTx = transactions.filter(t => t.is_expense);
    const map = {};
    expenseTx.forEach(t => {
      if (!categoryFilter || t.category.toLowerCase() === categoryFilter.toLowerCase()) {
        map[t.category] = (map[t.category] || 0.0) + Number(t.amount);
      }
    });
    return map;
  }

  static async getBudgetStatus(userId) {
    const expenses = await this.getMonthlyExpenses(userId);
    const profile = await getProfile(userId);
    const targetBudget = profile && profile.monthly_expenses_estimate > 0
      ? Number(profile.monthly_expenses_estimate)
      : 50000.0;
    const usage = targetBudget > 0 ? (expenses / targetBudget) * 100 : 0.0;
    return { targetBudget, expenses, usagePercentage: Math.min(usage, 200.0) };
  }

  static async getGoalProgress(userId, goalId = null) {
    const goals = await getGoals(userId);
    const filtered = goalId ? goals.filter(g => g.id === goalId) : goals;
    return filtered.map(g => ({
      id: g.id,
      name: g.name,
      targetAmount: Number(g.target_amount),
      savedAmount: Number(g.saved_amount),
      targetDate: g.target_date,
      category: g.category,
      percentage: g.target_amount > 0 ? Math.min((g.saved_amount / g.target_amount) * 100, 100.0) : 0.0
    }));
  }

  static async getUpcomingBills(userId) {
    const bills = await getBills(userId);
    return bills
      .filter(b => b.status !== 'Paid')
      .map(b => ({
        id: b.id,
        name: b.name,
        category: b.category,
        amount: Number(b.amount),
        dueDate: b.due_date,
        status: b.status
      }));
  }

  static async getFinancialHealth(userId) {
    const savingsRate = await this.getSavingsRate(userId);
    const budget = await this.getBudgetStatus(userId);
    const goals = await this.getGoalProgress(userId);

    const totalTarget = goals.reduce((s, g) => s + g.targetAmount, 0);
    const totalSaved = goals.reduce((s, g) => s + g.savedAmount, 0);
    const goalPct = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

    const savingsScore = Math.min((savingsRate / 100) * 40, 40);
    const budgetRatio = budget.expenses / (budget.targetBudget || 1);
    const budgetScore = Math.min(Math.max((1.0 - Math.min(budgetRatio, 1.0)) * 30, 0), 30);
    const goalScore = Math.min((goalPct / 100) * 30, 30);

    const healthScore = Math.round(savingsScore + budgetScore + goalScore);
    return Math.min(Math.max(healthScore, 0), 100);
  }

  static async getWeeklySummary(userId) {
    const income = await this.getMonthlyIncome(userId);
    const expenses = await this.getMonthlyExpenses(userId);
    const net = income - expenses;
    const rate = await this.getSavingsRate(userId);
    return `Weekly Summary: Income ₹${income.toFixed(0)}, Expenses ₹${expenses.toFixed(0)}, Net Cash Flow ₹${net.toFixed(0)}, Savings Rate ${rate.toFixed(1)}%.`;
  }

  static async getRecentTransactions(userId, limit = 10) {
    const transactions = await getTransactions(userId);
    return transactions.slice(0, limit).map(t => ({
      id: t.id,
      title: t.title,
      category: t.category,
      amount: Number(t.amount),
      isExpense: Boolean(t.is_expense),
      date: t.date
    }));
  }

  static async buildUserFinancialContext(userId, questionPrompt = '') {
    const balance = await this.getCurrentBalance(userId);
    const income = await this.getMonthlyIncome(userId);
    const expenses = await this.getMonthlyExpenses(userId);
    const netCashFlow = income - expenses;
    const savingsRate = await this.getSavingsRate(userId);
    const categoryExpenses = await this.getCategorySpending(userId);
    const budget = await this.getBudgetStatus(userId);
    const goals = await this.getGoalProgress(userId);
    const bills = await this.getUpcomingBills(userId);
    const healthScore = await this.getFinancialHealth(userId);
    const recentTx = await this.getRecentTransactions(userId, 5);
    const wallets = await getWallets(userId);

    const hasData = (wallets.length > 0) || (recentTx.length > 0) || (goals.length > 0) || (income > 0);

    return {
      userId,
      hasData,
      walletCount: wallets.length,
      currentBalance: balance,
      monthlyIncome: income,
      monthlyExpenses: expenses,
      netCashFlow: netCashFlow,
      savingsRate: savingsRate,
      healthScore: healthScore,
      targetBudget: budget.targetBudget,
      budgetUsagePercentage: budget.usagePercentage,
      categorySpending: categoryExpenses,
      goals: goals,
      upcomingBills: bills,
      recentTransactions: recentTx
    };
  }
}

module.exports = FinancialContextService;
