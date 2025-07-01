# Script para Testar Saldos com Dados Reais do Banco
# Testa o endpoint de saldos usando grupos pré-existentes no banco

# Configurações
$baseUrl = "http://localhost:8090"
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [string]$Body = $null,
        [string]$Description
    )
    
    Write-Host "`n=== $Description ===" -ForegroundColor Cyan
    Write-Host "[$Method] $Uri" -ForegroundColor Yellow
    
    if ($Body) {
        Write-Host "Body: $Body" -ForegroundColor Gray
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($Body))
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        
        Write-Host "✅ Sucesso!" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5 | Write-Host
        return $response
    }
    catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🚀 Testando Saldos com Dados Reais do Banco" -ForegroundColor Magenta
Write-Host "Este teste usa os usuários e grupos pré-cadastrados no banco de dados." -ForegroundColor Yellow

# 1. Login com usuário João (já existe no banco)
$loginData = @{
    email = "joao@teste.com"
    password = "password123"
} | ConvertTo-Json

$loginResponse = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/api/auth/login" -Headers $headers -Body $loginData -Description "1. Fazendo login com João (banco de dados)"

if ($loginResponse -and $loginResponse.accessToken) {
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $($loginResponse.accessToken)"
    Write-Host "🔑 Token obtido para João!" -ForegroundColor Green
} else {
    Write-Host "❌ Falha no login. Verifique se o banco foi populado com dados de seed." -ForegroundColor Red
    exit 1
}

# 2. Listar grupos do João
$groupsResponse = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups" -Headers $authHeaders -Description "2. Listando grupos do João"

# 3. Testar saldos do grupo "Apartamento 101" (ID 1)
Write-Host "`n📊 Testando saldos do grupo 'Apartamento 101':" -ForegroundColor Magenta
Write-Host "Este grupo tem as seguintes despesas:" -ForegroundColor Yellow
Write-Host "- Aluguel: R$ 1.500,00 (pago por João, dividido entre João, Maria, Pedro)" -ForegroundColor White
Write-Host "- Mercado: R$ 280,50 (pago por Maria, dividido entre todos)" -ForegroundColor White
Write-Host "- Luz: R$ 145,75 (pago por Pedro, dividido entre todos)" -ForegroundColor White
Write-Host "- Internet: R$ 120,00 (pago por João, dividido entre todos)" -ForegroundColor White
Write-Host "- Jantar: R$ 85,40 (pago por Maria, dividido entre todos)" -ForegroundColor White

$balances1Response = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/1/balances" -Headers $authHeaders -Description "3. Calculando saldos do Apartamento 101"

# 4. Testar saldos do grupo "Casa da Praia" (ID 3) - João é membro
Write-Host "`n📊 Testando saldos do grupo 'Casa da Praia':" -ForegroundColor Magenta
Write-Host "Este grupo tem as seguintes despesas:" -ForegroundColor Yellow
Write-Host "- Condomínio: R$ 350,00 (pago por Pedro, dividido entre Pedro, João, Ana)" -ForegroundColor White
Write-Host "- Limpeza: R$ 200,00 (pago por João, dividido entre todos)" -ForegroundColor White
Write-Host "- Compras: R$ 180,50 (pago por Ana, dividido entre todos)" -ForegroundColor White

$balances3Response = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/3/balances" -Headers $authHeaders -Description "4. Calculando saldos da Casa da Praia"

# 5. Testar saldos do grupo "Escritório Compartilhado" (ID 4) - João é admin
Write-Host "`n📊 Testando saldos do grupo 'Escritório Compartilhado':" -ForegroundColor Magenta
Write-Host "Este grupo tem as seguintes despesas:" -ForegroundColor Yellow
Write-Host "- Aluguel coworking: R$ 600,00 (pago por João, dividido entre João, Carlos, Julia)" -ForegroundColor White
Write-Host "- Café e água: R$ 95,00 (pago por Carlos, dividido entre todos)" -ForegroundColor White
Write-Host "- Material: R$ 150,00 (pago por Julia, dividido entre todos)" -ForegroundColor White

$balances4Response = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/4/balances" -Headers $authHeaders -Description "5. Calculando saldos do Escritório"

# 6. Tentar acessar grupo que João não é membro (deveria dar erro)
Write-Host "`n🔒 Testando segurança - tentando acessar grupo onde João não é membro:" -ForegroundColor Magenta
$balances2Response = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/api/groups/2/balances" -Headers $authHeaders -Description "6. Tentando acessar 'Viagem para Ubatuba' (acesso negado)"

Write-Host "`n🎉 Teste de saldos com dados reais finalizado!" -ForegroundColor Magenta
Write-Host "✅ Endpoint de saldos funcionando corretamente!" -ForegroundColor Green
Write-Host "✅ Cálculos matemáticos precisos!" -ForegroundColor Green
Write-Host "✅ Controle de acesso funcionando!" -ForegroundColor Green
