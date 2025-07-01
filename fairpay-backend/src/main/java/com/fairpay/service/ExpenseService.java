package com.fairpay.service;

import com.fairpay.dto.ExpenseRequestDTO;
import com.fairpay.dto.ExpenseResponseDTO;
import com.fairpay.model.Expense;
import com.fairpay.model.ExpenseParticipant;
import com.fairpay.model.Group;
import com.fairpay.model.User;
import com.fairpay.repository.ExpenseRepository;
import com.fairpay.repository.ExpenseParticipantRepository;
import com.fairpay.repository.GroupRepository;
import com.fairpay.repository.GroupMemberRepository;
import com.fairpay.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
public class ExpenseService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private ExpenseParticipantRepository expenseParticipantRepository;

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private GroupMemberRepository groupMemberRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public Expense createExpense(ExpenseRequestDTO dto, Long currentUserId) {
        // Validações
        validateExpenseRequest(dto);

        // Buscar entidades
        Group group = groupRepository.findById(dto.getGroupId())
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));

        User paidByUser = userRepository.findByEmail(dto.getPayer())
                .orElseThrow(() -> new EntityNotFoundException("Usuário pagador não encontrado"));
        
        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("Usuário atual não encontrado"));

        // Verificar se o usuário atual faz parte do grupo
        if (!isUserMemberOfGroup(currentUserId, group.getId())) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }

        // Verificar se o usuário pagador faz parte do grupo
        if (!isUserMemberOfGroup(paidByUser.getId(), group.getId())) {
            throw new IllegalArgumentException("Usuário pagador não faz parte do grupo");
        }

        // Validar se todos os participantes fazem parte do grupo
        for (String participantEmail : dto.getParticipants()) {
            User participant = userRepository.findByEmail(participantEmail)
                    .orElseThrow(() -> new EntityNotFoundException("Participante não encontrado: " + participantEmail));
            
            if (!isUserMemberOfGroup(participant.getId(), group.getId())) {
                throw new IllegalArgumentException("Participante " + participantEmail + " não faz parte do grupo");
            }
        }

        // Criar despesa
        Expense expense = new Expense();
        expense.setDescription(dto.getDescription());
        expense.setAmount(dto.getTotalAmount());
        expense.setExpenseDate(dto.getDate());
        expense.setGroup(group);
        expense.setPaidByUser(paidByUser);
        expense.setCreatedBy(currentUser);
        expense.setCreatedAt(Instant.now());

        if (dto.getCategoryId() != null) {
            // Buscar categoria se fornecida
            expense.setCategoryId(dto.getCategoryId());
        }

        Expense savedExpense = expenseRepository.save(expense);

        // Criar participantes da despesa
        createExpenseParticipants(savedExpense, dto.getParticipants(), dto.getTotalAmount());

        return savedExpense;
    }

    private void validateExpenseRequest(ExpenseRequestDTO dto) {
        if (dto.getDescription() == null || dto.getDescription().trim().isEmpty()) {
            throw new IllegalArgumentException("Descrição da despesa é obrigatória");
        }

        if (dto.getTotalAmount() == null || dto.getTotalAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Valor da despesa deve ser positivo");
        }

        if (dto.getGroupId() == null) {
            throw new IllegalArgumentException("Grupo é obrigatório");
        }

        if (dto.getPayer() == null || dto.getPayer().trim().isEmpty()) {
            throw new IllegalArgumentException("Email do usuário pagador é obrigatório");
        }

        if (dto.getParticipants() == null || dto.getParticipants().isEmpty()) {
            throw new IllegalArgumentException("Pelo menos um participante deve ser selecionado");
        }
    }

    private void createExpenseParticipants(Expense expense, List<String> participantEmails, BigDecimal totalAmount) {
        BigDecimal sharePerParticipant = totalAmount.divide(
                BigDecimal.valueOf(participantEmails.size()), 
                2, 
                RoundingMode.HALF_UP
        );

        for (String participantEmail : participantEmails) {
            User participant = userRepository.findByEmail(participantEmail)
                    .orElseThrow(() -> new EntityNotFoundException("Participante não encontrado: " + participantEmail));

            ExpenseParticipant expenseParticipant = new ExpenseParticipant();
            expenseParticipant.setExpense(expense);
            expenseParticipant.setUser(participant);
            expenseParticipant.setShare(sharePerParticipant);

            expenseParticipantRepository.save(expenseParticipant);
        }
    }

    private boolean isUserMemberOfGroup(Long userId, Long groupId) {
        return groupMemberRepository.existsByUserIdAndGroupId(userId, groupId);
    }

    public List<String> validateParticipants(Long groupId, List<String> participantEmails, Long currentUserId) {
        // Verificar se o usuário atual faz parte do grupo
        if (!isUserMemberOfGroup(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        List<String> validParticipants = new ArrayList<>();
        
        for (String email : participantEmails) {
            try {
                User user = userRepository.findByEmail(email)
                        .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado: " + email));
                
                if (isUserMemberOfGroup(user.getId(), groupId)) {
                    validParticipants.add(email);
                }
            } catch (EntityNotFoundException e) {
                // Usuário não existe ou não é membro do grupo, ignorar
            }
        }
        
        return validParticipants;
    }

    public List<Expense> getExpensesByGroup(Long groupId, Long currentUserId) {
        if (!isUserMemberOfGroup(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }
        
        return expenseRepository.findByGroupIdOrderByCreatedAtDesc(groupId);
    }

    public ExpenseResponseDTO convertToResponseDTO(Expense expense) {
        ExpenseResponseDTO responseDTO = new ExpenseResponseDTO();
        responseDTO.setId(expense.getId());
        responseDTO.setDescription(expense.getDescription());
        responseDTO.setAmount(expense.getAmount());
        responseDTO.setExpenseDate(expense.getExpenseDate());
        responseDTO.setCreatedAt(expense.getCreatedAt());
        responseDTO.setCategoryId(expense.getCategoryId());
        
        // Converter usuário que pagou
        ExpenseResponseDTO.PaidByUserDTO paidByDto = new ExpenseResponseDTO.PaidByUserDTO();
        paidByDto.setId(expense.getPaidByUser().getId());
        paidByDto.setName(expense.getPaidByUser().getName());
        paidByDto.setEmail(expense.getPaidByUser().getEmail());
        responseDTO.setPaidBy(paidByDto);
        
        // Converter grupo
        ExpenseResponseDTO.GroupDTO groupDto = new ExpenseResponseDTO.GroupDTO();
        groupDto.setId(expense.getGroup().getId());
        groupDto.setName(expense.getGroup().getName());
        responseDTO.setGroup(groupDto);
        
        // Buscar e converter participantes
        List<ExpenseParticipant> participants = expenseParticipantRepository.findByExpenseId(expense.getId());
        List<ExpenseResponseDTO.ParticipantDTO> participantDtos = participants.stream()
                .map(participant -> {
                    ExpenseResponseDTO.ParticipantDTO dto = new ExpenseResponseDTO.ParticipantDTO();
                    dto.setId(participant.getUser().getId());
                    dto.setName(participant.getUser().getName());
                    dto.setEmail(participant.getUser().getEmail());
                    dto.setShare(participant.getShare());
                    return dto;
                })
                .toList();
        responseDTO.setParticipants(participantDtos);
        
        return responseDTO;
    }
}