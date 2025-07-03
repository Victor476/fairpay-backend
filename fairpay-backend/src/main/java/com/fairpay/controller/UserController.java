package com.fairpay.controller;

import com.fairpay.security.AuthenticatedUser;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal AuthenticatedUser user) {
        if (user == null) {
            return ResponseEntity.status(401).body("Usuário não autenticado");
        }
        
        var response = new Object() {
            public final Long id = user.getId();
            public final String email = user.getUsername();
            public final String name = user.getName();
        };
        
        return ResponseEntity.ok(response);
    }
}
