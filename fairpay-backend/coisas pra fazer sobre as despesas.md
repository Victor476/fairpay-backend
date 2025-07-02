📋 Lista de Funcionalidades Faltantes Relacionadas a Despesas e Cálculos

vejo que as tabelas estão criadas, mas faltam várias implementações. Aqui está o que precisa ser desenvolvido:

## 🏗️ Modelos/Entidades que Faltam
- [x] **Entidade `Expense`** - para representar as despesas ✅ **IMPLEMENTADO**
- [x] **Entidade `ExpenseParticipant`** - para representar participantes das despesas ✅ **IMPLEMENTADO**
- [ ] **Entidade `Category`** - para categorizar despesas
- [ ] **Entidade `Payment`** - para registrar pagamentos entre usuários
- [ ] **Entidade `RecurringExpense`** - para despesas recorrentes

## 📝 DTOs Necessários
- [x] **ExpenseRequestDTO** - para criação de despesas ✅ **IMPLEMENTADO**
- [x] **ExpenseResponseDTO** - para retorno de despesas ✅ **IMPLEMENTADO**
- [ ] **PaymentRequestDTO** - para registro de pagamentos
- [x] **BalanceResponseDTO** - para mostrar saldos dos usuários ✅ **IMPLEMENTADO (GroupBalanceDTO)**
- [ ] **CategoryDTO** - para gerenciar categorias

## 🎯 Controllers Faltantes
- [x] **ExpenseController** - endpoints para CRUD de despesas ✅ **IMPLEMENTADO**
- [ ] **PaymentController** - endpoints para pagamentos
- [ ] **CategoryController** - endpoints para categorias
- [x] **BalanceController** - endpoint para calcular saldos ✅ **IMPLEMENTADO (em GroupController)**

## ⚙️ Services de Lógica de Negócio
- [x] **ExpenseService** - lógica para gerenciar despesas ✅ **IMPLEMENTADO**
- [ ] **PaymentService** - lógica para pagamentos
- [x] **BalanceCalculationService** - algoritmos de cálculo de saldos ✅ **IMPLEMENTADO (GroupBalanceService)**
- [ ] **DebtOptimizationService** - otimização de transferências
- [ ] **CategoryService** - gerenciamento de categorias

## 📊 Repositories
- [x] **ExpenseRepository** - acesso a dados de despesas ✅ **IMPLEMENTADO**
- [x] **ExpenseParticipantRepository** - participantes das despesas ✅ **IMPLEMENTADO**
- [ ] **PaymentRepository** - histórico de pagamentos
- [ ] **CategoryRepository** - categorias das despesas

## 🧮 Algoritmos de Cálculo Faltantes
- [x] **Divisão automática de despesas** - calcular quanto cada participante deve ✅ **IMPLEMENTADO (divisão igualitária)**
- [x] **Cálculo de saldos por usuário** - quem deve/recebe quanto ✅ **IMPLEMENTADO**
- [ ] **Otimização de transferências** - minimizar número de pagamentos
- [x] **Validação de participantes** - verificar se usuário pertence ao grupo ✅ **IMPLEMENTADO**

## 🔐 Validações e Regras de Negócio
- [x] **Validar se usuário pode criar despesa no grupo** ✅ **IMPLEMENTADO**
- [x] **Validar se participantes pertencem ao grupo** ✅ **IMPLEMENTADO**
- [x] **Validar valores das despesas** (positivos, não nulos) ✅ **IMPLEMENTADO**
- [x] **Validar datas das despesas** ✅ **IMPLEMENTADO**
- [x] **Verificar permissões para editar/excluir despesas** ✅ **IMPLEMENTADO**

## 📋 Endpoints Específicos Faltantes
```
✅ POST   /api/expenses                           - Criar despesa (IMPLEMENTADO)
✅ GET    /api/expenses/group/{groupId}           - Listar despesas do grupo (IMPLEMENTADO)
✅ PUT    /api/expenses/{expenseId}               - Editar despesa (IMPLEMENTADO)
✅ DELETE /api/expenses/{expenseId}               - Excluir despesa (IMPLEMENTADO)
✅ GET    /api/groups/{groupId}/balances          - Ver saldos do grupo (IMPLEMENTADO)
❌ POST   /api/groups/{groupId}/payments          - Registrar pagamento (FALTA)
❌ GET    /api/groups/{groupId}/payments          - Histórico de pagamentos (FALTA)
❌ GET    /api/categories                         - Listar categorias (FALTA)
❌ POST   /api/categories                         - Criar categoria (FALTA)
```

## 💰 Funcionalidades de Cálculo Específicas
- [x] **Divisão igualitária** - dividir despesa igualmente entre participantes ✅ **IMPLEMENTADO**
- [ ] **Divisão por percentual** - cada participante paga uma porcentagem
- [ ] **Divisão por valor fixo** - cada participante paga um valor específico
- [x] **Cálculo de quem deve para quem** - matriz de débitos ✅ **IMPLEMENTADO (saldos por usuário)**
- [ ] **Sugestão de pagamentos otimizados** - algoritmo para minimizar transferências porcentagem
- [ ] **Divisão por valor fixo** - cada participante paga um valor específico
- [ ] **Cálculo de quem deve para quem** - matriz de débitos
- [ ] **Sugestão de pagamentos otimizados** - algoritmo para minimizar transferências

## 📈 Relatórios e Estatísticas
- [ ] **Total gasto por usuário**
- [ ] **Gastos por categoria**
- [ ] **Gastos por período (mensal/semanal)**
- [ ] **Histórico detalhado de transações**
- [ ] **Exportação de dados** (CSV/PDF)

## 🔄 Funcionalidades Adicionais
- [ ] **Despesas recorrentes** - repetir despesas automaticamente
- [ ] **Anexos nas despesas** - upload de comprovantes
- [ ] **Comentários nas despesas** - discussões sobre gastos
- [ ] **Notificações** - avisar sobre novas despesas/pagamentos

## 🧪 Testes Necessários
- [ ] **Testes unitários** para serviços de cálculo
- [ ] **Testes de integração** para endpoints
- [ ] **Testes de validação** para regras de negócio
- [ ] **Testes de performance** para cálculos complexos

Essa é uma lista abrangente do que ainda precisa ser implementado para ter um sistema completo de gestão de despesas compartilhadas. Cada item representa uma funcionalidade importante para o funcionamento do FairPay.

---

## 📊 RESUMO DO PROGRESSO (Atualizado em 02/07/2025)

### ✅ **IMPLEMENTADO (Aprox. 60% das funcionalidades básicas):**

#### 🏗️ **Backend Core:**
- ✅ Entidades: `Expense`, `ExpenseParticipant`
- ✅ DTOs: `ExpenseRequestDTO`, `ExpenseResponseDTO`, `GroupBalanceDTO`
- ✅ Controllers: `ExpenseController` (CRUD completo)
- ✅ Services: `ExpenseService`, `GroupBalanceService`
- ✅ Repositories: `ExpenseRepository`, `ExpenseParticipantRepository`

#### 🔐 **Validações e Segurança:**
- ✅ Validação de usuário no grupo
- ✅ Validação de participantes
- ✅ Validação de valores e datas
- ✅ Controle de permissões (criador/admin para editar/excluir)

#### 📊 **Cálculos:**
- ✅ Divisão igualitária de despesas
- ✅ Cálculo de saldos por usuário
- ✅ Sistema de participações

#### 🌐 **Endpoints REST:**
- ✅ POST `/api/expenses` - Criar despesa
- ✅ GET `/api/expenses/group/{groupId}` - Listar despesas
- ✅ PUT `/api/expenses/{expenseId}` - Editar despesa
- ✅ DELETE `/api/expenses/{expenseId}` - Excluir despesa
- ✅ GET `/api/groups/{groupId}/balances` - Calcular saldos

### ❌ **AINDA FALTA IMPLEMENTAR (Aprox. 40%):**

#### 🏗️ **Entidades Avançadas:**
- ❌ `Category` - Sistema de categorização
- ❌ `Payment` - Registro de pagamentos entre usuários
- ❌ `RecurringExpense` - Despesas recorrentes

#### 💰 **Cálculos Avançados:**
- ❌ Divisão por percentual customizado
- ❌ Divisão por valor fixo diferenciado
- ❌ Otimização de transferências (algoritmo para minimizar pagamentos)

#### 📈 **Relatórios e Analytics:**
- ❌ Total gasto por usuário
- ❌ Gastos por categoria
- ❌ Gastos por período (mensal/semanal)
- ❌ Exportação de dados (CSV/PDF)

#### 🔄 **Funcionalidades Avançadas:**
- ❌ Despesas recorrentes automáticas
- ❌ Upload de anexos/comprovantes
- ❌ Sistema de comentários
- ❌ Notificações
- ❌ Múltiplas moedas

#### 🧪 **Qualidade:**
- ❌ Testes unitários completos
- ❌ Testes de integração abrangentes
- ❌ Testes de performance
- ❌ Documentação da API completa

### 🎯 **PRÓXIMAS PRIORIDADES SUGERIDAS:**

1. **Sistema de Categorias** (essencial para organização)
2. **Sistema de Pagamentos** (para registrar quitações)
3. **Otimização de Transferências** (UX importante)
4. **Testes Unitários** (qualidade de código)
5. **Relatórios Básicos** (valor para usuários)

**STATUS GERAL:** 🚧 **Projeto em desenvolvimento ativo - Funcionalidades básicas implementadas, faltam recursos avançados**