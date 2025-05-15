package com.fairpay.User;

import com.fairpay.User.dto.RegisterRequestDTO;
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
    public ResponseEntity<String> register(@RequestBody RegisterRequestDTO request, HttpServletRequest httpRequest) {
        System.out.println("Requisição para: " + httpRequest.getRequestURI());
        authService.register(request);
        return ResponseEntity.ok("Usuário registrado com sucesso!");

    }
}
