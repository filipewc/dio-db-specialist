-- Desabilitar autocommit
SET autocommit = 0;

-- Iniciar a transação
START TRANSACTION;

-- Inserir um novo produto
INSERT INTO produtos (produto_id, nome, preco) VALUES (101, 'Smartphone X', 1500.00);

-- Atualizar o estoque
UPDATE estoque SET quantidade = quantidade + 10 WHERE produto_id = 101;

-- Confirmar a transação (se tudo ocorrer bem)
COMMIT;

-- Caso algo dê errado, podemos desfazer as alterações
-- ROLLBACK;

-- Criando uma proccedure com transação

DELIMITER $$

CREATE PROCEDURE transacao_com_procedure(
    IN p_produto_id INT,
    IN p_nome VARCHAR(100),
    IN p_preco DECIMAL(10, 2),
    IN p_quantidade INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE exit_handler CONDITION FOR SQLEXCEPTION;
    DECLARE CONTINUE HANDLER FOR exit_handler
    BEGIN
        -- Em caso de erro, desfazer todas as alterações
        ROLLBACK;
        SET p_resultado = 'Erro ocorreu. Transação desfeita.';
    END;

    -- Iniciar a transação
    START TRANSACTION;

    -- Salvar um ponto de recuperação (SAVEPOINT)
    SAVEPOINT antes_da_insercao;

    -- Tentar inserir um novo produto
    INSERT INTO produtos (produto_id, nome, preco) VALUES (p_produto_id, p_nome, p_preco);

    -- Verificar se a quantidade é válida
    IF p_quantidade <= 0 THEN
        -- Desfazer até o SAVEPOINT
        ROLLBACK TO antes_da_insercao;
        SET p_resultado = 'Quantidade inválida. Alterações parciais desfeitas.';
    ELSE
        -- Atualizar o estoque
        UPDATE estoque SET quantidade = quantidade + p_quantidade WHERE produto_id = p_produto_id;

        -- Confirmar a transação
        COMMIT;
        SET p_resultado = 'Transação concluída com sucesso.';
    END IF;
END$$

DELIMITER ;

-- Chamada da procedure
CALL transacao_com_procedure(102, 'Notebook Y', 3000.00, 5, @resultado);
SELECT @resultado;

-- Teste com quantidade inválida
CALL transacao_com_procedure(103, 'Tablet Z', 800.00, -1, @resultado);
SELECT @resultado;

# Comando para criar o backup do banco de dados "ecommerce"
mysqldump -u root -p ecommerce > ecommerce_backup.sql

# Comando para restaurar o banco de dados "ecommerce"
mysql -u root -p ecommerce < ecommerce_backup.sql

-- Verificar se as tabelas e dados estão intactos
SELECT * FROM produtos LIMIT 10;
SELECT * FROM estoque LIMIT 10;