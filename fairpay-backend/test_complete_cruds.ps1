# Script de teste completo para os novos endpoints CRUD implementados
# Certifique-se de que a API está rodando em http://localhost:8090

$baseUrl = "http://localhost:8090"
$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🧪 TESTE COMPLETO DOS NOVOS ENDPOINTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Primeiro, vamos fazer login para obter um token
Write-Host "`n🔐 FAZENDO LOGIN PARA OBTER TOKEN..." -ForegroundColor Yellow

# Dados de login (ajuste conforme necessário)
$loginData = @{
    email = "test@test.com"
    password = "123456"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    $authToken = $loginResponse.token
    $userId = $loginResponse.user.id
    
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
    Write-Host "   Token: $($authToken.Substring(0,20))..." -ForegroundColor Gray
    Write-Host "   User ID: $userId" -ForegroundColor Gray
    
    # Atualizar headers com token
    $authHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $authToken"
    }
} catch {
    Write-Host "❌ ERRO NO LOGIN:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
    
    Write-Host "`n⚠️  Tentando criar usuário de teste..." -ForegroundColor Yellow
    
    # Tentar criar usuário de teste
    $registerData = @{
        name = "Test User"
        email = "test@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    try {
        $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $registerData
        Write-Host "✅ Usuário criado com sucesso!" -ForegroundColor Green
        
        # Fazer login novamente
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
        $authToken = $loginResponse.token
        $userId = $loginResponse.user.id
        
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $authToken"
        }
        
        Write-Host "✅ Login após registro realizado!" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERRO AO CRIAR USUÁRIO DE TESTE:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "👤 TESTANDO ENDPOINTS DE USUÁRIO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Testar GET /api/users/me
Write-Host "`n1️⃣ Testando GET /api/users/me..." -ForegroundColor Blue
try {
    $userProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
    Write-Host "✅ Perfil obtido com sucesso:" -ForegroundColor Green
    Write-Host "   Nome: $($userProfile.name)" -ForegroundColor Gray
    Write-Host "   Email: $($userProfile.email)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao obter perfil:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 2. Testar PUT /api/users/me
Write-Host "`n2️⃣ Testando PUT /api/users/me..." -ForegroundColor Blue
$updateProfileData = @{
    name = "Test User Updated"
    email = "test@test.com"
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
    
    # Voltar a senha original para continuar testando
    $revertPasswordData = @{
        currentPassword = "123456new"
        newPassword = "123456"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $revertPasswordData | Out-Null
    Write-Host "✅ Senha revertida para continuar testes" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao alterar senha:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "👥 TESTANDO ENDPOINTS DE GRUPO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Primeiro, criar um grupo para testar
Write-Host "`n📁 Criando grupo de teste..." -ForegroundColor Yellow
$createGroupData = @{
    name = "Grupo de Teste"
    description = "Grupo criado para testar os endpoints"
} | ConvertTo-Json

try {
    $createdGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method POST -Headers $authHeaders -Body $createGroupData
    $groupId = $createdGroup.id
    Write-Host "✅ Grupo criado com ID: $groupId" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao criar grupo:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 4. Testar GET /api/groups/{groupId}
Write-Host "`n4️⃣ Testando GET /api/groups/$groupId..." -ForegroundColor Blue
try {
    $groupDetails = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method GET -Headers $authHeaders
    Write-Host "✅ Detalhes do grupo obtidos:" -ForegroundColor Green
    Write-Host "   Nome: $($groupDetails.name)" -ForegroundColor Gray
    Write-Host "   Descrição: $($groupDetails.description)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao obter detalhes do grupo:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 5. Testar PUT /api/groups/{groupId}
Write-Host "`n5️⃣ Testando PUT /api/groups/$groupId..." -ForegroundColor Blue
$updateGroupData = @{
    name = "Grupo de Teste Atualizado"
    description = "Descrição atualizada do grupo"
} | ConvertTo-Json

try {
    $updatedGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method PUT -Headers $authHeaders -Body $updateGroupData
    Write-Host "✅ Grupo atualizado com sucesso:" -ForegroundColor Green
    Write-Host "   Nome: $($updatedGroup.name)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao atualizar grupo:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 6. Testar endpoints de membros (criar outro usuário primeiro)
Write-Host "`n👤 Criando segundo usuário para testar gerenciamento de membros..." -ForegroundColor Yellow
$user2RegisterData = @{
    name = "Test User 2"
    email = "test2@test.com"
    password = "123456"
} | ConvertTo-Json

try {
    $user2Response = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Headers $headers -Body $user2RegisterData
    
    # Fazer login do user2 para obter ID
    $user2LoginData = @{
        email = "test2@test.com"
        password = "123456"
    } | ConvertTo-Json
    
    $user2LoginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $user2LoginData
    $user2Id = $user2LoginResponse.user.id
    
    Write-Host "✅ Segundo usuário criado com ID: $user2Id" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Segundo usuário pode já existir, continuando..." -ForegroundColor Yellow
    $user2Id = $userId + 1  # Assumir ID sequencial
}

# 7. Testar POST /api/groups/{groupId}/members
Write-Host "`n6️⃣ Testando POST /api/groups/$groupId/members..." -ForegroundColor Blue
$addMemberData = @{
    userId = $user2Id
    role = "member"
} | ConvertTo-Json

try {
    $addMemberResult = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method POST -Headers $authHeaders -Body $addMemberData
    Write-Host "✅ Membro adicionado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao adicionar membro:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 8. Testar PUT /api/groups/{groupId}/members/{userId}
Write-Host "`n7️⃣ Testando PUT /api/groups/$groupId/members/$user2Id..." -ForegroundColor Blue
$updateRoleData = @{
    role = "admin"
} | ConvertTo-Json

try {
    $updateRoleResult = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$user2Id" -Method PUT -Headers $authHeaders -Body $updateRoleData
    Write-Host "✅ Papel do membro atualizado para admin!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao atualizar papel do membro:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 9. Testar DELETE /api/groups/{groupId}/members/{userId}
Write-Host "`n8️⃣ Testando DELETE /api/groups/$groupId/members/$user2Id..." -ForegroundColor Blue
try {
    $removeMemberResult = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$user2Id" -Method DELETE -Headers $authHeaders
    Write-Host "✅ Membro removido com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao remover membro:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 10. Listar membros para verificar
Write-Host "`n🔍 Verificando membros restantes..." -ForegroundColor Blue
try {
    $members = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method GET -Headers $authHeaders
    Write-Host "✅ Membros atuais do grupo:" -ForegroundColor Green
    $members | ForEach-Object { 
        Write-Host "   - $($_.name) ($($_.email))" -ForegroundColor Gray 
    }
} catch {
    Write-Host "❌ ERRO ao listar membros:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 11. Testar DELETE /api/groups/{groupId} - Excluir grupo
Write-Host "`n9️⃣ Testando DELETE /api/groups/$groupId..." -ForegroundColor Blue
try {
    $deleteGroupResult = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method DELETE -Headers $authHeaders
    Write-Host "✅ Grupo excluído com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao excluir grupo:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ ENDPOINTS TESTADOS:" -ForegroundColor Green
Write-Host "   👤 GET /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me/password" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 PUT /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 POST /api/groups/{groupId}/members" -ForegroundColor Gray
Write-Host "   👥 PUT /api/groups/{groupId}/members/{userId}" -ForegroundColor Gray
Write-Host "   👥 DELETE /api/groups/{groupId}/members/{userId}" -ForegroundColor Gray
Write-Host "   👥 DELETE /api/groups/{groupId}" -ForegroundColor Gray

Write-Host "`n🎉 TESTE COMPLETO FINALIZADO!" -ForegroundColor Green
Write-Host "Verifique os resultados acima para identificar problemas." -ForegroundColor Yellow
