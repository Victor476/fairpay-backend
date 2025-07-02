# Teste específico para debug do erro 500 na edição
param([string]$BaseUrl = "http://localhost:8090")

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== DEBUG ESPECÍFICO - ERRO 500 NA EDIÇÃO ===" -ForegroundColor Cyan

try {
    # Usar dados de teste já existentes (despesa 87, usuário 67)
    $timestamp = "20250701232822"
    
    # Login com usuário existente
    $loginData = @{
        email = "debug$timestamp@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    Write-Host "Fazendo login..." -ForegroundColor Blue
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.accessToken
    
    $authHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Buscar a despesa criada anteriormente
    Write-Host "Buscando despesa existente..." -ForegroundColor Blue
    $expenses = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/group/50" -Method GET -Headers $authHeaders
    
    if ($expenses.Count -gt 0) {
        $expense = $expenses[0]
        Write-Host "✅ Despesa encontrada: ID $($expense.id)" -ForegroundColor Green
        Write-Host "Descrição atual: $($expense.description)" -ForegroundColor Gray
        Write-Host "Valor atual: $($expense.totalAmount)" -ForegroundColor Gray
        Write-Host "CreatedBy: $($expense.createdBy.email)" -ForegroundColor Gray
        
        # Tentar editar com dados bem simples
        Write-Host "`nTentando edição simples..." -ForegroundColor Blue
        $editData = @{
            description = "Despesa editada - teste debug"
            totalAmount = 200.00
            groupId = 50
            payer = "debug$timestamp@test.com"
            participants = @("debug$timestamp@test.com")
            date = "2025-01-20"
        }
        
        $editJson = $editData | ConvertTo-Json -Depth 3
        Write-Host "Payload da edição:" -ForegroundColor Yellow
        Write-Host $editJson -ForegroundColor Gray
        
        try {
            $editResponse = Invoke-RestMethod -Uri "$BaseUrl/api/expenses/$($expense.id)" -Method PUT -Body $editJson -Headers $authHeaders
            Write-Host "✅ SUCESSO! Despesa editada!" -ForegroundColor Green
            Write-Host "Nova descrição: $($editResponse.description)" -ForegroundColor Green
            Write-Host "Novo valor: $($editResponse.totalAmount)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erro 500 confirmado:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            
            # Tentar capturar detalhes do erro
            if ($_.Exception.Response) {
                try {
                    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $responseBody = $reader.ReadToEnd()
                    Write-Host "Response completo: $responseBody" -ForegroundColor Red
                } catch {
                    Write-Host "Não foi possível ler o response body" -ForegroundColor Red
                }
            }
            
            Write-Host "`n⚠️ VERIFIQUE OS LOGS DO SERVIDOR SPRING BOOT PARA VER O STACKTRACE COMPLETO" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Nenhuma despesa encontrada" -ForegroundColor Red
    }
    
} catch {
    Write-Host "`n❌ ERRO GERAL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n📋 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Verificar logs do servidor Spring Boot" -ForegroundColor White
Write-Host "2. Procurar por stacktrace do erro 500" -ForegroundColor White
Write-Host "3. Identificar linha específica que está falhando" -ForegroundColor White
