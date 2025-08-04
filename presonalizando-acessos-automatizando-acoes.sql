-- View 1: Número de empregados por departamento e localidade
CREATE VIEW vw_empregados_por_departamento_localidade AS
SELECT 
    d.department_name AS Departamento,
    d.location_id AS Localidade,
    COUNT(e.employee_id) AS Total_Empregados
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name, d.location_id;

-- View 2: Lista de departamentos e seus gerentes
CREATE VIEW vw_departamentos_e_gerentes AS
SELECT 
    d.department_name AS Departamento,
    CONCAT(e.first_name, ' ', e.last_name) AS Gerente
FROM departments d
LEFT JOIN employees e ON d.manager_id = e.employee_id;

-- View 3: Projetos com maior número de empregados (ordenado descendentemente)
CREATE VIEW vw_projetos_maior_numero_empregados AS
SELECT 
    p.project_name AS Projeto,
    COUNT(ep.employee_id) AS Total_Empregados
FROM projects p
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_name
ORDER BY Total_Empregados DESC;

-- View 4: Lista de projetos, departamentos e gerentes
CREATE VIEW vw_projetos_departamentos_gerentes AS
SELECT 
    p.project_name AS Projeto,
    d.department_name AS Departamento,
    CONCAT(e.first_name, ' ', e.last_name) AS Gerente
FROM projects p
JOIN departments d ON p.department_id = d.department_id
LEFT JOIN employees e ON d.manager_id = e.employee_id;

-- View 5: Empregados com dependentes e se são gerentes
CREATE VIEW vw_empregados_com_dependentes_e_gerentes AS
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS Empregado,
    CASE 
        WHEN d.dependent_id IS NOT NULL THEN 'Sim'
        ELSE 'Não'
    END AS Possui_Dependentes,
    CASE 
        WHEN d.department_id IS NOT NULL THEN 'Sim'
        ELSE 'Não'
    END AS É_Gerente
FROM employees e
LEFT JOIN dependents d ON e.employee_id = d.employee_id
LEFT JOIN departments dep ON e.employee_id = dep.manager_id;

-- Criar usuário "gerente"
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha_segura';

-- Criar usuário "employee"
CREATE USER 'employee'@'localhost' IDENTIFIED BY 'senha_segura';

-- Conceder permissões ao usuário "gerente"
GRANT SELECT ON empresa.vw_empregados_por_departamento_localidade TO 'gerente'@'localhost';
GRANT SELECT ON empresa.vw_departamentos_e_gerentes TO 'gerente'@'localhost';
GRANT SELECT ON empresa.vw_projetos_maior_numero_empregados TO 'gerente'@'localhost';
GRANT SELECT ON empresa.vw_projetos_departamentos_gerentes TO 'gerente'@'localhost';
GRANT SELECT ON empresa.vw_empregados_com_dependentes_e_gerentes TO 'gerente'@'localhost';

-- Conceder permissões limitadas ao usuário "employee"
GRANT SELECT ON empresa.vw_empregados_por_departamento_localidade TO 'employee'@'localhost';
GRANT SELECT ON empresa.vw_empregados_com_dependentes_e_gerentes TO 'employee'@'localhost';

-- Revogar acesso a informações sensíveis para "employee"
REVOKE SELECT ON empresa.vw_departamentos_e_gerentes FROM 'employee'@'localhost';
REVOKE SELECT ON empresa.vw_projetos_departamentos_gerentes FROM 'employee'@'localhost';

-- Trigger: Atualizar salário base ao inserir ou atualizar colaborador
DELIMITER $$

CREATE TRIGGER trg_before_update_salario
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Garantir que o novo salário seja no mínimo 10% maior que o anterior
    IF NEW.salary < OLD.salary * 1.1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O novo salário deve ser pelo menos 10% maior que o anterior.';
    END IF;
END$$

DELIMITER ;