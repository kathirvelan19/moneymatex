package com.monematex.backend.controller;

import com.monematex.backend.dto.GoalDto;
import com.monematex.backend.model.Goal;
import com.monematex.backend.service.GoalService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/goals")
@CrossOrigin(origins = "*")
public class GoalController {

    private final GoalService goalService;

    public GoalController(GoalService goalService) {
        this.goalService = goalService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @GetMapping
    public ResponseEntity<List<GoalDto>> getGoals(Authentication authentication) {
        String userId = extractUserId(authentication);
        List<GoalDto> goals = goalService.getGoals(userId);
        return ResponseEntity.ok(goals);
    }

    @PostMapping
    public ResponseEntity<?> createGoal(@RequestBody GoalDto dto, Authentication authentication) {
        String userId = extractUserId(authentication);
        if (dto.getName() == null || dto.getTargetAmount() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Name and targetAmount are required."));
        }
        GoalDto created = goalService.createGoal(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PostMapping("/{id}/contributions")
    public ResponseEntity<?> addContribution(@PathVariable String id, @RequestBody Map<String, Object> body, Authentication authentication) {
        String userId = extractUserId(authentication);
        Double amount = body.get("amount") instanceof Number ? ((Number) body.get("amount")).doubleValue() : 0.0;
        String note = (String) body.get("note");

        Optional<Goal> goalOpt = goalService.addContribution(userId, id, amount, note);
        if (goalOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Goal not found."));
        }

        Goal goal = goalOpt.get();
        return ResponseEntity.ok(Map.of(
                "success", true,
                "savedAmount", goal.getSavedAmount(),
                "status", goal.getStatus()
        ));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteGoal(@PathVariable String id, Authentication authentication) {
        String userId = extractUserId(authentication);
        goalService.deleteGoal(id, userId);
        return ResponseEntity.ok(Map.of("success", true, "message", "Goal deleted."));
    }
}
