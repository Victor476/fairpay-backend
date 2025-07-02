# Script de debug para investigar os erros 500
$baseUrl = "http://localhost:8090"

Write-Host "🔍 DEBUG DOS ERROS 500" -ForegroundColor Red

$headers = @{
    "Content-Type" = "application/json"
}

# Login
$loginData = @{
    email = "victor@teste.com"
    password = "password123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Headers $headers -Body $loginData
$authHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $($loginResponse.accessToken)"
}

Write-Host "✅ Login realizado. Investigando erros..." -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🔍 ERRO 1: PUT /api/users/me/password" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Primeiro, vamos obter os dados do usuário atual
Write-Host "`n1. Obtendo dados atuais do usuário..." -ForegroundColor Yellow
try {
    $currentUser = Invoke-RestMethod -Uri "$baseUrl/api/users/me" -Method GET -Headers $authHeaders
    Write-Host "✅ Usuário atual:" -ForegroundColor Green
    Write-Host "   ID: $($currentUser.id)" -ForegroundColor Gray
    Write-Host "   Nome: $($currentUser.name)" -ForegroundColor Gray
    Write-Host "   Email: $($currentUser.email)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao obter dados do usuário" -ForegroundColor Red
    exit 1
}

# Testar alteração de senha com dados mínimos
Write-Host "`n2. Testando alteração de senha com dados básicos..." -ForegroundColor Yellow
$passwordData1 = @{
    currentPassword = "password123"
    newPassword = "newpass123"
} | ConvertTo-Json

Write-Host "Payload:" -ForegroundColor Gray
Write-Host $passwordData1 -ForegroundColor Gray

try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $passwordData1
    Write-Host "✅ Alteração de senha funcionou!" -ForegroundColor Green
    
    # Reverter
    $revertData = @{
        currentPassword = "newpass123"
        newPassword = "password123"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$baseUrl/api/users/me/password" -Method PUT -Headers $authHeaders -Body $revertData | Out-Null
    Write-Host "✅ Senha revertida" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO na alteração de senha:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta completa:" -ForegroundColor Yellow
        Write-Host $responseBody -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🔍 ERRO 2: PUT /api/groups/{groupId}" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Obter grupos do usuário
Write-Host "`n1. Obtendo grupos do usuário..." -ForegroundColor Yellow
try {
    $groups = Invoke-RestMethod -Uri "$baseUrl/api/groups" -Method GET -Headers $authHeaders
    if ($groups.Count -gt 0) {
        $groupId = $groups[0].id
        Write-Host "✅ Grupo encontrado: ID $groupId" -ForegroundColor Green
        Write-Host "   Nome atual: $($groups[0].name)" -ForegroundColor Gray
        Write-Host "   Descrição atual: $($groups[0].description)" -ForegroundColor Gray
        
        # Obter detalhes completos do grupo
        Write-Host "`n2. Obtendo detalhes completos do grupo..." -ForegroundColor Yellow
        try {
            $groupDetails = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method GET -Headers $authHeaders
            Write-Host "✅ Detalhes obtidos:" -ForegroundColor Green
            Write-Host "   Criado por ID: $($groupDetails.createdBy.id)" -ForegroundColor Gray
            Write-Host "   Usuário atual ID: $($currentUser.id)" -ForegroundColor Gray
            Write-Host "   É o criador? $($groupDetails.createdBy.id -eq $currentUser.id)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erro ao obter detalhes do grupo" -ForegroundColor Red
        }
        
        # Testar atualização com dados mínimos
        Write-Host "`n3. Testando atualização com dados básicos..." -ForegroundColor Yellow
        $updateData1 = @{
            name = "Teste Update $(Get-Date -Format 'HHmmss')"
            description = "Teste de atualização"
        } | ConvertTo-Json
        
        Write-Host "Payload:" -ForegroundColor Gray
        Write-Host $updateData1 -ForegroundColor Gray
        
        try {
            $updated = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId" -Method PUT -Headers $authHeaders -Body $updateData1
            Write-Host "✅ Atualização do grupo funcionou!" -ForegroundColor Green
            Write-Host "   Novo nome: $($updated.name)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ ERRO na atualização do grupo:" -ForegroundColor Red
            Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Resposta completa:" -ForegroundColor Yellow
                Write-Host $responseBody -ForegroundColor Yellow
            }
        }
        
    } else {
        Write-Host "❌ Nenhum grupo encontrado para testar" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao obter grupos" -ForegroundColor Red
}

Write-Host "`n🔍 DEBUG CONCLUÍDO!" -ForegroundColor Cyan
