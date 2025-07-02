# Teste debug para autenticacao
param([string]$BaseUrl = "http://localhost:8090")

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== TESTE DEBUG - AUTENTICACAO ===" -ForegroundColor Cyan
Write-Host "URL Base: $BaseUrl" -ForegroundColor Yellow

try {
    # 1. Registro
    Write-Host "`n1. Registrando usuario..." -ForegroundColor Blue
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $registerData = @{
        name = "Debug User $timestamp"
        email = "debug$timestamp@test.com"
        password = "123456"
        confirmPassword = "123456"
    } | ConvertTo-Json
    
    Write-Host "Payload de registro:" -ForegroundColor Gray
    Write-Host $registerData -ForegroundColor Gray
    
    $userResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Usuario registrado:" -ForegroundColor Green
    Write-Host "ID: $($userResponse.id)" -ForegroundColor Green
    Write-Host "Email: $($userResponse.email)" -ForegroundColor Green
    Write-Host "Name: $($userResponse.name)" -ForegroundColor Green
    
    # 2. Login
    Write-Host "`n2. Fazendo login..." -ForegroundColor Blue
    $loginData = @{
        email = "debug$timestamp@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    Write-Host "Payload de login:" -ForegroundColor Gray
    Write-Host $loginData -ForegroundColor Gray
    
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "Response completo do login:" -ForegroundColor Gray
    $loginResponse | ConvertTo-Json | Write-Host -ForegroundColor Gray
    
    if (-not $loginResponse.accessToken) {
        throw "AccessToken nao encontrado na resposta do login"
    }
    
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado:" -ForegroundColor Green
    Write-Host "Token (primeiros 20 chars): $($token.Substring(0, [Math]::Min(20, $token.Length)))" -ForegroundColor Green
    
    # 3. Teste de autenticacao - listar grupos
    Write-Host "`n3. Testando autenticacao (GET /api/groups)..." -ForegroundColor Blue
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "Headers:" -ForegroundColor Gray
    $headers | ConvertTo-Json | Write-Host -ForegroundColor Gray
    
    $groupsResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method GET -Headers $headers
    Write-Host "✅ Autenticacao funcionando - grupos encontrados: $($groupsResponse.Count)" -ForegroundColor Green
    
    # 4. Criar grupo
    Write-Host "`n4. Criando grupo..." -ForegroundColor Blue
    $groupData = @{
        name = "Grupo_Debug"
        description = "Grupo para debug"
    } | ConvertTo-Json
    
    Write-Host "Payload do grupo:" -ForegroundColor Gray
    Write-Host $groupData -ForegroundColor Gray
    
    $groupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/groups" -Method POST -Body $groupData -Headers $headers
    Write-Host "✅ Grupo criado:" -ForegroundColor Green
    Write-Host "ID: $($groupResponse.id)" -ForegroundColor Green
    Write-Host "Nome: $($groupResponse.name)" -ForegroundColor Green
    
    Write-Host "`n✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ ERRO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response Body: $responseBody" -ForegroundColor Red
            Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        } catch {
            Write-Host "Nao foi possivel ler o response body" -ForegroundColor Red
        }
    }
}
