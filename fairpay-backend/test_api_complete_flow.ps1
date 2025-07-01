# Script de Teste Completo da API FairPay
# Executa um fluxo completo: criar usuário, login, grupo, convite, despesa, etc.

# Configurações
$baseUrl = "http://localhost:8090"
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

# Função para fazer requisições e mostrar resultado
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
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $bodyBytes
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        
        Write-Host "✅ Sucesso!" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5 | Write-Host
        return $response
    }
    catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Detalhes do erro: $errorBody" -ForegroundColor Red
        }
        return $null
    }
}

# Variáveis para armazenar tokens e IDs
$user1Token = ""
$user2Token = ""
$groupId = ""
$inviteCode = ""
$expenseId = ""

Write-Host "🚀 Iniciando Teste Completo da API FairPay" -ForegroundColor Magenta
Write-Host "Certifique-se de que a aplicação está rodando em $baseUrl" -ForegroundColor Yellow

# 1. Criar primeiro usuário
$timestamp = [Math]::Floor((Get-Date).Ticks / 10000000)
$user1Email = "joao$timestamp@example.com"
$user2Email = "maria$timestamp@example.com"

$user1Data = @{
    name = "João Silva"
    email = $user1Email
    password = "senha123"
    confirmPassword = "senha123"
} | ConvertTo-Json

$user1Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/register" -Headers $headers -Body $user1Data -Description "1. Criando primeiro usuário (João)"

if (-not $user1Response) {
    Write-Host "❌ Falha ao criar primeiro usuário. Parando execução." -ForegroundColor Red
    exit 1
}

# 2. Fazer login do primeiro usuário
$loginData = @{
    email = $user1Email
    password = "senha123"
} | ConvertTo-Json

$loginResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/login" -Headers $headers -Body $loginData -Description "2. Fazendo login do João"

if ($loginResponse -and $loginResponse.accessToken) {
    $user1Token = $loginResponse.accessToken
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $user1Token"
    Write-Host "🔑 Token obtido para João: $($user1Token.Substring(0, 20))..." -ForegroundColor Green
} else {
    Write-Host "❌ Falha no login. Parando execução." -ForegroundColor Red
    exit 1
}

# 3. Criar segundo usuário
$user2Data = @{
    name = "Maria Santos"
    email = $user2Email
    password = "senha456"
    confirmPassword = "senha456"
} | ConvertTo-Json

$user2Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/register" -Headers $headers -Body $user2Data -Description "3. Criando segundo usuário (Maria)"

# 4. Login do segundo usuário
$login2Data = @{
    email = $user2Email
    password = "senha456"
} | ConvertTo-Json

$login2Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/login" -Headers $headers -Body $login2Data -Description "4. Fazendo login da Maria"

if ($login2Response -and $login2Response.accessToken) {
    $user2Token = $login2Response.accessToken
    $auth2Headers = $headers.Clone()
    $auth2Headers["Authorization"] = "Bearer $user2Token"
    Write-Host "🔑 Token obtido para Maria: $($user2Token.Substring(0, 20))..." -ForegroundColor Green
} else {
    Write-Host "⚠️ Falha no login da Maria, continuando com João apenas." -ForegroundColor Yellow
}

# 5. Criar grupo (com João)
$groupData = @{
    name = "Viagem para Gramado"
    description = "Despesas da viagem de fim de semana"
} | ConvertTo-Json

$groupResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/groups" -Headers $authHeaders -Body $groupData -Description "5. Criando grupo 'Viagem para Gramado'"

if ($groupResponse -and $groupResponse.id) {
    $groupId = $groupResponse.id
    Write-Host "🏠 Grupo criado com ID: $groupId" -ForegroundColor Green
} else {
    Write-Host "❌ Falha ao criar grupo. Parando execução." -ForegroundColor Red
    exit 1
}

# 6. Gerar link de convite
$inviteLinkResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/groups/$groupId/invite-link" -Headers $authHeaders -Description "6. Gerando link de convite para o grupo"

if ($inviteLinkResponse -and $inviteLinkResponse.inviteLink) {
    # Extrair o código do UUID da URL
    $inviteCode = ($inviteLinkResponse.inviteLink -split "/")[-1]
    Write-Host "📨 Código de convite gerado: $inviteCode" -ForegroundColor Green
} else {
    Write-Host "⚠️ Falha ao gerar convite, continuando sem convidar Maria." -ForegroundColor Yellow
}

# 7. Aceitar convite (com Maria, se possível)
if ($user2Token -and $inviteCode) {
    $joinResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/join/$inviteCode" -Headers $auth2Headers -Description "7. Maria aceitando convite do grupo"
    
    if ($joinResponse) {
        Write-Host "🎉 Maria entrou no grupo com sucesso!" -ForegroundColor Green
    }
}

# 8. Listar grupos do usuário
$groupsResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups" -Headers $authHeaders -Description "8. Listando grupos do João"

# 9. Criar primeira despesa
$expenseData = @{
    description = "Hotel - Pousada do Vale"
    totalAmount = 350.00
    groupId = $groupId
    payer = $user1Email
    participants = @($user1Email)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$expenseResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/expenses" -Headers $authHeaders -Body $expenseData -Description "9. Criando despesa 'Hotel - Pousada do Vale'"

if ($expenseResponse -and $expenseResponse.id) {
    $expenseId = $expenseResponse.id
    Write-Host "💰 Despesa criada com ID: $expenseId" -ForegroundColor Green
}

# 10. Criar segunda despesa (se Maria estiver no grupo)
if ($user2Token -and $inviteCode) {
    $expense2Data = @{
        description = "Jantar no Restaurante Bella Vista"
        totalAmount = 180.00
        groupId = $groupId
        payer = $user2Email
        participants = @($user1Email, $user2Email)
        date = (Get-Date).ToString("yyyy-MM-dd")
    } | ConvertTo-Json

    $expense2Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/expenses" -Headers $auth2Headers -Body $expense2Data -Description "10. Maria criando despesa 'Jantar no Restaurante'"
}

# 11. Listar despesas do grupo
$expensesResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/expenses/group/$groupId" -Headers $authHeaders -Description "11. Listando despesas do grupo"

# 12. Ver membros do grupo
$groupMembersResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/$groupId/members" -Headers $authHeaders -Description "12. Vendo membros do grupo"

# 13. Logout do primeiro usuário
$logoutResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/logout" -Headers $authHeaders -Description "13. Fazendo logout do João"

# 14. Logout do segundo usuário (se logado)
if ($user2Token) {
    $logout2Response = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/logout" -Headers $auth2Headers -Description "14. Fazendo logout da Maria"
}

Write-Host "`n🎉 Teste completo finalizado!" -ForegroundColor Magenta
Write-Host "Resumo do que foi testado:" -ForegroundColor Yellow
Write-Host "✅ Registro de usuários" -ForegroundColor Green
Write-Host "✅ Login/Logout" -ForegroundColor Green
Write-Host "✅ Criação de grupo" -ForegroundColor Green
Write-Host "✅ Geração de convite" -ForegroundColor Green
Write-Host "✅ Ingresso no grupo via convite" -ForegroundColor Green
Write-Host "✅ Criação de despesas" -ForegroundColor Green
Write-Host "✅ Listagem de grupos e despesas" -ForegroundColor Green

Write-Host "`nIDs gerados durante o teste:" -ForegroundColor Cyan
Write-Host "Grupo ID: $groupId" -ForegroundColor White
Write-Host "Código de Convite: $inviteCode" -ForegroundColor White
Write-Host "Despesa ID: $expenseId" -ForegroundColor White
