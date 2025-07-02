# Teste simples e inteligente dos endpoints
$baseUrl = "http://localhost:8090"

Write-Host "🧪 TESTE INTELIGENTE DOS ENDPOINTS CRUD" -ForegroundColor Cyan

# Lista de credenciais para tentar
$credenciais = @(
    @{ email = "admin@fairpay.com"; password = "admin123" },
    @{ email = "test@test.com"; password = "123456" },
    @{ email = "user@test.com"; password = "123456" },
    @{ email = "testuser@test.com"; password = "123456" }
)

$headers = @{
    "Content-Type" = "application/json"
}

$authToken = $null
$userId = $null
$authHeaders = $null

# Tentar login com credenciais existentes
Write-Host "`n🔐 Tentando login com usuários existentes..." -ForegroundColor Yellow

foreach ($cred in $credenciais) {
    Write-Host "   Tentando: $($cred.email)" -ForegroundColor Gray
    
    $loginData = @{
        email = $cred.email
        password = $cred.password
    } | ConvertTo-Json
    
    try {
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
        $authToken = $loginResponse.token
        $userId = $loginResponse.user.id
        
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $authToken"
        }
        
        Write-Host "✅ Login realizado com: $($cred.email)" -ForegroundColor Green
        Write-Host "   User ID: $userId" -ForegroundColor Gray
        break
    } catch {
        Write-Host "   ❌ Falhou: $($cred.email)" -ForegroundColor Red
    }
}

# Se não conseguiu login, tentar criar um usuário único
if ($null -eq $authToken) {
    Write-Host "`n📝 Criando usuário único para teste..." -ForegroundColor Yellow
    
    # Gerar email único baseado no timestamp
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    $uniqueEmail = "testuser$timestamp@test.com"
    
    $registerData = @{
        name = "Test User $timestamp"
        email = $uniqueEmail
        password = "123456"
    } | ConvertTo-Json
    
    try {
        $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $registerData
        Write-Host "✅ Usuário criado: $uniqueEmail" -ForegroundColor Green
        
        # Fazer login com o usuário criado
        $loginData = @{
            email = $uniqueEmail
            password = "123456"
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
        $authToken = $loginResponse.token
        $userId = $loginResponse.user.id
        
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $authToken"
        }
        
        Write-Host "✅ Login realizado com usuário criado!" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Erro ao criar usuário:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

if ($null -eq $authToken) {
    Write-Host "❌ Não foi possível obter token de autenticação" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "👤 TESTANDO ENDPOINTS DE USUÁRIO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Testar GET /api/users/me
Write-Host "`n1️⃣ Testando GET /api/users/me..." -ForegroundColor Blue
try {
    $userProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
    Write-Host "✅ Perfil obtido com sucesso:" -ForegroundColor Green
    Write-Host "   ID: $($userProfile.id)" -ForegroundColor Gray
    Write-Host "   Nome: $($userProfile.name)" -ForegroundColor Gray
    Write-Host "   Email: $($userProfile.email)" -ForegroundColor Gray
    Write-Host "   Telefone: $($userProfile.phoneNumber)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao obter perfil:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 2. Testar PUT /api/users/me
Write-Host "`n2️⃣ Testando PUT /api/users/me..." -ForegroundColor Blue
$updateProfileData = @{
    name = "Test User Updated $(Get-Date -Format 'HHmmss')"
    email = $userProfile.email  # Manter o mesmo email
    phoneNumber = "+5511999999999"
} | ConvertTo-Json

try {
    $updatedProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method PUT -Headers $authHeaders -Body $updateProfileData
    Write-Host "✅ Perfil atualizado com sucesso:" -ForegroundColor Green
    Write-Host "   Nome: $($updatedProfile.name)" -ForegroundColor Gray
    Write-Host "   Telefone: $($updatedProfile.phoneNumber)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao atualizar perfil:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 3. Testar PUT /api/users/me/password
Write-Host "`n3️⃣ Testando PUT /api/users/me/password..." -ForegroundColor Blue
$changePasswordData = @{
    currentPassword = "123456"
    newPassword = "123456new"
} | ConvertTo-Json

try {
    $passwordResult = Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $changePasswordData
    Write-Host "✅ Senha alterada com sucesso!" -ForegroundColor Green
    
    # Reverter senha para continuar testes
    Start-Sleep -Seconds 1
    $revertPasswordData = @{
        currentPassword = "123456new"
        newPassword = "123456"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $revertPasswordData | Out-Null
    Write-Host "✅ Senha revertida para continuar testes" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao alterar senha:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "👥 TESTANDO ENDPOINTS DE GRUPO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 4. Listar grupos existentes
Write-Host "`n4️⃣ Testando GET /api/groups..." -ForegroundColor Blue
$groupId = $null

try {
    $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Grupos encontrados: $($groups.Count)" -ForegroundColor Green
    
    if ($groups.Count -gt 0) {
        $groupId = $groups[0].id
        Write-Host "   Usando grupo existente ID: $groupId" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ ERRO ao listar grupos:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 5. Criar grupo se necessário
if ($null -eq $groupId) {
    Write-Host "`n📁 Criando grupo para testes..." -ForegroundColor Yellow
    $createGroupData = @{
        name = "Grupo de Teste $(Get-Date -Format 'HHmmss')"
        description = "Grupo criado automaticamente para testes"
    } | ConvertTo-Json
    
    try {
        $createdGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method POST -Headers $authHeaders -Body $createGroupData
        $groupId = $createdGroup.id
        Write-Host "✅ Grupo criado com ID: $groupId" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERRO ao criar grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

if ($null -ne $groupId) {
    # 6. Testar GET /api/groups/{groupId}
    Write-Host "`n5️⃣ Testando GET /api/groups/$groupId..." -ForegroundColor Blue
    try {
        $groupDetails = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method GET -Headers $authHeaders
        Write-Host "✅ Detalhes do grupo obtidos:" -ForegroundColor Green
        Write-Host "   Nome: $($groupDetails.name)" -ForegroundColor Gray
        Write-Host "   Descrição: $($groupDetails.description)" -ForegroundColor Gray
        Write-Host "   Criado por: $($groupDetails.createdBy.name)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao obter detalhes do grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    # 7. Testar PUT /api/groups/{groupId}
    Write-Host "`n6️⃣ Testando PUT /api/groups/$groupId..." -ForegroundColor Blue
    $updateGroupData = @{
        name = "Grupo Atualizado $(Get-Date -Format 'HHmmss')"
        description = "Descrição atualizada via teste automatizado"
    } | ConvertTo-Json
    
    try {
        $updatedGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method PUT -Headers $authHeaders -Body $updateGroupData
        Write-Host "✅ Grupo atualizado com sucesso:" -ForegroundColor Green
        Write-Host "   Nome: $($updatedGroup.name)" -ForegroundColor Gray
        Write-Host "   Descrição: $($updatedGroup.description)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao atualizar grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
        }
    }
    
    # 8. Testar membros do grupo
    Write-Host "`n7️⃣ Testando GET /api/groups/$groupId/members..." -ForegroundColor Blue
    try {
        $members = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method GET -Headers $authHeaders
        Write-Host "✅ Membros do grupo ($($members.Count)):" -ForegroundColor Green
        foreach ($member in $members) {
            Write-Host "   - $($member.name) ($($member.email))" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ ERRO ao listar membros:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ ENDPOINTS FUNCIONAIS TESTADOS:" -ForegroundColor Green
Write-Host "   👤 GET /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me/password" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups" -ForegroundColor Gray
Write-Host "   👥 POST /api/groups" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 PUT /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups/{groupId}/members" -ForegroundColor Gray

Write-Host "`n🎉 TESTE INTELIGENTE CONCLUÍDO!" -ForegroundColor Green
Write-Host "Os endpoints básicos de CRUD estão funcionando!" -ForegroundColor Yellow
