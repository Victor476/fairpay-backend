# ================================================================
# SCRIPT POWERSHELL PARA RECRIAR O BANCO FAIRPAY - VERSÃO ALTERNATIVA
# ================================================================

param(
    [string]$PostgresUser = "postgres",
    [string]$PostgresPassword = "postgres",
    [string]$PostgresHost = "localhost", 
    [string]$PostgresPort = "5432",
    [string]$DatabaseName = "fairpay_db"
)

Write-Host "🚀 Iniciando processo de recriação do banco de dados FairPay..." -ForegroundColor Green

# Tentar encontrar psql automaticamente
$PsqlPaths = @(
    "C:\Program Files\PostgreSQL\*\bin\psql.exe",
    "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe",
    "C:\PostgreSQL\*\bin\psql.exe",
    "psql.exe"
)

$PsqlExe = $null
foreach ($path in $PsqlPaths) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($found) {
        $PsqlExe = $found.FullName
        break
    }
}

if (-not $PsqlExe) {
    Write-Host "❌ ERRO: PostgreSQL psql não encontrado" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Caminhos verificados:" -ForegroundColor Yellow
    foreach ($path in $PsqlPaths) {
        Write-Host "   - $path" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "💡 Soluções:" -ForegroundColor Cyan
    Write-Host "   1. Instale o PostgreSQL se não estiver instalado" -ForegroundColor White
    Write-Host "   2. Adicione o PostgreSQL ao PATH do sistema" -ForegroundColor White
    Write-Host "   3. Execute este script do prompt de comando do PostgreSQL" -ForegroundColor White
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host "✅ PostgreSQL encontrado em: $PsqlExe" -ForegroundColor Green
Write-Host ""

# Obter senha
if (-not $PostgresPassword) {
    $SecurePassword = Read-Host "Digite a senha do PostgreSQL para o usuário '$PostgresUser'" -AsSecureString
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
    $env:PGPASSWORD = $PlainPassword
} else {
    $env:PGPASSWORD = $PostgresPassword
    Write-Host "✅ Usando senha padrão configurada" -ForegroundColor Green
}

Write-Host "📋 Configurações:" -ForegroundColor Yellow
Write-Host "   - Usuário: $PostgresUser" -ForegroundColor White
Write-Host "   - Host: $PostgresHost" -ForegroundColor White
Write-Host "   - Porta: $PostgresPort" -ForegroundColor White
Write-Host "   - Banco: $DatabaseName" -ForegroundColor White
Write-Host ""

# Caminho do script SQL
$ScriptPath = Join-Path $PSScriptRoot "script para criação do banco final.sql"

if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ ERRO: Arquivo não encontrado: $ScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Script SQL encontrado" -ForegroundColor Green
Write-Host ""

# Função para executar comando
function Invoke-PsqlCommand {
    param([string]$Command, [string]$Database = "postgres", [string]$Description)
    
    Write-Host "⏳ $Description..." -ForegroundColor Yellow
    
    try {
        $arguments = @("-U", $PostgresUser, "-h", $PostgresHost, "-p", $PostgresPort, "-d", $Database, "-c", $Command)
        $result = & $PsqlExe $arguments 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Description - Concluído" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Description - Falhou" -ForegroundColor Red
            Write-Host "Detalhes: $result" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Função para executar arquivo
function Invoke-PsqlFile {
    param([string]$FilePath, [string]$Database, [string]$Description)
    
    Write-Host "⏳ $Description..." -ForegroundColor Yellow
    
    try {
        $arguments = @("-U", $PostgresUser, "-h", $PostgresHost, "-p", $PostgresPort, "-d", $Database, "-f", $FilePath)
        $result = & $PsqlExe $arguments 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Description - Concluído" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Description - Falhou" -ForegroundColor Red
            Write-Host "Detalhes: $result" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Executar passos
Write-Host "🔌 Passo 1: Terminando conexões ativas..." -ForegroundColor Cyan
$terminateQuery = "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DatabaseName' AND pid <> pg_backend_pid();"
Invoke-PsqlCommand -Command $terminateQuery -Database "postgres" -Description "Terminando conexões"

Write-Host ""
Write-Host "🗑️ Passo 2: Excluindo banco existente..." -ForegroundColor Cyan
Invoke-PsqlCommand -Command "DROP DATABASE IF EXISTS $DatabaseName;" -Database "postgres" -Description "Excluindo banco"

Write-Host ""
Write-Host "🆕 Passo 3: Criando novo banco..." -ForegroundColor Cyan
$createQuery = "CREATE DATABASE $DatabaseName WITH OWNER = $PostgresUser ENCODING = 'UTF8';"
if (-not (Invoke-PsqlCommand -Command $createQuery -Database "postgres" -Description "Criando banco")) {
    Write-Host "❌ Falha crítica. Abortando..." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📊 Passo 4: Executando script de criação..." -ForegroundColor Cyan
if (-not (Invoke-PsqlFile -FilePath $ScriptPath -Database $DatabaseName -Description "Executando script completo")) {
    Write-Host "❌ Falha ao executar script" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔍 Passo 5: Verificação final..." -ForegroundColor Cyan
Invoke-PsqlCommand -Command "SELECT COUNT(*) as tabelas FROM information_schema.tables WHERE table_schema = 'public';" -Database $DatabaseName -Description "Contando tabelas"
Invoke-PsqlCommand -Command "SELECT COUNT(*) as roles FROM roles;" -Database $DatabaseName -Description "Verificando roles"
Invoke-PsqlCommand -Command "SELECT COUNT(*) as categorias FROM categories;" -Database $DatabaseName -Description "Verificando categorias"

# Limpar senha
$env:PGPASSWORD = $null

Write-Host ""
Write-Host "🎉 SUCESSO! Banco recriado com nova estrutura!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Reinicie a aplicação Spring Boot" -ForegroundColor White
Write-Host "   2. Teste os endpoints da API" -ForegroundColor White
Write-Host "   3. Verifique os dados iniciais" -ForegroundColor White
Write-Host ""

Read-Host "Pressione Enter para finalizar"
