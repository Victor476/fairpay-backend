package com.fairpay.dto;

import java.math.BigDecimal;

public class GroupBalanceDTO {
    private Long userId;
    private String name;
    private BigDecimal balance;

    public GroupBalanceDTO() {}

    public GroupBalanceDTO(Long userId, String name, BigDecimal balance) {
        this.userId = userId;
        this.name = name;
        this.balance = balance;
    }

    // Getters e Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }
}
