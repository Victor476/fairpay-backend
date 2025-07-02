package com.fairpay.dto;

import jakarta.validation.constraints.NotBlank;

public class UpdateMemberRoleRequestDTO {
    
    @NotBlank(message = "Papel é obrigatório")
    private String role; // "MEMBER" ou "ADMIN"
    
    // Constructors
    public UpdateMemberRoleRequestDTO() {}
    
    public UpdateMemberRoleRequestDTO(String role) {
        this.role = role;
    }
    
    // Getters and Setters
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
}
