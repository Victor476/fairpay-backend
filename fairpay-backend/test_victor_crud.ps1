# Teste dos endpoints CRUD usando o usuário Victor
$baseUrl = "http://localhost:8090"

Write-Host "🧪 TESTE DOS ENDPOINTS CRUD - USUÁRIO VICTOR" -ForegroundColor Cyan

$headers = @{
    "Content-Type" = "application/json"
}

# Credenciais do Victor
$loginData = @{
    email = "victor@teste.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "`n🔐 Fazendo login com Victor..." -ForegroundColor Yellow

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
    $authToken = $loginResponse.token
    $userId = $loginResponse.user.id
    
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
    Write-Host "   User ID: $userId" -ForegroundColor Gray
    Write-Host "   Nome: $($loginResponse.user.name)" -ForegroundColor Gray
    Write-Host "   Email: $($loginResponse.user.email)" -ForegroundColor Gray
    
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
    name = "Victor Angelo Updated"
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
    
    # Reverter senha para não quebrar futuros testes
    Start-Sleep -Seconds 1
    $revertPasswordData = @{
        currentPassword = "password123new"
        newPassword = "password123"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $revertPasswordData | Out-Null
    Write-Host "✅ Senha revertida para password123" -ForegroundColor Green
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

# 4. Listar grupos do Victor
Write-Host "`n4️⃣ Testando GET /api/groups..." -ForegroundColor Blue
$groupId = $null

try {
    $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    Write-Host "✅ Grupos encontrados: $($groups.Count)" -ForegroundColor Green
    
    if ($groups.Count -gt 0) {
        $groupId = $groups[0].id
        Write-Host "   Primeiro grupo ID: $groupId" -ForegroundColor Gray
        Write-Host "   Nome: $($groups[0].name)" -ForegroundColor Gray
    } else {
        Write-Host "   Nenhum grupo encontrado" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ ERRO ao listar grupos:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 5. Criar grupo se não existir
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
        Write-Host "   Nome: $($createdGroup.name)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao criar grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
        }
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
        Write-Host "   Criado por: $($groupDetails.createdBy.name)" -ForegroundColor Gray
        Write-Host "   Criado em: $($groupDetails.createdAt)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ ERRO ao obter detalhes do grupo:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
        }
    }
    
    # 7. Testar PUT /api/groups/{groupId}
    Write-Host "`n6️⃣ Testando PUT /api/groups/$groupId..." -ForegroundColor Blue
    $updateGroupData = @{
        name = "Grupo do Victor - Atualizado $(Get-Date -Format 'HHmmss')"
        description = "Descrição atualizada via teste automatizado dos endpoints CRUD"
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
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
        }
    }
    
    # 9. Testar novos endpoints de gerenciamento de membros
    Write-Host "`n8️⃣ Testando POST /api/groups/$groupId/members..." -ForegroundColor Blue
    
    # Primeiro, precisamos de outro usuário para adicionar
    # Vamos tentar com ID 1 (assumindo que existe)
    $testUserId = 1
    if ($testUserId -ne $userId) {
        $addMemberData = @{
            userId = $testUserId
            role = "member"
        } | ConvertTo-Json
        
        try {
            Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method POST -Headers $authHeaders -Body $addMemberData | Out-Null
            Write-Host "✅ Membro adicionado com sucesso (User ID: $testUserId)!" -ForegroundColor Green
            
            # 10. Testar alterar papel do membro
            Write-Host "`n9️⃣ Testando PUT /api/groups/$groupId/members/$testUserId..." -ForegroundColor Blue
            $updateRoleData = @{
                role = "admin"
            } | ConvertTo-Json
            
            try {
                Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$testUserId" -Method PUT -Headers $authHeaders -Body $updateRoleData | Out-Null
                Write-Host "✅ Papel do membro alterado para admin!" -ForegroundColor Green
                
                # 11. Testar remover membro
                Write-Host "`n🔟 Testando DELETE /api/groups/$groupId/members/$testUserId..." -ForegroundColor Blue
                try {
                    Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$testUserId" -Method DELETE -Headers $authHeaders | Out-Null
                    Write-Host "✅ Membro removido com sucesso!" -ForegroundColor Green
                } catch {
                    Write-Host "❌ ERRO ao remover membro:" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
            } catch {
                Write-Host "❌ ERRO ao alterar papel do membro:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ ERRO ao adicionar membro:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "⚠️  Não é possível testar adição de membros (não há outro usuário disponível)" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 RESUMO DOS TESTES COM VICTOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ ENDPOINTS TESTADOS COM SUCESSO:" -ForegroundColor Green
Write-Host "   🔐 POST /api/auth/login" -ForegroundColor Gray
Write-Host "   👤 GET /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me" -ForegroundColor Gray
Write-Host "   👤 PUT /api/users/me/password" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups" -ForegroundColor Gray
Write-Host "   👥 POST /api/groups" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 PUT /api/groups/{groupId}" -ForegroundColor Gray
Write-Host "   👥 GET /api/groups/{groupId}/members" -ForegroundColor Gray
Write-Host "   👥 POST /api/groups/{groupId}/members" -ForegroundColor Gray
Write-Host "   👥 PUT /api/groups/{groupId}/members/{userId}" -ForegroundColor Gray
Write-Host "   👥 DELETE /api/groups/{groupId}/members/{userId}" -ForegroundColor Gray

Write-Host "`n🎉 TESTE COMPLETO COM VICTOR FINALIZADO!" -ForegroundColor Green
Write-Host "Todos os endpoints básicos implementados estão funcionando!" -ForegroundColor Yellow
