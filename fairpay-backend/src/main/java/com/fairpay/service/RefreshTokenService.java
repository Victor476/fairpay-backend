package com.fairpay.service;

import com.fairpay.exception.TokenRefreshException;
import com.fairpay.model.RefreshToken;
import com.fairpay.model.User;
import com.fairpay.repository.RefreshTokenRepository;
import com.fairpay.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;


@Service
public class RefreshTokenService {
    
    // Valor constante - 24 horas em milissegundos
    private final long refreshTokenDurationMs = 86400000L;
    
    @Autowired
    private RefreshTokenRepository refreshTokenRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Transactional
    public RefreshToken createRefreshToken(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado com id: " + userId));
        
        // Verificar se já existe um token para este usuário
        Optional<RefreshToken> existingToken = refreshTokenRepository.findByUser(user);
        if (existingToken.isPresent()) {
            // Verificar se o token está expirado ou revogado
            RefreshToken token = existingToken.get();
            if (token.getExpiryDate().isAfter(Instant.now()) && !Boolean.TRUE.equals(token.getRevoked())) {
                // Token existente ainda válido, retorna ele
                return token;
            } else {
                // Token expirado ou revogado, deleta para criar um novo
                refreshTokenRepository.delete(token);
            }
        }
        
        // Criar novo token
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setExpiryDate(Instant.now().plusMillis(refreshTokenDurationMs));
        refreshToken.setCreatedAt(Instant.now());
        refreshToken.setRevoked(false);
        refreshToken.setToken(UUID.randomUUID().toString());
        
        return refreshTokenRepository.save(refreshToken);
    }

    public Optional<RefreshToken> findByToken(String token) {
        try {
            // Extrai o ID do token (formato "id.hash")
            String[] parts = token.split("\\.", 2);
            if (parts.length != 2) {
                return Optional.empty();
            }
            
            Long id = Long.parseLong(parts[0]);
            Optional<RefreshToken> refreshToken = refreshTokenRepository.findById(id);
            
            // Verifica se o token gerado pela entidade corresponde ao token fornecido
            if (refreshToken.isPresent() && token.equals(refreshToken.get().getToken())) {
                return refreshToken;
            }
            
            return Optional.empty();
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    public RefreshToken verifyExpiration(RefreshToken token) {
        if (token.getExpiryDate().compareTo(Instant.now()) < 0) {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
            throw new TokenRefreshException(token.getToken(), 
                    "Refresh token expirado. Faça login novamente.");
        }
        
        if (Boolean.TRUE.equals(token.getRevoked())) {
            throw new TokenRefreshException(token.getToken(), 
                    "Refresh token foi revogado. Faça login novamente.");
        }
        
        return token;
    }

    @Transactional
    public int deleteByUserId(Long userId) {
        return refreshTokenRepository.deleteByUserId(userId);
    }
    
    public Optional<RefreshToken> findByUser(User user) {
        return refreshTokenRepository.findByUser(user);
    }
}