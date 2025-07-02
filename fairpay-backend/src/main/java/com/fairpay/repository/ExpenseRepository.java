package com.fairpay.repository;

import com.fairpay.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    
    List<Expense> findByGroupIdOrderByCreatedAtDesc(Long groupId);
    
    List<Expense> findByGroupIdAndPaidByUserIdOrderByCreatedAtDesc(Long groupId, Long paidByUserId);
    
    // Buscar todas as despesas de um grupo (para cálculo de saldos)
    List<Expense> findByGroupId(Long groupId);
    
    // Buscar todas as despesas pagas por um usuário em um grupo específico
    @Query("SELECT e FROM Expense e WHERE e.group.id = :groupId AND e.paidByUser.id = :userId")
    List<Expense> findByGroupIdAndPaidByUserId(@Param("groupId") Long groupId, @Param("userId") Long userId);
    
    // Contar despesas de um grupo
    @Query("SELECT COUNT(e) FROM Expense e WHERE e.group.id = :groupId")
    long countByGroupId(@Param("groupId") Long groupId);
}
