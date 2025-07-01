#!/bin/bash

# ================================================================
# SCRIPT BASH PARA POPULAR O BANCO COM DADOS DE TESTE - LINUX MINT
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

echo -e "${GREEN}🌱 Populando banco de dados com dados de teste...${NC}"
echo ""

# Verificar se psql está disponível
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL psql não encontrado${NC}"
    echo -e "${YELLOW}💡 Para instalar no Linux Mint:${NC}"
    echo -e "   ${WHITE}sudo apt update${NC}"
    echo -e "   ${WHITE}sudo apt install postgresql postgresql-client${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL psql encontrado${NC}"

# Caminho do arquivo de semente
SEED_PATH="$(dirname "$0")/seed_data.sql"

if [ ! -f "$SEED_PATH" ]; then
    echo -e "${RED}❌ Arquivo de semente não encontrado: $SEED_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Arquivo de semente encontrado${NC}"
echo ""

# Configurar senha
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo -n "Digite a senha do PostgreSQL para o usuário '$POSTGRES_USER': "
    read -s POSTGRES_PASSWORD
    echo ""
fi

export PGPASSWORD="$POSTGRES_PASSWORD"

echo -e "${YELLOW}⏳ Executando arquivo de semente...${NC}"

# Executar arquivo de semente
if psql -U "$POSTGRES_USER" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -d "$DATABASE_NAME" -f "$SEED_PATH" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Dados de teste inseridos com sucesso!${NC}"
    echo ""
    echo -e "${CYAN}📊 Dados criados:${NC}"
    echo -e "   ${WHITE}👥 6 usuários de teste${NC}"
    echo -e "   ${WHITE}🏠 5 grupos diferentes${NC}"
    echo -e "   ${WHITE}💰 20 despesas variadas${NC}"
    echo -e "   ${WHITE}💳 5 pagamentos de exemplo${NC}"
    echo -e "   ${WHITE}🔗 3 links de convite ativos${NC}"
    echo -e "   ${WHITE}🔔 4 notificações de teste${NC}"
    echo ""
    echo -e "${YELLOW}👤 Usuários para teste:${NC}"
    echo -e "   ${WHITE}📧 joao@teste.com    | 🔑 password123 | 👑 Admin${NC}"
    echo -e "   ${WHITE}📧 maria@teste.com   | 🔑 password123 | 👤 User${NC}"
    echo -e "   ${WHITE}📧 pedro@teste.com   | 🔑 password123 | 👤 User${NC}"
    echo -e "   ${WHITE}📧 ana@teste.com     | 🔑 password123 | 👤 User${NC}"
    echo -e "   ${WHITE}📧 carlos@teste.com  | 🔑 password123 | 👤 User${NC}"
    echo -e "   ${WHITE}📧 julia@teste.com   | 🔑 password123 | 👤 User${NC}"
    echo ""
    echo -e "${YELLOW}🏠 Grupos criados:${NC}"
    echo -e "   ${WHITE}1. Apartamento 101 (João, Maria, Pedro)${NC}"
    echo -e "   ${WHITE}2. Viagem para Ubatuba (Maria, Ana, Julia, Carlos)${NC}"
    echo -e "   ${WHITE}3. Casa da Praia (Pedro, João, Ana)${NC}"
    echo -e "   ${WHITE}4. Escritório Compartilhado (João, Carlos, Julia)${NC}"
    echo -e "   ${WHITE}5. Festa de Aniversário (Maria, Pedro, Ana, Carlos, Julia)${NC}"
    echo ""
    echo -e "${CYAN}🧪 Cenários para teste:${NC}"
    echo -e "   ${WHITE}✅ Diferentes tipos de despesas${NC}"
    echo -e "   ${WHITE}✅ Divisões igualitárias automáticas${NC}"
    echo -e "   ${WHITE}✅ Pagamentos pendentes e confirmados${NC}"
    echo -e "   ${WHITE}✅ Saldos positivos e negativos${NC}"
    echo -e "   ${WHITE}✅ Notificações ativas${NC}"
    echo ""
    echo -e "${GREEN}🚀 Próximos passos:${NC}"
    echo -e "   ${WHITE}1. Inicie a aplicação Spring Boot${NC}"
    echo -e "   ${WHITE}2. Faça login com qualquer usuário acima${NC}"
    echo -e "   ${WHITE}3. Teste os endpoints da API${NC}"
    echo -e "   ${WHITE}4. Explore os grupos e despesas criados${NC}"
else
    echo -e "${RED}❌ Erro ao executar arquivo de semente${NC}"
    exit 1
fi

# Limpar variável de ambiente
unset PGPASSWORD

echo ""
echo -e "${GREEN}✨ Processo concluído!${NC}"
echo ""
