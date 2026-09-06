const fs = require('fs');
const path = require('path');

const dbPath = path.resolve(__dirname, 'database.json');

let memoryDb = {
  users: [],
  wallets: [],
  transactions: [],
  goals: [],
  goal_contributions: [],
  bills: [],
  profiles: []
};

function loadDb() {
  if (fs.existsSync(dbPath)) {
    try {
      const data = fs.readFileSync(dbPath, 'utf8');
      memoryDb = Object.assign(memoryDb, JSON.parse(data));
    } catch (e) {
      console.error('Error loading database.json:', e);
    }
  } else {
    saveDb();
  }
}

function saveDb() {
  try {
    fs.writeFileSync(dbPath, JSON.stringify(memoryDb, null, 2), 'utf8');
  } catch (e) {
    console.error('Error saving database.json:', e);
  }
}

async function initDb() {
  loadDb();
  return true;
}

// User Helpers
async function getUserById(id) {
  loadDb();
  return memoryDb.users.find(u => u.id === id) || null;
}

async function getUserByEmail(email) {
  loadDb();
  return memoryDb.users.find(u => u.email.toLowerCase() === email.toLowerCase()) || null;
}

async function createUser(user) {
  loadDb();
  memoryDb.users.push(user);
  saveDb();
  return user;
}

// Profile Helpers
async function getProfile(userId) {
  loadDb();
  return memoryDb.profiles.find(p => p.user_id === userId) || null;
}

async function upsertProfile(profile) {
  loadDb();
  const idx = memoryDb.profiles.findIndex(p => p.user_id === profile.user_id);
  if (idx >= 0) {
    memoryDb.profiles[idx] = Object.assign(memoryDb.profiles[idx], profile);
  } else {
    memoryDb.profiles.push(profile);
  }
  saveDb();
  return profile;
}

// Transactions Helpers
async function getTransactions(userId) {
  loadDb();
  return memoryDb.transactions
    .filter(t => t.user_id === userId)
    .sort((a, b) => new Date(b.date) - new Date(a.date));
}

async function createTransaction(tx) {
  loadDb();
  memoryDb.transactions.push(tx);
  saveDb();
  return tx;
}

async function deleteTransaction(id, userId) {
  loadDb();
  const initialLen = memoryDb.transactions.length;
  memoryDb.transactions = memoryDb.transactions.filter(t => !(t.id === id && t.user_id === userId));
  saveDb();
  return memoryDb.transactions.length < initialLen;
}

// Wallets Helpers
async function getWallets(userId) {
  loadDb();
  return memoryDb.wallets.filter(w => w.user_id === userId);
}

async function createWallet(wallet) {
  loadDb();
  if (wallet.is_primary) {
    memoryDb.wallets.forEach(w => {
      if (w.user_id === wallet.user_id) w.is_primary = 0;
    });
  }
  memoryDb.wallets.push(wallet);
  saveDb();
  return wallet;
}

async function updateWalletBalance(walletId, userId, delta) {
  loadDb();
  const wallet = memoryDb.wallets.find(w => w.id === walletId && w.user_id === userId);
  if (wallet) {
    wallet.balance = Math.max(0.0, Number(wallet.balance) + delta);
    saveDb();
  }
}

async function deleteWallet(id, userId) {
  loadDb();
  memoryDb.wallets = memoryDb.wallets.filter(w => !(w.id === id && w.user_id === userId));
  saveDb();
}

// Goals Helpers
async function getGoals(userId) {
  loadDb();
  return memoryDb.goals.filter(g => g.user_id === userId);
}

async function getGoalContributions(goalId, userId) {
  loadDb();
  return memoryDb.goal_contributions.filter(c => c.goal_id === goalId && c.user_id === userId);
}

async function createGoal(goal) {
  loadDb();
  memoryDb.goals.push(goal);
  saveDb();
  return goal;
}

async function addGoalContribution(goalId, userId, contribution) {
  loadDb();
  const goal = memoryDb.goals.find(g => g.id === goalId && g.user_id === userId);
  if (!goal) return null;

  goal.saved_amount = Number(goal.saved_amount) + Number(contribution.amount);
  if (goal.saved_amount >= goal.target_amount) {
    goal.status = 'Completed';
  }
  goal.updated_at = new Date().toISOString();

  memoryDb.goal_contributions.push(contribution);
  saveDb();
  return goal;
}

async function deleteGoal(id, userId) {
  loadDb();
  memoryDb.goals = memoryDb.goals.filter(g => !(g.id === id && g.user_id === userId));
  memoryDb.goal_contributions = memoryDb.goal_contributions.filter(c => !(c.goal_id === id && c.user_id === userId));
  saveDb();
}

// Bills Helpers
async function getBills(userId) {
  loadDb();
  return memoryDb.bills.filter(b => b.user_id === userId);
}

async function createBill(bill) {
  loadDb();
  memoryDb.bills.push(bill);
  saveDb();
  return bill;
}

async function deleteBill(id, userId) {
  loadDb();
  memoryDb.bills = memoryDb.bills.filter(b => !(b.id === id && b.user_id === userId));
  saveDb();
}

module.exports = {
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
};
