#!/bin/bash

# ================================================================
# SCRIPT BASH PARA RECRIAR O BANCO FAIRPAY - LINUX MINT
# ================================================================

# Configurações padrão
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
DATABASE_NAME="${DATABASE_NAME:-fairpay_db}"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando processo de recriação do banco de dados FairPay...${NC}"
echo -e "${YELLOW}📋 Configurações:${NC}"
echo -e "   ${WHITE}- Usuário: $POSTGRES_USER${NC}"
echo -e "   ${WHITE}- Host: $POSTGRES_HOST${NC}"
echo -e "   ${WHITE}- Porta: $POSTGRES_PORT${NC}"
echo -e "   ${WHITE}- Banco: $DATABASE_NAME${NC}"
echo ""

# Verificar se psql está disponível
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ ERRO: PostgreSQL psql não encontrado${NC}"
    echo -e "${YELLOW}💡 Para instalar no Linux Mint:${NC}"
    echo -e "   ${WHITE}sudo apt update${NC}"
    echo -e "   ${WHITE}sudo apt install postgresql postgresql-client${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL psql encontrado${NC}"

# Caminho do script SQL
SCRIPT_PATH="$(dirname "$0")/script para criação do banco final.sql"

# Verificar se o arquivo existe
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}❌ ERRO: Arquivo de script não encontrado: $SCRIPT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Script SQL encontrado${NC}"
echo ""

# Configurar variável de ambiente para senha
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo -n "Digite a senha do PostgreSQL para o usuário '$POSTGRES_USER': "
    read -s POSTGRES_PASSWORD
    echo ""
fi

export PGPASSWORD="$POSTGRES_PASSWORD"

echo -e "${GREEN}✅ Usando senha configurada${NC}"
echo ""

# Função para executar comando psql
execute_psql_command() {
    local command="$1"
    local database="$2"
    local description="$3"
    
    echo -e "${YELLOW}⏳ $description...${NC}"
    
    if psql -U "$POSTGRES_USER" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -d "$database" -c "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $description - Concluído${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - Falhou${NC}"
        return 1
    fi
}

# Função para executar arquivo SQL
execute_psql_file() {
    local file_path="$1"
    local database="$2"
    local description="$3"
    
    echo -e "${YELLOW}⏳ $description...${NC}"
    
    if psql -U "$POSTGRES_USER" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -d "$database" -f "$file_path" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $description - Concluído${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - Falhou${NC}"
        return 1
    fi
}

# Passo 1: Terminar conexões ativas
echo -e "${CYAN}🔌 Passo 1: Terminando conexões ativas...${NC}"
TERMINATE_QUERY="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DATABASE_NAME' AND pid <> pg_backend_pid();"
execute_psql_command "$TERMINATE_QUERY" "postgres" "Terminando conexões ativas"

echo ""
# Passo 2: Excluir banco existente
echo -e "${CYAN}🗑️ Passo 2: Excluindo banco existente...${NC}"
DROP_QUERY="DROP DATABASE IF EXISTS $DATABASE_NAME;"
if ! execute_psql_command "$DROP_QUERY" "postgres" "Excluindo banco $DATABASE_NAME"; then
    echo -e "${RED}❌ Falha ao excluir banco. Abortando...${NC}"
    exit 1
fi

echo ""
# Passo 3: Criar novo banco
echo -e "${CYAN}🆕 Passo 3: Criando novo banco...${NC}"
CREATE_QUERY="CREATE DATABASE $DATABASE_NAME WITH OWNER = $POSTGRES_USER ENCODING = 'UTF8';"
if ! execute_psql_command "$CREATE_QUERY" "postgres" "Criando banco $DATABASE_NAME"; then
    echo -e "${RED}❌ Falha ao criar banco. Abortando...${NC}"
    exit 1
fi

echo ""
# Passo 4: Executar script de criação
echo -e "${CYAN}📊 Passo 4: Executando script de criação...${NC}"
if ! execute_psql_file "$SCRIPT_PATH" "$DATABASE_NAME" "Executando script de criação completo"; then
    echo -e "${RED}❌ Falha ao executar script. Abortando...${NC}"
    exit 1
fi

echo ""
# Passo 5: Verificação final
echo -e "${CYAN}🔍 Passo 5: Verificação final...${NC}"
execute_psql_command "SELECT COUNT(*) as tabelas FROM information_schema.tables WHERE table_schema = 'public';" "$DATABASE_NAME" "Contando tabelas"
execute_psql_command "SELECT COUNT(*) as roles FROM roles;" "$DATABASE_NAME" "Verificando roles"
execute_psql_command "SELECT COUNT(*) as categorias FROM categories;" "$DATABASE_NAME" "Verificando categorias"

# Limpar variável de ambiente
unset PGPASSWORD

echo ""
echo -e "${GREEN}🎉 SUCESSO! Banco recriado com nova estrutura!${NC}"
echo ""
echo -e "${YELLOW}📝 Próximos passos:${NC}"
echo -e "   ${WHITE}1. Reinicie a aplicação Spring Boot${NC}"
echo -e "   ${WHITE}2. Teste os endpoints da API${NC}"
echo -e "   ${WHITE}3. Verifique os dados iniciais${NC}"
echo ""
echo -e "${CYAN}🔗 Para testar a conexão:${NC}"
echo -e "   ${WHITE}psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $DATABASE_NAME${NC}"
echo ""
