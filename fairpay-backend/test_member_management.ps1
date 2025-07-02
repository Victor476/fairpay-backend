# Teste dos novos endpoints de gerenciamento de membros
# Executar este script após criar um grupo e ter usuários para testar

$baseUrl = "http://localhost:8080"

# Variáveis - ajustar conforme necessário
$authToken = ""  # Token de um usuário admin
$groupId = ""    # ID do grupo para testar
$userIdToAdd = ""  # ID do usuário para adicionar/alterar papel

# Headers
$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $authToken"
}

Write-Host "=== TESTE: ADICIONAR MEMBRO AO GRUPO ===" -ForegroundColor Green

# 1. Adicionar membro como 'member'
$addMemberBody = @{
    userId = $userIdToAdd
    role = "member"
} | ConvertTo-Json

Write-Host "Adicionando membro com papel 'member'..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method POST -Headers $headers -Body $addMemberBody
    Write-Host "✅ Membro adicionado com sucesso:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro ao adicionar membro:" -ForegroundColor Red
    $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n=== TESTE: ALTERAR PAPEL DO MEMBRO ===" -ForegroundColor Green

# 2. Promover membro para admin
$updateRoleBody = @{
    role = "admin"
} | ConvertTo-Json

Write-Host "Promovendo membro para admin..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$userIdToAdd" -Method PUT -Headers $headers -Body $updateRoleBody
    Write-Host "✅ Papel alterado com sucesso:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro ao alterar papel:" -ForegroundColor Red
    $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n=== TESTE: VERIFICAR MEMBROS DO GRUPO ===" -ForegroundColor Green

# 3. Listar membros para verificar alterações
Write-Host "Listando membros do grupo..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method GET -Headers $headers
    Write-Host "✅ Membros do grupo:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro ao listar membros:" -ForegroundColor Red
    $_.Exception.Message
}

Write-Host "`n=== TESTE: REBAIXAR ADMIN PARA MEMBER ===" -ForegroundColor Green

# 4. Rebaixar admin para member
$demoteRoleBody = @{
    role = "member"
} | ConvertTo-Json

Write-Host "Rebaixando admin para member..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$userIdToAdd" -Method PUT -Headers $headers -Body $demoteRoleBody
    Write-Host "✅ Papel alterado com sucesso:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro ao alterar papel:" -ForegroundColor Red
    $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n=== TESTE: TESTES DE VALIDAÇÃO ===" -ForegroundColor Yellow

# 5. Testar validações - adicionar membro que já existe
Write-Host "Testando: adicionar membro que já existe..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members" -Method POST -Headers $headers -Body $addMemberBody
    Write-Host "⚠️  Deveria ter dado erro, mas retornou:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "✅ Erro esperado capturado:" -ForegroundColor Green
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

# 6. Testar papel inválido
Write-Host "`nTestando: papel inválido..."
$invalidRoleBody = @{
    role = "invalid_role"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/groups/$groupId/members/$userIdToAdd" -Method PUT -Headers $headers -Body $invalidRoleBody
    Write-Host "⚠️  Deveria ter dado erro, mas retornou:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "✅ Erro esperado capturado:" -ForegroundColor Green
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n=== TESTE CONCLUÍDO ===" -ForegroundColor Cyan
Write-Host "Lembre-se de:"
Write-Host "1. Definir as variáveis no início do script"
Write-Host "2. Ter um token válido de um usuário admin"
Write-Host "3. Ter um grupo existente e usuário para adicionar"
Write-Host "4. Verificar os logs do backend para detalhes"
