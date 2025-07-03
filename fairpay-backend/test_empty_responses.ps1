# Script para testar usuário sem grupos
$baseUrl = "http://localhost:8090"
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

Write-Host "🔍 Testando usuário sem grupos" -ForegroundColor Cyan

# 1. Criar um novo usuário que não tem grupos
$timestamp = [Math]::Floor((Get-Date).Ticks / 10000000)
$newUserEmail = "testuser$timestamp@example.com"

$userData = @{
    name = "Test User"
    email = $newUserEmail
    password = "senha123"
    confirmPassword = "senha123"
} | ConvertTo-Json

Write-Host "`n=== 1. Criando novo usuário sem grupos ===" -ForegroundColor Yellow
try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($userData))
    Write-Host "✅ Usuário criado: $($userResponse.user.email)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Fazer login
$loginData = @{
    email = $newUserEmail
    password = "senha123"
} | ConvertTo-Json

Write-Host "`n=== 2. Fazendo login ===" -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($loginData))
    $token = $loginResponse.accessToken
    Write-Host "✅ Login realizado!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Configurar headers com token
$authHeaders = $headers.Clone()
$authHeaders["Authorization"] = "Bearer $token"

# 4. Testar /api/users/me
Write-Host "`n=== 3. Testando /api/users/me ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
    Write-Host "✅ Sucesso - Resposta: $($response | ConvertTo-Json)" -ForegroundColor Green
    Write-Host "Tipo da resposta: $($response.GetType())" -ForegroundColor Gray
    Write-Host "Campos na resposta: $($response.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# 5. Testar /api/groups (deve estar vazio)
Write-Host "`n=== 4. Testando /api/groups (deve estar vazio) ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Sucesso - Resposta: $($response | ConvertTo-Json)" -ForegroundColor Green
    Write-Host "Tipo da resposta: $($response.GetType())" -ForegroundColor Gray
    Write-Host "Número de grupos: $($response.Count)" -ForegroundColor Gray
    
    if ($response.Count -eq 0) {
        Write-Host "⚠️ Lista de grupos está vazia (como esperado)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# 6. Testar comportamento da resposta vazia
Write-Host "`n=== 5. Analisando resposta vazia ===" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host "Content Type: $($response.Headers.'Content-Type')" -ForegroundColor Gray
    Write-Host "Content Length: $($response.Headers.'Content-Length')" -ForegroundColor Gray
    Write-Host "Raw Content: '$($response.Content)'" -ForegroundColor Gray
    
    if ($response.Content -eq "[]") {
        Write-Host "✅ Resposta é array JSON vazio válido" -ForegroundColor Green
    } elseif ($response.Content -eq "") {
        Write-Host "⚠️ Resposta está completamente vazia (pode causar problemas)" -ForegroundColor Yellow
    } else {
        Write-Host "ℹ️ Resposta tem conteúdo: $($response.Content)" -ForegroundColor Blue
    }
} catch {
    Write-Host "❌ Erro com Invoke-WebRequest: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✨ Teste concluído!" -ForegroundColor Magenta
