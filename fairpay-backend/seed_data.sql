-- ================================================================
-- ARQUIVO DE SEMENTE PARA TESTES - FAIRPAY
-- Popula o banco com dados realistas para facilitar os testes
-- ================================================================

-- IMPORTANTE: Execute apenas APÓS criar o banco com o script principal
-- Este arquivo deve ser executado conectado ao banco 'fairpay_db'

-- ================================================================
-- LIMPAR DADOS EXISTENTES (OPCIONAL)
-- ================================================================

-- Descomente as linhas abaixo se quiser limpar dados existentes
-- TRUNCATE TABLE expense_participants, expenses, payments, group_members, group_invite_links, groups, user_roles, users RESTART IDENTITY CASCADE;

-- ================================================================
-- USUÁRIOS DE TESTE
-- ================================================================

-- Inserir usuários (senhas são 'password123' com hash bcrypt)
INSERT INTO users (name, email, password_hash, phone, email_verified, is_active) VALUES
('João Silva', 'joao@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-1111', true, true),
('Maria Santos', 'maria@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-2222', true, true),
('Pedro Costa', 'pedro@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-3333', true, true),
('Ana Lima', 'ana@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-4444', true, true),
('Carlos Oliveira', 'carlos@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-5555', true, true),
('Julia Ferreira', 'julia@teste.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTUW8u6rjBbsttMwi5HdoW.bJYYYQh9y', '(11) 99999-6666', true, true);

-- ================================================================
-- ASSOCIAR ROLES AOS USUÁRIOS
-- ================================================================

-- João como admin, outros como usuários normais
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- João = ADMIN
(2, 2), -- Maria = USER
(3, 2), -- Pedro = USER
(4, 2), -- Ana = USER
(5, 2), -- Carlos = USER
(6, 2); -- Julia = USER

-- ================================================================
-- GRUPOS DE TESTE
-- ================================================================

INSERT INTO groups (name, description, created_by_id, currency) VALUES
('Apartamento 101', 'Divisão de gastos do apartamento compartilhado', 1, 'BRL'),
('Viagem para Ubatuba', 'Gastos da viagem de fim de semana', 2, 'BRL'),
('Casa da Praia', 'Aluguel e gastos da casa de veraneio', 3, 'BRL'),
('Escritório Compartilhado', 'Despesas do coworking', 1, 'BRL'),
('Festa de Aniversário', 'Organização da festa da Maria', 2, 'BRL');

-- ================================================================
-- MEMBROS DOS GRUPOS
-- ================================================================

-- Apartamento 101 (João, Maria, Pedro)
INSERT INTO group_members (user_id, group_id, role) VALUES
(1, 1, 'admin'),   -- João criador
(2, 1, 'member'),  -- Maria
(3, 1, 'member');  -- Pedro

-- Viagem para Ubatuba (Maria, Ana, Julia, Carlos)
INSERT INTO group_members (user_id, group_id, role) VALUES
(2, 2, 'admin'),   -- Maria criadora
(4, 2, 'member'),  -- Ana
(6, 2, 'member'),  -- Julia
(5, 2, 'member');  -- Carlos

-- Casa da Praia (Pedro, João, Ana)
INSERT INTO group_members (user_id, group_id, role) VALUES
(3, 3, 'admin'),   -- Pedro criador
(1, 3, 'member'),  -- João
(4, 3, 'member');  -- Ana

-- Escritório Compartilhado (João, Carlos, Julia)
INSERT INTO group_members (user_id, group_id, role) VALUES
(1, 4, 'admin'),   -- João criador
(5, 4, 'member'),  -- Carlos
(6, 4, 'member');  -- Julia

-- Festa de Aniversário (Maria, Pedro, Ana, Carlos, Julia)
INSERT INTO group_members (user_id, group_id, role) VALUES
(2, 5, 'admin'),   -- Maria criadora
(3, 5, 'member'),  -- Pedro
(4, 5, 'member'),  -- Ana
(5, 5, 'member'),  -- Carlos
(6, 5, 'member');  -- Julia

-- ================================================================
-- DESPESAS DE TESTE
-- ================================================================

-- Despesas do Apartamento 101
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount, expense_date, created_by_id) VALUES
(1, 1, 3, 'Aluguel de Junho', 1500.00, '2025-06-01', 1),
(1, 2, 1, 'Compras do mercado', 280.50, '2025-06-15', 2),
(1, 3, 8, 'Conta de luz', 145.75, '2025-06-20', 3),
(1, 1, 8, 'Internet', 120.00, '2025-06-25', 1),
(1, 2, 1, 'Jantar delivery', 85.40, '2025-06-28', 2);

-- Despesas da Viagem para Ubatuba
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount, expense_date, created_by_id) VALUES
(2, 2, 3, 'Aluguel da casa', 800.00, '2025-06-10', 2),
(2, 4, 2, 'Combustível', 250.00, '2025-06-10', 4),
(2, 6, 1, 'Churrasco', 320.00, '2025-06-11', 6),
(2, 5, 4, 'Passeio de barco', 480.00, '2025-06-12', 5),
(2, 2, 1, 'Café da manhã', 150.00, '2025-06-13', 2);

-- Despesas da Casa da Praia
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount, expense_date, created_by_id) VALUES
(3, 3, 3, 'Condomínio', 350.00, '2025-06-01', 3),
(3, 1, 8, 'Limpeza', 200.00, '2025-06-05', 1),
(3, 4, 7, 'Compras para casa', 180.50, '2025-06-10', 4);

-- Despesas do Escritório
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount, expense_date, created_by_id) VALUES
(4, 1, 8, 'Aluguel coworking', 600.00, '2025-06-01', 1),
(4, 5, 1, 'Café e água', 95.00, '2025-06-15', 5),
(4, 6, 7, 'Material de escritório', 150.00, '2025-06-20', 6);

-- Despesas da Festa
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount, expense_date, created_by_id) VALUES
(5, 2, 1, 'Buffet', 850.00, '2025-06-25', 2),
(5, 3, 4, 'Decoração', 200.00, '2025-06-24', 3),
(5, 4, 1, 'Bebidas', 180.00, '2025-06-25', 4),
(5, 5, 4, 'Som e DJ', 300.00, '2025-06-25', 5);

-- ================================================================
-- PARTICIPANTES DAS DESPESAS (DIVISÃO IGUALITÁRIA)
-- ================================================================

-- Apartamento 101 - Aluguel (3 pessoas: João, Maria, Pedro)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(1, 1, 500.00), (1, 2, 500.00), (1, 3, 500.00);

-- Apartamento 101 - Mercado (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(2, 1, 93.50), (2, 2, 93.50), (2, 3, 93.50);

-- Apartamento 101 - Luz (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(3, 1, 48.58), (3, 2, 48.58), (3, 3, 48.59);

-- Apartamento 101 - Internet (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(4, 1, 40.00), (4, 2, 40.00), (4, 3, 40.00);

-- Apartamento 101 - Jantar (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(5, 1, 28.47), (5, 2, 28.47), (5, 3, 28.46);

-- Viagem Ubatuba - Aluguel (4 pessoas: Maria, Ana, Julia, Carlos)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(6, 2, 200.00), (6, 4, 200.00), (6, 6, 200.00), (6, 5, 200.00);

-- Viagem Ubatuba - Combustível (4 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(7, 2, 62.50), (7, 4, 62.50), (7, 6, 62.50), (7, 5, 62.50);

-- Viagem Ubatuba - Churrasco (4 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(8, 2, 80.00), (8, 4, 80.00), (8, 6, 80.00), (8, 5, 80.00);

-- Viagem Ubatuba - Passeio (4 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(9, 2, 120.00), (9, 4, 120.00), (9, 6, 120.00), (9, 5, 120.00);

-- Viagem Ubatuba - Café (4 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(10, 2, 37.50), (10, 4, 37.50), (10, 6, 37.50), (10, 5, 37.50);

-- Casa da Praia - Condomínio (3 pessoas: Pedro, João, Ana)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(11, 3, 116.67), (11, 1, 116.67), (11, 4, 116.66);

-- Casa da Praia - Limpeza (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(12, 3, 66.67), (12, 1, 66.67), (12, 4, 66.66);

-- Casa da Praia - Compras (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(13, 3, 60.17), (13, 1, 60.17), (13, 4, 60.16);

-- Escritório - Aluguel (3 pessoas: João, Carlos, Julia)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(14, 1, 200.00), (14, 5, 200.00), (14, 6, 200.00);

-- Escritório - Café (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(15, 1, 31.67), (15, 5, 31.67), (15, 6, 31.66);

-- Escritório - Material (3 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(16, 1, 50.00), (16, 5, 50.00), (16, 6, 50.00);

-- Festa - Buffet (5 pessoas: Maria, Pedro, Ana, Carlos, Julia)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(17, 2, 170.00), (17, 3, 170.00), (17, 4, 170.00), (17, 5, 170.00), (17, 6, 170.00);

-- Festa - Decoração (5 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(18, 2, 40.00), (18, 3, 40.00), (18, 4, 40.00), (18, 5, 40.00), (18, 6, 40.00);

-- Festa - Bebidas (5 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(19, 2, 36.00), (19, 3, 36.00), (19, 4, 36.00), (19, 5, 36.00), (19, 6, 36.00);

-- Festa - Som (5 pessoas)
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(20, 2, 60.00), (20, 3, 60.00), (20, 4, 60.00), (20, 5, 60.00), (20, 6, 60.00);

-- ================================================================
-- ALGUNS PAGAMENTOS DE EXEMPLO
-- ================================================================

INSERT INTO payments (group_id, from_user_id, to_user_id, amount, description, payment_method, status, confirmed_by_receiver) VALUES
(1, 2, 1, 500.00, 'Pagamento da parte do aluguel', 'pix', 'confirmed', true),
(1, 3, 1, 450.00, 'Parte das despesas de junho', 'transferencia', 'confirmed', true),
(2, 4, 2, 300.00, 'Parte da viagem', 'pix', 'confirmed', true),
(2, 5, 2, 250.00, 'Gastos da viagem', 'dinheiro', 'pending', false),
(3, 1, 3, 150.00, 'Despesas da casa', 'pix', 'confirmed', true);

-- ================================================================
-- LINKS DE CONVITE ATIVOS
-- ================================================================

INSERT INTO group_invite_links (token, group_id, created_by_id, max_uses, expires_at) VALUES
('convite-apartamento-123', 1, 1, 5, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('convite-viagem-456', 2, 2, 3, CURRENT_TIMESTAMP + INTERVAL '7 days'),
('convite-escritorio-789', 4, 1, 10, CURRENT_TIMESTAMP + INTERVAL '60 days');

-- ================================================================
-- NOTIFICAÇÕES DE EXEMPLO
-- ================================================================

INSERT INTO notifications (user_id, type, title, message, related_expense_id, related_group_id) VALUES
(2, 'new_expense', 'Nova despesa adicionada', 'João adicionou uma despesa de R$ 120,00 para Internet no grupo Apartamento 101', 4, 1),
(3, 'new_expense', 'Nova despesa adicionada', 'João adicionou uma despesa de R$ 120,00 para Internet no grupo Apartamento 101', 4, 1),
(1, 'payment_received', 'Pagamento recebido', 'Maria confirmou o pagamento de R$ 500,00 referente ao aluguel', null, 1),
(2, 'debt_reminder', 'Lembrete de pagamento', 'Você tem R$ 150,00 pendentes no grupo Apartamento 101', null, 1);

-- ================================================================
-- TOKENS DE REFRESH ATIVOS
-- ================================================================

INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES
(1, 'refresh_token_joao_' || extract(epoch from now()), CURRENT_TIMESTAMP + INTERVAL '7 days'),
(2, 'refresh_token_maria_' || extract(epoch from now()), CURRENT_TIMESTAMP + INTERVAL '7 days'),
(3, 'refresh_token_pedro_' || extract(epoch from now()), CURRENT_TIMESTAMP + INTERVAL '7 days');

-- ================================================================
-- LOGS DE AUDITORIA
-- ================================================================

INSERT INTO audit_logs (user_id, entity_type, entity_id, action, new_values, ip_address) VALUES
(1, 'group', 1, 'create', '{"name": "Apartamento 101", "description": "Divisão de gastos do apartamento"}', '127.0.0.1'),
(2, 'expense', 2, 'create', '{"description": "Compras do mercado", "amount": 280.50}', '127.0.0.1'),
(1, 'payment', 1, 'create', '{"amount": 500.00, "description": "Pagamento da parte do aluguel"}', '127.0.0.1');

-- ================================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- ================================================================

-- Verificações finais
SELECT 'Dados inseridos com sucesso!' as status;
SELECT COUNT(*) as total_usuarios FROM users;
SELECT COUNT(*) as total_grupos FROM groups;
SELECT COUNT(*) as total_despesas FROM expenses;
SELECT COUNT(*) as total_pagamentos FROM payments;

-- Mostrar saldos por grupo
SELECT 
    g.name as grupo,
    u.name as usuario,
    ub.balance as saldo
FROM user_balances ub
JOIN groups g ON ub.group_id = g.id
JOIN users u ON ub.user_id = u.id
ORDER BY g.name, u.name;

COMMIT;
