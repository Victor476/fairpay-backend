# Teste de diagnóstico para verificar o que está funcionando
$baseUrl = "http://localhost:8090"

Write-Host "🔍 DIAGNÓSTICO DOS ENDPOINTS" -ForegroundColor Cyan

$headers = @{
    "Content-Type" = "application/json"
}

# 1. Testar login
Write-Host "`n1. Testando login..." -ForegroundColor Yellow
$loginData = @{
    email = "victor@teste.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    Write-Host "✅ Login funcionou!" -ForegroundColor Green
    Write-Host "Resposta completa do login:" -ForegroundColor Gray
    $loginResponse | ConvertTo-Json -Depth 3
    
    if ($loginResponse.token) {
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $($loginResponse.token)"
        }
        
        # 2. Testar endpoints existentes conhecidos
        Write-Host "`n2. Testando GET /api/groups (endpoint conhecido)..." -ForegroundColor Yellow
        try {
            $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
            Write-Host "✅ Endpoint /api/groups funcionou!" -ForegroundColor Green
            Write-Host "Grupos encontrados: $($groups.Count)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Endpoint /api/groups falhou:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
        
        # 3. Testar novo endpoint de usuário
        Write-Host "`n3. Testando GET /api/users/me (endpoint novo)..." -ForegroundColor Yellow
        try {
            $userProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
            Write-Host "✅ Endpoint /api/users/me funcionou!" -ForegroundColor Green
            Write-Host "Resposta:" -ForegroundColor Gray
            $userProfile | ConvertTo-Json -Depth 3
        } catch {
            Write-Host "❌ Endpoint /api/users/me falhou:" -ForegroundColor Red
            Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Corpo da resposta: $responseBody" -ForegroundColor Yellow
            }
        }
        
        # 4. Verificar se UserController está registrado
        Write-Host "`n4. Testando se UserController está ativo..." -ForegroundColor Yellow
        try {
            # Tentar um endpoint que provavelmente dará 404 se UserController não existir
            # ou outro erro se existir mas tiver problema
            Invoke-RestMethod -Uri "$baseUrl/api/users/test" -Method GET -Headers $authHeaders -ErrorAction Stop
        } catch {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "Status Code: $statusCode" -ForegroundColor Gray
            
            if ($statusCode -eq "NotFound") {
                Write-Host "❌ UserController provavelmente não está registrado (404)" -ForegroundColor Red
            } elseif ($statusCode -eq "Unauthorized") {
                Write-Host "⚠️  UserController existe mas há problema de autorização" -ForegroundColor Yellow
            } else {
                Write-Host "✅ UserController parece estar registrado (erro diferente de 404)" -ForegroundColor Green
            }
        }
        
    } else {
        Write-Host "❌ Login não retornou token" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Login falhou:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🔍 DIAGNÓSTICO CONCLUÍDO" -ForegroundColor Cyan
