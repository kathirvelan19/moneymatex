require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const {
  initDb,
  getUserById,
  getUserByEmail,
  createUser,
  getProfile,
  upsertProfile,
  getTransactions,
  createTransaction,
  deleteTransaction,
  getWallets,
  createWallet,
  updateWalletBalance,
  deleteWallet,
  getGoals,
  getGoalContributions,
  createGoal,
  addGoalContribution,
  deleteGoal,
  getBills,
  createBill,
  deleteBill
} = require('./db');
const { authenticateToken, JWT_SECRET } = require('./middleware/auth');
const FinancialContextService = require('./services/financial_context_service');
const AIService = require('./services/ai_service');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

initDb().then(() => {
  console.log('Database initialized successfully.');
}).catch((err) => {
  console.error('Failed to initialize database:', err);
});

// ==========================================
// AUTHENTICATION ENDPOINTS
// ==========================================

app.post('/api/v1/auth/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Name, email, and password are required.' });
    }

    const existingUser = await getUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'User with this email already exists.' });
    }

    const userId = 'usr_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7);
    const passwordHash = await bcrypt.hash(password, 10);
    const createdAt = new Date().toISOString();

    const newUser = { id: userId, email: email.toLowerCase(), password_hash: passwordHash, name, created_at: createdAt };
    await createUser(newUser);

    await upsertProfile({ user_id: userId, occupation: 'Professional', financial_priority: 'Manage Expenses' });

    const token = jwt.sign({ userId, email: email.toLowerCase() }, JWT_SECRET, { expiresIn: '7d' });
    return res.status(201).json({ token, user: { id: userId, email: email.toLowerCase(), name } });
  } catch (err) {
    console.error('Signup error:', err);
    return res.status(500).json({ error: 'Internal server error during signup.' });
  }
});

app.post('/api/v1/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const user = await getUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    return res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ error: 'Internal server error during login.' });
  }
});

app.get('/api/v1/auth/me', authenticateToken, async (req, res) => {
  try {
    const user = await getUserById(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found.' });
    return res.json({ user: { id: user.id, email: user.email, name: user.name, created_at: user.created_at } });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch current user session.' });
  }
});

// Password reset memory storage
const passwordResets = new Map();

app.post('/api/v1/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || !email.trim()) {
      return res.status(400).json({ error: 'Email address is required.' });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 mins

    passwordResets.set(email.toLowerCase().trim(), { code, expiresAt, verified: false });
    console.log(`[MONEYMATEX SECURITY] Password Reset OTP generated for ${email}: [${code}]`);

    return res.json({ success: true, message: 'Verification code sent to your email.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to process forgot password request.' });
  }
});

app.post('/api/v1/auth/verify-reset-code', async (req, res) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) {
      return res.status(400).json({ error: 'Email and verification code are required.' });
    }

    const record = passwordResets.get(email.toLowerCase().trim());
    if (!record) {
      return res.status(400).json({ error: 'Incorrect verification code. Please try again.' });
    }

    if (Date.now() > record.expiresAt) {
      passwordResets.delete(email.toLowerCase().trim());
      return res.status(400).json({ error: 'This code has expired. Request a new code.' });
    }

    if (record.code !== code.trim()) {
      return res.status(400).json({ error: 'Incorrect verification code. Please try again.' });
    }

    const resetToken = 'rst_' + Date.now() + '_' + Math.random().toString(36).substring(2, 8);
    record.verified = true;
    record.resetToken = resetToken;

    return res.json({ success: true, message: 'Code verified successfully.', resetToken });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to verify reset code.' });
  }
});

app.post('/api/v1/auth/reset-password', async (req, res) => {
  try {
    const { email, resetToken, newPassword } = req.body;
    if (!email || !resetToken || !newPassword) {
      return res.status(400).json({ error: 'Email, reset token, and new password are required.' });
    }

    const record = passwordResets.get(email.toLowerCase().trim());
    if (!record || !record.verified || record.resetToken !== resetToken) {
      return res.status(400).json({ error: 'Invalid or expired password reset session. Please request a new code.' });
    }

    const user = await getUserByEmail(email);
    if (user) {
      user.password_hash = await bcrypt.hash(newPassword, 10);
    }

    passwordResets.delete(email.toLowerCase().trim());
    return res.json({ success: true, message: 'Password updated successfully. You can now log in with your new password.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to reset password.' });
  }
});

// ==========================================
// TRANSACTIONS ENDPOINTS (USER ISOLATED)
// ==========================================

app.get('/api/v1/transactions', authenticateToken, async (req, res) => {
  try {
    const rows = await getTransactions(req.userId);
    const transactions = rows.map(r => ({
      id: r.id,
      title: r.title,
      category: r.category,
      amount: Number(r.amount),
      isExpense: Boolean(r.is_expense),
      date: r.date,
      paymentMethod: r.payment_method,
      walletId: r.wallet_id || '',
      notes: r.notes || ''
    }));
    return res.json(transactions);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch transactions.' });
  }
});

app.post('/api/v1/transactions', authenticateToken, async (req, res) => {
  try {
    const { id, title, category, amount, isExpense, date, paymentMethod, walletId, notes } = req.body;
    const txId = id || 'tx_' + Date.now();
    const createdAt = new Date().toISOString();

    const txItem = {
      id: txId,
      user_id: req.userId,
      title,
      category,
      amount: Number(amount),
      is_expense: isExpense ? 1 : 0,
      date,
      payment_method: paymentMethod || 'Wallet',
      wallet_id: walletId || '',
      notes: notes || '',
      created_at: createdAt
    };

    await createTransaction(txItem);

    if (walletId) {
      const delta = isExpense ? -Number(amount) : Number(amount);
      await updateWalletBalance(walletId, req.userId, delta);
    }

    return res.status(201).json({
      id: txId, title, category, amount: Number(amount), isExpense: Boolean(isExpense), date, paymentMethod, walletId, notes
    });
  } catch (err) {
    console.error('Create transaction error:', err);
    return res.status(500).json({ error: 'Failed to create transaction.' });
  }
});

app.delete('/api/v1/transactions/:id', authenticateToken, async (req, res) => {
  try {
    const success = await deleteTransaction(req.params.id, req.userId);
    if (!success) return res.status(404).json({ error: 'Transaction not found.' });
    return res.json({ success: true, message: 'Transaction deleted.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to delete transaction.' });
  }
});

// ==========================================
// WALLETS ENDPOINTS (USER ISOLATED)
// ==========================================

app.get('/api/v1/wallets', authenticateToken, async (req, res) => {
  try {
    const rows = await getWallets(req.userId);
    const wallets = rows.map(w => ({
      id: w.id,
      name: w.name,
      type: w.type,
      provider: w.provider,
      balance: Number(w.balance),
      createdAt: w.created_at,
      trackingMethod: w.tracking_method,
      isPrimary: Boolean(w.is_primary)
    }));
    return res.json(wallets);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch wallets.' });
  }
});

app.post('/api/v1/wallets', authenticateToken, async (req, res) => {
  try {
    const { id, name, type, provider, balance, isPrimary, trackingMethod } = req.body;
    const walletId = id || 'wlt_' + Date.now();
    const createdAt = new Date().toISOString();

    const newWallet = {
      id: walletId,
      user_id: req.userId,
      name,
      type,
      provider,
      balance: Number(balance || 0),
      is_primary: isPrimary ? 1 : 0,
      tracking_method: trackingMethod || 'Manual',
      created_at: createdAt
    };

    await createWallet(newWallet);

    return res.status(201).json({
      id: walletId, name, type, provider, balance: Number(balance || 0), isPrimary: Boolean(isPrimary), trackingMethod, createdAt
    });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to create wallet.' });
  }
});

app.delete('/api/v1/wallets/:id', authenticateToken, async (req, res) => {
  try {
    await deleteWallet(req.params.id, req.userId);
    return res.json({ success: true, message: 'Wallet deleted.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to delete wallet.' });
  }
});

// ==========================================
// GOALS ENDPOINTS (USER ISOLATED)
// ==========================================

app.get('/api/v1/goals', authenticateToken, async (req, res) => {
  try {
    const rows = await getGoals(req.userId);
    const goals = await Promise.all(rows.map(async g => {
      const contribs = await getGoalContributions(g.id, req.userId);
      return {
        id: g.id,
        name: g.name,
        targetAmount: Number(g.target_amount),
        savedAmount: Number(g.saved_amount),
        targetDate: g.target_date,
        category: g.category,
        priority: g.priority,
        createdAt: g.created_at,
        updatedAt: g.updated_at,
        status: g.status,
        notes: g.notes || '',
        contributions: contribs.map(c => ({
          id: c.id, goalId: c.goal_id, amount: Number(c.amount), date: c.date, note: c.note || ''
        }))
      };
    }));
    return res.json(goals);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch goals.' });
  }
});

app.post('/api/v1/goals', authenticateToken, async (req, res) => {
  try {
    const { id, name, targetAmount, savedAmount, targetDate, category, priority, notes } = req.body;
    const goalId = id || 'gl_' + Date.now();
    const now = new Date().toISOString();

    const newGoal = {
      id: goalId,
      user_id: req.userId,
      name,
      target_amount: Number(targetAmount),
      saved_amount: Number(savedAmount || 0),
      target_date: targetDate,
      category,
      priority: priority || 'Medium',
      status: 'In Progress',
      notes: notes || '',
      created_at: now,
      updated_at: now
    };

    await createGoal(newGoal);

    return res.status(201).json({
      id: goalId, name, targetAmount: Number(targetAmount), savedAmount: Number(savedAmount || 0), targetDate, category, priority, status: 'In Progress', notes, createdAt: now, updatedAt: now, contributions: []
    });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to create goal.' });
  }
});

app.post('/api/v1/goals/:id/contributions', authenticateToken, async (req, res) => {
  try {
    const { amount, note } = req.body;
    const now = new Date().toISOString();
    const contribId = 'gc_' + Date.now();

    const contribution = { id: contribId, goal_id: req.params.id, user_id: req.userId, amount: Number(amount), date: now, note: note || '' };
    const updatedGoal = await addGoalContribution(req.params.id, req.userId, contribution);

    if (!updatedGoal) return res.status(404).json({ error: 'Goal not found.' });

    return res.json({ success: true, savedAmount: updatedGoal.saved_amount, status: updatedGoal.status });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to add contribution.' });
  }
});

app.delete('/api/v1/goals/:id', authenticateToken, async (req, res) => {
  try {
    await deleteGoal(req.params.id, req.userId);
    return res.json({ success: true, message: 'Goal deleted.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to delete goal.' });
  }
});

// ==========================================
// BILLS ENDPOINTS (USER ISOLATED)
// ==========================================

app.get('/api/v1/bills', authenticateToken, async (req, res) => {
  try {
    const rows = await getBills(req.userId);
    const bills = rows.map(b => ({
      id: b.id,
      name: b.name,
      category: b.category,
      amount: Number(b.amount),
      dueDate: b.due_date,
      frequency: b.frequency,
      paymentMethod: b.payment_method,
      walletId: b.wallet_id || '',
      isRecurring: Boolean(b.is_recurring),
      reminderEnabled: Boolean(b.reminder_enabled),
      reminderTime: b.reminder_time,
      status: b.status,
      createdAt: b.created_at,
      updatedAt: b.updated_at
    }));
    return res.json(bills);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch bills.' });
  }
});

app.post('/api/v1/bills', authenticateToken, async (req, res) => {
  try {
    const { id, name, category, amount, dueDate, frequency, paymentMethod, walletId, isRecurring, reminderEnabled, reminderTime } = req.body;
    const billId = id || 'bill_' + Date.now();
    const now = new Date().toISOString();

    const newBill = {
      id: billId,
      user_id: req.userId,
      name,
      category,
      amount: Number(amount),
      due_date: dueDate,
      frequency,
      payment_method: paymentMethod,
      wallet_id: walletId || '',
      is_recurring: isRecurring ? 1 : 0,
      reminder_enabled: reminderEnabled ? 1 : 0,
      reminder_time: reminderTime || '09:00 AM',
      status: 'Upcoming',
      created_at: now,
      updated_at: now
    };

    await createBill(newBill);

    return res.status(201).json({
      id: billId, name, category, amount: Number(amount), dueDate, frequency, paymentMethod, walletId, isRecurring: Boolean(isRecurring), reminderEnabled: Boolean(reminderEnabled), reminderTime, status: 'Upcoming', createdAt: now, updatedAt: now
    });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to create bill.' });
  }
});

app.delete('/api/v1/bills/:id', authenticateToken, async (req, res) => {
  try {
    await deleteBill(req.params.id, req.userId);
    return res.json({ success: true, message: 'Bill deleted.' });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to delete bill.' });
  }
});

// ==========================================
// PROFILE ENDPOINTS (USER ISOLATED)
// ==========================================

app.get('/api/v1/profile', authenticateToken, async (req, res) => {
  try {
    const user = await getUserById(req.userId);
    const profile = await getProfile(req.userId);

    return res.json({
      name: user ? user.name : 'User',
      email: user ? user.email : '',
      occupation: profile ? profile.occupation : 'Professional',
      financialPriority: profile ? profile.financial_priority : 'Manage Expenses',
      monthlyIncome: profile ? Number(profile.monthly_income) : 0.0,
      additionalIncome: profile ? Number(profile.additional_income) : 0.0,
      monthlyExpensesEstimate: profile ? Number(profile.monthly_expenses_estimate) : 0.0,
      currentSavings: profile ? Number(profile.current_savings) : 0.0,
      debtAmount: profile ? Number(profile.debt_amount) : 0.0,
      primaryGoal: profile ? profile.primary_goal : 'Emergency Fund',
      goalTargetAmount: profile ? Number(profile.goal_target_amount) : 0.0
    });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to fetch user profile.' });
  }
});

app.put('/api/v1/profile', authenticateToken, async (req, res) => {
  try {
    const {
      occupation, financialPriority, monthlyIncome, additionalIncome,
      monthlyExpensesEstimate, currentSavings, debtAmount, primaryGoal, goalTargetAmount
    } = req.body;

    await upsertProfile({
      user_id: req.userId,
      occupation: occupation || 'Professional',
      financial_priority: financialPriority || 'Manage Expenses',
      monthly_income: Number(monthlyIncome || 0),
      additional_income: Number(additionalIncome || 0),
      monthly_expenses_estimate: Number(monthlyExpensesEstimate || 0),
      current_savings: Number(currentSavings || 0),
      debt_amount: Number(debtAmount || 0),
      primary_goal: primaryGoal || 'Emergency Fund',
      goal_target_amount: Number(goalTargetAmount || 0)
    });

    return res.json({ success: true, message: 'Profile updated.' });
  } catch (err) {
    console.error('Update profile error:', err);
    return res.status(500).json({ error: 'Failed to update profile.' });
  }
});

// ==========================================
// REAL K2i AI ASSISTANT ENDPOINT
// ==========================================

app.post('/api/v1/ai/chat', authenticateToken, async (req, res) => {
  try {
    const { prompt } = req.body;
    if (!prompt || typeof prompt !== 'string' || prompt.trim() === '') {
      return res.status(400).json({ error: 'Prompt is required.' });
    }

    const financialContext = await FinancialContextService.buildUserFinancialContext(req.userId, prompt);
    const aiResponse = await AIService.generateK2iResponse(prompt, financialContext);

    return res.json({
      response: aiResponse,
      context: {
        currentBalance: financialContext.currentBalance,
        monthlyIncome: financialContext.monthlyIncome,
        monthlyExpenses: financialContext.monthlyExpenses,
        netCashFlow: financialContext.netCashFlow,
        savingsRate: financialContext.savingsRate,
        healthScore: financialContext.healthScore
      }
    });
  } catch (err) {
    console.error('AI chat endpoint error:', err.message);
    if (err.message.includes('AI provider/API key is required')) {
      return res.status(503).json({ error: 'AI provider/API key is required.' });
    }
    return res.status(500).json({ error: 'AI service is currently unavailable. Please try again later.' });
  }
});

app.post('/api/v1/ai/health-score', authenticateToken, async (req, res) => {
  try {
    const healthScore = await FinancialContextService.getFinancialHealth(req.userId);
    const context = await FinancialContextService.buildUserFinancialContext(req.userId);
    return res.json({ healthScore, context });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to calculate health score.' });
  }
});

app.listen(PORT, () => {
  console.log(`MoneyMateX Backend API Server running on port ${PORT}`);
});
