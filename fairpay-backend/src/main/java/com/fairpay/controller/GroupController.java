package com.fairpay.controller;

import com.fairpay.dto.GroupBalanceDTO;
import com.fairpay.dto.GroupRequestDTO;
import com.fairpay.dto.GroupResponseDTO;
import com.fairpay.dto.AddMemberRequestDTO;
import com.fairpay.dto.UpdateMemberRoleRequestDTO;
import com.fairpay.model.Group;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.GroupBalanceService;
import com.fairpay.service.GroupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    @Autowired
    private GroupService groupService;

    @Autowired
    private GroupBalanceService groupBalanceService;

    @PostMapping
    public ResponseEntity<?> createGroup(
            @RequestBody GroupRequestDTO groupRequestDTO,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            Group createdGroup = groupService.createGroup(groupRequestDTO, user.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(createdGroup));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao criar grupo."));
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

    @GetMapping
    public ResponseEntity<?> getUserGroups(@AuthenticationPrincipal AuthenticatedUser user) {
        try {
            var groups = groupService.getUserGroups(user.getId());
            var responseDTOs = groups.stream()
                    .map(this::toResponse)
                    .toList();
            return ResponseEntity.ok(responseDTOs);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar grupos do usuário"));
        }
    }

    @GetMapping("/{groupId}/members")
    public ResponseEntity<?> getGroupMembers(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            var members = groupService.getGroupMembers(groupId, user.getId());
            return ResponseEntity.ok(members);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar membros do grupo"));
        }
    }

    @GetMapping("/{groupId}/balances")
    public ResponseEntity<?> getGroupBalances(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            List<GroupBalanceDTO> balances = groupBalanceService.calculateGroupBalances(groupId, user.getId());
            return ResponseEntity.ok(balances);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao calcular saldos do grupo"));
        }
    }

    @GetMapping("/{groupId}")
    public ResponseEntity<?> getGroupDetails(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            GroupResponseDTO groupDetails = groupService.getGroupDetails(groupId, user.getId());
            return ResponseEntity.ok(groupDetails);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar detalhes do grupo"));
        }
    }

    @PutMapping("/{groupId}")
    public ResponseEntity<?> updateGroup(
            @PathVariable Long groupId,
            @RequestBody GroupRequestDTO groupRequestDTO,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            GroupResponseDTO updatedGroup = groupService.updateGroup(groupId, groupRequestDTO, user.getId());
            return ResponseEntity.ok(updatedGroup);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao atualizar grupo"));
        }
    }

    @DeleteMapping("/{groupId}")
    public ResponseEntity<?> deleteGroup(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            groupService.deleteGroup(groupId, user.getId());
            return ResponseEntity.ok(Map.of("message", "Grupo excluído com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao excluir grupo"));
        }
    }

    @DeleteMapping("/{groupId}/members/{userId}")
    public ResponseEntity<?> removeMember(
            @PathVariable Long groupId,
            @PathVariable Long userId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            groupService.removeMember(groupId, userId, user.getId());
            return ResponseEntity.ok(Map.of("message", "Membro removido com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao remover membro"));
        }
    }

    @PostMapping("/{groupId}/leave")
    public ResponseEntity<?> leaveGroup(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            groupService.leaveGroup(groupId, user.getId());
            return ResponseEntity.ok(Map.of("message", "Você saiu do grupo com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao sair do grupo"));
        }
    }

    @PostMapping("/{groupId}/members")
    public ResponseEntity<?> addMember(
            @PathVariable Long groupId,
            @RequestBody AddMemberRequestDTO request,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            groupService.addMember(groupId, request.getUserId(), request.getRole(), user.getId());
            return ResponseEntity.ok(Map.of("message", "Membro adicionado com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao adicionar membro"));
        }
    }

    @PutMapping("/{groupId}/members/{userId}")
    public ResponseEntity<?> updateMemberRole(
            @PathVariable Long groupId,
            @PathVariable Long userId,
            @RequestBody UpdateMemberRoleRequestDTO request,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            groupService.updateMemberRole(groupId, userId, request.getRole(), user.getId());
            return ResponseEntity.ok(Map.of("message", "Papel do membro atualizado com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao atualizar papel do membro"));
        }
    }
}
