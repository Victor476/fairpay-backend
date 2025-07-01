-- ================================================================
-- SCRIPT SQL PARA RECRIAR O BANCO FAIRPAY VIA COPY/PASTE
-- ================================================================

-- EXECUTE ESTE BLOCO PRIMEIRO (conectado ao banco 'postgres')
-- ================================================================

-- Terminar conexões ativas
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'fairpay_db' AND pid <> pg_backend_pid();

-- Excluir banco se existir
DROP DATABASE IF EXISTS fairpay_db;

-- Criar novo banco
CREATE DATABASE fairpay_db WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- ================================================================
-- AGORA CONECTE AO BANCO 'fairpay_db' E EXECUTE O RESTO
-- ================================================================

-- Use: \c fairpay_db

-- DEPOIS COLE E EXECUTE TODO O CONTEÚDO DO ARQUIVO:
-- "script para criação do banco final.sql"
