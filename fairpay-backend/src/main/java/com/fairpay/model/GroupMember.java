package com.fairpay.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "group_members")
public class GroupMember {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id", nullable = false)
    private Group group;
    
    @Column(name = "role", nullable = false)
    private String role = "member"; // Default role
    
    @Column(name = "joined_at")
    private Instant joinedAt;
    
    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public Group getGroup() { return group; }
    public void setGroup(Group group) { this.group = group; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public Instant getJoinedAt() { return joinedAt; }
    public void setJoinedAt(Instant joinedAt) { this.joinedAt = joinedAt; }
}
