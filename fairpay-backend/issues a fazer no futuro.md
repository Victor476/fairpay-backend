Baseado na análise da lista de funcionalidades faltantes, aqui estão as **issues** que precisamos criar, organizadas por prioridade e categoria:

## 🏆 **ISSUES DE ALTA PRIORIDADE:**

### 📋 **Sistema de Categorias (Essencial)**
1. `Implementar entidade Category para categorização de despesas`
2. `Criar CategoryRepository com queries básicas`
3. `Desenvolver CategoryService com lógica de negócio`
4. `Implementar CategoryController com endpoints CRUD`
5. `Criar CategoryDTO para requests e responses`
6. `Integrar sistema de categorias com ExpenseService`

### 💳 **Sistema de Pagamentos (Crítico)**
7. `Implementar entidade Payment para registro de quitações`
8. `Criar PaymentRepository com queries de histórico`
9. `Desenvolver PaymentService com validações`
10. `Implementar PaymentController com endpoints`
11. `Criar PaymentRequestDTO e PaymentResponseDTO`
12. `Integrar pagamentos com cálculo de saldos`

### 🧮 **Otimização de Transferências (UX)**
13. `Implementar DebtOptimizationService`
14. `Desenvolver algoritmo para minimizar transferências`
15. `Criar endpoint para sugestões de pagamento otimizadas`

## 🔧 **ISSUES DE PRIORIDADE MÉDIA:**

### 📊 **Relatórios Básicos**
16. `Implementar relatório de gastos por usuário`
17. `Criar relatório de gastos por categoria`
18. `Desenvolver relatório de gastos por período`
19. `Implementar endpoint para exportação de dados (CSV)`

### 💰 **Cálculos Avançados**
20. `Implementar divisão de despesas por percentual customizado`
21. `Desenvolver divisão por valor fixo diferenciado`
22. `Criar interface para diferentes tipos de divisão`

### 🔄 **Despesas Recorrentes**
23. `Implementar entidade RecurringExpense`
24. `Criar serviço para processar despesas recorrentes`
25. `Desenvolver scheduler para criação automática`

## 🧪 **ISSUES DE QUALIDADE (Importante)**

### 🧪 **Testes**
26. `Criar testes unitários para ExpenseService`
27. `Implementar testes unitários para GroupBalanceService`
28. `Desenvolver testes de integração para ExpenseController`
29. `Criar testes de integração para endpoints de saldos`
30. `Implementar testes de performance para cálculos complexos`

### 📚 **Documentação**
31. `Documentar API REST com OpenAPI/Swagger`
32. `Criar documentação de instalação e configuração`
33. `Desenvolver guia de contribuição para desenvolvedores`

## 🚀 **ISSUES DE FUNCIONALIDADES AVANÇADAS:**

### 📎 **Anexos e Mídia**
34. `Implementar upload de anexos/comprovantes`
35. `Criar sistema de armazenamento de arquivos`
36. `Desenvolver endpoints para gerenciar anexos`

### 💬 **Sistema de Comentários**
37. `Implementar entidade Comment para despesas`
38. `Criar sistema de comentários em despesas`
39. `Desenvolver notificações para comentários`

### 🔔 **Notificações**
40. `Implementar sistema básico de notificações`
41. `Criar notificações para novas despesas`
42. `Desenvolver notificações para pagamentos`

### 🌍 **Internacionalização**
43. `Implementar suporte a múltiplas moedas`
44. `Criar sistema de conversão de moedas`
45. `Desenvolver formatação regional de valores`

## 🔧 **ISSUES DE MELHORIAS TÉCNICAS:**

### ⚡ **Performance**
46. `Implementar cache para cálculos de saldos`
47. `Otimizar queries de busca de despesas`
48. `Criar índices de banco de dados para performance`

### 🔐 **Segurança**
49. `Implementar rate limiting para APIs`
50. `Desenvolver logs de auditoria detalhados`
51. `Criar validações de segurança adicionais`

### 🏗️ **Arquitetura**
52. `Refatorar código para melhor separação de responsabilidades`
53. `Implementar padrão de eventos para desacoplamento`
54. `Criar sistema de migrations para banco de dados`

---

## 📊 **RESUMO POR PRIORIDADE:**

- **🏆 Alta Prioridade:** 15 issues (Categorias, Pagamentos, Otimização)
- **🔧 Média Prioridade:** 11 issues (Relatórios, Cálculos, Recorrentes)  
- **🧪 Qualidade:** 8 issues (Testes, Documentação)
- **🚀 Avançadas:** 12 issues (Anexos, Comentários, Notificações, i18n)
- **🔧 Técnicas:** 9 issues (Performance, Segurança, Arquitetura)

**Total:** 55 issues identificadas

Sugiro começarmos pelas **15 issues de alta prioridade**, focando primeiro no sistema de categorias (issues 1-6) que é fundamental para organização das despesas.