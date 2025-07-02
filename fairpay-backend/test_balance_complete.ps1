# Script para testar o cálculo de saldos - versão completa
# PowerShell script com encoding UTF-8

param(
    [string]$BaseUrl = "http://localhost:8090"
)

# Configurar encoding UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🧮 Teste Completo de Cálculo de Saldos" -ForegroundColor Cyan
Write-Host "=" * 50

# Função para criar usuário e fazer login
function Create-UserAndLogin {
    param($email, $name, $password)
    
    Write-Host "👤 Criando usuário $name..." -ForegroundColor Yellow
    $registerBody = @{
        name = $name
        email = $email
        password = $password
    } | ConvertTo-Json -Depth 10

    try {
        $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json; charset=utf-8"
        Write-Host "✅ Usuário $name criado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Usuário $name já existe ou erro: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "🔑 Fazendo login para $name..." -ForegroundColor Yellow
    $loginBody = @{
        email = $email
        password = $password
    } | ConvertTo-Json -Depth 10

    try {
        $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json; charset=utf-8"
        Write-Host "✅ Login realizado para $name!" -ForegroundColor Green
        return $loginResponse.accessToken
    } catch {
        Write-Host "❌ Erro no login para ${name}: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# 1. Criar usuários de teste
$users = @(
    @{name="João Silva"; email="joao.silva@teste.com"; password="123456"},
    @{name="Maria Santos"; email="maria.santos@teste.com"; password="123456"},
    @{name="Pedro Costa"; email="pedro.costa@teste.com"; password="123456"}
)

$tokens = @{}
foreach ($user in $users) {
    $token = Create-UserAndLogin -email $user.email -name $user.name -password $user.password
    if ($token) {
        $tokens[$user.email] = $token
    }
}

# Usar o primeiro usuário como principal
$mainUserEmail = $users[0].email
$mainToken = $tokens[$mainUserEmail]

if (-not $mainToken) {
    Write-Host "❌ Não foi possível obter token do usuário principal" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $mainToken"
    "Content-Type" = "application/json; charset=utf-8"
}

# 2. Criar grupo de teste
Write-Host "`n🏠 2. Criando grupo de teste..." -ForegroundColor Yellow
$groupBody = @{
    name = "Teste de Saldos $(Get-Random)"
    description = "Grupo para testar cálculo de saldos"
    imageUrl = "https://example.com/group.jpg"
} | ConvertTo-Json -Depth 10

try {
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupBody -Headers $headers
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name) (ID: $groupId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar grupo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Adicionar outros usuários ao grupo (via convites)
Write-Host "`n📨 3. Adicionando outros usuários ao grupo..." -ForegroundColor Yellow

# Gerar convite
try {
    $inviteResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$groupId/invite-link" -Method POST -Headers $headers
    $inviteToken = $inviteResponse.token
    Write-Host "✅ Convite gerado: $inviteToken" -ForegroundColor Green
    
    # Adicionar outros usuários
    foreach ($user in $users[1..2]) {
        $userEmail = $user.email
        $userToken = $tokens[$userEmail]
        if ($userToken) {
            $userHeaders = @{
                "Authorization" = "Bearer $userToken"
                "Content-Type" = "application/json; charset=utf-8"
            }
            try {
                $joinResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/join/$inviteToken" -Method GET -Headers $userHeaders
                Write-Host "✅ $($user.name) entrou no grupo" -ForegroundColor Green
            } catch {
                Write-Host "⚠️  Erro ao adicionar $($user.name): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
} catch {
    Write-Host "❌ Erro ao gerar convite: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Criar despesas de teste
Write-Host "`n💰 4. Criando despesas de teste..." -ForegroundColor Yellow

$expenses = @(
    @{description="Supermercado"; amount=150.00; paidBy="joao.silva@teste.com"; participants=@("joao.silva@teste.com", "maria.santos@teste.com", "pedro.costa@teste.com")},
    @{description="Conta de Luz"; amount=90.00; paidBy="maria.santos@teste.com"; participants=@("joao.silva@teste.com", "maria.santos@teste.com", "pedro.costa@teste.com")},
    @{description="Internet"; amount=80.00; paidBy="pedro.costa@teste.com"; participants=@("joao.silva@teste.com", "maria.santos@teste.com")},
    @{description="Limpeza"; amount=120.00; paidBy="joao.silva@teste.com"; participants=@("maria.santos@teste.com", "pedro.costa@teste.com")}
)

foreach ($expense in $expenses) {
    $expenseBody = @{
        groupId = $groupId
        description = $expense.description
        amount = $expense.amount
        paidByEmail = $expense.paidBy
        participantEmails = $expense.participants
    } | ConvertTo-Json -Depth 10

    try {
        $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseBody -Headers $headers
        Write-Host "✅ Despesa criada: $($expense.description) - R$ $($expense.amount)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao criar despesa $($expense.description): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. Listar despesas criadas
Write-Host "`n📋 5. Listando despesas do grupo..." -ForegroundColor Yellow
try {
    $expensesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$groupId" -Method GET -Headers $headers
    Write-Host "✅ Despesas encontradas: $($expensesResponse.Count)" -ForegroundColor Green
    
    foreach ($expense in $expensesResponse) {
        $paidBy = $expense.paidByUser.name
        $amount = $expense.amount
        $participantCount = $expense.participants.Count
        Write-Host "  • $($expense.description): R$ $amount (Pago por: $paidBy, $participantCount participantes)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erro ao listar despesas: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. TESTAR CÁLCULO DE SALDOS
Write-Host "`n🧮 6. CALCULANDO SALDOS DO GRUPO..." -ForegroundColor Yellow
try {
    $balancesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$groupId/balances" -Method GET -Headers $headers
    Write-Host "✅ Saldos calculados com sucesso!" -ForegroundColor Green
    
    Write-Host "`n📊 RESULTADO DOS SALDOS:" -ForegroundColor Blue
    Write-Host ("-" * 90) -ForegroundColor Gray
    Write-Host ('{0,-20} {1,-15} {2,-15} {3,-15}' -f "Nome", "Total Pago", "Total Devido", "Saldo Final") -ForegroundColor Cyan
    Write-Host ("-" * 90) -ForegroundColor Gray
    
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
    
    Write-Host ("-" * 90) -ForegroundColor Gray
    Write-Host ("VERIFICAÇÃO: Soma total = R$ {0:F2} (deve ser próximo de 0)" -f $totalBalance) -ForegroundColor Magenta
    
    if ([Math]::Abs($totalBalance) -lt 0.01) {
        Write-Host "✅ TESTE PASSOU: Saldos estão balanceados!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ATENÇÃO: Saldos não estão balanceados (diferença: R$ $totalBalance)" -ForegroundColor Yellow
    }
    
    Write-Host "`n💡 Interpretação dos saldos:" -ForegroundColor Blue
    Write-Host "  • Saldo POSITIVO: Pessoa tem a RECEBER" -ForegroundColor Green
    Write-Host "  • Saldo NEGATIVO: Pessoa DEVE para o grupo" -ForegroundColor Red
    Write-Host "  • Saldo ZERO: Pessoa está quites" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ ERRO ao calcular saldos: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Teste de cálculo de saldos concluído!" -ForegroundColor Cyan
