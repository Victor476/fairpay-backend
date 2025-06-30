package com.fairpay.controller;

import com.fairpay.dto.LoginRequestDTO;
import com.fairpay.dto.RefreshTokenRequestDTO;
import com.fairpay.dto.RegisterRequestDTO;
import com.fairpay.dto.TokenResponseDTO;
import com.fairpay.exception.TokenRefreshException;
import com.fairpay.model.User;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

import java.util.HashMap;
import java.util.Map; 

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequestDTO request, HttpServletRequest httpRequest) {
        // Registra o usuário e obtém o resultado
        User registeredUser = authService.register(request);
        
        // Cria o objeto de resposta no formato desejado
        var response = new Object() {
            public final boolean success = true;
            public final String message = "Usuário registrado com sucesso!";
            public final Object user = new Object() {
                public final Long id = registeredUser.getId();
                public final String name = registeredUser.getName();
                public final String email = registeredUser.getEmail();
            };
        };
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequestDTO loginRequest) {
        try {
            TokenResponseDTO tokenResponse = authService.login(loginRequest);
            return ResponseEntity.ok(tokenResponse);
        } catch (Exception e) {
            // Captura qualquer erro e retorna uma resposta mais informativa
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Falha na autenticação: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@Valid @RequestBody RefreshTokenRequestDTO request) {
        try {
            TokenResponseDTO response = authService.refreshToken(request.getRefreshToken());
            return ResponseEntity.ok(response);
        } catch (TokenRefreshException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser(@AuthenticationPrincipal AuthenticatedUser user) {
        if (user == null) {
            return ResponseEntity.ok().body("Usuário já estava deslogado");
        }
        
        Long userId = user.getId();
        authService.logout(userId);
        return ResponseEntity.ok().body("Logout realizado com sucesso!");
    }
}