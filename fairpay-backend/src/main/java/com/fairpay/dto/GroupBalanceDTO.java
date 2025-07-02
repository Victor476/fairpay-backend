package com.fairpay.dto;

import java.math.BigDecimal;

public class GroupBalanceDTO {
    private Long userId;
    private String name;
    private BigDecimal totalPaid;    // Total que o usuário pagou
    private BigDecimal totalOwed;    // Total que o usuário deve
    private BigDecimal balance;      // Diferença (positivo = tem a receber, negativo = deve)

    public GroupBalanceDTO() {}

    public GroupBalanceDTO(Long userId, String name, BigDecimal totalPaid, 
                          BigDecimal totalOwed, BigDecimal balance) {
        this.userId = userId;
        this.name = name;
        this.totalPaid = totalPaid;
        this.totalOwed = totalOwed;
        this.balance = balance;
    }

    // Construtor de compatibilidade com implementação atual
    public GroupBalanceDTO(Long userId, String name, BigDecimal balance) {
        this.userId = userId;
        this.name = name;
        this.balance = balance;
        this.totalPaid = BigDecimal.ZERO;
        this.totalOwed = BigDecimal.ZERO;
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

    public BigDecimal getTotalPaid() {
        return totalPaid;
    }

    public void setTotalPaid(BigDecimal totalPaid) {
        this.totalPaid = totalPaid;
    }

    public BigDecimal getTotalOwed() {
        return totalOwed;
    }

    public void setTotalOwed(BigDecimal totalOwed) {
        this.totalOwed = totalOwed;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    @Override
    public String toString() {
        return "GroupBalanceDTO{" +
                "userId=" + userId +
                ", name='" + name + '\'' +
                ", totalPaid=" + totalPaid +
                ", totalOwed=" + totalOwed +
                ", balance=" + balance +
                '}';
    }
}
