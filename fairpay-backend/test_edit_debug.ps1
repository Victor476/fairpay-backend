# Teste simples para verificar edição e exclusão de despesas - VERSÃO DEBUG
param([string]$BaseUrl = "http://localhost:8090")

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "DEBUG - Teste Simples - Edição e Exclusão de Despesas" -ForegroundColor Cyan

# 1. Criar usuário único
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$userEmail = "edit_test_${timestamp}@example.com"
$userName = "TestEditUser${timestamp}"

Write-Host "`n1. Criando usuário: $userName" -ForegroundColor Yellow
$registerBody = @{
    name = $userName
    email = $userEmail
    password = "123456"
    confirmPassword = "123456"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✅ Usuário criado!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Login
Write-Host "`n2. Fazendo login..." -ForegroundColor Yellow
$loginBody = @{
    email = $userEmail
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 3. Criar grupo
Write-Host "`n3. Criando grupo..." -ForegroundColor Yellow
$groupBody = @{
    name = "Grupo Teste $(Get-Random)"
    description = "Grupo criado pelo script de teste"
} | ConvertTo-Json

try {
    Write-Host "   Payload: $groupBody" -ForegroundColor Gray
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupBody -Headers $headers
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name) (ID: $groupId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar grupo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}

# 4. Criar despesa
Write-Host "`n4. Criando despesa..." -ForegroundColor Yellow
$expenseBody = @{
    groupId = $groupId
    description = "Despesa Original"
    totalAmount = 100.00
    payer = $userEmail
    participants = @($userEmail)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    Write-Host "   Payload da despesa: $expenseBody" -ForegroundColor Gray
    $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseBody -Headers $headers
    $expenseId = $expenseResponse.id
    Write-Host "✅ Despesa criada: ID $expenseId - $($expenseResponse.description) - R$ $($expenseResponse.totalAmount)" -ForegroundColor Green
    
    # Aguardar para garantir persistência
    Start-Sleep -Seconds 2
    
} catch {
    Write-Host "❌ Erro ao criar despesa: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}

# 5. TESTAR EDIÇÃO
Write-Host "`n5. TESTANDO EDIÇÃO DE DESPESA..." -ForegroundColor Yellow
$editBody = @{
    groupId = $groupId
    description = "Despesa EDITADA - Nova Descrição"
    totalAmount = 200.00
    payer = $userEmail
    participants = @($userEmail)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    Write-Host "   Payload da edição: $editBody" -ForegroundColor Gray
    Write-Host "   Endpoint: PUT $BaseUrl/api/expenses/$expenseId" -ForegroundColor Gray
    
    $editResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method PUT -Body $editBody -Headers $headers
    Write-Host "✅ SUCESSO! Despesa editada:" -ForegroundColor Green
    Write-Host "   Descrição: $($editResponse.description)" -ForegroundColor Gray
    Write-Host "   Valor: R$ $($editResponse.totalAmount)" -ForegroundColor Gray
    
    # Verificar se mudanças foram aplicadas
    if ($editResponse.description -eq "Despesa EDITADA - Nova Descrição" -and $editResponse.totalAmount -eq 200.00) {
        Write-Host "✅ VALIDAÇÃO: Edição aplicada corretamente!" -ForegroundColor Green
    } else {
        Write-Host "❌ VALIDAÇÃO: Edição não foi aplicada!" -ForegroundColor Red
        Write-Host "   Descrição atual: $($editResponse.description)" -ForegroundColor Yellow
        Write-Host "   Valor atual: R$ $($editResponse.totalAmount)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ ERRO ao editar despesa: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   HTTP Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "   Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    
    # Verificar se a despesa ainda existe
    try {
        $checkExpense = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$groupId" -Method GET -Headers $headers
        $despesaExiste = $checkExpense | Where-Object { $_.id -eq $expenseId }
        if ($despesaExiste) {
            Write-Host "   A despesa ainda existe no banco. ID: $expenseId" -ForegroundColor Yellow
            Write-Host "   Detalhes da despesa: $($despesaExiste | ConvertTo-Json)" -ForegroundColor Gray
        } else {
            Write-Host "   A despesa não foi encontrada no banco." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Erro ao verificar se a despesa existe: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 6. TESTAR EXCLUSÃO
Write-Host "`n6. TESTANDO EXCLUSÃO DE DESPESA..." -ForegroundColor Yellow
try {
    Write-Host "   Endpoint: DELETE $BaseUrl/api/expenses/$expenseId" -ForegroundColor Gray
    $deleteResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method DELETE -Headers $headers
    Write-Host "✅ SUCESSO! Despesa excluída: $($deleteResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao excluir despesa: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   HTTP Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "   Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

Write-Host "`nTESTE DEBUG CONCLUÍDO!" -ForegroundColor Cyan
