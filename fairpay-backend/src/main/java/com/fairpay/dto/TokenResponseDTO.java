package com.fairpay.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor  // Adicionar construtor vazio
@Builder
public class TokenResponseDTO {
    
    private String accessToken;
    private String refreshToken;
    private String tokenType;
}