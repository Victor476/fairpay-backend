# Exemplos de Requisições da API FairPay
# Use este arquivo como referência para requisições individuais

$baseUrl = "http://localhost:8090"
$headers = @{"Content-Type" = "application/json"}

Write-Host "📚 Exemplos de Requisições da API FairPay" -ForegroundColor Magenta
Write-Host "Execute cada bloco individualmente conforme necessário" -ForegroundColor Yellow

# =======================
# AUTENTICAÇÃO
# =======================

# Registrar novo usuário
<#
$userData = @{
    name = "João Silva"
    email = "joao@example.com"
    password = "senha123"
    confirmPassword = "senha123"
} | ConvertTo-Json

$registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $userData
Write-Host "Usuário criado:" -ForegroundColor Green
$registerResponse | ConvertTo-Json -Depth 3
#>

# Fazer login
<#
$loginData = @{
    email = "joao@example.com"
    password = "senha123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
$token = $loginResponse.token
$authHeaders = $headers.Clone()
$authHeaders["Authorization"] = "Bearer $token"
Write-Host "Login realizado. Token:" -ForegroundColor Green
Write-Host $token
#>

# Logout
<#
Invoke-RestMethod -Uri "$baseUrl/api/auth/logout" -Method POST -Headers $authHeaders
Write-Host "Logout realizado com sucesso" -ForegroundColor Green
#>

# =======================
# GRUPOS
# =======================

# Criar grupo
<#
$groupData = @{
    name = "Viagem para Gramado"
    description = "Despesas da viagem de fim de semana"
} | ConvertTo-Json

$groupResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method POST -Headers $authHeaders -Body $groupData
Write-Host "Grupo criado:" -ForegroundColor Green
$groupResponse | ConvertTo-Json -Depth 3
$groupId = $groupResponse.id
#>

# Listar grupos do usuário
<#
$groupsResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
Write-Host "Grupos do usuário:" -ForegroundColor Green
$groupsResponse | ConvertTo-Json -Depth 3
#>

# Ver detalhes de um grupo específico
<#
$groupId = "SEU_GROUP_ID_AQUI"
$groupDetailsResponse = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method GET -Headers $authHeaders
Write-Host "Detalhes do grupo:" -ForegroundColor Green
$groupDetailsResponse | ConvertTo-Json -Depth 3
#>

# Atualizar grupo
<#
$groupId = "SEU_GROUP_ID_AQUI"
$updateGroupData = @{
    name = "Viagem para Gramado - Atualizado"
    description = "Despesas da viagem de fim de semana (editado)"
} | ConvertTo-Json

$updateGroupResponse = Invoke-RestMethod -Uri "$baseUrl/groups/$groupId" -Method PUT -Headers $authHeaders -Body $updateGroupData
Write-Host "Grupo atualizado:" -ForegroundColor Green
$updateGroupResponse | ConvertTo-Json -Depth 3
#>

# Deletar grupo
<#
$groupId = "SEU_GROUP_ID_AQUI"
Invoke-RestMethod -Uri "$baseUrl/groups/$groupId" -Method DELETE -Headers $authHeaders
Write-Host "Grupo deletado com sucesso" -ForegroundColor Green
#>

# =======================
# CONVITES
# =======================

# Gerar link de convite
<#
$groupId = "SEU_GROUP_ID_AQUI"
$inviteResponse = Invoke-RestMethod -Uri "$baseUrl/groups/$groupId/invite-link" -Method POST -Headers $authHeaders
Write-Host "Link de convite gerado:" -ForegroundColor Green
$inviteResponse | ConvertTo-Json -Depth 3
$inviteCode = $inviteResponse.inviteCode
#>

# Entrar em grupo via convite
<#
$inviteCode = "SEU_INVITE_CODE_AQUI"
$joinResponse = Invoke-RestMethod -Uri "$baseUrl/groups/join/$inviteCode" -Method POST -Headers $authHeaders
Write-Host "Entrou no grupo:" -ForegroundColor Green
$joinResponse | ConvertTo-Json -Depth 3
#>

# =======================
# DESPESAS
# =======================

# Criar despesa
<#
$expenseData = @{
    description = "Hotel - Pousada do Vale"
    amount = 350.00
    groupId = "SEU_GROUP_ID_AQUI"
    paidByUserId = "SEU_USER_ID_AQUI"
    participantIds = @("USER_ID_1", "USER_ID_2")
    expenseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

$expenseResponse = Invoke-RestMethod -Uri "$baseUrl/expenses" -Method POST -Headers $authHeaders -Body $expenseData
Write-Host "Despesa criada:" -ForegroundColor Green
$expenseResponse | ConvertTo-Json -Depth 3
$expenseId = $expenseResponse.id
#>

# Listar despesas de um grupo
<#
$groupId = "SEU_GROUP_ID_AQUI"
$expensesResponse = Invoke-RestMethod -Uri "$baseUrl/expenses/group/$groupId" -Method GET -Headers $authHeaders
Write-Host "Despesas do grupo:" -ForegroundColor Green
$expensesResponse | ConvertTo-Json -Depth 3
#>

# Ver detalhes de uma despesa específica
<#
$expenseId = "SEU_EXPENSE_ID_AQUI"
$expenseDetailsResponse = Invoke-RestMethod -Uri "$baseUrl/expenses/$expenseId" -Method GET -Headers $authHeaders
Write-Host "Detalhes da despesa:" -ForegroundColor Green
$expenseDetailsResponse | ConvertTo-Json -Depth 3
#>

# Atualizar despesa
<#
$expenseId = "SEU_EXPENSE_ID_AQUI"
$updateExpenseData = @{
    description = "Hotel - Pousada do Vale (atualizado)"
    amount = 375.00
    groupId = "SEU_GROUP_ID_AQUI"
    paidByUserId = "SEU_USER_ID_AQUI"
    participantIds = @("USER_ID_1", "USER_ID_2")
    expenseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

$updateExpenseResponse = Invoke-RestMethod -Uri "$baseUrl/expenses/$expenseId" -Method PUT -Headers $authHeaders -Body $updateExpenseData
Write-Host "Despesa atualizada:" -ForegroundColor Green
$updateExpenseResponse | ConvertTo-Json -Depth 3
#>

# Deletar despesa
<#
$expenseId = "SEU_EXPENSE_ID_AQUI"
Invoke-RestMethod -Uri "$baseUrl/expenses/$expenseId" -Method DELETE -Headers $authHeaders
Write-Host "Despesa deletada com sucesso" -ForegroundColor Green
#>

# =======================
# PAGAMENTOS
# =======================

# Marcar pagamento como realizado
<#
$paymentData = @{
    expenseId = "SEU_EXPENSE_ID_AQUI"
    payerUserId = "SEU_USER_ID_AQUI"
    receiverUserId = "SEU_USER_ID_AQUI"
    amount = 175.00
} | ConvertTo-Json

$paymentResponse = Invoke-RestMethod -Uri "$baseUrl/payments" -Method POST -Headers $authHeaders -Body $paymentData
Write-Host "Pagamento registrado:" -ForegroundColor Green
$paymentResponse | ConvertTo-Json -Depth 3
#>

# =======================
# UTILITÁRIOS
# =======================

# Função para teste rápido de conectividade
function Test-ApiConnection {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method GET -TimeoutSec 5
        Write-Host "✅ API está online!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ API não está respondendo em $baseUrl" -ForegroundColor Red
        return $false
    }
}

# Função para obter token rapidamente (usando usuário de teste)
function Get-TestToken {
    param(
        [string]$email = "admin@fairpay.com",
        [string]$password = "admin123"
    )
    
    try {
        $loginData = @{
            email = $email
            password = $password
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
        $token = $loginResponse.token
        
        $authHeaders = $headers.Clone()
        $authHeaders["Authorization"] = "Bearer $token"
        
        Write-Host "🔑 Token obtido com sucesso!" -ForegroundColor Green
        return @{
            token = $token
            headers = $authHeaders
            user = $loginResponse.user
        }
    } catch {
        Write-Host "❌ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# =======================
# EXEMPLOS DE USO
# =======================

Write-Host "`n💡 Exemplos de como usar este arquivo:" -ForegroundColor Cyan
Write-Host "1. Descomente o bloco que deseja testar" -ForegroundColor White
Write-Host "2. Substitua os placeholders (SEU_*_ID_AQUI) pelos valores reais" -ForegroundColor White
Write-Host "3. Execute o script ou selecione e execute apenas o bloco desejado" -ForegroundColor White
Write-Host "`n🚀 Para testes automatizados, use:" -ForegroundColor Cyan
Write-Host "   .\test_api_quick.ps1      (teste rápido)" -ForegroundColor White
Write-Host "   .\test_api_complete_flow.ps1 (teste completo)" -ForegroundColor White

# Teste de conectividade (sempre executado)
Write-Host "`n🔗 Testando conectividade com a API..." -ForegroundColor Yellow
Test-ApiConnection
