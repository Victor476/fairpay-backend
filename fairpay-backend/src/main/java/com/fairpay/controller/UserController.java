package com.fairpay.controller;

import com.fairpay.dto.UserProfileRequestDTO;
import com.fairpay.dto.UserProfileResponseDTO;
import com.fairpay.dto.ChangePasswordRequestDTO;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * Obter dados do usuário autenticado
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal AuthenticatedUser user) {
        try {
            UserProfileResponseDTO userProfile = userService.getUserProfile(user.getId());
            return ResponseEntity.ok(userProfile);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar dados do usuário"));
        }
    }

    /**
     * Editar perfil do usuário autenticado
     */
    @PutMapping("/me")
    public ResponseEntity<?> updateCurrentUser(
            @Valid @RequestBody UserProfileRequestDTO request,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            UserProfileResponseDTO updatedUser = userService.updateUserProfile(user.getId(), request);
            return ResponseEntity.ok(updatedUser);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao atualizar perfil do usuário"));
        }
    }

    /**
     * Alterar senha do usuário autenticado
     */
    @PutMapping("/me/password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordRequestDTO request,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            userService.changePassword(user.getId(), request);
            return ResponseEntity.ok(Map.of("message", "Senha alterada com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao alterar senha"));
        }
    }

    /**
     * Excluir conta do usuário autenticado
     */
    @DeleteMapping("/me")
    public ResponseEntity<?> deleteCurrentUser(@AuthenticationPrincipal AuthenticatedUser user) {
        try {
            userService.deleteUser(user.getId());
            return ResponseEntity.ok(Map.of("message", "Conta excluída com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao excluir conta"));
        }
    }

    /**
     * Obter dados públicos de um usuário específico
     */
    @GetMapping("/{userId}")
    public ResponseEntity<?> getUserById(
            @PathVariable Long userId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            UserProfileResponseDTO userProfile = userService.getPublicUserProfile(userId, user.getId());
            return ResponseEntity.ok(userProfile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar dados do usuário"));
        }
    }
}
