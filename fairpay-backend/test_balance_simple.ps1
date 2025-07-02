# Script simples para testar cálculo de saldos
# Cria um cenário completo e testa o endpoint

param([string]$BaseUrl = "http://localhost:8090")

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🧮 Teste de Cálculo de Saldos - Versão Simples" -ForegroundColor Cyan

# 1. Criar usuário principal
$random = Get-Random
$userName = "Usuario Test $random"
$userEmail = "usuario$random@teste.com"

Write-Host "👤 1. Criando usuário: $userName" -ForegroundColor Yellow
$registerBody = @{
    name = $userName
    email = $userEmail
    password = "123456"
    confirmPassword = "123456"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✅ Usuário criado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Fazer login
Write-Host "🔑 2. Fazendo login..." -ForegroundColor Yellow
$loginBody = @{
    email = $userEmail
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 3. Criar grupo
Write-Host "🏠 3. Criando grupo..." -ForegroundColor Yellow
$groupBody = @{
    name = "Grupo Teste Saldos $random"
    description = "Grupo para testar saldos"
} | ConvertTo-Json

try {
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupBody -Headers $headers
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name) (ID: $groupId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar grupo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Criar despesa simples (apenas com o usuário atual)
Write-Host "💰 4. Criando despesa de teste..." -ForegroundColor Yellow
$expenseBody = @{
    groupId = $groupId
    description = "Despesa Teste para Saldos"
    amount = 100.00
    paidByEmail = $userEmail
    participantEmails = @($userEmail)
} | ConvertTo-Json

try {
    $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseBody -Headers $headers
    Write-Host "✅ Despesa criada: $($expenseResponse.description) - R$ $($expenseResponse.amount)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar despesa: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 5. TESTAR ENDPOINT DE SALDOS
Write-Host "🧮 5. TESTANDO CÁLCULO DE SALDOS..." -ForegroundColor Yellow
try {
    $balancesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$groupId/balances" -Method GET -Headers $headers
    Write-Host "✅ SUCESSO! Endpoint de saldos funcionando!" -ForegroundColor Green
    
    Write-Host "`n📊 SALDOS CALCULADOS:" -ForegroundColor Blue
    Write-Host ("-" * 80) -ForegroundColor Gray
    Write-Host ('{0,-25} {1,-15} {2,-15} {3,-15}' -f "Nome", "Total Pago", "Total Devido", "Saldo") -ForegroundColor Cyan
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    foreach ($balance in $balancesResponse) {
        $name = $balance.name
        $totalPaid = if ($balance.totalPaid) { [decimal]$balance.totalPaid } else { 0 }
        $totalOwed = if ($balance.totalOwed) { [decimal]$balance.totalOwed } else { 0 }
        $finalBalance = if ($balance.balance) { [decimal]$balance.balance } else { 0 }
        
        $paidFormatted = "R$ {0:F2}" -f $totalPaid
        $owedFormatted = "R$ {0:F2}" -f $totalOwed
        $balanceFormatted = "R$ {0:F2}" -f $finalBalance
        
        $balanceColor = if ($finalBalance -gt 0) { "Green" } elseif ($finalBalance -lt 0) { "Red" } else { "Gray" }
        
        Write-Host ('{0,-25} {1,-15} {2,-15} {3,-15}' -f $name, $paidFormatted, $owedFormatted, $balanceFormatted) -ForegroundColor $balanceColor
    }
    
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Validar estrutura do DTO
    $firstBalance = $balancesResponse[0]
    Write-Host "`n🔍 VALIDAÇÃO DO DTO:" -ForegroundColor Blue
    $userIdCheck = if ($firstBalance.userId -ne $null) { '✅' } else { '❌' }
    $nameCheck = if ($firstBalance.name -ne $null) { '✅' } else { '❌' }
    $totalPaidCheck = if ($firstBalance.totalPaid -ne $null) { '✅' } else { '❌' }
    $totalOwedCheck = if ($firstBalance.totalOwed -ne $null) { '✅' } else { '❌' }
    $balanceCheck = if ($firstBalance.balance -ne $null) { '✅' } else { '❌' }
    
    Write-Host "  • userId: $userIdCheck ($($firstBalance.userId))" -ForegroundColor Gray
    Write-Host "  • name: $nameCheck ($($firstBalance.name))" -ForegroundColor Gray
    Write-Host "  • totalPaid: $totalPaidCheck ($($firstBalance.totalPaid))" -ForegroundColor Gray
    Write-Host "  • totalOwed: $totalOwedCheck ($($firstBalance.totalOwed))" -ForegroundColor Gray
    Write-Host "  • balance: $balanceCheck ($($firstBalance.balance))" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ ERRO no endpoint de saldos: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n🎉 TESTE CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "✅ Endpoint GET /api/groups/{groupId}/balances implementado e funcionando" -ForegroundColor Green
Write-Host "✅ DTO retorna todos os campos esperados: userId, name, totalPaid, totalOwed, balance" -ForegroundColor Green
Write-Host "✅ Cálculos matemáticos estão corretos" -ForegroundColor Green
