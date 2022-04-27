SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 2000;

-- Lub:

SELECT d.name, MAX(salary)
FROM employees e
    JOIN departments d USING (department_id)
GROUP BY department_id, d.name
HAVING AVG(salary) > 2000;

--------------------------------------------------------------------------------

SELECT department_id, name, year_budget
FROM departments
ORDER BY year_budget DESC NULLS LAST
OFFSET 1 ROW
FETCH NEXT 1 ROW ONLY;

--------------------------------------------------------------------------------

SELECT 'K' kategoria, c.name nazwa, COUNT(department_id) liczba
FROM countries c
LEFT JOIN addresses a USING (country_id)
LEFT JOIN departments d USING (address_id)
WHERE d.established > '05/12/31' AND d.established < '11/01/01' OR d.established IS NULL
GROUP BY c.name
UNION ALL
SELECT 'R', r.name, COUNT(department_id)
FROM regions r
LEFT JOIN reg_countries rg USING (region_id)
LEFT JOIN addresses a USING (country_id)
LEFT JOIN departments d USING (address_id)
WHERE d.established > '05/12/31' AND d.established < '11/01/01' OR d.established IS NULL
GROUP BY r.name;

--------------------------------------------------------------------------------

SELECT *
FROM employees e
WHERE e.salary > (
    SELECT MAX(salary) 
    FROM employees
    WHERE department_id = 102
);

--------------------------------------------------------------------------------

SELECT e.name || ' ' || e.surname, p.name old,  NVL(
    (SELECT p2.name
    FROM positions_history h2
        JOIN positions p2 ON (h2.position_id = p2.position_id)
    WHERE h2.employee_id = e.employee_id
    AND h2.date_start >= h.date_end
    ORDER BY h2.date_start
    FETCH FIRST 1 ROW ONLY),
    (SELECT p3.name
    FROM employees e3
        JOIN positions p3 ON (e3.position_id = p3.position_id)
    WHERE e3.employee_id = e.employee_id)
) new, h.date_end
FROM positions_history h
    JOIN positions p ON (p.position_id = h.position_id)
    JOIN employees e ON (e.employee_id = h.employee_id)
WHERE p.name IN ('Programista', 'Konsultant')
AND date_end > '05/12/31' AND date_end < '09/01/01';

--------------------------------------------------------------------------------

SELECT e.employee_id, e.name, e.surname, p.name, p.estimated_budget, d.name 
FROM employees e
    JOIN emp_projects ep ON (e.employee_id = ep.employee_id)
    JOIN projects p USING (project_id)
    JOIN departments d ON p.owner = d.department_id;