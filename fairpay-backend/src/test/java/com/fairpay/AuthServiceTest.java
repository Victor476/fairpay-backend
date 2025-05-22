package com.fairpay;

import com.fairpay.repository.UserRepository;
import com.fairpay.service.AuthService;
import com.fairpay.dto.RegisterRequestDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    private AuthService authService;
    private UserRepository userRepository;
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);
        authService = new AuthService(userRepository, passwordEncoder);
    }


    @Test
    void shouldRegisterUserSuccessfully() {
        RegisterRequestDTO dto = new RegisterRequestDTO();
        dto.setName("João1");
        dto.setEmail("joao1@example.com");
        dto.setPassword("senha123");
        dto.setConfirmPassword("senha123");

        when(userRepository.existsByEmail("joao1@example.com")).thenReturn(false);
        when(passwordEncoder.encode("senha123")).thenReturn("hashedSenha");

        authService.register(dto);

        verify(userRepository, times(1)).save(Mockito.argThat(user ->
                user.getName().equals("João1")
                        && user.getEmail().equals("joao1@example.com")
                        && user.getPassword().equals("hashedSenha")
                        && user.getCreatedAt() != null
        ));
    }

    @Test
    void shouldThrowIfPasswordsDoNotMatch() {
        RegisterRequestDTO dto = new RegisterRequestDTO();
        dto.setPassword("abc");
        dto.setConfirmPassword("def");

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.register(dto);
        });

        assertEquals("Senhas não coincidem.", exception.getMessage());
    }

    @Test
    void shouldThrowIfEmailAlreadyExists() {
        RegisterRequestDTO dto = new RegisterRequestDTO();
        dto.setEmail("joao1@example.com");
        dto.setPassword("senha123");
        dto.setConfirmPassword("senha123");

        when(userRepository.existsByEmail("joao1@example.com")).thenReturn(true);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.register(dto);
        });

        assertEquals("E-mail já está em uso.", exception.getMessage());
    }
}
