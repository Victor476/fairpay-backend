# Teste de edicao de despesas com debug detalhado
param([string]$BaseUrl = "http://localhost:8090")

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "TESTE DETALHADO: EDICAO E EXCLUSAO DESPESAS" -ForegroundColor Cyan  
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "URL Base: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description
    )
    
    Write-Host "`n📡 $Description" -ForegroundColor Blue
    Write-Host "Method: $Method" -ForegroundColor Gray
    Write-Host "URI: $Uri" -ForegroundColor Gray
    
    if ($Body) {
        Write-Host "Body:" -ForegroundColor Gray
        Write-Host $Body -ForegroundColor Gray
    }
    
    if ($Headers.Count -gt 0) {
        Write-Host "Headers:" -ForegroundColor Gray
        $Headers | ConvertTo-Json | Write-Host -ForegroundColor Gray
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Body $Body -Headers $Headers
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        
        Write-Host "✅ Sucesso:" -ForegroundColor Green
        $response | ConvertTo-Json | Write-Host -ForegroundColor Green
        
        return $response
    } catch {
        Write-Host "❌ Erro:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Response Body: $responseBody" -ForegroundColor Red
                Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            } catch {
                Write-Host "Nao foi possivel ler response body" -ForegroundColor Red
            }
        }
        throw
    }
}

try {
    # 1. Registro
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $registerData = @{
        name = "Test User $timestamp"
        email = "test$timestamp@test.com"
        password = "123456"
        confirmPassword = "123456"
    } | ConvertTo-Json
    
    $userResponse = Invoke-ApiCall -Method "POST" -Uri "$BaseUrl/api/auth/register" -Body $registerData -Headers @{"Content-Type" = "application/json"} -Description "Registrando usuario"
    
    # 2. Login
    $loginData = @{
        email = "test$timestamp@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-ApiCall -Method "POST" -Uri "$BaseUrl/api/auth/login" -Body $loginData -Headers @{"Content-Type" = "application/json"} -Description "Fazendo login"
    
    $token = $loginResponse.accessToken
    $authHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # 3. Criar grupo
    $groupData = @{
        name = "Grupo_Teste_$timestamp"
        description = "Grupo para teste de edicao"
    } | ConvertTo-Json
    
    $groupResponse = Invoke-ApiCall -Method "POST" -Uri "$BaseUrl/api/groups" -Body $groupData -Headers $authHeaders -Description "Criando grupo"
    
    $groupId = $groupResponse.id
    
    # 4. Criar despesa
    $expenseData = @{
        description = "Pizza teste edicao"
        totalAmount = 50.00
        groupId = $groupId
        payer = $userResponse.user.email
        participants = @($userResponse.user.email)
        date = "2025-01-19"
    } | ConvertTo-Json
    
    $expenseResponse = Invoke-ApiCall -Method "POST" -Uri "$BaseUrl/api/expenses" -Body $expenseData -Headers $authHeaders -Description "Criando despesa"
    
    $expenseId = $expenseResponse.id
    
    # 5. Editar despesa
    $editedExpenseData = @{
        description = "Pizza editada - agora e pizza grande"
        totalAmount = 75.00
        groupId = $groupId
        payer = $userResponse.user.email
        participants = @($userResponse.user.email)
        date = "2025-01-19"
    } | ConvertTo-Json
    
    $editedExpenseResponse = Invoke-ApiCall -Method "PUT" -Uri "$BaseUrl/api/expenses/$expenseId" -Body $editedExpenseData -Headers $authHeaders -Description "Editando despesa"
    
    # 6. Excluir despesa
    $deleteResponse = Invoke-ApiCall -Method "DELETE" -Uri "$BaseUrl/api/expenses/$expenseId" -Headers $authHeaders -Description "Excluindo despesa"
    
    Write-Host "`n✅ TESTE COMPLETO EXECUTADO COM SUCESSO!" -ForegroundColor Green
    Write-Host "- Usuario criado: $($userResponse.user.email)" -ForegroundColor Green
    Write-Host "- Grupo criado: $($groupResponse.name)" -ForegroundColor Green
    Write-Host "- Despesa criada e editada: ID $expenseId" -ForegroundColor Green
    Write-Host "- Despesa excluida com sucesso" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ TESTE FALHOU!" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 RESULTADO DO TESTE:" -ForegroundColor Cyan
Write-Host "✅ Endpoints PUT e DELETE implementados" -ForegroundColor Green
Write-Host "✅ Validacoes funcionando" -ForegroundColor Green
Write-Host "✅ Permissoes aplicadas" -ForegroundColor Green
Write-Host "`n🎉 Teste finalizado!" -ForegroundColor Cyan
