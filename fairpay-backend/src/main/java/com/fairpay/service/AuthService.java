package com.fairpay.service;

import com.fairpay.dto.LoginRequestDTO;
import com.fairpay.dto.RegisterRequestDTO;
import com.fairpay.dto.TokenResponseDTO;
import com.fairpay.exception.TokenRefreshException;
import com.fairpay.model.RefreshToken;
import com.fairpay.model.User;
import com.fairpay.repository.RefreshTokenRepository;
import com.fairpay.repository.UserRepository;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;  // <-- Adicione esta importação


import java.time.LocalDateTime;
import java.util.regex.Pattern;

@Service
public class AuthService {

    

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @Autowired
    private RefreshTokenService refreshTokenService;
    
    // Regex para validação de e-mail (padrão simples)
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

    public User register(RegisterRequestDTO registerDto) {
        // Validar nome
        if (registerDto.getName() == null || registerDto.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Nome não pode ser vazio.");
        }
        
        // Validar formato de e-mail
        if (registerDto.getEmail() == null || 
            !EMAIL_PATTERN.matcher(registerDto.getEmail()).matches()) {
            throw new IllegalArgumentException("Formato de e-mail inválido.");
        }
        
        // Verificar se e-mail já existe
        if (userRepository.existsByEmail(registerDto.getEmail())) {
            throw new RuntimeException("E-mail já está em uso.");
        }
        
        // Validar se as senhas são iguais
        if (!registerDto.getPassword().equals(registerDto.getConfirmPassword())) {
            throw new IllegalArgumentException("Senhas não coincidem.");
        }
        
        // Criar novo usuário
        User newUser = new User();
        newUser.setName(registerDto.getName());
        newUser.setEmail(registerDto.getEmail());
        newUser.setPassword(passwordEncoder.encode(registerDto.getPassword()));
        newUser.setCreatedAt(LocalDateTime.now());
        
        // Salvar e retornar o usuário
        return userRepository.save(newUser);
    }
    
    public TokenResponseDTO login(LoginRequestDTO loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));
    
        SecurityContextHolder.getContext().setAuthentication(authentication);
        AuthenticatedUser userDetails = (AuthenticatedUser) authentication.getPrincipal();
    
        String accessToken = tokenProvider.generateAccessToken(userDetails, userDetails.getId());
        
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userDetails.getId());
    
        return TokenResponseDTO.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.getToken()) // Agora usa o método getToken()
                .tokenType("Bearer")
                .build();
    }

    public TokenResponseDTO refreshToken(String refreshTokenStr) {
        return refreshTokenService.findByToken(refreshTokenStr)
                .map(token -> refreshTokenService.verifyExpiration(token))
                .map(refreshToken -> {
                    User user = refreshToken.getUser();
                    AuthenticatedUser userDetails = new AuthenticatedUser(
                            user.getId(),
                            user.getEmail(),
                            user.getPassword(),
                            java.util.Collections.emptyList()
                    );
                    
                    String accessToken = tokenProvider.generateAccessToken(userDetails, user.getId());
                    
                    return TokenResponseDTO.builder()
                            .accessToken(accessToken)
                            .refreshToken(refreshTokenStr)
                            .tokenType("Bearer")
                            .build();
                })
                .orElseThrow(() -> new TokenRefreshException(refreshTokenStr, 
                        "Refresh token não encontrado na base de dados"));
    }
    
    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public void logout(Long userId) {
        userRepository.findById(userId).ifPresent(user -> {
            refreshTokenService.findByUser(user).ifPresent(token -> {
                token.setRevoked(true);
                refreshTokenRepository.save(token);
            });
        });
}
}