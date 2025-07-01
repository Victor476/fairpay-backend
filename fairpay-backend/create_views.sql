-- ================================================================
-- FAIRPAY VIEWS - CRIAÇÃO APÓS INICIALIZAÇÃO DO HIBERNATE
-- Sistema de Divisão de Despesas Compartilhadas
-- ================================================================

-- Remover views existentes (se houverem)
DROP VIEW IF EXISTS user_balances CASCADE;
DROP VIEW IF EXISTS group_summary CASCADE;

-- ================================================================
-- VIEWS ÚTEIS PARA CONSULTAS
-- ================================================================

-- View para saldos dos usuários por grupo
CREATE VIEW user_balances AS
SELECT 
    gm.group_id,
    gm.user_id,
    u.name as user_name,
    u.email as user_email,
    COALESCE(paid.total_paid, 0) as total_paid,
    COALESCE(owes.total_owes, 0) as total_owes,
    COALESCE(paid.total_paid, 0) - COALESCE(owes.total_owes, 0) as balance
FROM group_members gm
JOIN users u ON gm.user_id = u.id
LEFT JOIN (
    SELECT group_id, paid_by_user_id, SUM(amount) as total_paid
    FROM expenses 
    GROUP BY group_id, paid_by_user_id
) paid ON gm.group_id = paid.group_id AND gm.user_id = paid.paid_by_user_id
LEFT JOIN (
    SELECT e.group_id, ep.user_id, SUM(ep.share) as total_owes
    FROM expense_participants ep
    JOIN expenses e ON ep.expense_id = e.id
    GROUP BY e.group_id, ep.user_id
) owes ON gm.group_id = owes.group_id AND gm.user_id = owes.user_id
WHERE gm.is_active = true;

-- View para resumo de grupos
CREATE VIEW group_summary AS
SELECT 
    g.id,
    g.name,
    g.description,
    COUNT(DISTINCT gm.user_id) as member_count,
    COUNT(DISTINCT e.id) as expense_count,
    COALESCE(SUM(e.amount), 0) as total_expenses,
    g.created_at
FROM groups g
LEFT JOIN group_members gm ON g.id = gm.group_id AND gm.is_active = true
LEFT JOIN expenses e ON g.id = e.group_id
WHERE g.is_active = true
GROUP BY g.id, g.name, g.description, g.created_at;

-- ================================================================
-- COMENTÁRIOS FINAIS
-- ================================================================

-- Views criadas:
-- ✅ user_balances - Saldos dos usuários por grupo
-- ✅ group_summary - Resumo dos grupos com estatísticas

SELECT 'Views criadas com sucesso!' as status;
