# Teste simples para verificar o campo createdBy
param([string]$BaseUrl = "http://localhost:8090")

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== TESTE DEBUG - CAMPO CREATED_BY ===" -ForegroundColor Cyan

try {
    # 1. Registro
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $registerData = @{
        name = "Debug User $timestamp"
        email = "debug$timestamp@test.com"
        password = "123456"
        confirmPassword = "123456"
    } | ConvertTo-Json
    
    $userResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Usuario registrado: $($userResponse.user.email)" -ForegroundColor Green
    
    # 2. Login
    $loginData = @{
        email = "debug$timestamp@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.accessToken
    
    $authHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # 3. Criar grupo
    $groupData = @{
        name = "Grupo_Debug_$timestamp"
        description = "Grupo para debug"
    } | ConvertTo-Json
    
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupData -Headers $authHeaders
    Write-Host "✅ Grupo criado: ID $($groupResponse.id)" -ForegroundColor Green
    
    # 4. Criar despesa
    $expenseData = @{
        description = "Despesa debug"
        totalAmount = 100.00
        groupId = $groupResponse.id
        payer = $userResponse.user.email
        participants = @($userResponse.user.email)
        date = "2025-01-19"
    } | ConvertTo-Json
    
    Write-Host "`n📋 Criando despesa..." -ForegroundColor Blue
    $expenseResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses" -Method POST -Body $expenseData -Headers $authHeaders
    Write-Host "✅ Despesa criada: ID $($expenseResponse.id)" -ForegroundColor Green
    Write-Host "CreatedBy ID no response: Se existe ou nao?" -ForegroundColor Yellow
    
    # 5. Buscar todas as despesas do grupo para ver o created_by
    Write-Host "`n📋 Buscando despesas do grupo..." -ForegroundColor Blue
    $groupExpenses = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/$($groupResponse.id)" -Method GET -Headers $authHeaders
    Write-Host "✅ Despesas encontradas: $($groupExpenses.Count)" -ForegroundColor Green
    
    foreach ($exp in $groupExpenses) {
        if ($exp.id -eq $expenseResponse.id) {
            Write-Host "📊 Despesa criada encontrada:" -ForegroundColor Yellow
            Write-Host "ID: $($exp.id)" -ForegroundColor Gray
            Write-Host "Description: $($exp.description)" -ForegroundColor Gray
            Write-Host "PaidBy ID: $($exp.paidBy.id)" -ForegroundColor Gray
            Write-Host "PaidBy Email: $($exp.paidBy.email)" -ForegroundColor Gray
            
            # Verificar se há campo createdBy
            if ($exp.PSObject.Properties.Name -contains "createdBy") {
                Write-Host "CreatedBy ID: $($exp.createdBy.id)" -ForegroundColor Gray
                Write-Host "CreatedBy Email: $($exp.createdBy.email)" -ForegroundColor Gray
            } else {
                Write-Host "❌ Campo createdBy NAO encontrado no response!" -ForegroundColor Red
            }
            break
        }
    }
    
    # 6. Tentar editar (aqui deve dar erro)
    Write-Host "`n📝 Tentando editar despesa..." -ForegroundColor Blue
    $editData = @{
        description = "Despesa editada"
        totalAmount = 150.00
        groupId = $groupResponse.id
        payer = $userResponse.user.email
        participants = @($userResponse.user.email)
        date = "2025-01-19"
    } | ConvertTo-Json
    
    try {
        $editResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$($expenseResponse.id)" -Method PUT -Body $editData -Headers $authHeaders
        Write-Host "✅ Despesa editada com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao editar:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "`n❌ ERRO GERAL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
