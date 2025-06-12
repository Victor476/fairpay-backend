package com.fairpay.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GroupRequestDTO {

    @NotBlank(message = "O nome do grupo é obrigatório.")
    private String name;

    private String description;

    private String imageUrl; // Opcional
}
