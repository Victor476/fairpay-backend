📋 Lista de Funcionalidades Faltantes Relacionadas a Despesas e Cálculos

vejo que as tabelas estão criadas, mas faltam várias implementações. Aqui está o que precisa ser desenvolvido:

## 🏗️ Modelos/Entidades que Faltam
- [ ] **Entidade `Expense`** - para representar as despesas
- [ ] **Entidade `ExpenseParticipant`** - para representar participantes das despesas
- [ ] **Entidade `Category`** - para categorizar despesas
- [ ] **Entidade `Payment`** - para registrar pagamentos entre usuários
- [ ] **Entidade `RecurringExpense`** - para despesas recorrentes

## 📝 DTOs Necessários
- [ ] **ExpenseRequestDTO** - para criação de despesas
- [ ] **ExpenseResponseDTO** - para retorno de despesas
- [ ] **PaymentRequestDTO** - para registro de pagamentos
- [ ] **BalanceResponseDTO** - para mostrar saldos dos usuários
- [ ] **CategoryDTO** - para gerenciar categorias

## 🎯 Controllers Faltantes
- [ ] **ExpenseController** - endpoints para CRUD de despesas
- [ ] **PaymentController** - endpoints para pagamentos
- [ ] **CategoryController** - endpoints para categorias
- [ ] **BalanceController** - endpoint para calcular saldos

## ⚙️ Services de Lógica de Negócio
- [ ] **ExpenseService** - lógica para gerenciar despesas
- [ ] **PaymentService** - lógica para pagamentos
- [ ] **BalanceCalculationService** - algoritmos de cálculo de saldos
- [ ] **DebtOptimizationService** - otimização de transferências
- [ ] **CategoryService** - gerenciamento de categorias

## 📊 Repositories
- [ ] **ExpenseRepository** - acesso a dados de despesas
- [ ] **ExpenseParticipantRepository** - participantes das despesas
- [ ] **PaymentRepository** - histórico de pagamentos
- [ ] **CategoryRepository** - categorias das despesas

## 🧮 Algoritmos de Cálculo Faltantes
- [ ] **Divisão automática de despesas** - calcular quanto cada participante deve
- [ ] **Cálculo de saldos por usuário** - quem deve/recebe quanto
- [ ] **Otimização de transferências** - minimizar número de pagamentos
- [ ] **Validação de participantes** - verificar se usuário pertence ao grupo

## 🔐 Validações e Regras de Negócio
- [ ] **Validar se usuário pode criar despesa no grupo**
- [ ] **Validar se participantes pertencem ao grupo**
- [ ] **Validar valores das despesas** (positivos, não nulos)
- [ ] **Validar datas das despesas**
- [ ] **Verificar permissões para editar/excluir despesas**

## 📋 Endpoints Específicos Faltantes
```
POST   /api/groups/{groupId}/expenses           - Criar despesa
GET    /api/groups/{groupId}/expenses           - Listar despesas do grupo
PUT    /api/expenses/{expenseId}                - Editar despesa
DELETE /api/expenses/{expenseId}                - Excluir despesa
GET    /api/groups/{groupId}/balance            - Ver saldos do grupo
POST   /api/groups/{groupId}/payments           - Registrar pagamento
GET    /api/groups/{groupId}/payments           - Histórico de pagamentos
GET    /api/categories                          - Listar categorias
POST   /api/categories                          - Criar categoria
```

## 💰 Funcionalidades de Cálculo Específicas
- [ ] **Divisão igualitária** - dividir despesa igualmente entre participantes
- [ ] **Divisão por percentual** - cada participante paga uma porcentagem
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