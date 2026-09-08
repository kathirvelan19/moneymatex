package com.monematex.backend.controller;

import com.monematex.backend.dto.AIChatRequest;
import com.monematex.backend.dto.AIChatResponse;
import com.monematex.backend.service.AIService;
import com.monematex.backend.service.FinancialContextService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/ai")
@CrossOrigin(origins = "*")
public class AIController {

    private final AIService aiService;
    private final FinancialContextService contextService;

    public AIController(AIService aiService, FinancialContextService contextService) {
        this.aiService = aiService;
        this.contextService = contextService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @PostMapping("/chat")
    public ResponseEntity<?> chat(@RequestBody AIChatRequest request, Authentication authentication) {
        if (request.getPrompt() == null || request.getPrompt().trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Prompt is required."));
        }

        String userId = extractUserId(authentication);
        try {
            Map<String, Object> context = contextService.buildUserFinancialContext(userId, request.getPrompt());
            String responseText = aiService.generateK2iResponse(request.getPrompt(), context);

            Map<String, Object> summaryContext = Map.of(
                    "currentBalance", context.get("currentBalance"),
                    "monthlyIncome", context.get("monthlyIncome"),
                    "monthlyExpenses", context.get("monthlyExpenses"),
                    "netCashFlow", context.get("netCashFlow"),
                    "savingsRate", context.get("savingsRate"),
                    "healthScore", context.get("healthScore")
            );

            return ResponseEntity.ok(new AIChatResponse(responseText, summaryContext));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "AI service is currently unavailable. Please try again later."));
        }
    }

    @PostMapping("/health-score")
    public ResponseEntity<?> getHealthScore(Authentication authentication) {
        String userId = extractUserId(authentication);
        try {
            int healthScore = contextService.getFinancialHealth(userId);
            Map<String, Object> context = contextService.buildUserFinancialContext(userId, "");
            return ResponseEntity.ok(Map.of(
                    "healthScore", healthScore,
                    "context", context
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to calculate health score."));
        }
    }
}
