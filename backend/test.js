const http = require('http');

function request(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : {};
          resolve({ statusCode: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ statusCode: res.statusCode, body });
        }
      });
    });
    req.on('error', reject);
    if (postData) req.write(JSON.stringify(postData));
    req.end();
  });
}

async function runTests() {
  console.log('=== STARTING MONEMATEX BACKEND TEST SUITE ===');

  // Test 1: User A Registration
  console.log('\n[1] Testing User A Registration...');
  const userAEmail = `usera_${Date.now()}@test.com`;
  const regA = await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/auth/signup', method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }, { name: 'User A', email: userAEmail, password: 'password123' });
  console.log('User A Signup Status:', regA.statusCode);
  if (regA.statusCode !== 201) throw new Error('User A signup failed');
  const tokenA = regA.body.token;

  // Test 2: User B Registration
  console.log('\n[2] Testing User B Registration...');
  const userBEmail = `userb_${Date.now()}@test.com`;
  const regB = await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/auth/signup', method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }, { name: 'User B', email: userBEmail, password: 'password123' });
  console.log('User B Signup Status:', regB.statusCode);
  if (regB.statusCode !== 201) throw new Error('User B signup failed');
  const tokenB = regB.body.token;

  // Test 3: Add Income & Expenses for User A
  console.log('\n[3] Adding Financial Data for User A...');
  await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/transactions', method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${tokenA}` }
  }, { title: 'Salary', category: 'Salary', amount: 50000, isExpense: false, date: '2026-08-01', paymentMethod: 'Bank' });

  await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/transactions', method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${tokenA}` }
  }, { title: 'Food & Dining', category: 'Food', amount: 5000, isExpense: true, date: '2026-08-02', paymentMethod: 'Card' });

  // Test 4: Add Expenses for User B
  console.log('\n[4] Adding Financial Data for User B...');
  await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/transactions', method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${tokenB}` }
  }, { title: 'Snacks', category: 'Food', amount: 1000, isExpense: true, date: '2026-08-03', paymentMethod: 'Cash' });

  // Test 5: Verify User Isolation (User A tx != User B tx)
  console.log('\n[5] Verifying User Isolation...');
  const txA = await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/transactions', method: 'GET',
    headers: { 'Authorization': `Bearer ${tokenA}` }
  });
  const txB = await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/transactions', method: 'GET',
    headers: { 'Authorization': `Bearer ${tokenB}` }
  });

  console.log(`User A Transaction Count: ${txA.body.length} (Expected: 2)`);
  console.log(`User B Transaction Count: ${txB.body.length} (Expected: 1)`);
  if (txA.body.length !== 2 || txB.body.length !== 1) {
    throw new Error('USER ISOLATION FAILURE: Transactions mixed across users!');
  }

  // Test 6: AI Chat API Endpoint for missing key (or failure handling)
  console.log('\n[6] Testing AI Chat Endpoint with missing/configured API key...');
  const aiChatRes = await request({
    hostname: 'localhost', port: 3000, path: '/api/v1/ai/chat', method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${tokenA}` }
  }, { prompt: 'How much did I spend on food?' });

  console.log('AI Chat Status Code:', aiChatRes.statusCode);
  console.log('AI Chat Response:', aiChatRes.body);

  console.log('\n=== BACKEND TEST SUITE COMPLETED SUCCESSFULLY ===');
}

runTests().catch(err => {
  console.error('Backend Test Error:', err);
  process.exit(1);
});
