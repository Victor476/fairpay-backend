package com.fairpay.repository;

import com.fairpay.model.GroupMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    
    @Query("SELECT COUNT(gm) > 0 FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId")
    boolean existsByUserIdAndGroupId(@Param("userId") Long userId, @Param("groupId") Long groupId);

    List<GroupMember> findByGroupId(Long groupId);
    
    List<GroupMember> findByUserId(Long userId);
    
    // Buscar membro específico por usuário e grupo
    @Query("SELECT gm FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId")
    Optional<GroupMember> findByUserIdAndGroupId(@Param("userId") Long userId, @Param("groupId") Long groupId);
    
    // Verificar se usuário é admin de um grupo
    @Query("SELECT COUNT(gm) > 0 FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId AND gm.role = :role")
    boolean existsByUserIdAndGroupIdAndRole(@Param("userId") Long userId, @Param("groupId") Long groupId, @Param("role") String role);
    
    // Verificar se usuário é o único admin de algum grupo
    @Query("SELECT COUNT(g.id) > 0 FROM Group g WHERE g.id IN " +
           "(SELECT gm.group.id FROM GroupMember gm WHERE gm.user.id = :userId AND gm.role = 'admin') " +
           "AND (SELECT COUNT(gm2) FROM GroupMember gm2 WHERE gm2.group.id = g.id AND gm2.role = 'admin') = 1")
    boolean existsAsOnlyAdmin(@Param("userId") Long userId);
    
    // Excluir todas as participações de um usuário
    @Modifying
    @Query("DELETE FROM GroupMember gm WHERE gm.user.id = :userId")
    void deleteByUserId(@Param("userId") Long userId);
    
    // Excluir todos os membros de um grupo
    @Modifying
    @Query("DELETE FROM GroupMember gm WHERE gm.group.id = :groupId")
    void deleteByGroupId(@Param("groupId") Long groupId);
    
    // Excluir membro específico de um grupo
    @Modifying
    @Query("DELETE FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId")
    void deleteByUserIdAndGroupId(@Param("userId") Long userId, @Param("groupId") Long groupId);
    
    // Contar administradores de um grupo
    @Query("SELECT COUNT(gm) FROM GroupMember gm WHERE gm.group.id = :groupId AND gm.role = 'admin'")
    long countAdminsByGroupId(@Param("groupId") Long groupId);
}
