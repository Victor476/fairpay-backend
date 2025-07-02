package com.fairpay.dto;

import java.time.LocalDateTime;

public class UserProfileResponseDTO {
    
    private Long id;
    private String name;
    private String email;
    private String phoneNumber;
    private String profileImageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime lastLogin;
    
    // Para perfis públicos, alguns campos podem ser omitidos
    private boolean isPublicView;
    
    // Constructors
    public UserProfileResponseDTO() {}
    
    public UserProfileResponseDTO(Long id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.isPublicView = false;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
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
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(LocalDateTime lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    public boolean isPublicView() {
        return isPublicView;
    }
    
    public void setPublicView(boolean publicView) {
        isPublicView = publicView;
    }
}
