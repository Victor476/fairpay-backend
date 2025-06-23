package com.fairpay.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;

@Entity
@Table(name = "refresh_tokens")
@Data
public class RefreshToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String token;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "expires_at", nullable = false)
    private Instant expiryDate;
    
    @Column(name = "created_at")
    private Instant createdAt;
    
    @Column(name = "revoked")
    private Boolean revoked;
    
    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            this.createdAt = Instant.now();
        }
        if (revoked == null) {
            this.revoked = false;
        }
    }
    
    // Método para definir o token (opcional - implementar se necessário)
    public void setToken(String token) {
        // Em um cenário real, você poderia armazenar isso em outra coluna
        this.token = token;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
    
    public Boolean getRevoked() {
        return revoked;
    }
    
    public void setRevoked(Boolean revoked) {
        this.revoked = revoked;
    }
    
    // O método getExpiryDate() já deve existir, mas aqui está para completude
    public Instant getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(Instant expiryDate) {
        this.expiryDate = expiryDate;
    }
}