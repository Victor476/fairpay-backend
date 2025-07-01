#!/bin/bash

# ================================================================
# SCRIPT DE INSTALAÇÃO E CONFIGURAÇÃO COMPLETA - LINUX MINT
# Instala PostgreSQL, Java, Maven e configura o ambiente FairPay
# ================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Instalação e Configuração do Ambiente FairPay - Linux Mint${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# Verificar se é root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Não execute este script como root. Use um usuário normal.${NC}"
    exit 1
fi

# Atualizar sistema
echo -e "${YELLOW}📦 Atualizando sistema...${NC}"
sudo apt update -qq

# Verificar e instalar PostgreSQL
echo -e "${YELLOW}🗄️ Verificando PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${CYAN}📥 Instalando PostgreSQL...${NC}"
    sudo apt install -y postgresql postgresql-client postgresql-contrib
    
    # Configurar senha do postgres
    echo -e "${CYAN}🔐 Configurando senha do usuário postgres...${NC}"
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
    
    echo -e "${GREEN}✅ PostgreSQL instalado e configurado${NC}"
else
    echo -e "${GREEN}✅ PostgreSQL já está instalado${NC}"
fi

# Verificar e instalar Java
echo -e "${YELLOW}☕ Verificando Java...${NC}"
if ! command -v java &> /dev/null; then
    echo -e "${CYAN}📥 Instalando OpenJDK 17...${NC}"
    sudo apt install -y openjdk-17-jdk openjdk-17-jre
    echo -e "${GREEN}✅ Java 17 instalado${NC}"
else
    JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "([0-9]+)' | cut -d'"' -f2)
    echo -e "${GREEN}✅ Java $JAVA_VERSION já está instalado${NC}"
fi

# Verificar e instalar Maven
echo -e "${YELLOW}📦 Verificando Maven...${NC}"
if ! command -v mvn &> /dev/null; then
    echo -e "${CYAN}📥 Instalando Maven...${NC}"
    sudo apt install -y maven
    echo -e "${GREEN}✅ Maven instalado${NC}"
else
    MAVEN_VERSION=$(mvn -version 2>&1 | grep -oP 'Apache Maven [0-9.]+' | cut -d' ' -f3)
    echo -e "${GREEN}✅ Maven $MAVEN_VERSION já está instalado${NC}"
fi

# Verificar e instalar curl (para testes de API)
echo -e "${YELLOW}🌐 Verificando curl...${NC}"
if ! command -v curl &> /dev/null; then
    echo -e "${CYAN}📥 Instalando curl...${NC}"
    sudo apt install -y curl
    echo -e "${GREEN}✅ curl instalado${NC}"
else
    echo -e "${GREEN}✅ curl já está instalado${NC}"
fi

# Verificar e instalar git
echo -e "${YELLOW}📋 Verificando git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${CYAN}📥 Instalando git...${NC}"
    sudo apt install -y git
    echo -e "${GREEN}✅ git instalado${NC}"
else
    echo -e "${GREEN}✅ git já está instalado${NC}"
fi

# Iniciar e habilitar PostgreSQL
echo -e "${YELLOW}🔄 Configurando serviços...${NC}"
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verificar se PostgreSQL está rodando
if systemctl is-active --quiet postgresql; then
    echo -e "${GREEN}✅ PostgreSQL está rodando${NC}"
else
    echo -e "${RED}❌ Erro: PostgreSQL não está rodando${NC}"
    exit 1
fi

# Tornar scripts executáveis
echo -e "${YELLOW}🔧 Configurando permissões dos scripts...${NC}"
SCRIPT_DIR="$(dirname "$0")"
chmod +x "$SCRIPT_DIR/recreate_database.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/populate_database.sh" 2>/dev/null || true

echo ""
echo -e "${GREEN}🎉 Instalação concluída com sucesso!${NC}"
echo ""
echo -e "${CYAN}📋 Resumo da instalação:${NC}"
echo -e "   ${WHITE}✅ PostgreSQL com senha 'postgres'${NC}"
echo -e "   ${WHITE}✅ Java/OpenJDK 17${NC}"
echo -e "   ${WHITE}✅ Apache Maven${NC}"
echo -e "   ${WHITE}✅ curl para testes${NC}"
echo -e "   ${WHITE}✅ git para versionamento${NC}"
echo ""
echo -e "${YELLOW}🚀 Próximos passos:${NC}"
echo -e "   ${WHITE}1. Execute: ./recreate_database.sh${NC}"
echo -e "   ${WHITE}2. Execute: ./populate_database.sh${NC}"
echo -e "   ${WHITE}3. Inicie a aplicação: mvn spring-boot:run${NC}"
echo ""
echo -e "${CYAN}🔗 Comandos úteis:${NC}"
echo -e "   ${WHITE}# Conectar ao PostgreSQL:${NC}"
echo -e "   ${WHITE}psql -U postgres -d fairpay_db${NC}"
echo ""
echo -e "   ${WHITE}# Verificar status do PostgreSQL:${NC}"
echo -e "   ${WHITE}sudo systemctl status postgresql${NC}"
echo ""
echo -e "   ${WHITE}# Parar/Iniciar PostgreSQL:${NC}"
echo -e "   ${WHITE}sudo systemctl stop postgresql${NC}"
echo -e "   ${WHITE}sudo systemctl start postgresql${NC}"
echo ""
echo -e "${GREEN}✨ Ambiente pronto para desenvolvimento!${NC}"
echo ""
