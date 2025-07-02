package com.fairpay.service;

import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.dto.GroupResponseDTO;
import com.fairpay.dto.GroupMemberResponseDTO;
import com.fairpay.model.Group;
import com.fairpay.model.GroupMember;
import com.fairpay.model.User;
import com.fairpay.repository.ExpenseRepository;
import com.fairpay.repository.GroupMemberRepository;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GroupService {

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GroupMemberRepository groupMemberRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;

    public Group createGroup(GroupRequestDTO groupRequestDTO, Long creatorUserId) {
        // Buscar usuário criador
        User creator = userRepository.findById(creatorUserId)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));

        // Validar nome do grupo
        if (groupRequestDTO.getName() == null || groupRequestDTO.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("O nome do grupo não pode ser vazio.");
        }

        // Criar grupo
        Group group = new Group();
        group.setName(groupRequestDTO.getName());
        group.setDescription(groupRequestDTO.getDescription());
        group.setImageUrl(groupRequestDTO.getImageUrl());
        group.setCreatedBy(creator);
        group.setCreatedAt(Instant.now());

        Group savedGroup = groupRepository.save(group);

        // Automaticamente adicionar o criador como membro do grupo
        GroupMember creatorMember = new GroupMember();
        creatorMember.setUser(creator);
        creatorMember.setGroup(savedGroup);
        creatorMember.setRole("admin"); // Criador é automaticamente admin
        creatorMember.setJoinedAt(Instant.now());
        groupMemberRepository.save(creatorMember);

        return savedGroup;
    }    public List<GroupMemberResponseDTO> getGroupMembers(Long groupId, Long currentUserId) {
        // Verificar se o usuário faz parte do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        // Buscar todos os membros do grupo
        List<GroupMember> groupMembers = groupMemberRepository.findByGroupId(groupId);
        
        return groupMembers.stream()
                .map(gm -> new GroupMemberResponseDTO(
                    gm.getUser().getId(),
                    gm.getUser().getName(),
                    gm.getUser().getEmail(),
                    gm.getRole()
                ))
                .collect(Collectors.toList());
    }

    public List<Group> getUserGroups(Long userId) {
        // Buscar todos os grupos onde o usuário é membro
        List<GroupMember> groupMembers = groupMemberRepository.findByUserId(userId);
        
        return groupMembers.stream()
                .map(GroupMember::getGroup)
                .collect(Collectors.toList());
    }

    /**
     * Obter detalhes específicos de um grupo
     */
    public GroupResponseDTO getGroupDetails(Long groupId, Long currentUserId) {
        // Verificar se o usuário faz parte do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        return new GroupResponseDTO(group);
    }

    /**
     * Atualizar informações do grupo
     */
    @Transactional
    public GroupResponseDTO updateGroup(Long groupId, GroupRequestDTO request, Long currentUserId) {
        // Verificar se o usuário é admin do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupIdAndRole(currentUserId, groupId, "admin")) {
            throw new IllegalArgumentException("Apenas administradores podem editar o grupo");
        }
        
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Validar e atualizar dados
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Nome do grupo é obrigatório");
        }
        
        group.setName(request.getName().trim());
        group.setDescription(request.getDescription());
        group.setImageUrl(request.getImageUrl());
        
        Group updatedGroup = groupRepository.save(group);
        return new GroupResponseDTO(updatedGroup);
    }

    /**
     * Excluir grupo
     */
    @Transactional
    public void deleteGroup(Long groupId, Long currentUserId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Verificar se o usuário é o criador do grupo
        if (!group.getCreatedBy().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("Apenas o criador pode excluir o grupo");
        }
        
        // Verificar se há despesas pendentes no grupo
        long expenseCount = expenseRepository.countByGroupId(groupId);
        if (expenseCount > 0) {
            throw new IllegalArgumentException("Não é possível excluir o grupo. Existem despesas registradas. Exclua todas as despesas primeiro.");
        }
        
        // Remover todos os membros do grupo
        groupMemberRepository.deleteByGroupId(groupId);
        
        // Excluir o grupo
        groupRepository.delete(group);
    }

    /**
     * Remover membro do grupo
     */
    @Transactional
    public void removeMember(Long groupId, Long userIdToRemove, Long currentUserId) {
        // Verificar se o usuário atual é admin do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupIdAndRole(currentUserId, groupId, "admin")) {
            throw new IllegalArgumentException("Apenas administradores podem remover membros");
        }
        
        // Verificar se o grupo existe
        if (!groupRepository.existsById(groupId)) {
            throw new EntityNotFoundException("Grupo não encontrado");
        }
        
        // Verificar se o usuário a ser removido faz parte do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(userIdToRemove, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        // Não permitir remover o criador do grupo
        Group group = groupRepository.findById(groupId).get();
        if (group.getCreatedBy().getId().equals(userIdToRemove)) {
            throw new IllegalArgumentException("Não é possível remover o criador do grupo");
        }
        
        // Remover o membro
        groupMemberRepository.deleteByUserIdAndGroupId(userIdToRemove, groupId);
    }

    /**
     * Sair do grupo
     */
    @Transactional
    public void leaveGroup(Long groupId, Long currentUserId) {
        // Verificar se o grupo existe
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Verificar se o usuário faz parte do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        // Não permitir que o criador saia do grupo
        if (group.getCreatedBy().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("O criador do grupo não pode sair. Para sair, transfira a criação para outro membro ou exclua o grupo.");
        }
        
        // Verificar se não é o único admin
        if (groupMemberRepository.existsByUserIdAndGroupIdAndRole(currentUserId, groupId, "admin")) {
            long adminCount = groupMemberRepository.countAdminsByGroupId(groupId);
            if (adminCount <= 1) {
                throw new IllegalArgumentException("Você é o único administrador do grupo. Promova outro membro a administrador antes de sair.");
            }
        }
        
        // Remover o usuário do grupo
        groupMemberRepository.deleteByUserIdAndGroupId(currentUserId, groupId);
    }
    
    /**
     * Adicionar membro diretamente ao grupo
     */
    @Transactional
    public void addMember(Long groupId, Long userIdToAdd, String role, Long currentUserId) {
        // Verificar se o grupo existe
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Verificar se o usuário atual é admin ou criador
        if (!isUserAdminOfGroup(currentUserId, groupId) && !group.getCreatedBy().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("Apenas administradores podem adicionar membros");
        }
        
        // Verificar se o usuário a ser adicionado existe
        User userToAdd = userRepository.findById(userIdToAdd)
                .orElseThrow(() -> new EntityNotFoundException("Usuário a ser adicionado não encontrado"));
        
        // Verificar se o usuário já não faz parte do grupo
        if (groupMemberRepository.existsByUserIdAndGroupId(userIdToAdd, groupId)) {
            throw new IllegalArgumentException("Usuário já faz parte do grupo");
        }
        
        // Validar role
        if (role == null || (!role.equals("member") && !role.equals("admin"))) {
            throw new IllegalArgumentException("Papel deve ser 'member' ou 'admin'");
        }
        
        // Criar novo membro
        GroupMember groupMember = new GroupMember();
        groupMember.setGroup(group);
        groupMember.setUser(userToAdd);
        groupMember.setRole(role);
        groupMember.setJoinedAt(Instant.now());
        
        groupMemberRepository.save(groupMember);
    }
    
    /**
     * Alterar papel do membro
     */
    @Transactional
    public void updateMemberRole(Long groupId, Long userIdToUpdate, String newRole, Long currentUserId) {
        // Verificar se o grupo existe
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));
        
        // Verificar se o usuário atual é admin ou criador
        if (!isUserAdminOfGroup(currentUserId, groupId) && !group.getCreatedBy().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("Apenas administradores podem alterar papéis");
        }
        
        // Verificar se o usuário a ser atualizado existe no grupo
        GroupMember memberToUpdate = groupMemberRepository.findByUserIdAndGroupId(userIdToUpdate, groupId)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não faz parte do grupo"));
        
        // Validar novo role
        if (newRole == null || (!newRole.equals("member") && !newRole.equals("admin"))) {
            throw new IllegalArgumentException("Papel deve ser 'member' ou 'admin'");
        }
        
        // Não permitir que o usuário altere seu próprio papel
        if (currentUserId.equals(userIdToUpdate)) {
            throw new IllegalArgumentException("Você não pode alterar seu próprio papel");
        }
        
        // Se for remover admin, verificar se não é o único
        if (memberToUpdate.getRole().equals("admin") && newRole.equals("member")) {
            long adminCount = groupMemberRepository.countAdminsByGroupId(groupId);
            if (adminCount <= 1) {
                throw new IllegalArgumentException("Não é possível remover o último administrador do grupo");
            }
        }
        
        // Atualizar papel
        memberToUpdate.setRole(newRole);
        groupMemberRepository.save(memberToUpdate);
    }
    
    /**
     * Verificar se usuário é admin do grupo
     */
    private boolean isUserAdminOfGroup(Long userId, Long groupId) {
        return groupMemberRepository.existsByUserIdAndGroupIdAndRole(userId, groupId, "admin");
    }
}
