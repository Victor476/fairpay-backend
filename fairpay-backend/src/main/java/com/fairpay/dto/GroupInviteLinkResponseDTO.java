package com.fairpay.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class GroupInviteLinkResponseDTO {
    private String inviteLink;
    private LocalDateTime expiresAt;
}
