package com.fairpay.controller;

import com.fairpay.dto.GroupInviteLinkRequestDTO;
import com.fairpay.dto.GroupInviteLinkResponseDTO;
import com.fairpay.dto.GroupJoinResponseDTO;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.GroupInviteLinkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/groups")
public class GroupInviteController {
    
    @Autowired
    private GroupInviteLinkService inviteLinkService;
    
    /**
     * Endpoint para gerar link de convite
     */
    @PostMapping("/{groupId}/invite-link")
    public ResponseEntity<GroupInviteLinkResponseDTO> generateInviteLink(
            @PathVariable Long groupId,
            @RequestBody(required = false) GroupInviteLinkRequestDTO requestDTO,
            @AuthenticationPrincipal AuthenticatedUser currentUser) {
        
        // Verificar se request é nulo - criar um novo se for
        if (requestDTO == null) {
            requestDTO = new GroupInviteLinkRequestDTO();
        }
        
        GroupInviteLinkResponseDTO responseDTO = inviteLinkService.generateInviteLink(
            groupId, 
            currentUser.getId(), 
            requestDTO
        );
        
        return ResponseEntity.ok(responseDTO);
    }
    
    /**
     * Endpoint para aceitar convite e entrar no grupo
     */
    @GetMapping("/join/{token}")
    public ResponseEntity<GroupJoinResponseDTO> joinGroup(
            @PathVariable String token,
            @AuthenticationPrincipal AuthenticatedUser currentUser) {
        
        GroupJoinResponseDTO responseDTO = inviteLinkService.processJoinRequest(
            token, 
            currentUser.getId()
        );
        
        return ResponseEntity.ok(responseDTO);
    }
}
