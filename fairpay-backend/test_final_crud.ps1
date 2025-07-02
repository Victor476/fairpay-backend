# Teste corrigido com a estrutura correta de resposta do login
$baseUrl = "http://localhost:8090"

Write-Host "🧪 TESTE CORRIGIDO DOS ENDPOINTS CRUD" -ForegroundColor Cyan

$headers = @{
    "Content-Type" = "application/json"
}

# Login com Victor
Write-Host "`n🔐 Fazendo login com Victor..." -ForegroundColor Yellow
$loginData = @{
    email = "victor@teste.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
    
    # Usar accessToken em vez de token
    $authToken = $loginResponse.accessToken
    Write-Host "   Token obtido: $($authToken.Substring(0,30))..." -ForegroundColor Gray
    
    $authHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $authToken"
    }
} catch {
    Write-Host "❌ ERRO NO LOGIN:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
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
    Write-Host "   Ativo: $($userProfile.isActive)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao obter perfil:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 2. Testar PUT /api/users/me
Write-Host "`n2️⃣ Testando PUT /api/users/me..." -ForegroundColor Blue
$updateProfileData = @{
    name = "Victor Angelo - Atualizado $(Get-Date -Format 'HHmmss')"
    email = "victor@teste.com"  # Manter o mesmo email
    phoneNumber = "+5511987654321"
} | ConvertTo-Json

try {
    $updatedProfile = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method PUT -Headers $authHeaders -Body $updateProfileData
    Write-Host "✅ Perfil atualizado com sucesso:" -ForegroundColor Green
    Write-Host "   Nome: $($updatedProfile.name)" -ForegroundColor Gray
    Write-Host "   Telefone: $($updatedProfile.phoneNumber)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO ao atualizar perfil:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
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
    currentPassword = "password123"
    newPassword = "password123new"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $changePasswordData | Out-Null
    Write-Host "✅ Senha alterada com sucesso!" -ForegroundColor Green
    
    # Reverter senha
    Start-Sleep -Seconds 1
    $revertPasswordData = @{
        currentPassword = "password123new"
        newPassword = "password123"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $revertPasswordData | Out-Null
    Write-Host "✅ Senha revertida com sucesso" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO ao alterar senha:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
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

# 4. Listar grupos
Write-Host "`n4️⃣ Testando GET /api/groups..." -ForegroundColor Blue
$groupId = $null

try {
    $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Grupos encontrados: $($groups.Count)" -ForegroundColor Green
    
    if ($groups.Count -gt 0) {
        $groupId = $groups[0].id
        Write-Host "   Primeiro grupo ID: $groupId" -ForegroundColor Gray
        Write-Host "   Nome: $($groups[0].name)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ ERRO ao listar grupos:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 5. Criar grupo se necessário
if ($null -eq $groupId) {
    Write-Host "`n📁 Criando grupo para testes..." -ForegroundColor Yellow
    $createGroupData = @{
        name = "Grupo do Victor - Teste $(Get-Date -Format 'HHmmss')"
        description = "Grupo criado para testar os endpoints CRUD"
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
        Write-Host "   ID: $($groupDetails.id)" -ForegroundColor Gray
        Write-Host "   Nome: $($groupDetails.name)" -ForegroundColor Gray
        Write-Host "   Descrição: $($groupDetails.description)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao obter detalhes do grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    # 7. Testar PUT /api/groups/{groupId}
    Write-Host "`n6️⃣ Testando PUT /api/groups/$groupId..." -ForegroundColor Blue
    $updateGroupData = @{
        name = "Grupo Atualizado - $(Get-Date -Format 'HHmmss')"
        description = "Descrição atualizada via teste automatizado"
    } | ConvertTo-Json
    
    try {
        $updatedGroup = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method PUT -Headers $authHeaders -Body $updateGroupData
        Write-Host "✅ Grupo atualizado com sucesso:" -ForegroundColor Green
        Write-Host "   Nome: $($updatedGroup.name)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao atualizar grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    # 8. Testar membros
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
    
    # 9. Testar novos endpoints de gerenciamento de membros
    Write-Host "`n8️⃣ Testando POST /api/groups/$groupId/members..." -ForegroundColor Blue
    $testUserId = 1  # Assumindo que existe usuário com ID 1
    
    $addMemberData = @{
        userId = $testUserId
        role = "member"
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method POST -Headers $authHeaders -Body $addMemberData | Out-Null
        Write-Host "✅ Endpoint POST /api/groups/{groupId}/members funcionou!" -ForegroundColor Green
        
        # Testar alterar papel
        Write-Host "`n9️⃣ Testando PUT /api/groups/$groupId/members/$testUserId..." -ForegroundColor Blue
        $updateRoleData = @{
            role = "admin"
        } | ConvertTo-Json
        
        try {
            Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$testUserId" -Method PUT -Headers $authHeaders -Body $updateRoleData | Out-Null
            Write-Host "✅ Endpoint PUT /api/groups/{groupId}/members/{userId} funcionou!" -ForegroundColor Green
        } catch {
            Write-Host "❌ ERRO ao alterar papel:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
        
        # Testar remover membro
        Write-Host "`n🔟 Testando DELETE /api/groups/$groupId/members/$testUserId..." -ForegroundColor Blue
        try {
            Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$testUserId" -Method DELETE -Headers $authHeaders | Out-Null
            Write-Host "✅ Endpoint DELETE /api/groups/{groupId}/members/{userId} funcionou!" -ForegroundColor Green
        } catch {
            Write-Host "❌ ERRO ao remover membro:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
        
    } catch {
        Write-Host "❌ ERRO ao adicionar membro:" -ForegroundColor Red
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n🎉 TESTE CORRIGIDO CONCLUÍDO!" -ForegroundColor Green
Write-Host "Agora testando todos os endpoints implementados!" -ForegroundColor Yellow
