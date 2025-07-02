# Script para testar o cálculo de saldos de um grupo
# PowerShell script com encoding UTF-8

param(
    [string]$BaseUrl = "http://localhost:8090",
    [string]$GroupId = "1"
)

# Configurar encoding UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🧮 Testando Cálculo de Saldos do Grupo $GroupId" -ForegroundColor Cyan
Write-Host "=" * 50

# 1. Login para obter token
Write-Host "📝 1. Fazendo login..." -ForegroundColor Yellow
$loginBody = @{
    email = "joao@teste.com"
    password = "password123"
} | ConvertTo-Json -Depth 10

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json; charset=utf-8"
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Headers com token
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json; charset=utf-8"
}

# 2. Verificar despesas do grupo
Write-Host "`n💰 2. Listando despesas do grupo $GroupId..." -ForegroundColor Yellow
try {
    $expensesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$GroupId" -Method GET -Headers $headers
    Write-Host "✅ Despesas encontradas: $($expensesResponse.Count)" -ForegroundColor Green
    
    if ($expensesResponse.Count -gt 0) {
        Write-Host "📋 Despesas no grupo:" -ForegroundColor Blue
        foreach ($expense in $expensesResponse) {
            $paidBy = $expense.paidByUser.name
            $amount = $expense.amount
            $participants = ($expense.participants | ForEach-Object { $_.user.name }) -join ", "
            Write-Host "  • $($expense.description): R$ $amount (Pago por: $paidBy, Participantes: $participants)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ Erro ao buscar despesas: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Calcular saldos do grupo
Write-Host "`n🧮 3. Calculando saldos do grupo $GroupId..." -ForegroundColor Yellow
try {
    $balancesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$GroupId/balances" -Method GET -Headers $headers
    Write-Host "✅ Saldos calculados com sucesso!" -ForegroundColor Green
    
    Write-Host "`n📊 Saldos dos membros:" -ForegroundColor Blue
    Write-Host ("-" * 80) -ForegroundColor Gray
    Write-Host ('{0,-20} {1,-15} {2,-15} {3,-15}' -f "Nome", "Total Pago", "Total Devido", "Saldo") -ForegroundColor Cyan
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    $totalBalance = 0
    foreach ($balance in $balancesResponse) {
        $name = $balance.name
        $totalPaid = [decimal]$balance.totalPaid
        $totalOwed = [decimal]$balance.totalOwed
        $finalBalance = [decimal]$balance.balance
        $totalBalance += $finalBalance
        
        $balanceColor = if ($finalBalance -gt 0) { "Green" } elseif ($finalBalance -lt 0) { "Red" } else { "Gray" }
        $paidFormatted = "R$ {0:F2}" -f $totalPaid
        $owedFormatted = "R$ {0:F2}" -f $totalOwed
        $balanceFormatted = "R$ {0:F2}" -f $finalBalance
        
        Write-Host ('{0,-20} {1,-15} {2,-15} {3,-15}' -f $name, $paidFormatted, $owedFormatted, $balanceFormatted) -ForegroundColor $balanceColor
    }
    
    Write-Host ("-" * 80) -ForegroundColor Gray
    Write-Host ("Total de saldos (deve ser ~0): R$ {0:F2}" -f $totalBalance) -ForegroundColor Magenta
    
    if ([Math]::Abs($totalBalance) -lt 0.01) {
        Write-Host "✅ Verificação de integridade: OK (saldos balanceados)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Verificação de integridade: ATENÇÃO (saldos não balanceados)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erro ao calcular saldos: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# 4. Verificar membros do grupo
Write-Host "`n👥 4. Listando membros do grupo $GroupId..." -ForegroundColor Yellow
try {
    $membersResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$GroupId/members" -Method GET -Headers $headers
    Write-Host "✅ Membros encontrados: $($membersResponse.Count)" -ForegroundColor Green
    
    Write-Host "📋 Membros do grupo:" -ForegroundColor Blue
    foreach ($member in $membersResponse) {
        Write-Host "  • $($member.name) ($($member.email))" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erro ao buscar membros: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Teste de cálculo de saldos concluído!" -ForegroundColor Cyan
