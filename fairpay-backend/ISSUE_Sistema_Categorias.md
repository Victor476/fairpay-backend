# 📋 [FEATURE] Sistema Completo de Categorias para Despesas

### 📝 História de Usuário — Sistema de Categorias (Backend)

#### Como um(a)
usuário membro de um grupo de despesas,

#### Eu quero
criar, editar e gerenciar categorias para organizar minhas despesas,

#### Para que
eu possa classificar gastos por tipo (Alimentação, Transporte, etc.) e ter melhor controle financeiro e relatórios mais organizados.

---

### ✅ Critérios de Aceitação

#### 🏗️ **Backend - Endpoints**
- [ ] Criar endpoint `POST /api/categories` para criar nova categoria
- [ ] Criar endpoint `GET /api/categories` para listar categorias do usuário
- [ ] Criar endpoint `GET /api/categories/group/{groupId}` para listar categorias do grupo
- [ ] Criar endpoint `PUT /api/categories/{id}` para editar categoria
- [ ] Criar endpoint `DELETE /api/categories/{id}` para excluir categoria
- [ ] Criar endpoint `GET /api/categories/{id}` para buscar categoria específica

#### � **Funcionalidades Principais**
- [ ] Sistema deve permitir criar categorias pessoais e por grupo
- [ ] Sistema deve validar nome único por usuário/grupo
- [ ] Sistema deve suportar cores (formato hex) e ícones
- [ ] Sistema deve implementar soft delete (não excluir fisicamente)
- [ ] Sistema deve impedir exclusão de categorias em uso
- [ ] Sistema deve incluir categorias padrão (Alimentação, Transporte, etc.)

#### 🔐 **Validações e Segurança**
- [ ] Apenas usuários autenticados podem gerenciar categorias
- [ ] Apenas criador da categoria pode editar/excluir
- [ ] Apenas membros do grupo podem acessar categorias do grupo
- [ ] Validar formato de cores (hex válido)
- [ ] Validar comprimento de nomes (max 50 chars)

#### 🔗 **Integração com Despesas**
- [ ] Despesas podem ser criadas com categoria
- [ ] Despesas exibem informações da categoria na resposta
- [ ] Sistema valida se categoria pertence ao grupo da despesa
- [ ] Sistema mantém compatibilidade com despesas sem categoria

---

### 🔐 Regras de Acesso

- Apenas usuários autenticados e membros do grupo podem gerenciar categorias
- Apenas o criador da categoria ou administrador do grupo pode editar/excluir

---

### 🔗 Exemplo de Requisição (Criar Categoria)

```json
POST /api/categories

{
  "name": "Alimentação",
  "description": "Gastos com comida e bebida",
  "color": "#FF6B6B",
  "icon": "restaurant",
  "groupId": 1
}
```

### 📝 Exemplo de Resposta

```json
{
  "id": 1,
  "name": "Alimentação", 
  "description": "Gastos com comida e bebida",
  "color": "#FF6B6B",
  "icon": "restaurant",
  "createdBy": {
    "id": 1,
    "name": "João Silva"
  },
  "group": {
    "id": 1,
    "name": "Apartamento 101"
  },
  "createdAt": "2025-07-02T10:30:00Z"
}
```

### 🔄 Exemplo de Integração com Despesas

```json
POST /api/expenses

{
  "description": "Almoço de domingo",
  "totalAmount": 150.00,
  "date": "2025-07-02",
  "groupId": 1,
  "payer": "joao@email.com",
  "participants": ["joao@email.com", "maria@email.com"],
  "categoryId": 1
}
```

---

### 📋 Tarefas Técnicas (Implementação)

### 🏗️ **Backend - Modelo de Dados**
- [ ] Implementar entidade `Category` com campos:
  - `id` (Long, auto-increment)
  - `name` (String, obrigatório, único por usuário/grupo)
  - `description` (String, opcional)
  - `color` (String, opcional - código hex para UI)
  - `icon` (String, opcional - nome do ícone)
  - `createdBy` (User, obrigatório)
  - `group` (Group, opcional - categoria global ou específica do grupo)
  - `createdAt` (Instant, automático)
  - `isActive` (Boolean, padrão true)

### 📊 **Repository Layer**
- [ ] Criar `CategoryRepository` com queries:
  - `findByCreatedByIdAndIsActiveTrue()`
  - `findByGroupIdAndIsActiveTrue()`
  - `findByNameAndCreatedByIdAndGroupId()` (para verificar duplicatas)
  - `findAllActiveOrderByName()`

### ⚙️ **Service Layer**
- [ ] Desenvolver `CategoryService` com métodos:
  - `createCategory()` - Criar nova categoria
  - `updateCategory()` - Atualizar categoria existente
  - `deleteCategory()` - Soft delete (isActive = false)
  - `getUserCategories()` - Listar categorias do usuário
  - `getGroupCategories()` - Listar categorias do grupo
  - `validateCategoryAccess()` - Verificar permissões

### 📝 **DTOs**
- [ ] Criar `CategoryRequestDTO`:
  - `name` (obrigatório, max 50 chars)
  - `description` (opcional, max 200 chars)
  - `color` (opcional, validação hex)
  - `icon` (opcional)
  - `groupId` (opcional)

- [ ] Criar `CategoryResponseDTO`:
  - `id`
  - `name`
  - `description`
  - `color`
  - `icon`
  - `createdBy` (nome do usuário)
  - `group` (nome do grupo, se aplicável)
  - `createdAt`

### 🌐 **Controller Layer**
- [ ] Implementar `CategoryController` com endpoints:
  - `POST /api/categories` - Criar categoria
  - `GET /api/categories` - Listar categorias do usuário
  - `GET /api/categories/group/{groupId}` - Listar categorias do grupo
  - `PUT /api/categories/{id}` - Atualizar categoria
  - `DELETE /api/categories/{id}` - Excluir categoria
  - `GET /api/categories/{id}` - Buscar categoria específica

### 🔐 **Validações e Regras de Negócio**
- [ ] Validar nome único por usuário/grupo
- [ ] Verificar permissões (apenas criador pode editar/excluir)
- [ ] Validar cores (formato hex válido)
- [ ] Impedir exclusão de categorias em uso
- [ ] Validar acesso a categorias de grupo

### 🔗 **Integração com Sistema Existente**
- [ ] Atualizar `ExpenseService` para suportar categorias:
  - Validar categoria no `createExpense()`
  - Incluir categoria no `updateExpense()`
  - Verificar se categoria pertence ao grupo da despesa

- [ ] Atualizar `ExpenseResponseDTO`:
  - Adicionar campo `category` com dados da categoria

### 📋 **Dados Iniciais (Seed)**
- [ ] Criar categorias padrão globais:
  - 🍕 Alimentação
  - 🚗 Transporte
  - 🏠 Moradia
  - 🎬 Entretenimento
  - 🛒 Compras
  - 💊 Saúde
  - 📚 Educação
  - 🧾 Outros

---

### 📊 Informações Técnicas

**Prioridade:** 🔥 **ALTA** - Funcionalidade essencial para organização  
**Esforço:** 📏 **Médio** - ~8-12 horas de desenvolvimento  
**Dependências:** Nenhuma (pode ser desenvolvido independentemente)  
**Labels:** `feature`, `high-priority`, `backend`, `categories`  
**Milestone:** v1.1.0

---

### 🔗 Issues Relacionadas

Esta issue faz parte do épico de melhorias do sistema de despesas e será prerequisito para:
- Sistema de relatórios por categoria
- Dashboard com gráficos por categoria  
- Filtros avançados de despesas

---

### 📝 Notas Técnicas

- Implementar soft delete para categorias (não excluir fisicamente)
- Considerar cache para categorias globais (performance)
- Preparar estrutura para futuras melhorias (subcategorias)
- Manter compatibilidade com despesas existentes (categoria null permitida)
- Incluir categorias padrão: 🍕 Alimentação, 🚗 Transporte, 🏠 Moradia, 🎬 Entretenimento, 🛒 Compras, 💊 Saúde, 📚 Educação, 🧾 Outros

---

**Criado em:** 02/07/2025  
**Assignee:** A definir
