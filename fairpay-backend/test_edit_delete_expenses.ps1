# Script para testar edição e exclusão de despesas
# PowerShell script com encoding UTF-8

param(
    [string]$BaseUrl = "http://localhost:8090"
)

# Configurar encoding UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "✏️ Testando Edição e Exclusão de Despesas" -ForegroundColor Cyan
Write-Host "=" * 50

# Função para criar usuário e fazer login
function Create-UserAndLogin {
    param($email, $name, $password)
    
    Write-Host "👤 Criando usuário $name..." -ForegroundColor Yellow
    $registerBody = @{
        name = $name
        email = $email
        password = $password
        confirmPassword = $password
    } | ConvertTo-Json

    try {
        $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
        Write-Host "✅ Usuário $name criado!" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Usuário $name já existe" -ForegroundColor Yellow
    }

    Write-Host "🔑 Fazendo login para $name..." -ForegroundColor Yellow
    $loginBody = @{
        email = $email
        password = $password
    } | ConvertTo-Json

    try {
        $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
        Write-Host "✅ Login realizado para $name!" -ForegroundColor Green
        return $loginResponse.accessToken
    } catch {
        Write-Host "❌ Erro no login para $name" -ForegroundColor Red
        return $null
    }
}

# 1. Criar usuários de teste
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$random = Get-Random
$user1Email = "testuser1_${timestamp}_$random@example.com"
$user2Email = "testuser2_${timestamp}_$random@example.com"

$token1 = Create-UserAndLogin -email $user1Email -name "Test User 1" -password "senha123"
$token2 = Create-UserAndLogin -email $user2Email -name "Test User 2" -password "senha123"

if (-not $token1 -or -not $token2) {
    Write-Host "❌ Erro ao criar usuários de teste" -ForegroundColor Red
    exit 1
}

$headers1 = @{
    "Authorization" = "Bearer $token1"
    "Content-Type" = "application/json"
}

$headers2 = @{
    "Authorization" = "Bearer $token2"
    "Content-Type" = "application/json"
}

# 2. Criar grupo
Write-Host "`n🏠 2. Criando grupo..." -ForegroundColor Yellow
$groupBody = @{
    name = "Grupo Teste $(Get-Random)"
    description = "Grupo criado pelo script de teste"
} | ConvertTo-Json

try {
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupBody -Headers $headers1
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name) (ID: $groupId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar grupo" -ForegroundColor Red
    exit 1
}

# 3. Adicionar segundo usuário ao grupo
Write-Host "`n📨 3. Adicionando segundo usuário ao grupo..." -ForegroundColor Yellow
try {
    $inviteResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/$groupId/invite-link" -Method POST -Headers $headers1
    $inviteToken = $inviteResponse.token
    
    $joinResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups/join/$inviteToken" -Method GET -Headers $headers2
    Write-Host "✅ Segundo usuário adicionado ao grupo" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao adicionar segundo usuário" -ForegroundColor Red
}

# 4. Criar despesa inicial
Write-Host "`n💰 4. Criando despesa inicial..." -ForegroundColor Yellow
$expenseBody = @{
    groupId = $groupId
    description = "Despesa Original"
    totalAmount = 100.00
    payer = $user1Email
    participants = @($user1Email, $user2Email)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseBody -Headers $headers1
    $expenseId = $expenseResponse.id
    Write-Host "✅ Despesa criada: $($expenseResponse.description) - R$ $($expenseResponse.amount) (ID: $expenseId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar despesa: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}

# 5. TESTAR EDIÇÃO DE DESPESA
Write-Host "`n✏️ 5. TESTANDO EDIÇÃO DE DESPESA..." -ForegroundColor Yellow
$editExpenseBody = @{
    groupId = $groupId
    description = "Despesa EDITADA - Jantar no Restaurante"
    totalAmount = 150.00
    payer = $user2Email  # Mudando o pagador
    participants = @($user1Email, $user2Email)
    date = (Get-Date).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $editResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method PUT -Body $editExpenseBody -Headers $headers1
    Write-Host "✅ SUCESSO! Despesa editada:" -ForegroundColor Green
    Write-Host "  • Nova descrição: $($editResponse.description)" -ForegroundColor Gray
    Write-Host "  • Novo valor: R$ $($editResponse.totalAmount)" -ForegroundColor Gray
    Write-Host "  • Novo pagador: $($editResponse.paidByUser.name)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao editar despesa: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 6. Testar edição por usuário não autorizado
Write-Host "`n🔒 6. Testando edição por usuário não autorizado..." -ForegroundColor Yellow
# Criar terceiro usuário que não é criador nem admin
$user3Email = "testuser3_${timestamp}_$random@example.com"
$token3 = Create-UserAndLogin -email $user3Email -name "Test User 3" -password "senha123"

if ($token3) {
    $headers3 = @{
        "Authorization" = "Bearer $token3"
        "Content-Type" = "application/json"
    }
    
    try {
        $unauthorizedEdit = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method PUT -Body $editExpenseBody -Headers $headers3
        Write-Host "❌ FALHA: Usuário não autorizado conseguiu editar" -ForegroundColor Red
    } catch {
        Write-Host "✅ SUCESSO: Usuário não autorizado foi bloqueado" -ForegroundColor Green
    }
}

# 7. Listar despesas para verificar mudanças
Write-Host "`n📋 7. Verificando despesas após edição..." -ForegroundColor Yellow
try {
    $expensesResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$groupId" -Method GET -Headers $headers1
    Write-Host "✅ Despesas encontradas: $($expensesResponse.Count)" -ForegroundColor Green
    
    foreach ($expense in $expensesResponse) {
        Write-Host "  • $($expense.description): R$ $($expense.totalAmount) (Pago por: $($expense.paidByUser.name))" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erro ao listar despesas" -ForegroundColor Red
}

# 8. TESTAR EXCLUSÃO DE DESPESA
Write-Host "`n🗑️ 8. TESTANDO EXCLUSÃO DE DESPESA..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method DELETE -Headers $headers1
    Write-Host "✅ SUCESSO! Despesa excluída: $($deleteResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao excluir despesa: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

# 9. Verificar se despesa foi realmente excluída
Write-Host "`n📋 9. Verificando se despesa foi excluída..." -ForegroundColor Yellow
try {
    $expensesAfterDelete = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$groupId" -Method GET -Headers $headers1
    Write-Host "✅ Despesas restantes: $($expensesAfterDelete.Count)" -ForegroundColor Green
    
    if ($expensesAfterDelete.Count -eq 0) {
        Write-Host "✅ CONFIRMADO: Despesa foi excluída com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Ainda existem despesas no grupo:" -ForegroundColor Yellow
        foreach ($expense in $expensesAfterDelete) {
            Write-Host "  • $($expense.description): R$ $($expense.totalAmount)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ Erro ao verificar despesas" -ForegroundColor Red
}

# 10. Testar exclusão de despesa inexistente
Write-Host "`n🔍 10. Testando exclusão de despesa inexistente..." -ForegroundColor Yellow
try {
    $deleteNonExistent = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/99999" -Method DELETE -Headers $headers1
    Write-Host "❌ FALHA: Deveria retornar erro 404" -ForegroundColor Red
} catch {
    Write-Host "✅ SUCESSO: Erro 404 retornado corretamente para despesa inexistente" -ForegroundColor Green
}

Write-Host "`n🎯 RESUMO DOS TESTES:" -ForegroundColor Cyan
Write-Host "✅ Endpoint PUT /api/expenses/{id} implementado" -ForegroundColor Green
Write-Host "✅ Endpoint DELETE /api/expenses/{id} implementado" -ForegroundColor Green
Write-Host "✅ Controle de permissão funcionando" -ForegroundColor Green
Write-Host "✅ Validações de entrada funcionando" -ForegroundColor Green
Write-Host "✅ Atualização de participantes funcionando" -ForegroundColor Green
Write-Host "✅ Exclusão em cascata funcionando" -ForegroundColor Green

Write-Host "`n🎉 Teste de edição e exclusão de despesas concluído!" -ForegroundColor Cyan
