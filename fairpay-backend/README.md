# FairPay Backend

## Visão Geral

O FairPay Backend é uma API RESTful desenvolvida com Spring Boot que gerencia divisão de despesas e pagamentos entre grupos de pessoas. A aplicação facilita o acompanhamento de dívidas, pagamentos e balanços financeiros entre amigos, roommates ou grupos.

## Tecnologias

- **Java 21**
- **Spring Boot 3.x**
- **PostgreSQL**: Banco de dados relacional
- **JWT**: Autenticação e autorização
- **Hibernate/JPA**: Mapeamento objeto-relacional
- **Docker**: Containerização da aplicação

## Funcionalidades Principais

- **Gerenciamento de Usuários**
  - Cadastro e autenticação
  - Perfis de usuário
  - Recuperação de senha

- **Grupos**
  - Criação e gerenciamento de grupos
  - Convites por link
  - Adição e remoção de membros

- **Despesas**
  - Registro de despesas
  - Divisão personalizada
  - Categorização

- **Pagamentos**
  - Registro de pagamentos
  - Atualização automática de saldos
  - Histórico de transações

- **Balanço**
  - Cálculo de dívidas otimizadas
  - Visualização de balanço atual
  - Relatórios de despesas

## Estrutura da API

### Endpoints Principais

- `/api/auth`: Autenticação e gerenciamento de tokens
- `/api/users`: Operações relacionadas a usuários
- `/api/groups`: Gerenciamento de grupos
- `/api/expenses`: Registro e consulta de despesas
- `/api/payments`: Registro e consulta de pagamentos
- `/api/balance`: Consulta de saldos e balanços

## Configuração Local

### Pré-requisitos

- Java 21+
- Maven
- PostgreSQL
- IDE (IntelliJ IDEA, Eclipse, etc.)

### Executando Localmente

1. Clone o repositório
   ```bash
   git clone https://github.com/seu-usuario/fairpay.git
   cd fairpay/fairpay-backend/fairpay-backend
   ```

2. Configure o PostgreSQL
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/fairpay
   spring.datasource.username=fairpay
   spring.datasource.password=fairpay123
   ```

3. Execute a aplicação
   ```bash
   ./mvnw spring-boot:run
   ```

4. A API estará disponível em `http://localhost:8090`

## Configuração Docker

A aplicação pode ser executada usando Docker. Consulte o README principal na raiz do projeto para instruções detalhadas sobre Docker.

## Segurança

- Autenticação baseada em JWT
- Tokens de refresh para manter a sessão
- Armazenamento seguro de senhas com BCrypt
- Validação de entrada de dados

## Modelagem de Dados

A aplicação utiliza as seguintes entidades principais:
- User: Armazena informações do usuário
- Group: Define grupos de usuários que compartilham despesas
- Expense: Registro de despesas com informações de valor, descrição e divisão
- Payment: Registro de pagamentos entre usuários
- Transaction: Histórico de todas as transações financeiras

## Integração com Frontend

O backend se comunica com o frontend Next.js através de endpoints RESTful, sendo o frontend responsável pela renderização e experiência do usuário.

## Desenvolvimento

### Padrões de Código

- Arquitetura em camadas (Controller, Service, Repository)
- Tratamento centralizado de exceções
- DTOs para transferência de dados
- Validação de entrada

### Testes

- Testes unitários para lógica de negócio
- Testes de integração para APIs

## Licença

Este projeto está licenciado sob a Licença MIT.

## Contribuições

Contribuições são bem-vindas! Por favor, siga os padrões de código e adicione testes para novas funcionalidades.
