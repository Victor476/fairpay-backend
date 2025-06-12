package com.fairpay.controller;

import com.fairpay.dto.RegisterRequestDTO;
import com.fairpay.model.User;
import com.fairpay.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequestDTO request, HttpServletRequest httpRequest) {
        System.out.println("Requisição para: " + httpRequest.getRequestURI());
        
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
            // Aqui você pode adicionar geração de token se tiver implementado JWT
            public final String token = generateDummyToken(registeredUser);
        };
        
        return ResponseEntity.ok(response);
    }
    
    // Método temporário para gerar um token fictício
    // Em produção, você teria uma implementação real de JWT
    private String generateDummyToken(User user) {
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTYiLCJuYW1lIjoiTm9tZSBkbyBVc3XDoXJpbyIsImlhdCI6MTUxNjIzOTAyMn0.exemplo_token_jwt";
    }
}