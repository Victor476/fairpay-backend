# ================================================================
# SCRIPT PARA POPULAR O BANCO COM DADOS DE TESTE
# ================================================================

param(
    [string]$PostgresUser = "postgres",
    [string]$PostgresPassword = "postgres",
    [string]$PostgresHost = "localhost",
    [string]$PostgresPort = "5432",
    [string]$DatabaseName = "fairpay_db"
)

Write-Host "🌱 Populando banco de dados com dados de teste..." -ForegroundColor Green
Write-Host ""

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
    Write-Host "❌ PostgreSQL psql não encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "✅ PostgreSQL encontrado: $PsqlExe" -ForegroundColor Green

# Caminho do arquivo de semente
$SeedPath = Join-Path $PSScriptRoot "seed_data.sql"

if (-not (Test-Path $SeedPath)) {
    Write-Host "❌ Arquivo de semente não encontrado: $SeedPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Arquivo de semente encontrado" -ForegroundColor Green
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

Write-Host "⏳ Executando arquivo de semente..." -ForegroundColor Yellow

try {
    $arguments = @("-U", $PostgresUser, "-h", $PostgresHost, "-p", $PostgresPort, "-d", $DatabaseName, "-f", $SeedPath)
    $result = & $PsqlExe $arguments 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dados de teste inseridos com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Dados criados:" -ForegroundColor Cyan
        Write-Host "   👥 6 usuários de teste" -ForegroundColor White
        Write-Host "   🏠 5 grupos diferentes" -ForegroundColor White
        Write-Host "   💰 20 despesas variadas" -ForegroundColor White
        Write-Host "   💳 5 pagamentos de exemplo" -ForegroundColor White
        Write-Host "   🔗 3 links de convite ativos" -ForegroundColor White
        Write-Host "   🔔 4 notificações de teste" -ForegroundColor White
        Write-Host ""
        Write-Host "👤 Usuários para teste:" -ForegroundColor Yellow
        Write-Host "   📧 joao@teste.com    | 🔑 password123 | 👑 Admin" -ForegroundColor White
        Write-Host "   📧 maria@teste.com   | 🔑 password123 | 👤 User" -ForegroundColor White
        Write-Host "   📧 pedro@teste.com   | 🔑 password123 | 👤 User" -ForegroundColor White
        Write-Host "   📧 ana@teste.com     | 🔑 password123 | 👤 User" -ForegroundColor White
        Write-Host "   📧 carlos@teste.com  | 🔑 password123 | 👤 User" -ForegroundColor White
        Write-Host "   📧 julia@teste.com   | 🔑 password123 | 👤 User" -ForegroundColor White
        Write-Host ""
        Write-Host "🏠 Grupos criados:" -ForegroundColor Yellow
        Write-Host "   1. Apartamento 101 (João, Maria, Pedro)" -ForegroundColor White
        Write-Host "   2. Viagem para Ubatuba (Maria, Ana, Julia, Carlos)" -ForegroundColor White
        Write-Host "   3. Casa da Praia (Pedro, João, Ana)" -ForegroundColor White
        Write-Host "   4. Escritório Compartilhado (João, Carlos, Julia)" -ForegroundColor White
        Write-Host "   5. Festa de Aniversário (Maria, Pedro, Ana, Carlos, Julia)" -ForegroundColor White
        Write-Host ""
        Write-Host "🧪 Cenários para teste:" -ForegroundColor Cyan
        Write-Host "   ✅ Diferentes tipos de despesas" -ForegroundColor White
        Write-Host "   ✅ Divisões igualitárias automáticas" -ForegroundColor White
        Write-Host "   ✅ Pagamentos pendentes e confirmados" -ForegroundColor White
        Write-Host "   ✅ Saldos positivos e negativos" -ForegroundColor White
        Write-Host "   ✅ Notificações ativas" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Próximos passos:" -ForegroundColor Green
        Write-Host "   1. Inicie a aplicação Spring Boot" -ForegroundColor White
        Write-Host "   2. Faça login com qualquer usuário acima" -ForegroundColor White
        Write-Host "   3. Teste os endpoints da API" -ForegroundColor White
        Write-Host "   4. Explore os grupos e despesas criados" -ForegroundColor White
        
    } else {
        Write-Host "❌ Erro ao executar arquivo de semente" -ForegroundColor Red
        Write-Host "Detalhes: $result" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# Limpar senha
$env:PGPASSWORD = $null

Write-Host ""
Read-Host "Pressione Enter para finalizar"
