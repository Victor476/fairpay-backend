package com.fairpay.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.Instant;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ExpenseResponseDTO {
    
    private Long id;
    private String description;
    private BigDecimal amount;
    private LocalDate expenseDate;
    private Instant createdAt;
    private Long categoryId;
    
    private PaidByUserDTO paidBy;
    private GroupDTO group;
    private List<ParticipantDTO> participants;
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class PaidByUserDTO {
        private Long id;
        private String name;
        private String email;
    }
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class GroupDTO {
        private Long id;
        private String name;
    }
    
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ParticipantDTO {
        private Long id;
        private String name;
        private String email;
        private BigDecimal share;
    }
}
