package com.fairpay.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class AddMemberRequestDTO {
    
    @NotNull(message = "ID do usuário é obrigatório")
    private Long userId;
    
    @NotBlank(message = "Papel é obrigatório")
    private String role; // "MEMBER" ou "ADMIN"
    
    // Constructors
    public AddMemberRequestDTO() {}
    
    public AddMemberRequestDTO(Long userId, String role) {
        this.userId = userId;
        this.role = role;
    }
    
    // Getters and Setters
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
}
