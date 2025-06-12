package com.fairpay.dto;

import java.time.Instant;
import com.fairpay.model.Group;

public class GroupResponseDTO {

    private Long id;
    private String name;
    private String description;
    private String imageUrl;
    private Instant createdAt;
    private CreatorDTO createdBy;

    public GroupResponseDTO(Group group) {
        this.id = group.getId();
        this.name = group.getName();
        this.description = group.getDescription();
        this.imageUrl = group.getImageUrl();
        this.createdAt = group.getCreatedAt();
        this.createdBy = new CreatorDTO(group.getCreatedBy().getId(), group.getCreatedBy().getName());
    }

    // Getters e Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public CreatorDTO getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(CreatorDTO createdBy) {
        this.createdBy = createdBy;
    }

    // Classe interna para representar o criador
    public static class CreatorDTO {
        private Long id;
        private String name;

        public CreatorDTO(Long id, String name) {
            this.id = id;
            this.name = name;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
