# 🏦 FairPay Backend

## 🎯 Visão Geral

O **FairPay Backend** é uma API RESTful robusta desenvolvida com Spring Boot que facilita a **divisão justa de despesas** entre grupos de pessoas. Similar ao Splitwise, o sistema permite gerenciar gastos compartilhados, calcular saldos automaticamente e manter o controle financeiro em grupos de amigos, roommates, viagens ou eventos.

## 🚀 Tecnologias

- **Java 21** - Versão LTS mais recente
- **Spring Boot 3.4.4** - Framework principal
- **Spring Security** - Autenticação e autorização
- **PostgreSQL 17.5** - Banco de dados relacional
- **JWT (JJWT 0.11.5)** - Tokens de autenticação
- **Hibernate/JPA** - Mapeamento objeto-relacional
- **Maven** - Gerenciamento de dependências
- **Docker** - Containerização (configurado)

## ✨ Funcionalidades Implementadas

### 🔐 **Sistema de Autenticação Completo**
- ✅ Registro de usuários com validação
- ✅ Login/logout com JWT tokens
- ✅ Refresh tokens (24h duração)
- ✅ Access tokens (15min duração)
- ✅ Proteção de rotas com `@AuthenticationPrincipal`

### 👥 **Gerenciamento de Grupos**
- ✅ Criação de grupos com metadados (nome, descrição, imagem)
- ✅ Listagem de grupos do usuário autenticado
- ✅ Visualização de membros do grupo
- ✅ **Sistema de convites por link único** com expiração configurável
- ✅ Controle de acesso por membro

### 💰 **Gestão Completa de Despesas**
- ✅ **CRUD completo** - Criar, listar, editar e excluir despesas
- ✅ Divisão automática entre participantes selecionados
- ✅ Validação de participantes do grupo
- ✅ **Controle de permissões** (apenas criador ou admin pode editar/excluir)
- ✅ Histórico completo por grupo
- ✅ Campos: descrição, valor, pagador, participantes, data

### 🧮 **Cálculo Automático de Saldos**
- ✅ **Balanço individual** de cada membro do grupo
- ✅ Total pago vs total devido por pessoa
- ✅ Saldo final calculado automaticamente
- ✅ API otimizada: `GET /api/groups/{groupId}/balances`
- ✅ Dados atualizados em tempo real

### 🔗 **Sistema de Convites por Link**
- ✅ Geração de links únicos e seguros
- ✅ Expiração configurável (padrão: 7 dias)
- ✅ Aceitação automática via GET request
- ✅ Validação de permissões e grupo

### 🛡️ **Segurança e Validação**
- ✅ Controle de acesso baseado em membros do grupo
- ✅ Validação robusta de dados de entrada
- ✅ Tratamento centralizado de exceções
- ✅ Logs de auditoria e debugging
- ✅ Encoding UTF-8 para caracteres especiais

## 📡 API Endpoints Documentados

### 🔐 **Autenticação** (`/api/auth`)

| Método | Endpoint | Descrição | Payload |
|--------|----------|-----------|---------|
| `POST` | `/api/auth/register` | Registrar usuário | `{"name": "string", "email": "string", "password": "string"}` |
| `POST` | `/api/auth/login` | Fazer login | `{"email": "string", "password": "string"}` |
| `POST` | `/api/auth/refresh` | Renovar token | `{"refreshToken": "string"}` |
| `POST` | `/api/auth/logout` | Fazer logout | Header: `Authorization: Bearer {token}` |

### 👥 **Grupos** (`/api/groups`)

| Método | Endpoint | Descrição | Payload |
|--------|----------|-----------|---------|
| `POST` | `/api/groups` | Criar grupo | `{"name": "string", "description": "string", "imageUrl": "string"}` |
| `GET` | `/api/groups` | Listar grupos do usuário | Token JWT obrigatório |
| `GET` | `/api/groups/{id}/members` | Membros do grupo | Token JWT obrigatório |
| `GET` | `/api/groups/{id}/balances` | **Calcular saldos** | Token JWT obrigatório |

### 🔗 **Convites** (`/api/groups`)

| Método | Endpoint | Descrição | Payload |
|--------|----------|-----------|---------|
| `POST` | `/api/groups/{id}/invite-link` | Gerar link de convite | `{"expirationHours": number}` (opcional) |
| `GET` | `/api/groups/join/{token}` | Aceitar convite | Token JWT obrigatório |

### 💰 **Despesas** (`/api/expenses`)

| Método | Endpoint | Descrição | Payload |
|--------|----------|-----------|---------|
| `POST` | `/api/expenses` | Criar despesa | `{"groupId": number, "description": "string", "totalAmount": number, "payer": "email", "participants": ["email1", "email2"]}` |
| `GET` | `/api/expenses/group/{id}` | Listar despesas do grupo | Token JWT obrigatório |
| `PUT` | `/api/expenses/{id}` | **Editar despesa** | Mesmo payload do POST |
| `DELETE` | `/api/expenses/{id}` | **Excluir despesa** | Token JWT obrigatório |
| `POST` | `/api/expenses/validate-participants` | Validar participantes | `{"groupId": number, "participants": ["email1", "email2"]}` |

### 👤 **Usuários** (`/api/users`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/users/me` | Dados do usuário atual |

## 🏗️ Configuração e Desenvolvimento

### 📋 **Pré-requisitos**

- **Java 21+** (JDK obrigatório)
- **Maven 3.6+** (ou usar wrapper incluído)
- **PostgreSQL 15+** (recomendado 17.5)
- **Git** para clonagem
- **IDE** (IntelliJ IDEA, VS Code, Eclipse)

### 🚀 **Executando Localmente**

#### 1. **Clone o repositório**
```bash
git clone https://github.com/Victor476/fairpay-backend.git
cd fairpay-backend/fairpay-backend
```


#### 3. **Setup do banco automatizado**
```bash
# Windows PowerShell
.\recreate_database.ps1
.\populate_database.ps1

# Linux/macOS
./recreate_database.sh
./populate_database.sh
```

#### 4. **Execute a aplicação**
```bash
# Usando Maven Wrapper (recomendado)
./mvnw spring-boot:run

# Windows
.\mvnw.cmd spring-boot:run

# Maven instalado globalmente
mvn spring-boot:run
```

#### 5. **Aplicação disponível em**
- **API**: `http://localhost:8090`
- **Swagger** (se configurado): `http://localhost:8090/swagger-ui.html`

### 🧪 **Testando a API**


#### **Dados de Teste Pré-carregados**
- **6 usuários** com senha `password123`
- **5 grupos** diferentes com cenários variados
- **20+ despesas** com divisões realistas
- **Participações automáticas** calculadas

### 🐳 **Docker (Configurado)**

#### **Docker Compose disponível**
```bash
# Construir e iniciar todos os serviços
docker-compose up --build

# Apenas iniciar (após build)
docker-compose up -d

# Parar serviços
docker-compose down
```

## 📊 Status do Projeto

### ✅ **Implementado e Testado (≈70%)**

#### **Backend Core**
- ✅ Arquitetura Spring Boot robusta
- ✅ Segurança JWT implementada
- ✅ CRUD completo de usuários, grupos e despesas
- ✅ Sistema de convites por link
- ✅ Cálculo automático de saldos

#### **API REST**
- ✅ **21 endpoints** documentados e funcionais
- ✅ Validação de entrada padronizada
- ✅ Tratamento de erros centralizado
- ✅ Controle de acesso por membro

#### **Automação**
- ✅ Scripts de setup cross-platform
- ✅ Testes automatizados em PowerShell
- ✅ População de dados seed
- ✅ Docker configurado

### 🚧 **Em Desenvolvimento (≈30%)**

#### **Funcionalidades Planejadas**
- 🔄 Sistema de categorias de despesas
- 🔄 Registro de pagamentos entre usuários
- 🔄 Divisão customizada (percentual/valor fixo)
- 🔄 Otimização automática de transferências
- 🔄 Relatórios e analytics
- 🔄 Notificações por email
- 🔄 Upload de comprovantes/anexos
- 🔄 Suporte a múltiplas moedas


### **Banco de Dados (PostgreSQL)**
```sql
-- Principais tabelas implementadas
CREATE TABLE users (id, name, email, password, created_at);
CREATE TABLE groups (id, name, description, image_url, created_by, created_at);
CREATE TABLE group_members (group_id, user_id, role, joined_at);
CREATE TABLE expenses (id, group_id, description, amount, paid_by, created_by, date);
CREATE TABLE expense_participants (expense_id, user_id, amount_owed);
CREATE TABLE refresh_tokens (id, user_id, token, expires_at);
```

## 🛡️ Segurança Implementada

### **Autenticação JWT**
- 🔐 **Access tokens**: 15 minutos (para operações)
- 🔄 **Refresh tokens**: 24 horas (para renovação)
- 🚪 **Logout seguro**: Invalidação de tokens
- 🛡️ **Proteção CORS**: Configurado para frontend

### **Controle de Acesso**
- ✅ Usuários autenticados apenas
- ✅ Membros do grupo apenas
- ✅ Criador/Admin para operações críticas
- ✅ Validação de permissões em tempo real

### **Validação de Dados**
- ✅ Validação de entrada com `@Valid`
- ✅ Sanitização de dados
- ✅ Prevenção de SQL Injection (JPA)
- ✅ Encoding UTF-8 adequado

## 🧮 Exemplo: Cálculo de Saldos

### **Cenário**: Grupo de 3 pessoas com despesas compartilhadas

```json
// GET /api/groups/1/balances
[
  {
    "userId": 1,
    "name": "João",
    "totalPaid": 150.00,    // Pagou R$ 150
    "totalOwed": 100.00,    // Deve R$ 100  
    "balance": 50.00        // Tem a receber R$ 50
  },
  {
    "userId": 2, 
    "name": "Maria",
    "totalPaid": 50.00,     // Pagou R$ 50
    "totalOwed": 100.00,    // Deve R$ 100
    "balance": -50.00       // Deve pagar R$ 50
  },
  {
    "userId": 3,
    "name": "Carlos", 
    "totalPaid": 100.00,    // Pagou R$ 100
    "totalOwed": 100.00,    // Deve R$ 100
    "balance": 0.00         // Está quite
  }
]
```

**Matemática**: `saldo = total_pago - total_devido`

## ⚡ Performance e Otimização

### **Otimizações Implementadas**
- ✅ **Queries otimizadas** com JPA Criteria
- ✅ **Pool de conexões** HikariCP (5-10 conexões)
- ✅ **Lazy loading** para relacionamentos
- ✅ **Índices de banco** em campos chave
- ✅ **Pagination** ready (implementável)

### **Configurações de Produção**
```properties
# Performance tuning
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.connection-timeout=20000
```

## 🧪 Testes e Qualidade

### **Cobertura de Testes**
- ✅ **Testes de integração**: Scripts PowerShell automatizados
- ✅ **Testes de API**: Todos os endpoints validados
- ✅ **Cenários de erro**: 400, 401, 403, 404, 500
- ✅ **Validação de dados**: Entrada inválida testada
- 🔄 **Testes unitários**: Em desenvolvimento

```


## 📈 Roadmap de Desenvolvimento

### **Versão 1.0 - Core (70% completo)**
- [x] Sistema de usuários e autenticação
- [x] Gerenciamento de grupos  
- [x] CRUD de despesas
- [x] Cálculo de saldos
- [x] Sistema de convites

### **Versão 1.1 - Categorias (Planejado)**
- [ ] Sistema completo de categorias
- [ ] Categorias globais e personalizadas
- [ ] Integração com despesas
- [ ] Relatórios por categoria

### **Versão 1.2 - Pagamentos (Planejado)**  
- [ ] Registro de pagamentos
- [ ] Histórico de transações
- [ ] Notificações de pagamento
- [ ] Reconciliação automática

### **Versão 2.0 - Avançado (Futuro)**
- [ ] Divisão customizada
- [ ] Upload de anexos
- [ ] Múltiplas moedas
- [ ] Mobile app integration
- [ ] Analytics avançado

## 🤝 Contribuindo

### **Para Desenvolvedores**

1. **Fork** o repositório
2. **Clone** sua fork localmente
3. **Crie** uma branch para sua feature: `git checkout -b feature/nova-funcionalidade`
4. **Execute** os testes: `./test_api_complete_flow.ps1`
5. **Commit** suas mudanças: `git commit -m "Adiciona nova funcionalidade"`
6. **Push** para sua branch: `git push origin feature/nova-funcionalidade`
7. **Abra** um Pull Request

### **Padrões de Código**
- ✅ Arquitetura em camadas (Controller → Service → Repository)
- ✅ DTOs para transferência de dados
- ✅ Tratamento centralizado de exceções
- ✅ Documentação JavaDoc em métodos públicos
- ✅ Logs estruturados com SLF4J


---

## 🎯 **Status Atual**: ✅ **Funcional e Pronto para Uso**

**Última atualização**: Julho de 2025  
**Versão**: 0.0.1-SNAPSHOT  
**Ambiente de desenvolvimento**: Ativo  

### **Quick Start** 🚀
```bash
git clone https://github.com/Victor476/fairpay-backend.git
cd fairpay-backend/fairpay-backend
./recreate_database.ps1
./mvnw spring-boot:run
# API disponível em http://localhost:8090
```

### **Casos de Uso Típicos** 💡
- 🍕 **Grupo de amigos** dividindo conta do restaurante
- 🏠 **Roommates** compartilhando contas da casa
- ✈️ **Viagens** com múltiplas despesas compartilhadas  
- 🎉 **Eventos** com gastos coletivos organizados

**FairPay** - *Divisão justa, amizades preservadas* 🤝

