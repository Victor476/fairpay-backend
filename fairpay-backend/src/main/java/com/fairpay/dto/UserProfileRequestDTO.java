package com.fairpay.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class UserProfileRequestDTO {
    
    @NotBlank(message = "Nome é obrigatório")
    private String name;
    
    @Email(message = "Email deve ter formato válido")
    @NotBlank(message = "Email é obrigatório")
    private String email;
    
    // Campos opcionais
    private String phoneNumber;
    private String profileImageUrl;
    
    // Constructors
    public UserProfileRequestDTO() {}
    
    public UserProfileRequestDTO(String name, String email) {
        this.name = name;
        this.email = email;
    }
    
    // Getters and Setters
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getProfileImageUrl() {
        return profileImageUrl;
    }
    
    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
}
