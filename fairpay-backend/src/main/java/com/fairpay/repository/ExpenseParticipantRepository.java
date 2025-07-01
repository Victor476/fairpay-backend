package com.fairpay.repository;

import com.fairpay.model.ExpenseParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipant, Long> {
    
    List<ExpenseParticipant> findByExpenseId(Long expenseId);
    
    List<ExpenseParticipant> findByUserId(Long userId);
    
    List<ExpenseParticipant> findByExpenseIdAndUserId(Long expenseId, Long userId);
    
    // Buscar participações de um usuário em despesas de um grupo específico
    @Query("SELECT ep FROM ExpenseParticipant ep " +
           "WHERE ep.user.id = :userId AND ep.expense.group.id = :groupId")
    List<ExpenseParticipant> findByUserIdAndGroupId(@Param("userId") Long userId, @Param("groupId") Long groupId);
    
    // Buscar todas as participações em despesas de um grupo
    @Query("SELECT ep FROM ExpenseParticipant ep WHERE ep.expense.group.id = :groupId")
    List<ExpenseParticipant> findByGroupId(@Param("groupId") Long groupId);
}
