# Script de Teste Rápido da API FairPay
# Versão simplificada para testes básicos

$baseUrl = "http://localhost:8090"
$headers = @{"Content-Type" = "application/json; charset=utf-8"}

Write-Host "🚀 Teste Rápido da API FairPay" -ForegroundColor Magenta

# 1. Criar usuário
$userData = @{
    name = "Teste User"
    email = "teste$(Get-Random)@example.com"
    password = "senha123"
    confirmPassword = "senha123"
} | ConvertTo-Json

Write-Host "`n1. Criando usuário..." -ForegroundColor Yellow
try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $userData
    Write-Host "✅ Usuário criado: $($userResponse.user.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Login
$loginData = @{
    email = $userResponse.user.email
    password = "senha123"
} | ConvertTo-Json

Write-Host "`n2. Fazendo login..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    $token = $loginResponse.accessToken
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $token"
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Criar grupo
$groupData = @{
    name = "Grupo Teste $(Get-Random)"
    description = "Grupo criado pelo script de teste"
} | ConvertTo-Json

Write-Host "`n3. Criando grupo..." -ForegroundColor Yellow
try {
    $groupResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method POST -Headers $authHeaders -Body $groupData
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name) (ID: $groupId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar grupo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Gerar convite
Write-Host "`n4. Gerando convite..." -ForegroundColor Yellow
try {
    $inviteResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/invite-link" -Method POST -Headers $authHeaders
    $inviteCode = $inviteResponse.inviteCode
    Write-Host "✅ Convite gerado: $inviteCode" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao gerar convite: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Criar despesa
$expenseData = @{
    description = "Despesa de Teste $(Get-Random)"
    totalAmount = 100.50
    groupId = $groupId
    payer = $userResponse.user.email
    participants = @($userResponse.user.email)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

Write-Host "`n5. Criando despesa..." -ForegroundColor Yellow
try {
    $expenseResponse = Invoke-RestMethod -Uri "$baseUrl/api/expenses" -Method POST -Headers $authHeaders -Body $expenseData
    Write-Host "✅ Despesa criada: $($expenseResponse.description) (R$ $($expenseResponse.totalAmount))" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar despesa: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Listar grupos
Write-Host "`n6. Listando grupos..." -ForegroundColor Yellow
try {
    $groupsResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Grupos encontrados: $($groupsResponse.Count)" -ForegroundColor Green
    $groupsResponse | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor White }
} catch {
    Write-Host "❌ Erro ao listar grupos: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Logout
Write-Host "`n7. Fazendo logout..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/api/auth/logout" -Method POST -Headers $authHeaders
    Write-Host "✅ Logout realizado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no logout: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Teste rápido concluído!" -ForegroundColor Magenta
