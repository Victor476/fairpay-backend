package com.fairpay.service;

import com.fairpay.dto.ChangePasswordRequestDTO;
import com.fairpay.dto.UserProfileRequestDTO;
import com.fairpay.dto.UserProfileResponseDTO;
import com.fairpay.model.User;
import com.fairpay.repository.GroupMemberRepository;
import com.fairpay.repository.RefreshTokenRepository;
import com.fairpay.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.regex.Pattern;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private GroupMemberRepository groupMemberRepository;
    
    @Autowired
    private RefreshTokenRepository refreshTokenRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    // Regex para validação de e-mail
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

    /**
     * Obter perfil completo do usuário (dados privados)
     */
    public UserProfileResponseDTO getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
        
        return convertToProfileResponse(user, false);
    }

    /**
     * Obter perfil público do usuário (dados limitados)
     */
    public UserProfileResponseDTO getPublicUserProfile(Long userId, Long requesterId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
        
        // Verificar se o solicitante tem permissão para ver este perfil
        // Por enquanto, qualquer usuário autenticado pode ver perfis públicos
        // Futuramente pode-se adicionar lógica de privacidade
        
        return convertToProfileResponse(user, true);
    }

    /**
     * Atualizar perfil do usuário
     */
    @Transactional
    public UserProfileResponseDTO updateUserProfile(Long userId, UserProfileRequestDTO request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
        
        // Validar dados
        validateProfileUpdate(request, userId);
        
        // Atualizar campos
        user.setName(request.getName().trim());
        user.setEmail(request.getEmail().trim().toLowerCase());
        
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().trim().isEmpty()) {
            user.setPhoneNumber(request.getPhoneNumber().trim());
        }
        
        if (request.getProfileImageUrl() != null && !request.getProfileImageUrl().trim().isEmpty()) {
            user.setProfileImageUrl(request.getProfileImageUrl().trim());
        }
        
        User updatedUser = userRepository.save(user);
        return convertToProfileResponse(updatedUser, false);
    }

    /**
     * Alterar senha do usuário
     */
    @Transactional
    public void changePassword(Long userId, ChangePasswordRequestDTO request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
        
        // Validar senha atual
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Senha atual incorreta");
        }
        
        // Validar nova senha
        if (request.getNewPassword().length() < 6) {
            throw new IllegalArgumentException("Nova senha deve ter pelo menos 6 caracteres");
        }
        
        // Atualizar senha
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
        
        // Invalidar todos os refresh tokens do usuário (forçar novo login)
        refreshTokenRepository.deleteByUserId(userId);
    }

    /**
     * Excluir conta do usuário
     */
    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));
        
        // Verificar se o usuário não é o único admin de algum grupo
        boolean isOnlyAdminInAnyGroup = groupMemberRepository.existsAsOnlyAdmin(userId);
        if (isOnlyAdminInAnyGroup) {
            throw new IllegalArgumentException("Não é possível excluir a conta. Você é o único administrador de um ou mais grupos. Transfira a administração ou exclua os grupos primeiro.");
        }
        
        // Remover de todos os grupos
        groupMemberRepository.deleteByUserId(userId);
        
        // Remover refresh tokens
        refreshTokenRepository.deleteByUserId(userId);
        
        // Excluir usuário
        userRepository.delete(user);
    }

    /**
     * Converter User para UserProfileResponseDTO
     */
    private UserProfileResponseDTO convertToProfileResponse(User user, boolean isPublicView) {
        UserProfileResponseDTO response = new UserProfileResponseDTO();
        response.setId(user.getId());
        response.setName(user.getName());
        response.setCreatedAt(user.getCreatedAt());
        response.setPublicView(isPublicView);
        
        if (!isPublicView) {
            // Dados privados (apenas para o próprio usuário)
            response.setEmail(user.getEmail());
            response.setPhoneNumber(user.getPhoneNumber());
            response.setLastLogin(user.getLastLogin());
        } else {
            // Dados públicos (para outros usuários)
            // Email pode ser mostrado em contexto de grupos, mas pode ser configurável no futuro
            response.setEmail(user.getEmail());
        }
        
        response.setProfileImageUrl(user.getProfileImageUrl());
        
        return response;
    }

    /**
     * Validar dados de atualização do perfil
     */
    private void validateProfileUpdate(UserProfileRequestDTO request, Long userId) {
        // Validar nome
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Nome é obrigatório");
        }
        
        // Validar email
        if (request.getEmail() == null || !EMAIL_PATTERN.matcher(request.getEmail()).matches()) {
            throw new IllegalArgumentException("Email inválido");
        }
        
        // Verificar se email já está em uso por outro usuário
        userRepository.findByEmail(request.getEmail().toLowerCase().trim())
                .ifPresent(existingUser -> {
                    if (!existingUser.getId().equals(userId)) {
                        throw new IllegalArgumentException("Este email já está em uso por outro usuário");
                    }
                });
    }
}
