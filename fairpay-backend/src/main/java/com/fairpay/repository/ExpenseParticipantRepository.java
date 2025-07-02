package com.fairpay.repository;

import com.fairpay.model.ExpenseParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipant, Long> {
    
    List<ExpenseParticipant> findByExpenseId(Long expenseId);
    
    @Query("SELECT ep FROM ExpenseParticipant ep WHERE ep.expense.group.id = :groupId")
    List<ExpenseParticipant> findByGroupId(@Param("groupId") Long groupId);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM ExpenseParticipant ep WHERE ep.expense.id = :expenseId")
    void deleteByExpenseId(@Param("expenseId") Long expenseId);
}
