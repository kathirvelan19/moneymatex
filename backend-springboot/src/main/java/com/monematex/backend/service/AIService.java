package com.monematex.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AIService {

    private static final String SYSTEM_PROMPT = """
            You are K2i, the MoneyMateX Financial Intelligence Assistant.
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
            You are K2i, not a generic ChatGPT assistant.
            """;

    @Value("${ai.provider:gemini}")
    private String aiProvider;

    @Value("${ai.model:gemini-2.0-flash}")
    private String aiModel;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public AIService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    public String generateK2iResponse(String userPrompt, Map<String, Object> context) {
        String envKey = System.getenv("AI_API_KEY");
        String keyToUse = (envKey != null && !envKey.trim().isEmpty()) ? envKey : aiApiKey;

        if (keyToUse == null || keyToUse.trim().isEmpty()) {
            throw new IllegalArgumentException("AI provider/API key is required.");
        }

        Boolean hasData = (Boolean) context.get("hasData");
        String lowerPrompt = userPrompt.toLowerCase();

        if (Boolean.FALSE.equals(hasData)) {
            if (lowerPrompt.contains("balance") || lowerPrompt.contains("wallet")) {
                return "I don't have enough wallet data to determine your current balance yet. Add a wallet or account first.";
            }
            if (lowerPrompt.contains("spend") || lowerPrompt.contains("expense") || lowerPrompt.contains("income")) {
                return "I don't have enough transaction data to calculate your spending for this month yet.";
            }
        }

        String contextSummaryStr;
        try {
            contextSummaryStr = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(context);
        } catch (Exception e) {
            contextSummaryStr = context.toString();
        }

        String fullPrompt = SYSTEM_PROMPT + "\n\n"
                + "SUPPLIED AUTHENTICATED USER FINANCIAL CONTEXT (Calculated deterministically by MoneyMateX):\n"
                + contextSummaryStr + "\n\n"
                + "USER QUESTION:\n\"" + userPrompt + "\"\n\n"
                + "Provide a concise, direct, helpful answer using ONLY the numerical financial values supplied above. Do NOT fabricate numbers.";

        String aiResponseText = callGeminiApi(keyToUse, aiModel, fullPrompt);

        if (!validateResponse(aiResponseText, context)) {
            double balance = context.containsKey("currentBalance") ? ((Number) context.get("currentBalance")).doubleValue() : 0.0;
            double income = context.containsKey("monthlyIncome") ? ((Number) context.get("monthlyIncome")).doubleValue() : 0.0;
            double expenses = context.containsKey("monthlyExpenses") ? ((Number) context.get("monthlyExpenses")).doubleValue() : 0.0;
            return String.format("Based on your verified MoneyMateX records: Current balance is ₹%.0f, Monthly Income is ₹%.0f, and Monthly Expenses are ₹%.0f.",
                    balance, income, expenses);
        }

        return aiResponseText;
    }

    private String callGeminiApi(String apiKey, String model, String prompt) {
        String url = String.format("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", model, apiKey);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> part = Map.of("text", prompt);
        Map<String, Object> content = Map.of("parts", List.of(part));
        Map<String, Object> requestBody = Map.of("contents", List.of(content));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map body = response.getBody();
                List candidates = (List) body.get("candidates");
                if (candidates != null && !candidates.isEmpty()) {
                    Map firstCand = (Map) candidates.get(0);
                    Map contentObj = (Map) firstCand.get("content");
                    if (contentObj != null) {
                        List parts = (List) contentObj.get("parts");
                        if (parts != null && !parts.isEmpty()) {
                            Map firstPart = (Map) parts.get(0);
                            String text = (String) firstPart.get("text");
                            if (text != null) return text.trim();
                        }
                    }
                }
            }
            throw new RuntimeException("Empty or invalid response structure from Gemini API");
        } catch (Exception e) {
            throw new RuntimeException("Gemini API Error: " + e.getMessage(), e);
        }
    }

    private boolean validateResponse(String responseText, Map<String, Object> context) {
        Pattern pattern = Pattern.compile("₹?\\s*\\d[\\d,.]*");
        Matcher matcher = pattern.matcher(responseText);

        Set<Long> validValues = new HashSet<>();
        addValueIfPresent(validValues, context.get("currentBalance"));
        addValueIfPresent(validValues, context.get("monthlyIncome"));
        addValueIfPresent(validValues, context.get("monthlyExpenses"));
        addValueIfPresent(validValues, context.get("netCashFlow"));
        addValueIfPresent(validValues, context.get("savingsRate"));
        addValueIfPresent(validValues, context.get("healthScore"));
        addValueIfPresent(validValues, context.get("targetBudget"));
        addValueIfPresent(validValues, context.get("budgetUsagePercentage"));

        while (matcher.find()) {
            String match = matcher.group();
            String cleanNum = match.replaceAll("[₹,\\s]", "");
            try {
                double val = Double.parseDouble(cleanNum);
                if (val < 10 && val == Math.floor(val)) continue; // ignore small integer counts

                long rounded = Math.round(val);
                boolean found = false;
                for (long validVal : validValues) {
                    if (Math.abs(validVal - rounded) <= 2) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    return false;
                }
            } catch (Exception ignored) {}
        }

        return true;
    }

    private void addValueIfPresent(Set<Long> set, Object obj) {
        if (obj instanceof Number number) {
            set.add(Math.round(number.doubleValue()));
        }
    }
}
