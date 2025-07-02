# Script para testar novos endpoints de Usuario e Grupo
param([string]$BaseUrl = "http://localhost:8090")

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🧪 Testando Novos Endpoints - CRUDs de Usuário e Grupo" -ForegroundColor Cyan
Write-Host "=" * 60

# Função para testar endpoint
function Test-Endpoint {
    param($Method, $Url, $Body, $Headers, $Description)
    
    Write-Host "`n🔍 $Description" -ForegroundColor Yellow
    Write-Host "   $Method $Url" -ForegroundColor Gray
    
    try {
        if ($Body) {
            Write-Host "   Body: $Body" -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $Body -Headers $Headers
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers
        }
        
        Write-Host "✅ Sucesso!" -ForegroundColor Green
        Write-Host "   Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
        return $response
    }
    catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host "   Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        return $null
    }
}

# 1. Registrar usuário de teste
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testUser = @{
    name = "Teste User $timestamp"
    email = "testuser$timestamp@test.com"
    password = "123456"
    confirmPassword = "123456"
} | ConvertTo-Json

$userResponse = Test-Endpoint -Method "POST" -Url "$BaseUrl/api/auth/register" -Body $testUser -Headers @{"Content-Type" = "application/json"} -Description "1. Registrando usuário de teste"

if (-not $userResponse) {
    Write-Host "❌ Falha no registro. Encerrando teste." -ForegroundColor Red
    exit 1
}

# 2. Fazer login
$loginData = @{
    email = "testuser$timestamp@test.com"
    password = "123456"
} | ConvertTo-Json

$loginResponse = Test-Endpoint -Method "POST" -Url "$BaseUrl/api/auth/login" -Body $loginData -Headers @{"Content-Type" = "application/json"} -Description "2. Fazendo login"

if (-not $loginResponse -or -not $loginResponse.accessToken) {
    Write-Host "❌ Falha no login. Encerrando teste." -ForegroundColor Red
    exit 1
}

$token = $loginResponse.accessToken
$authHeaders = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`n🎯 Testando Endpoints de USUÁRIO" -ForegroundColor Magenta
Write-Host "-" * 40

# 3. Testar GET /api/users/me
$meResponse = Test-Endpoint -Method "GET" -Url "$BaseUrl/api/users/me" -Headers $authHeaders -Description "3. Obter dados do usuário atual"

# 4. Testar PUT /api/users/me (editar perfil)
$updateProfileData = @{
    name = "Nome Atualizado $timestamp"
    email = "testuser$timestamp@test.com"
    phoneNumber = "(11) 99999-9999"
} | ConvertTo-Json

$updateResponse = Test-Endpoint -Method "PUT" -Url "$BaseUrl/api/users/me" -Body $updateProfileData -Headers $authHeaders -Description "4. Atualizar perfil do usuário"

# 5. Testar PUT /api/users/me/password (alterar senha)
$changePasswordData = @{
    currentPassword = "123456"
    newPassword = "novaSenha123"
    confirmNewPassword = "novaSenha123"
} | ConvertTo-Json

$passwordResponse = Test-Endpoint -Method "PUT" -Url "$BaseUrl/api/users/me/password" -Body $changePasswordData -Headers $authHeaders -Description "5. Alterar senha do usuário"

Write-Host "`n🎯 Testando Endpoints de GRUPO" -ForegroundColor Magenta
Write-Host "-" * 40

# 6. Criar grupo para testes
$groupData = @{
    name = "Grupo Teste $timestamp"
    description = "Grupo criado para testar novos endpoints"
} | ConvertTo-Json

$groupResponse = Test-Endpoint -Method "POST" -Url "$BaseUrl/api/groups" -Body $groupData -Headers $authHeaders -Description "6. Criar grupo de teste"

if (-not $groupResponse) {
    Write-Host "❌ Falha ao criar grupo. Pulando testes de grupo." -ForegroundColor Red
} else {
    $groupId = $groupResponse.id
    
    # 7. Testar GET /api/groups/{groupId} (detalhes do grupo)
    $groupDetailsResponse = Test-Endpoint -Method "GET" -Url "$BaseUrl/api/groups/$groupId" -Headers $authHeaders -Description "7. Obter detalhes do grupo"
    
    # 8. Testar PUT /api/groups/{groupId} (editar grupo)
    $updateGroupData = @{
        name = "Grupo Atualizado $timestamp"
        description = "Descrição atualizada do grupo"
    } | ConvertTo-Json
    
    $updateGroupResponse = Test-Endpoint -Method "PUT" -Url "$BaseUrl/api/groups/$groupId" -Body $updateGroupData -Headers $authHeaders -Description "8. Atualizar informações do grupo"
    
    # 9. Testar GET /api/groups/{groupId}/members (já existente, mas confirmar)
    $membersResponse = Test-Endpoint -Method "GET" -Url "$BaseUrl/api/groups/$groupId/members" -Headers $authHeaders -Description "9. Listar membros do grupo"
    
    # 10. Testar DELETE /api/groups/{groupId} (excluir grupo)
    $deleteGroupResponse = Test-Endpoint -Method "DELETE" -Url "$BaseUrl/api/groups/$groupId" -Headers $authHeaders -Description "10. Excluir grupo"
}

Write-Host "`n🎯 Testando Endpoints com Permissões" -ForegroundColor Magenta
Write-Host "-" * 40

# 11. Criar segundo usuário para testes de permissão
$testUser2 = @{
    name = "Teste User 2 $timestamp"
    email = "testuser2$timestamp@test.com"
    password = "123456"
    confirmPassword = "123456"
} | ConvertTo-Json

$user2Response = Test-Endpoint -Method "POST" -Url "$BaseUrl/api/auth/register" -Body $testUser2 -Headers @{"Content-Type" = "application/json"} -Description "11. Registrando segundo usuário"

if ($user2Response) {
    # 12. Testar GET /api/users/{userId} (perfil público)
    $publicProfileResponse = Test-Endpoint -Method "GET" -Url "$BaseUrl/api/users/$($user2Response.user.id)" -Headers $authHeaders -Description "12. Obter perfil público de outro usuário"
}

Write-Host "`n📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host "✅ Registro de usuário: OK" -ForegroundColor Green
Write-Host "✅ Login: OK" -ForegroundColor Green

if ($meResponse) { Write-Host "✅ GET /api/users/me: OK" -ForegroundColor Green } else { Write-Host "❌ GET /api/users/me: FALHOU" -ForegroundColor Red }
if ($updateResponse) { Write-Host "✅ PUT /api/users/me: OK" -ForegroundColor Green } else { Write-Host "❌ PUT /api/users/me: FALHOU" -ForegroundColor Red }
if ($passwordResponse) { Write-Host "✅ PUT /api/users/me/password: OK" -ForegroundColor Green } else { Write-Host "❌ PUT /api/users/me/password: FALHOU" -ForegroundColor Red }

if ($groupResponse) { Write-Host "✅ POST /api/groups: OK" -ForegroundColor Green } else { Write-Host "❌ POST /api/groups: FALHOU" -ForegroundColor Red }
if ($groupDetailsResponse) { Write-Host "✅ GET /api/groups/{id}: OK" -ForegroundColor Green } else { Write-Host "❌ GET /api/groups/{id}: FALHOU" -ForegroundColor Red }
if ($updateGroupResponse) { Write-Host "✅ PUT /api/groups/{id}: OK" -ForegroundColor Green } else { Write-Host "❌ PUT /api/groups/{id}: FALHOU" -ForegroundColor Red }
if ($deleteGroupResponse) { Write-Host "✅ DELETE /api/groups/{id}: OK" -ForegroundColor Green } else { Write-Host "❌ DELETE /api/groups/{id}: FALHOU" -ForegroundColor Red }

if ($publicProfileResponse) { Write-Host "✅ GET /api/users/{id}: OK" -ForegroundColor Green } else { Write-Host "❌ GET /api/users/{id}: FALHOU" -ForegroundColor Red }

Write-Host "`n🎉 Teste dos novos CRUDs concluído!" -ForegroundColor Cyan
