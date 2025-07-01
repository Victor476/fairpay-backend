# 🐧 FairPay - Configuração para Linux Mint

Este guia explica como configurar e executar o FairPay no Linux Mint.

## 🚀 Instalação Rápida (Recomendada)

Execute o script de instalação automática:

```bash
# Tornar o script executável
chmod +x setup_linux_mint.sh

# Executar instalação completa
./setup_linux_mint.sh
```

Este script irá instalar automaticamente:
- ✅ PostgreSQL 
- ✅ Java 17 (OpenJDK)
- ✅ Apache Maven
- ✅ curl e git
- ✅ Configurar senha padrão do PostgreSQL

## 📋 Instalação Manual

Se preferir instalar manualmente:

### 1. Atualizar sistema
```bash
sudo apt update
sudo apt upgrade
```

### 2. Instalar PostgreSQL
```bash
sudo apt install postgresql postgresql-client postgresql-contrib

# Configurar senha do postgres
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Iniciar serviço
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 3. Instalar Java 17
```bash
sudo apt install openjdk-17-jdk openjdk-17-jre
```

### 4. Instalar Maven
```bash
sudo apt install maven
```

### 5. Ferramentas adicionais
```bash
sudo apt install curl git
```

## 🗄️ Configuração do Banco de Dados

### 1. Recriar banco com nova estrutura
```bash
# Tornar script executável
chmod +x recreate_database.sh

# Executar
./recreate_database.sh
```

### 2. Popular com dados de teste
```bash
# Tornar script executável
chmod +x populate_database.sh

# Executar
./populate_database.sh
```

## ▶️ Executar a Aplicação

```bash
# Compilar e executar
mvn clean spring-boot:run

# Ou compilar separadamente
mvn clean compile
mvn spring-boot:run
```

A aplicação estará disponível em: `http://localhost:8090`

## 🧪 Testar a API

### Login de teste
```bash
curl -X POST http://localhost:8090/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@teste.com",
    "password": "password123"
  }'
```

### Listar grupos (após login)
```bash
curl -X GET http://localhost:8090/api/user/groups \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## 👥 Usuários de Teste

| Email | Senha | Tipo |
|-------|-------|------|
| `joao@teste.com` | `password123` | Admin |
| `maria@teste.com` | `password123` | User |
| `pedro@teste.com` | `password123` | User |
| `ana@teste.com` | `password123` | User |
| `carlos@teste.com` | `password123` | User |
| `julia@teste.com` | `password123` | User |

## 🛠️ Comandos Úteis

### PostgreSQL
```bash
# Conectar ao banco
psql -U postgres -d fairpay_db

# Status do serviço
sudo systemctl status postgresql

# Parar/Iniciar serviço
sudo systemctl stop postgresql
sudo systemctl start postgresql

# Ver logs
sudo journalctl -u postgresql
```

### Maven
```bash
# Limpar compilação
mvn clean

# Compilar apenas
mvn compile

# Executar testes
mvn test

# Empacotar JAR
mvn package
```

### Aplicação
```bash
# Executar em modo debug
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"

# Executar com perfil específico
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Ver logs em tempo real
tail -f logs/application.log
```

## 🔧 Configurações Personalizadas

### Variáveis de Ambiente
```bash
# No arquivo ~/.bashrc ou ~/.profile
export POSTGRES_USER="postgres"
export POSTGRES_PASSWORD="postgres"
export POSTGRES_HOST="localhost"
export POSTGRES_PORT="5432"
export DATABASE_NAME="fairpay_db"
```

### Configuração alternativa do banco
```bash
# Usar configurações customizadas
POSTGRES_PASSWORD="minhasenha" ./recreate_database.sh
DATABASE_NAME="fairpay_dev" ./populate_database.sh
```

## 🐛 Resolução de Problemas

### PostgreSQL não inicia
```bash
# Verificar status
sudo systemctl status postgresql

# Ver logs
sudo journalctl -u postgresql -n 50

# Reiniciar serviço
sudo systemctl restart postgresql
```

### Erro de conexão
```bash
# Verificar se PostgreSQL está escutando
sudo netstat -plnt | grep 5432

# Verificar configuração
sudo cat /etc/postgresql/*/main/postgresql.conf | grep listen_addresses
```

### Erro de autenticação
```bash
# Verificar método de autenticação
sudo cat /etc/postgresql/*/main/pg_hba.conf

# Resetar senha do postgres
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
```

### Java/Maven não encontrado
```bash
# Verificar instalação
java -version
mvn -version

# Verificar JAVA_HOME
echo $JAVA_HOME

# Configurar se necessário
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

## 📁 Estrutura dos Scripts

```
fairpay-backend/
├── setup_linux_mint.sh      # Instalação completa do ambiente
├── recreate_database.sh     # Recriar banco de dados
├── populate_database.sh     # Popular com dados de teste
├── seed_data.sql           # Dados de teste SQL
└── script para criação do banco final.sql  # Schema completo
```

## ✨ Dicas Adicionais

### Alias úteis para o .bashrc
```bash
# Adicionar ao ~/.bashrc
alias fairpay-start="cd ~/fairpay && mvn spring-boot:run"
alias fairpay-test="cd ~/fairpay && mvn test"
alias fairpay-db="psql -U postgres -d fairpay_db"
alias fairpay-logs="tail -f ~/fairpay/logs/application.log"
```

### Configurar VS Code (opcional)
```bash
# Instalar VS Code
sudo snap install code --classic

# Extensões recomendadas
code --install-extension vscjava.vscode-java-pack
code --install-extension ms-vscode.vscode-spring-initializr
code --install-extension cweijan.vscode-postgresql-client2
```

Com essa configuração, você terá um ambiente completo para desenvolver e testar o FairPay no Linux Mint! 🎉
