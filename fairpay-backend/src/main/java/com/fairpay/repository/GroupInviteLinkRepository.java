package com.fairpay.repository;

import com.fairpay.model.GroupInviteLink;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupInviteLinkRepository extends JpaRepository<GroupInviteLink, Long> {
    
    Optional<GroupInviteLink> findByToken(String token);
    
    boolean existsByTokenAndIsActiveTrue(String token);
    
    Optional<GroupInviteLink> findByTokenAndIsActiveTrue(String token);
}
