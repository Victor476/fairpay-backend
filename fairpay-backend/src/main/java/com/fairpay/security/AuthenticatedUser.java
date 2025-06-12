package com.fairpay.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class AuthenticatedUser {

    public Long getUserId() {
        // Retorna um ID fixo (como se fosse o usuário autenticado)
        return 1L;
    }

    public String getUserName() {
        // Retorna um nome fixo
        return "Usuário Teste";
    }
}
