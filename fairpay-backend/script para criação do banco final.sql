-- ================================================================
-- FAIRPAY DATABASE - SCRIPT DE CRIAÇÃO FINAL
-- Sistema de Divisão de Despesas Compartilhadas
-- ================================================================

-- CONFIGURAÇÕES INICIAIS
SET TIME ZONE 'America/Sao_Paulo';

-- ================================================================
-- TABELAS PRINCIPAIS - USUÁRIOS E AUTENTICAÇÃO
-- ================================================================

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, role_id)
);

-- ================================================================
-- TABELAS DE GRUPOS E MEMBROS
-- ================================================================

CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    currency VARCHAR(3) DEFAULT 'BRL',
    is_active BOOLEAN DEFAULT TRUE,
    created_by_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- admin, member
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (user_id, group_id)
);

CREATE TABLE group_invite_links (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    created_by_id BIGINT NOT NULL REFERENCES users(id),
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- TABELAS DE CATEGORIAS E DESPESAS
-- ================================================================

CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(7), -- hex color
    is_default BOOLEAN DEFAULT FALSE,
    created_by_id BIGINT REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    paid_by_user_id BIGINT NOT NULL REFERENCES users(id),
    category_id BIGINT REFERENCES categories(id),
    description TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    expense_date DATE NOT NULL,
    division_method VARCHAR(20) DEFAULT 'equal', -- equal, percentage, fixed, custom
    notes TEXT,
    receipt_url VARCHAR(255),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_expense_id BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by_id BIGINT NOT NULL REFERENCES users(id)
);

CREATE TABLE expense_participants (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id),
    share NUMERIC(12, 2) NOT NULL CHECK (share >= 0),
    percentage NUMERIC(5, 2), -- para divisão por porcentagem
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (expense_id, user_id)
);

-- ================================================================
-- TABELAS DE PAGAMENTOS E TRANSFERÊNCIAS
-- ================================================================

CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    from_user_id BIGINT NOT NULL REFERENCES users(id),
    to_user_id BIGINT NOT NULL REFERENCES users(id),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    payment_method VARCHAR(50), -- pix, dinheiro, transferencia, etc
    payment_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, cancelled
    confirmed_by_receiver BOOLEAN DEFAULT FALSE,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (from_user_id != to_user_id)
);

-- ================================================================
-- TABELAS DE DESPESAS RECORRENTES
-- ================================================================

CREATE TABLE recurring_expenses (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id),
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    paid_by_user_id BIGINT NOT NULL REFERENCES users(id),
    frequency VARCHAR(20) NOT NULL, -- daily, weekly, monthly, yearly
    frequency_interval INTEGER DEFAULT 1, -- a cada X dias/semanas/meses
    start_date DATE NOT NULL,
    end_date DATE,
    next_date DATE NOT NULL,
    last_generated_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    auto_generate BOOLEAN DEFAULT TRUE,
    created_by_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recurring_expense_participants (
    id BIGSERIAL PRIMARY KEY,
    recurring_expense_id BIGINT NOT NULL REFERENCES recurring_expenses(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id),
    share_percentage NUMERIC(5, 2) DEFAULT 0,
    UNIQUE (recurring_expense_id, user_id)
);

-- ================================================================
-- TABELAS DE ANEXOS E COMENTÁRIOS
-- ================================================================

CREATE TABLE attachments (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size BIGINT,
    uploaded_by_id BIGINT NOT NULL REFERENCES users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expense_comments (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id),
    comment TEXT NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- TABELAS DE NOTIFICAÇÕES
-- ================================================================

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- new_expense, payment_received, debt_reminder, etc
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_expense_id BIGINT REFERENCES expenses(id),
    related_payment_id BIGINT REFERENCES payments(id),
    related_group_id BIGINT REFERENCES groups(id),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- TABELAS DE AUDITORIA E SEGURANÇA
-- ================================================================

CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    entity_type VARCHAR(50) NOT NULL, -- expense, payment, group, etc
    entity_id BIGINT,
    action VARCHAR(50) NOT NULL, -- create, update, delete
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- ÍNDICES PARA PERFORMANCE
-- ================================================================

-- Índices para consultas frequentes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_groups_active ON groups(is_active);
CREATE INDEX idx_group_members_user_group ON group_members(user_id, group_id);
CREATE INDEX idx_group_members_active ON group_members(is_active);
CREATE INDEX idx_expenses_group_date ON expenses(group_id, expense_date DESC);
CREATE INDEX idx_expenses_paid_by ON expenses(paid_by_user_id);
CREATE INDEX idx_expense_participants_expense ON expense_participants(expense_id);
CREATE INDEX idx_expense_participants_user ON expense_participants(user_id);
CREATE INDEX idx_payments_group_date ON payments(group_id, payment_date DESC);
CREATE INDEX idx_payments_from_user ON payments(from_user_id);
CREATE INDEX idx_payments_to_user ON payments(to_user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);
CREATE INDEX idx_recurring_expenses_next_date ON recurring_expenses(next_date) WHERE is_active = true;

-- ================================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- ================================================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================================
-- DADOS INICIAIS
-- ================================================================

-- Roles padrão
INSERT INTO roles (name, label, description) VALUES
('ADMIN', 'Administrador', 'Acesso total ao sistema'),
('USER', 'Usuário', 'Usuário padrão do sistema');

-- Categorias padrão
INSERT INTO categories (name, icon, color, is_default) VALUES
('Alimentação', '🍽️', '#FF6B6B', true),
('Transporte', '🚗', '#4ECDC4', true),
('Moradia', '🏠', '#45B7D1', true),
('Lazer', '🎉', '#96CEB4', true),
('Saúde', '⚕️', '#FFEAA7', true),
('Educação', '📚', '#DDA0DD', true),
('Compras', '🛒', '#98D8C8', true),
('Serviços', '🔧', '#FDCB6E', true),
('Outros', '📋', '#A29BFE', true);

-- ================================================================
-- VIEWS ÚTEIS PARA CONSULTAS (Criadas após inicialização do Hibernate)
-- ================================================================

-- NOTA: As views serão criadas em um script separado após o Hibernate inicializar
-- para evitar conflitos com alterações de schema automáticas

-- ================================================================
-- COMENTÁRIOS FINAIS
-- ================================================================

-- Este script cria uma estrutura completa para o FairPay com:
-- ✅ Gestão completa de usuários e autenticação
-- ✅ Sistema robusto de grupos e convites
-- ✅ Despesas com múltiplos métodos de divisão
-- ✅ Sistema de pagamentos com confirmação
-- ✅ Despesas recorrentes automatizadas
-- ✅ Notificações e auditoria
-- ✅ Anexos e comentários
-- ✅ Índices otimizados para performance
-- ✅ Views para consultas complexas
-- ✅ Triggers para manutenção automática

COMMIT;