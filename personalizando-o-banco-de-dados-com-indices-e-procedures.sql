-- Query 1: Qual o departamento com maior número de pessoas?
SELECT 
    d.department_name AS Departamento,
    COUNT(e.employee_id) AS Total_Empregados
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY Total_Empregados DESC
LIMIT 1;

-- Query 2: Quais são os departamentos por cidade?
SELECT 
    d.department_name AS Departamento,
    l.city AS Cidade
FROM departments d
JOIN locations l ON d.location_id = l.location_id;

-- Query 3: Relação de empregados por departamento
SELECT 
    d.department_name AS Departamento,
    CONCAT(e.first_name, ' ', e.last_name) AS Empregado
FROM departments d
JOIN employees e ON d.department_id = e.department_id;

-- Índice para a tabela `departments` (departamento)
ALTER TABLE departments ADD INDEX idx_department_id (department_id); -- Usado em JOINs frequentemente
ALTER TABLE departments ADD INDEX idx_department_name (department_name); -- Usado em GROUP BY e ORDER BY

-- Índice para a tabela `employees` (empregados)
ALTER TABLE employees ADD INDEX idx_employee_department_id (department_id); -- Usado em JOINs frequentemente
ALTER TABLE employees ADD INDEX idx_employee_id (employee_id); -- Chave primária, mas útil para buscas rápidas

-- Índice para a tabela `locations` (localidades)
ALTER TABLE locations ADD INDEX idx_location_id (location_id); -- Usado em JOINs frequentemente
ALTER TABLE locations ADD INDEX idx_city (city); -- Usado em WHERE e SELECT

-- Procedure para manipulação de dados

DELIMITER $$

CREATE PROCEDURE manipular_dados(
    IN p_opcao INT, -- 1 = Inserir, 2 = Atualizar, 3 = Excluir
    IN p_id INT, -- ID do registro a ser manipulado
    IN p_nome VARCHAR(100), -- Novo nome (para inserção/atualização)
    IN p_cidade VARCHAR(100), -- Nova cidade (para inserção/atualização)
    OUT p_resultado VARCHAR(255) -- Mensagem de resultado
)
BEGIN
    DECLARE v_controle INT DEFAULT 0; -- Variável de controle

    CASE p_opcao
        WHEN 1 THEN -- Inserção
            INSERT INTO universidade (id, nome, cidade)
            VALUES (p_id, p_nome, p_cidade);
            SET p_resultado = 'Registro inserido com sucesso.';
        
        WHEN 2 THEN -- Atualização
            UPDATE universidade
            SET nome = p_nome, cidade = p_cidade
            WHERE id = p_id;
            SET p_resultado = 'Registro atualizado com sucesso.';
        
        WHEN 3 THEN -- Exclusão
            DELETE FROM universidade
            WHERE id = p_id;
            SET p_resultado = 'Registro excluído com sucesso.';
        
        ELSE -- Opção inválida
            SET p_resultado = 'Opção inválida.';
    END CASE;
END$$

DELIMITER ;

-- Chamada da procedure

-- Chamada para inserir um novo registro
CALL manipular_dados(1, 101, 'Universidade Federal', 'São Paulo', @resultado);
SELECT @resultado;

-- Chamada para atualizar um registro existente
CALL manipular_dados(2, 101, 'Universidade Estadual', 'Rio de Janeiro', @resultado);
SELECT @resultado;

-- Chamada para excluir um registro
CALL manipular_dados(3, 101, NULL, NULL, @resultado);
SELECT @resultado;

