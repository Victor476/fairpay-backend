package com.fairpay.controller;

import com.fairpay.dto.ExpenseRequestDTO;
import com.fairpay.dto.ExpenseResponseDTO;
import com.fairpay.model.Expense;
import com.fairpay.security.AuthenticatedUser;
import com.fairpay.service.ExpenseService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/expenses")
public class ExpenseController {

    @Autowired
    private ExpenseService expenseService;

    @PostMapping
    public ResponseEntity<?> createExpense(
            @Valid @RequestBody ExpenseRequestDTO expenseRequestDTO,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            Expense expense = expenseService.createExpense(expenseRequestDTO, user.getId());
            ExpenseResponseDTO response = expenseService.convertToResponseDTO(expense);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro interno do servidor"));
        }
    }

    @GetMapping("/group/{groupId}")
    public ResponseEntity<?> getGroupExpenses(
            @PathVariable Long groupId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            var expenses = expenseService.getExpensesByGroup(groupId, user.getId());
            var responseDTOs = expenses.stream()
                    .map(expenseService::convertToResponseDTO)
                    .toList();
            return ResponseEntity.ok(responseDTOs);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar despesas"));
        }
    }

    @PostMapping("/validate-participants")
    public ResponseEntity<?> validateParticipants(
            @RequestBody Map<String, Object> request,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            Long groupId = Long.valueOf(request.get("groupId").toString());
            @SuppressWarnings("unchecked")
            List<String> participantEmails = (List<String>) request.get("participants");

            List<String> validParticipants = expenseService.validateParticipants(groupId, participantEmails, user.getId());

            return ResponseEntity.ok(Map.of("validParticipants", validParticipants));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao validar participantes"));
        }
    }

    @PutMapping("/{expenseId}")
    public ResponseEntity<?> updateExpense(
            @PathVariable Long expenseId,
            @Valid @RequestBody ExpenseRequestDTO expenseRequestDTO,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            ExpenseResponseDTO response = expenseService.updateExpense(expenseId, expenseRequestDTO, user.getId());
            return ResponseEntity.ok(response);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro interno do servidor"));
        }
    }

    @DeleteMapping("/{expenseId}")
    public ResponseEntity<?> deleteExpense(
            @PathVariable Long expenseId,
            @AuthenticationPrincipal AuthenticatedUser user) {
        try {
            expenseService.deleteExpense(expenseId, user.getId());
            return ResponseEntity.ok(Map.of("message", "Despesa excluída com sucesso"));
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro interno do servidor"));
        }
    }
}