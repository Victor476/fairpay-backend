-- TABELAS BÁSICAS

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(100) NOT NULL
);

CREATE TABLE user_roles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE (user_id, role_id)
);

CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_members (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    UNIQUE (user_id, group_id)
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id),
    paid_by_user_id INTEGER NOT NULL REFERENCES users(id),
    category_id INTEGER REFERENCES categories(id),
    description TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    expense_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expense_participants (
    id SERIAL PRIMARY KEY,
    expense_id INTEGER NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    share NUMERIC(12, 2) NOT NULL
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id),
    from_user_id INTEGER NOT NULL REFERENCES users(id),
    to_user_id INTEGER NOT NULL REFERENCES users(id),
    amount NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABELAS COMPLEMENTARES

CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE
);

CREATE TABLE password_reset_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(100) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    expense_id INTEGER NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recurring_expenses (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id),
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    paid_by_user_id INTEGER NOT NULL REFERENCES users(id),
    recurrence VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    last_generated DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expense_comments (
    id SERIAL PRIMARY KEY,
    expense_id INTEGER NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    comment TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invitations (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    invited_email VARCHAR(100) NOT NULL,
    invited_by_user_id INTEGER NOT NULL REFERENCES users(id),
    token VARCHAR(100) NOT NULL UNIQUE,
    accepted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- USERS
INSERT INTO users (name, email, password_hash) VALUES
('Alice Silva', 'alice@example.com', 'hash_alice'),
('Bruno Costa', 'bruno@example.com', 'hash_bruno'),
('Carla Souza', 'carla@example.com', 'hash_carla');

-- ROLES
INSERT INTO roles (name, label) VALUES
('admin', 'Administrador'),
('user', 'Usuário Padrão');

-- USER_ROLES
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- Alice é admin
(2, 2), -- Bruno é user
(3, 2); -- Carla é user

-- GROUPS
INSERT INTO groups (name) VALUES
('Apartamento 101'),
('Viagem para Ubatuba');

-- GROUP_MEMBERS
INSERT INTO group_members (user_id, group_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(1, 2),
(3, 2);

-- CATEGORIES
INSERT INTO categories (name) VALUES
('Aluguel'),
('Comida'),
('Transporte'),
('Lazer');

-- EXPENSES
INSERT INTO expenses (group_id, paid_by_user_id, category_id, description, amount) VALUES
(1, 1, 1, 'Aluguel de Outubro', 1500.00),
(1, 2, 2, 'Compras do mercado', 300.00),
(2, 3, 4, 'Passeio de barco', 450.00);

-- EXPENSE_PARTICIPANTS
INSERT INTO expense_participants (expense_id, user_id, share) VALUES
(1, 1, 500.00), (1, 2, 500.00), (1, 3, 500.00),
(2, 1, 100.00), (2, 2, 100.00), (2, 3, 100.00),
(3, 1, 225.00), (3, 3, 225.00);

-- PAYMENTS
INSERT INTO payments (group_id, from_user_id, to_user_id, amount) VALUES
(1, 2, 1, 500.00),
(2, 3, 1, 225.00);

-- REFRESH TOKENS
INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES
(1, 'token1', NOW() + INTERVAL '7 days'),
(2, 'token2', NOW() + INTERVAL '7 days');

-- PASSWORD RESET TOKENS
INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES
(3, 'reset_token1', NOW() + INTERVAL '1 hour');

-- AUDIT LOGS
INSERT INTO audit_logs (user_id, action, description, ip_address) VALUES
(1, 'LOGIN', 'Login realizado com sucesso', '127.0.0.1');

-- ATTACHMENTS
INSERT INTO attachments (expense_id, file_url, file_type) VALUES
(1, 'https://example.com/recibo1.pdf', 'application/pdf');

-- RECURRING EXPENSES
INSERT INTO recurring_expenses (group_id, description, amount, paid_by_user_id, recurrence, start_date) VALUES
(1, 'Internet Mensal', 120.00, 2, 'monthly', '2024-01-01');

-- EXPENSE COMMENTS
INSERT INTO expense_comments (expense_id, user_id, comment) VALUES
(1, 2, 'Não esquecer de pagar até o dia 5!');

-- INVITATIONS
INSERT INTO invitations (group_id, invited_email, invited_by_user_id, token) VALUES
(1, 'novo.membro@example.com', 1, 'invite_token_123');

atualizações

-- 1. Adicionar colunas faltantes na tabela groups
ALTER TABLE groups 
ADD COLUMN description TEXT,
ADD COLUMN image_url VARCHAR(255),
ADD COLUMN created_by_id INTEGER;

-- 2. Atualizar grupos existentes com um criador padrão (substitua 1 pelo ID de um usuário existente)
UPDATE groups SET created_by_id = 1 WHERE created_by_id IS NULL;

-- 3. Tornar a coluna NOT NULL após atualizar os dados
ALTER TABLE groups ALTER COLUMN created_by_id SET NOT NULL;

-- 4. Adicionar a constraint de foreign key
ALTER TABLE groups ADD CONSTRAINT fk_groups_created_by 
FOREIGN KEY (created_by_id) REFERENCES users(id);

-- 5. Criar a nova tabela para links de convite
CREATE TABLE group_invite_links (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    created_by_id INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);