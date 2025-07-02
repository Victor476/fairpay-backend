# Teste para corrigir problemas de encoding UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "🔧 TESTE DE CORREÇÃO DE ENCODING" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Login
Write-Host "`n1. Fazendo login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri 'http://localhost:8090/api/auth/login' -Method POST -ContentType 'application/json; charset=utf-8' -Body '{"email":"victor@teste.com","password":"password123"}'
$token = $loginResponse.token
Write-Host "✅ Login realizado"

$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json; charset=utf-8'
}

# Teste 1: Verificar se o problema é de permissão ou encoding
Write-Host "`n2. Testando com dados simples (sem acentos)..." -ForegroundColor Yellow
$simplePayload = @{
    name = "Test Simple"
    description = "Simple test without special chars"
} | ConvertTo-Json -Depth 2

try {
    $response = Invoke-RestMethod -Uri 'http://localhost:8090/api/groups/1' -Method PUT -Headers $headers -Body $simplePayload
    Write-Host "✅ Dados simples funcionaram!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro com dados simples:" -ForegroundColor Red
    $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Red
    }
}

# Teste 2: Verificar membros e permissões
Write-Host "`n3. Verificando membros do grupo..." -ForegroundColor Yellow
try {
    $members = Invoke-RestMethod -Uri 'http://localhost:8090/api/groups/1/members' -Method GET -Headers $headers
    Write-Host "✅ Membros obtidos:" -ForegroundColor Green
    $members | ForEach-Object {
        Write-Host "   - ID: $($_.userId), Nome: $($_.userName), Role: $($_.role)"
    }
} catch {
    Write-Host "❌ Erro ao obter membros:" -ForegroundColor Red
    $_.Exception.Message
}

# Teste 3: Verificar detalhes do grupo
Write-Host "`n4. Verificando detalhes do grupo..." -ForegroundColor Yellow
try {
    $group = Invoke-RestMethod -Uri 'http://localhost:8090/api/groups/1' -Method GET -Headers $headers
    Write-Host "✅ Grupo obtido:" -ForegroundColor Green
    Write-Host "   - Nome: $($group.name)"
    Write-Host "   - Descrição: $($group.description)"
    Write-Host "   - Criado por: $($group.createdBy)"
    
    # Verificar se Victor é admin ou criador
    $userProfile = Invoke-RestMethod -Uri 'http://localhost:8090/api/users/me' -Method GET -Headers $headers
    Write-Host "   - Usuário atual ID: $($userProfile.id)"
    Write-Host "   - É criador? $($group.createdBy -eq $userProfile.id)"
} catch {
    Write-Host "❌ Erro ao obter grupo:" -ForegroundColor Red
    $_.Exception.Message
}

Write-Host "`n🔧 TESTE CONCLUÍDO!" -ForegroundColor Cyan
