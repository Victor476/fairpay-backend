package com.fairpay.service;

import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.model.Group;
import com.fairpay.model.User;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class GroupService {

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private UserRepository userRepository;

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

        return groupRepository.save(group);
    }
}
