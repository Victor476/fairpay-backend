# Teste direto da API
Write-Host "🧪 TESTE DIRETO DA API" -ForegroundColor Green

# Login
$loginData = @{
    email = "victor@teste.com"
    password = "senha123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8090/api/auth/login" -Method POST -Body $loginData -ContentType "application/json; charset=utf-8"
    Write-Host "✅ Login funcionou!" -ForegroundColor Green
    
    $token = $response.accessToken
    if ($token) {
        Write-Host "✅ Token obtido: $($token.Substring(0,20))..." -ForegroundColor Green
        
        # Headers
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json; charset=utf-8"
        }
        
        # Teste 1: GET Profile
        try {
            $profile = Invoke-RestMethod -Uri "http://localhost:8090/api/users/me" -Method GET -Headers $headers
            Write-Host "✅ GET Profile: $($profile.name) - $($profile.email)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erro GET Profile: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Teste 2: GET Groups
        try {
            $groups = Invoke-RestMethod -Uri "http://localhost:8090/api/groups" -Method GET -Headers $headers
            Write-Host "✅ GET Groups: $($groups.Count) grupos encontrados" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erro GET Groups: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Teste 3: GET Group Members (se houver grupo)
        if ($groups -and $groups.Count -gt 0) {
            try {
                $groupId = $groups[0].id
                $members = Invoke-RestMethod -Uri "http://localhost:8090/api/groups/$groupId/members" -Method GET -Headers $headers
                Write-Host "✅ GET Members: $($members.Count) membros no grupo $groupId" -ForegroundColor Green
                
                # Mostrar detalhes dos membros para verificar encoding
                foreach ($member in $members) {
                    Write-Host "   - $($member.userName) ($($member.role))" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "❌ Erro GET Members: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
    } else {
        Write-Host "❌ Token não encontrado na resposta" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "🏁 TESTE DIRETO CONCLUÍDO" -ForegroundColor Green
