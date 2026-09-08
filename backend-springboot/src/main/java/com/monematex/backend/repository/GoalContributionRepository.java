package com.monematex.backend.repository;

import com.monematex.backend.model.GoalContribution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GoalContributionRepository extends JpaRepository<GoalContribution, String> {
    List<GoalContribution> findByGoalIdAndUserId(String goalId, String userId);
    void deleteByGoalIdAndUserId(String goalId, String userId);
}
