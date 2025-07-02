package com.fairpay.repository;

import com.fairpay.model.GroupMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    
    @Query("SELECT COUNT(gm) > 0 FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId")
    boolean existsByUserIdAndGroupId(@Param("userId") Long userId, @Param("groupId") Long groupId);

    List<GroupMember> findByGroupId(Long groupId);
    
    List<GroupMember> findByUserId(Long userId);
    
    // Verificar se usuário é admin de um grupo
    @Query("SELECT COUNT(gm) > 0 FROM GroupMember gm WHERE gm.user.id = :userId AND gm.group.id = :groupId AND gm.role = :role")
    boolean existsByUserIdAndGroupIdAndRole(@Param("userId") Long userId, @Param("groupId") Long groupId, @Param("role") String role);
}
