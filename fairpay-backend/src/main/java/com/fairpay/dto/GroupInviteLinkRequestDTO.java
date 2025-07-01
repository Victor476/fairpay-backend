package com.fairpay.dto;

import lombok.Data;

@Data
public class GroupInviteLinkRequestDTO {
    private Integer expiresInDays = 7; // Valor padrão: 7 dias
}
