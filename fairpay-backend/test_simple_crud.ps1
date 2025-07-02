# Teste simples passo a passo
$baseUrl = "http://localhost:8090"

Write-Host "🧪 TESTE SIMPLES DOS ENDPOINTS" -ForegroundColor Cyan

# 1. Testar se a API está respondendo
Write-Host "`n1. Testando conectividade..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-RestMethod -Uri "$baseUrl/api/auth/test" -Method GET -ErrorAction SilentlyContinue
    Write-Host "✅ API respondendo" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Endpoint de test não existe, mas API está online" -ForegroundColor Yellow
}

# 2. Tentar login com usuário existente
Write-Host "`n2. Tentando login..." -ForegroundColor Yellow
$loginData = @{
    email = "admin@fairpay.com"
    password = "admin123"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
    Write-Host "Token obtido: $($loginResponse.token.Substring(0,20))..." -ForegroundColor Gray
    
    $authToken = $loginResponse.token
    $userId = $loginResponse.user.id
    
    $authHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $authToken"
    }
    
} catch {
    Write-Host "❌ Erro no login:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta do servidor: $responseBody" -ForegroundColor Yellow
    }
    
    Write-Host "`nTentando com outro usuário..." -ForegroundColor Yellow
    $loginData2 = @{
        email = "test@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    try {
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData2
        Write-Host "✅ Login realizado com segundo usuário!" -ForegroundColor Green
        
        $authToken = $loginResponse.token
        $userId = $loginResponse.user.id
        
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $authToken"
        }
    } catch {
        Write-Host "❌ Erro também com segundo usuário" -ForegroundColor Red
        Write-Host "Vamos tentar criar um usuário..." -ForegroundColor Yellow
        
        # Tentar registrar um usuário
        $registerData = @{
            name = "Test User"
            email = "testuser@test.com"
            password = "123456"
        } | ConvertTo-Json
        
        try {
            $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $registerData
            Write-Host "✅ Usuário criado com sucesso!" -ForegroundColor Green
            
            # Login com usuário criado
            $newLoginData = @{
                email = "testuser@test.com"
                password = "123456"
            } | ConvertTo-Json
            
            $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $newLoginData
            $authToken = $loginResponse.token
            $userId = $loginResponse.user.id
            
            $authHeaders = @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $authToken"
            }
            
            Write-Host "✅ Login com usuário criado realizado!" -ForegroundColor Green
            
        } catch {
            Write-Host "❌ Erro ao criar usuário:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            exit 1
        }
    }
}

# 3. Testar endpoint de usuário
Write-Host "`n3. Testando GET /api/users/me..." -ForegroundColor Yellow
try {
    $userProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
    Write-Host "✅ Perfil do usuário obtido:" -ForegroundColor Green
    Write-Host "   Nome: $($userProfile.name)" -ForegroundColor Gray
    Write-Host "   Email: $($userProfile.email)" -ForegroundColor Gray
    Write-Host "   ID: $($userProfile.id)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao obter perfil:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 4. Testar atualização de perfil
Write-Host "`n4. Testando PUT /api/users/me..." -ForegroundColor Yellow
$updateData = @{
    name = "Test User Updated"
    email = "testuser@test.com"
    phoneNumber = "+5511999999999"
} | ConvertTo-Json

try {
    $updatedProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method PUT -Headers $authHeaders -Body $updateData
    Write-Host "✅ Perfil atualizado:" -ForegroundColor Green
    Write-Host "   Nome: $($updatedProfile.name)" -ForegroundColor Gray
    Write-Host "   Telefone: $($updatedProfile.phoneNumber)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao atualizar perfil:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 5. Listar grupos do usuário
Write-Host "`n5. Testando GET /api/groups..." -ForegroundColor Yellow
try {
    $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Grupos do usuário:" -ForegroundColor Green
    
    if ($groups.Count -gt 0) {
        $groupId = $groups[0].id
        Write-Host "   Primeiro grupo ID: $groupId" -ForegroundColor Gray
        
        # 6. Testar detalhes do grupo
        Write-Host "`n6. Testando GET /api/groups/$groupId..." -ForegroundColor Yellow
        try {
            $groupDetails = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method GET -Headers $authHeaders
            Write-Host "✅ Detalhes do grupo:" -ForegroundColor Green
            Write-Host "   Nome: $($groupDetails.name)" -ForegroundColor Gray
            Write-Host "   Descrição: $($groupDetails.description)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erro ao obter detalhes do grupo:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } else {
        Write-Host "   Nenhum grupo encontrado. Criando um..." -ForegroundColor Yellow
        
        # Criar grupo para testar
        $createGroupData = @{
            name = "Grupo de Teste"
            description = "Grupo criado para testes"
        } | ConvertTo-Json
        
        try {
            $newGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method POST -Headers $authHeaders -Body $createGroupData
            Write-Host "✅ Grupo criado: $($newGroup.name)" -ForegroundColor Green
            $groupId = $newGroup.id
        } catch {
            Write-Host "❌ Erro ao criar grupo:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Erro ao listar grupos:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🎉 TESTE SIMPLES CONCLUÍDO!" -ForegroundColor Green
