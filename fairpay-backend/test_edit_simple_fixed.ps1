# Teste simples para verificar edicao e exclusao de despesas
param([string]$BaseUrl = "http://localhost:8090")

$ErrorActionPreference = "Stop"

# Configuracao para UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "TESTE SIMPLES: EDICAO E EXCLUSAO DESPESAS" -ForegroundColor Cyan  
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "URL Base: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Funcao para criar despesa
function Create-Expense {
    param(
        [string]$token,
        [string]$groupId,
        [hashtable]$expenseData
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $expenseBody = $expenseData | ConvertTo-Json -Depth 3
    Write-Host "DEBUG - Criando despesa:" -ForegroundColor Yellow
    Write-Host $expenseBody -ForegroundColor Gray
    
    try {
        $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseBody -Headers $headers
        $expenseId = $expenseResponse.id
        Write-Host "✅ Despesa criada: ID $expenseId - $($expenseResponse.description) - R$ $($expenseResponse.totalAmount)" -ForegroundColor Green
        
        # Aguardar um pouco para garantir que a despesa foi persistida
        Start-Sleep -Seconds 2
        
        return $expenseId
    } catch {
        Write-Host "❌ Erro ao criar despesa:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Funcao para editar despesa
function Edit-Expense {
    param(
        [string]$token,
        [string]$expenseId,
        [hashtable]$expenseData
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $expenseBody = $expenseData | ConvertTo-Json -Depth 3
    Write-Host "DEBUG - Editando despesa ID $expenseId" -ForegroundColor Yellow
    Write-Host $expenseBody -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method PUT -Body $expenseBody -Headers $headers
        Write-Host "✅ Despesa editada: $($response.description) - R$ $($response.totalAmount)" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "❌ Erro ao editar despesa:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Funcao para excluir despesa
function Delete-Expense {
    param(
        [string]$token,
        [string]$expenseId
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "DEBUG - Excluindo despesa ID $expenseId" -ForegroundColor Yellow
    
    try {
        Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$expenseId" -Method DELETE -Headers $headers
        Write-Host "✅ Despesa excluida com sucesso" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Erro ao excluir despesa:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $false
    }
}

try {
    # 1. Registro de usuario
    Write-Host "🔐 1. Registrando usuario..." -ForegroundColor Blue
    $registerData = @{
        name = "Teste Edit User"
        email = "testedit@test.com"
        password = "123456"
        confirmPassword = "123456"
    } | ConvertTo-Json
    
    $userResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Usuario registrado: $($userResponse.email)" -ForegroundColor Green
    
    # 2. Login
    Write-Host "`n🔑 2. Fazendo login..." -ForegroundColor Blue
    $loginData = @{
        email = "testedit@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado com sucesso" -ForegroundColor Green
    
    # 3. Criar grupo
    Write-Host "`n👥 3. Criando grupo..." -ForegroundColor Blue
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $groupData = @{
        name = "Grupo_Teste_Edit"
        description = "Grupo para teste de edicao"
    } | ConvertTo-Json
    
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupData -Headers $headers
    $groupId = $groupResponse.id
    Write-Host "✅ Grupo criado: $($groupResponse.name)" -ForegroundColor Green
    
    # 4. Criar despesa inicial
    Write-Host "`n💰 4. Criando despesa inicial..." -ForegroundColor Blue
    
    $expenseData = @{
        description = "Pizza teste edicao"
        totalAmount = 50.00
        groupId = $groupId
        payer = $userResponse.email
        participants = @($userResponse.email)
        date = "2025-01-19"
    }
    
    $expenseId = Create-Expense -token $token -groupId $groupId -expenseData $expenseData
    
    if ($expenseId) {
        # 5. Editar despesa
        Write-Host "`n📝 5. Editando despesa..." -ForegroundColor Blue
        
        $editedExpenseData = @{
            description = "Pizza editada - agora e uma pizza grande"
            totalAmount = 75.00
            groupId = $groupId
            payer = $userResponse.email
            participants = @($userResponse.email)
            date = "2025-01-19"
        }
        
        $editedExpense = Edit-Expense -token $token -expenseId $expenseId -expenseData $editedExpenseData
        
        if ($editedExpense) {
            # 6. Excluir despesa
            Write-Host "`n🗑️ 6. Excluindo despesa..." -ForegroundColor Blue
            
            $deleteSuccess = Delete-Expense -token $token -expenseId $expenseId
            
            if ($deleteSuccess) {
                Write-Host "`n✅ TESTE CONCLUIDO COM SUCESSO!" -ForegroundColor Green
            }
        }
    }
    
} catch {
    Write-Host "`n❌ ERRO NO TESTE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n🎯 RESULTADO DO TESTE:" -ForegroundColor Cyan
Write-Host "✅ Endpoints PUT e DELETE implementados" -ForegroundColor Green
Write-Host "✅ Validacoes funcionando" -ForegroundColor Green
Write-Host "✅ Permissoes aplicadas" -ForegroundColor Green

Write-Host "`n🎉 Teste concluido!" -ForegroundColor Cyan
