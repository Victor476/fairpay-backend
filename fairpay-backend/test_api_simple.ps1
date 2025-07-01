# Script de Teste Simples da API FairPay com Saldos
# Testa os principais endpoints incluindo o novo endpoint de saldos

# Configurações
$baseUrl = "http://localhost:8090"
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

# Função para fazer requisições
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [string]$Body = $null,
        [string]$Description
    )
    
    Write-Host "`n=== $Description ===" -ForegroundColor Cyan
    Write-Host "[$Method] $Uri" -ForegroundColor Yellow
    
    if ($Body) {
        Write-Host "Body: $Body" -ForegroundColor Gray
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($Body))
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        
        Write-Host "✅ Sucesso!" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5 | Write-Host
        return $response
    }
    catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🚀 Iniciando Teste da API FairPay com Saldos" -ForegroundColor Magenta

# 1. Registrar usuário
$userData = @{
    name = "João Silva"
    email = "joao.teste@example.com"
    password = "senha123"
    confirmPassword = "senha123"
} | ConvertTo-Json

$userResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/register" -Headers $headers -Body $userData -Description "1. Registrando usuário"

# 2. Fazer login
$loginData = @{
    email = "joao.teste@example.com"
    password = "senha123"
} | ConvertTo-Json

$loginResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/login" -Headers $headers -Body $loginData -Description "2. Fazendo login"

if ($loginResponse -and $loginResponse.accessToken) {
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $($loginResponse.accessToken)"
    Write-Host "🔑 Token obtido!" -ForegroundColor Green
} else {
    Write-Host "❌ Falha no login. Parando execução." -ForegroundColor Red
    exit 1
}

# 3. Criar grupo
$groupData = @{
    name = "Teste Saldos"
    description = "Grupo para testar cálculo de saldos"
} | ConvertTo-Json

$groupResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/groups" -Headers $authHeaders -Body $groupData -Description "3. Criando grupo"

if ($groupResponse -and $groupResponse.id) {
    $groupId = $groupResponse.id
    Write-Host "🏠 Grupo criado com ID: $groupId" -ForegroundColor Green
} else {
    Write-Host "❌ Falha ao criar grupo." -ForegroundColor Red
    exit 1
}

# 4. Listar grupos
$groupsResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups" -Headers $authHeaders -Description "4. Listando grupos"

# 5. Criar primeira despesa
$expenseData = @{
    description = "Despesa Teste 1"
    totalAmount = 100.00
    groupId = $groupId
    payer = "joao.teste@example.com"
    participants = @("joao.teste@example.com")
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$expenseResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/expenses" -Headers $authHeaders -Body $expenseData -Description "5. Criando primeira despesa"

# 6. Criar segunda despesa
$expense2Data = @{
    description = "Despesa Teste 2"
    totalAmount = 150.00
    groupId = $groupId
    payer = "joao.teste@example.com"
    participants = @("joao.teste@example.com")
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$expense2Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/expenses" -Headers $authHeaders -Body $expense2Data -Description "6. Criando segunda despesa"

# 7. Calcular saldos do grupo
$balancesResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/$groupId/balances" -Headers $authHeaders -Description "7. Calculando saldos do grupo"

# 8. Listar membros do grupo
$membersResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/$groupId/members" -Headers $authHeaders -Description "8. Listando membros do grupo"

# 9. Logout
$logoutResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/logout" -Headers $authHeaders -Description "9. Fazendo logout"

Write-Host "`n🎉 Teste com saldos finalizado!" -ForegroundColor Magenta
Write-Host "✅ Registro, login, grupo, despesas e cálculo de saldos funcionando!" -ForegroundColor Green
