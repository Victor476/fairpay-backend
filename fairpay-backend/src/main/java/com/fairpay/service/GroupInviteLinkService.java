package com.fairpay.service;

import com.fairpay.dto.GroupInviteLinkRequestDTO;
import com.fairpay.dto.GroupInviteLinkResponseDTO;
import com.fairpay.dto.GroupJoinResponseDTO;
import com.fairpay.dto.GroupResponseDTO;
import com.fairpay.model.Group;
import com.fairpay.model.GroupInviteLink;
import com.fairpay.model.User;
import com.fairpay.repository.GroupInviteLinkRepository;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class GroupInviteLinkService {
    
    @Value("${app.baseUrl:http://localhost:8090}")
    private String baseUrl;
    
    @Autowired
    private GroupRepository groupRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private GroupInviteLinkRepository inviteLinkRepository;
    
    /**
     * Gera um link de convite para um grupo
     */
    @Transactional
    public GroupInviteLinkResponseDTO generateInviteLink(Long groupId, Long userId, GroupInviteLinkRequestDTO requestDTO) {
        // Verificar se o grupo existe
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Verificar se o usuário existe
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));
        
        // Verificar se o usuário é administrador do grupo
        if (!group.getCreatedBy().getId().equals(userId)) {
            throw new IllegalArgumentException("Apenas o criador do grupo pode gerar links de convite");
        }
        
        // Gerar token único
        String token = UUID.randomUUID().toString();
        
        // Criar entidade GroupInviteLink
        GroupInviteLink inviteLink = new GroupInviteLink();
        inviteLink.setToken(token);
        inviteLink.setGroup(group);
        inviteLink.setCreatedBy(user);
        inviteLink.setCreatedAt(LocalDateTime.now());
        
        // Definir data de expiração
        int expiresInDays = requestDTO != null && requestDTO.getExpiresInDays() != null ? 
                requestDTO.getExpiresInDays() : 7;
        inviteLink.setExpiresAt(LocalDateTime.now().plusDays(expiresInDays));
        
        // Salvar no banco
        GroupInviteLink savedLink = inviteLinkRepository.save(inviteLink);
        
        // Montar resposta
        GroupInviteLinkResponseDTO responseDTO = new GroupInviteLinkResponseDTO();
        responseDTO.setInviteLink(baseUrl + "/api/groups/join/" + savedLink.getToken());
        responseDTO.setExpiresAt(savedLink.getExpiresAt());
        
        return responseDTO;
    }
    
    /**
     * Processa a aceitação de um convite de grupo
     */
    @Transactional
    public GroupJoinResponseDTO processJoinRequest(String token, Long userId) {
        // Verificar se o token existe e está ativo
        GroupInviteLink inviteLink = inviteLinkRepository.findByTokenAndIsActiveTrue(token)
                .orElseThrow(() -> new EntityNotFoundException("Link de convite inválido"));
        
        // Verificar se o link expirou
        if (inviteLink.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalStateException("Link de convite expirado");
        }
        
        // Verificar se o usuário existe
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));
        
        // Obter o grupo
        Group group = inviteLink.getGroup();
        
        // Verificar se o usuário já é membro
        if (group.isMember(user)) {
            throw new IllegalStateException("Você já é membro deste grupo");
        }
        
        // Adicionar usuário ao grupo
        group.addMember(user);
        groupRepository.save(group);
        
        // Marcar o link como usado (opcional)
        inviteLink.setUsedAt(LocalDateTime.now());
        inviteLinkRepository.save(inviteLink);
        
        // Preparar resposta
        GroupJoinResponseDTO responseDTO = new GroupJoinResponseDTO();
        responseDTO.setMessage("Você entrou com sucesso no grupo '" + group.getName() + "'");
        
        GroupResponseDTO groupDTO = new GroupResponseDTO(group);
        responseDTO.setGroup(groupDTO);
        
        return responseDTO;
    }
}
