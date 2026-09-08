package com.monematex.backend.service;

import com.monematex.backend.dto.ProfileDto;
import com.monematex.backend.model.User;
import com.monematex.backend.model.UserProfile;
import com.monematex.backend.repository.UserProfileRepository;
import com.monematex.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class ProfileService {

    private final UserProfileRepository profileRepository;
    private final UserRepository userRepository;

    public ProfileService(UserProfileRepository profileRepository, UserRepository userRepository) {
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
    }

    public ProfileDto getProfile(String userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<UserProfile> profileOpt = profileRepository.findByUserId(userId);

        String name = userOpt.map(User::getName).orElse("User");
        String email = userOpt.map(User::getEmail).orElse("");

        UserProfile p = profileOpt.orElseGet(() -> new UserProfile(
                userId, "Professional", "Manage Expenses", 0.0, 0.0, 0.0, 0.0, 0.0, "Emergency Fund", 0.0
        ));

        return new ProfileDto(
                name,
                email,
                p.getOccupation() != null ? p.getOccupation() : "Professional",
                p.getFinancialPriority() != null ? p.getFinancialPriority() : "Manage Expenses",
                p.getMonthlyIncome() != null ? p.getMonthlyIncome() : 0.0,
                p.getAdditionalIncome() != null ? p.getAdditionalIncome() : 0.0,
                p.getMonthlyExpensesEstimate() != null ? p.getMonthlyExpensesEstimate() : 0.0,
                p.getCurrentSavings() != null ? p.getCurrentSavings() : 0.0,
                p.getDebtAmount() != null ? p.getDebtAmount() : 0.0,
                p.getPrimaryGoal() != null ? p.getPrimaryGoal() : "Emergency Fund",
                p.getGoalTargetAmount() != null ? p.getGoalTargetAmount() : 0.0
        );
    }

    @Transactional
    public void upsertProfile(String userId, ProfileDto dto) {
        UserProfile profile = profileRepository.findByUserId(userId).orElse(new UserProfile());
        profile.setUserId(userId);
        profile.setOccupation(dto.getOccupation() != null ? dto.getOccupation() : "Professional");
        profile.setFinancialPriority(dto.getFinancialPriority() != null ? dto.getFinancialPriority() : "Manage Expenses");
        profile.setMonthlyIncome(dto.getMonthlyIncome() != null ? dto.getMonthlyIncome() : 0.0);
        profile.setAdditionalIncome(dto.getAdditionalIncome() != null ? dto.getAdditionalIncome() : 0.0);
        profile.setMonthlyExpensesEstimate(dto.getMonthlyExpensesEstimate() != null ? dto.getMonthlyExpensesEstimate() : 0.0);
        profile.setCurrentSavings(dto.getCurrentSavings() != null ? dto.getCurrentSavings() : 0.0);
        profile.setDebtAmount(dto.getDebtAmount() != null ? dto.getDebtAmount() : 0.0);
        profile.setPrimaryGoal(dto.getPrimaryGoal() != null ? dto.getPrimaryGoal() : "Emergency Fund");
        profile.setGoalTargetAmount(dto.getGoalTargetAmount() != null ? dto.getGoalTargetAmount() : 0.0);

        profileRepository.save(profile);
    }
}
