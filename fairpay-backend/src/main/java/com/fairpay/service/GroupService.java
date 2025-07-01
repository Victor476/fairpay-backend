package com.fairpay.service;

import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.model.Group;
import com.fairpay.model.GroupMember;
import com.fairpay.model.User;
import com.fairpay.repository.GroupMemberRepository;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
        groupMemberRepository.save(creatorMember);

        return savedGroup;
    }    public List<Object> getGroupMembers(Long groupId, Long currentUserId) {
        // Verificar se o usuário faz parte do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        // Buscar todos os membros do grupo
        List<GroupMember> groupMembers = groupMemberRepository.findByGroupId(groupId);
        
        return groupMembers.stream()
                .map(gm -> new Object() {
                    public final Long id = gm.getUser().getId();
                    public final String name = gm.getUser().getName();
                    public final String email = gm.getUser().getEmail();
                })
                .collect(Collectors.toList());
    }

    public List<Group> getUserGroups(Long userId) {
        // Buscar todos os grupos onde o usuário é membro
        List<GroupMember> groupMembers = groupMemberRepository.findByUserId(userId);
        
        return groupMembers.stream()
                .map(GroupMember::getGroup)
                .collect(Collectors.toList());
    }
}
