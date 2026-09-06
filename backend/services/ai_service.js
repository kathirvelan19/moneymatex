const https = require('https');

const SYSTEM_PROMPT = `You are K2i, the MoneyMateX Financial Intelligence Assistant.
You are an AI reasoning and explanation layer.
MoneyMateX application data is the only source of financial truth.
Never invent or estimate financial values.
Never assume missing values.
Never create fictional transactions, balances, income, expenses, budgets, goals, bills, savings, debt or financial health scores.
All numerical financial facts supplied in your context were calculated by the MoneyMateX application.
Use those values exactly.
If required information is missing, explicitly say that there is not enough information to answer accurately.
Do not calculate critical financial values independently when a deterministic application calculation is available.
You may explain, compare, summarize and provide personalized recommendations based only on the supplied financial context.
Do not expose internal implementation details, API keys, authentication tokens or sensitive credentials.
You are K2i, not a generic ChatGPT assistant.`;

class AIService {
  static validateResponse(responseText, context) {
    // Extract numbers formatted like ₹X,XXX or plain numbers from response
    const numberMatches = responseText.match(/₹?\s*\d[\d,.]*/g);
    if (!numberMatches) return true;

    // Collect all valid numerical values from context
    const validValues = new Set();
    validValues.add(Math.round(context.currentBalance));
    validValues.add(Math.round(context.monthlyIncome));
    validValues.add(Math.round(context.monthlyExpenses));
    validValues.add(Math.round(context.netCashFlow));
    validValues.add(Math.round(context.savingsRate));
    validValues.add(Math.round(context.healthScore));
    validValues.add(Math.round(context.targetBudget));
    validValues.add(Math.round(context.budgetUsagePercentage));

    if (context.categorySpending) {
      Object.values(context.categorySpending).forEach(v => validValues.add(Math.round(v)));
    }
    if (context.goals) {
      context.goals.forEach(g => {
        validValues.add(Math.round(g.targetAmount));
        validValues.add(Math.round(g.savedAmount));
        validValues.add(Math.round(g.percentage));
      });
    }
    if (context.upcomingBills) {
      context.upcomingBills.forEach(b => validValues.add(Math.round(b.amount)));
    }
    if (context.recentTransactions) {
      context.recentTransactions.forEach(t => validValues.add(Math.round(t.amount)));
    }

    // Allow small integers (e.g. 1, 2, 5, 10, 100) or percentages or year
    for (const match of numberMatches) {
      const numStr = match.replace(/[₹,\s]/g, '');
      const val = parseFloat(numStr);
      if (isNaN(val)) continue;
      if (val < 10 && Number.isInteger(val)) continue; // ignore small counts like "5 goals"

      const rounded = Math.round(val);
      // Check if context contains this value (with small tolerance)
      let found = false;
      for (const validVal of validValues) {
        if (Math.abs(validVal - rounded) <= 2) {
          found = true;
          break;
        }
      }
      if (!found) {
        // Response contains unsupported financial figure
        return false;
      }
    }
    return true;
  }

  static async generateK2iResponse(userPrompt, context) {
    const provider = process.env.AI_PROVIDER || 'gemini';
    const apiKey = process.env.AI_API_KEY || '';
    const model = process.env.AI_MODEL || 'gemini-2.0-flash';

    if (!apiKey || apiKey.trim() === '') {
      throw new Error('AI provider/API key is required.');
    }

    // Check missing data cases (Requirement 11)
    const lowerPrompt = userPrompt.toLowerCase();

    if (!context.hasData) {
      if (lowerPrompt.includes('balance') || lowerPrompt.includes('wallet')) {
        return "I don't have enough wallet data to determine your current balance yet. Add a wallet or account first.";
      }
      if (lowerPrompt.includes('spend') || lowerPrompt.includes('expense') || lowerPrompt.includes('income')) {
        return "I don't have enough transaction data to calculate your spending for this month yet.";
      }
    }

    const contextSummaryStr = JSON.stringify(context, null, 2);

    const fullPrompt = `${SYSTEM_PROMPT}

SUPPLIED AUTHENTICATED USER FINANCIAL CONTEXT (Calculated deterministically by MoneyMateX):
${contextSummaryStr}

USER QUESTION:
"${userPrompt}"

Provide a concise, direct, helpful answer using ONLY the numerical financial values supplied above. Do NOT fabricate numbers.`;

    let aiResponseText = '';

    if (provider.toLowerCase() === 'gemini') {
      aiResponseText = await this._callGeminiApi(apiKey, model, fullPrompt);
    } else {
      throw new Error(`Unsupported AI provider: ${provider}`);
    }

    // Validate response against supplied context (Requirement 10)
    const isValid = this.validateResponse(aiResponseText, context);
    if (!isValid) {
      // Re-generate or fallback to deterministic statement
      return `Based on your verified MoneyMateX records: Current balance is ₹${context.currentBalance.toFixed(0)}, Monthly Income is ₹${context.monthlyIncome.toFixed(0)}, Monthly Expenses are ₹${context.monthlyExpenses.toFixed(0)}, and Savings Goal Progress is ${context.goals.length > 0 ? context.goals[0].percentage.toFixed(1) : 0}%.`;
    }

    return aiResponseText;
  }

  static _callGeminiApi(apiKey, model, prompt) {
    return new Promise((resolve, reject) => {
      const postData = JSON.stringify({
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ]
      });

      const options = {
        hostname: 'generativelanguage.googleapis.com',
        path: `/v1beta/models/${model}:generateContent?key=${apiKey}`,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData)
        }
      };

      const req = https.request(options, (res) => {
        let body = '';
        res.on('data', chunk => body += chunk);
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            try {
              const data = JSON.parse(body);
              const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
              if (text) resolve(text.trim());
              else reject(new Error('Empty response from Gemini API'));
            } catch (err) {
              reject(err);
            }
          } else {
            reject(new Error(`Gemini API HTTP Error ${res.statusCode}: ${body}`));
          }
        });
      });

      req.on('error', (err) => reject(err));
      req.write(postData);
      req.end();
    });
  }
}

module.exports = AIService;
