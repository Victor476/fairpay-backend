package com.fairpay.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class ExpenseRequestDTO {
    
    @NotBlank(message = "Descrição é obrigatória")
    private String description;
    
    @NotNull(message = "Valor é obrigatório")
    @Positive(message = "Valor deve ser positivo")
    private BigDecimal totalAmount;
    
    @NotNull(message = "Data da despesa é obrigatória")
    private LocalDate date;
    
    @NotNull(message = "Grupo é obrigatório")
    private Long groupId;
    
    @NotBlank(message = "Email do usuário pagador é obrigatório")
    private String payer;
    
    private Long categoryId;
    
    @NotNull(message = "Participantes são obrigatórios")
    private List<String> participants;
}