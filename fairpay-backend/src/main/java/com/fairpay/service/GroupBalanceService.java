package com.fairpay.service;

import com.fairpay.dto.GroupBalanceDTO;
import com.fairpay.model.Expense;
import com.fairpay.model.ExpenseParticipant;
import com.fairpay.model.Group;
import com.fairpay.model.User;
import com.fairpay.repository.ExpenseParticipantRepository;
import com.fairpay.repository.ExpenseRepository;
import com.fairpay.repository.GroupMemberRepository;
import com.fairpay.repository.GroupRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GroupBalanceService {

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private GroupMemberRepository groupMemberRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private ExpenseParticipantRepository expenseParticipantRepository;

    /**
     * Calcula os saldos de todos os membros de um grupo
     * 
     * @param groupId ID do grupo
     * @param currentUserId ID do usuário que está fazendo a consulta
     * @return Lista com os saldos de cada membro
     */
    public List<GroupBalanceDTO> calculateGroupBalances(Long groupId, Long currentUserId) {
        // Verificar se o grupo existe
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("Grupo não encontrado"));

        // Verificar se o usuário atual é membro do grupo
        if (!groupMemberRepository.existsByUserIdAndGroupId(currentUserId, groupId)) {
            throw new IllegalArgumentException("Usuário não faz parte do grupo");
        }

        // Buscar todos os membros do grupo
        List<User> groupMembers = groupMemberRepository.findByGroupId(groupId)
                .stream()
                .map(gm -> gm.getUser())
                .toList();

        // Buscar todas as despesas do grupo
        List<Expense> groupExpenses = expenseRepository.findByGroupId(groupId);

        // Buscar todas as participações nas despesas do grupo
        List<ExpenseParticipant> allParticipations = expenseParticipantRepository.findByGroupId(groupId);

        // Calcular saldos
        Map<Long, BigDecimal> totalPaid = new HashMap<>(); // Quanto cada pessoa pagou
        Map<Long, BigDecimal> totalOwed = new HashMap<>(); // Quanto cada pessoa deve

        // Inicializar mapas com zero para todos os membros
        for (User member : groupMembers) {
            totalPaid.put(member.getId(), BigDecimal.ZERO);
            totalOwed.put(member.getId(), BigDecimal.ZERO);
        }

        // Calcular total pago por cada membro
        for (Expense expense : groupExpenses) {
            Long payerId = expense.getPaidByUser().getId();
            BigDecimal amount = expense.getAmount();
            totalPaid.put(payerId, totalPaid.get(payerId).add(amount));
        }

        // Calcular total que cada membro deve (baseado nas participações)
        for (ExpenseParticipant participation : allParticipations) {
            Long participantId = participation.getUser().getId();
            BigDecimal share = participation.getShare();
            totalOwed.put(participantId, totalOwed.get(participantId).add(share));
        }

        // Calcular saldo final (pagou - deve)
        List<GroupBalanceDTO> balances = new ArrayList<>();
        for (User member : groupMembers) {
            Long memberId = member.getId();
            BigDecimal paid = totalPaid.get(memberId);
            BigDecimal owed = totalOwed.get(memberId);
            BigDecimal balance = paid.subtract(owed); // positivo = tem a receber, negativo = deve

            balances.add(new GroupBalanceDTO(
                    memberId,
                    member.getName(),
                    balance
            ));
        }

        return balances;
    }
}
