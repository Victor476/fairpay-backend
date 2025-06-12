package com.fairpay.controller;

import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.dto.GroupResponseDTO;
import com.fairpay.model.Group;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.GroupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
    
@RestController
@RequestMapping("/api/groups")
public class GroupController {

    @Autowired
    private GroupService groupService;

    @PostMapping
    public ResponseEntity<?> createGroup(@RequestBody GroupRequestDTO groupRequestDTO) {
        try {
            Long authenticatedUserId = 1L; // ID simulado

            Group createdGroup = groupService.createGroup(groupRequestDTO, authenticatedUserId);
            return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(createdGroup));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erro ao criar grupo.");
        }
    }

    private Object toResponse(Group group) {
        return new Object() {
            public final Long id = group.getId();
            public final String name = group.getName();
            public final String description = group.getDescription();
            public final String imageUrl = group.getImageUrl();
            public final java.time.Instant createdAt = group.getCreatedAt();
            public final Object createdBy = new Object() {
                public final Long id = group.getCreatedBy().getId();
                public final String name = group.getCreatedBy().getName();
            };
        };
    }
}
