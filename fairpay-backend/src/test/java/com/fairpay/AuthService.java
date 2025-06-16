package com.fairpay.service;

import com.fairpay.dto.RegisterRequestDTO;
import com.fairpay.model.User;
import com.fairpay.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.regex.Pattern;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    
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
    
    // Você pode adicionar aqui outros métodos relacionados à autenticação
    // como login, recuperação de senha, etc.
}