package com.fairpay.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequestDTO {
    
    @NotBlank(message = "Token é obrigatório")
    private String token;
    
    @NotBlank(message = "Nova senha é obrigatória")
    @Size(min = 6, message = "A senha deve ter pelo menos 6 caracteres")
    private String newPassword;
    
    // Constructors
    public ResetPasswordRequestDTO() {}
    
    public ResetPasswordRequestDTO(String token, String newPassword) {
        this.token = token;
        this.newPassword = newPassword;
    }
    
    // Getters and Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getNewPassword() {
        return newPassword;
    }
    
    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}
