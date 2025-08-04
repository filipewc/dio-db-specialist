# Projeto: Otimização de Consultas com Índices em Banco de Dados

## Descrição
Este projeto tem como objetivo otimizar consultas SQL no banco de dados `company` criando índices estratégicos. Os índices foram desenvolvidos com base nas perguntas fornecidas, considerando os campos mais acessados e relevantes para garantir melhor desempenho.

## Motivação para Criação dos Índices
1. **Índices em `departments`:**
   - `idx_department_id`: Usado em JOINs entre `departments` e `employees`.
   - `idx_department_name`: Usado em GROUP BY e ORDER BY para ordenar e agrupar resultados.

2. **Índices em `employees`:**
   - `idx_employee_department_id`: Usado em JOINs entre `employees` e `departments`.
   - `idx_employee_id`: Chave primária, mas otimiza buscas individuais.

3. **Índices em `locations`:**
   - `idx_location_id`: Usado em JOINs entre `departments` e `locations`.
   - `idx_city`: Usado em WHERE e SELECT para filtrar por cidade.

## Considerações Finais
Os índices foram criados apenas onde necessário para evitar sobrecarga desnecessária na escrita de dados. Eles melhoram significativamente a velocidade das consultas, especialmente em tabelas grandes.