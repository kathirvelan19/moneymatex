package com.monematex.backend.service;

import com.monematex.backend.dto.GoalContributionDto;
import com.monematex.backend.dto.GoalDto;
import com.monematex.backend.model.Goal;
import com.monematex.backend.model.GoalContribution;
import com.monematex.backend.repository.GoalContributionRepository;
import com.monematex.backend.repository.GoalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class GoalService {

    private final GoalRepository goalRepository;
    private final GoalContributionRepository contributionRepository;

    public GoalService(GoalRepository goalRepository, GoalContributionRepository contributionRepository) {
        this.goalRepository = goalRepository;
        this.contributionRepository = contributionRepository;
    }

    public List<GoalDto> getGoals(String userId) {
        List<Goal> goals = goalRepository.findByUserId(userId);
        return goals.stream().map(g -> {
            List<GoalContribution> contribs = contributionRepository.findByGoalIdAndUserId(g.getId(), userId);
            List<GoalContributionDto> contribDtos = contribs.stream().map(c -> new GoalContributionDto(
                    c.getId(), c.getGoalId(), c.getAmount(), c.getDate(), c.getNote() != null ? c.getNote() : ""
            )).collect(Collectors.toList());

            return new GoalDto(
                    g.getId(),
                    g.getName(),
                    g.getTargetAmount(),
                    g.getSavedAmount(),
                    g.getTargetDate(),
                    g.getCategory(),
                    g.getPriority(),
                    g.getStatus(),
                    g.getNotes() != null ? g.getNotes() : "",
                    g.getCreatedAt(),
                    g.getUpdatedAt(),
                    contribDtos
            );
        }).collect(Collectors.toList());
    }

    @Transactional
    public GoalDto createGoal(String userId, GoalDto dto) {
        String goalId = dto.getId() != null && !dto.getId().trim().isEmpty()
                ? dto.getId()
                : "gl_" + System.currentTimeMillis();
        String now = LocalDateTime.now().format(DateTimeFormatter.ISO_DATE_TIME);

        Goal goal = new Goal(
                goalId,
                userId,
                dto.getName(),
                dto.getTargetAmount() != null ? dto.getTargetAmount() : 0.0,
                dto.getSavedAmount() != null ? dto.getSavedAmount() : 0.0,
                dto.getTargetDate(),
                dto.getCategory(),
                dto.getPriority() != null ? dto.getPriority() : "Medium",
                "In Progress",
                dto.getNotes() != null ? dto.getNotes() : "",
                now,
                now
        );

        goalRepository.save(goal);

        dto.setId(goalId);
        dto.setStatus("In Progress");
        dto.setCreatedAt(now);
        dto.setUpdatedAt(now);
        dto.setContributions(new ArrayList<>());
        return dto;
    }

    @Transactional
    public Optional<Goal> addContribution(String userId, String goalId, Double amount, String note) {
        Optional<Goal> goalOpt = goalRepository.findByIdAndUserId(goalId, userId);
        if (goalOpt.isEmpty()) return Optional.empty();

        Goal goal = goalOpt.get();
        double contribAmount = amount != null ? amount : 0.0;
        double newSaved = (goal.getSavedAmount() != null ? goal.getSavedAmount() : 0.0) + contribAmount;
        goal.setSavedAmount(newSaved);

        if (goal.getTargetAmount() != null && newSaved >= goal.getTargetAmount()) {
            goal.setStatus("Completed");
        }
        String now = LocalDateTime.now().format(DateTimeFormatter.ISO_DATE_TIME);
        goal.setUpdatedAt(now);
        goalRepository.save(goal);

        String contribId = "gc_" + System.currentTimeMillis();
        GoalContribution contrib = new GoalContribution(
                contribId, goalId, userId, contribAmount, now, note != null ? note : ""
        );
        contributionRepository.save(contrib);

        return Optional.of(goal);
    }

    @Transactional
    public void deleteGoal(String id, String userId) {
        goalRepository.deleteByIdAndUserId(id, userId);
        contributionRepository.deleteByGoalIdAndUserId(id, userId);
    }
}
