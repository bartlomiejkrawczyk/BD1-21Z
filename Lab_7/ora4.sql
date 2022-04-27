-- Napisz zapytanie, które zwróci œrednie zarobki pracowników pogrupowane ze wzglêdu na pierwsz¹ literê imienia pracowników. Wyklucz te grupy, dla których œrednie zarobki s¹ puste.

SELECT  SUBSTR(e.name, 1, 1), AVG(salary)
FROM employees e
GROUP BY SUBSTR(e.name, 1, 1)
HAVING AVG(salary) IS NOT NULL;

-- Napisz zapytanie zwracaj¹ce listê pracowników (poka¿ ich imiê, nazwisko oraz nazwê departamentu, w którym pracuj¹), którzy zostali zatrudnieni wczeœniej ni¿ wszyscy pracownicy pracuj¹cy na stanowiskach 'Konsultant' lub 'Kadrowy'. Wynik posortuj malej¹co wzglêdem dat.

SELECT e.name, e.surname, d.name, e.date_employed
FROM employees e
    LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.date_employed < (
    SELECT MIN(e2.date_employed)
    FROM employees e2
        JOIN positions p ON e2.position_id = p.position_id
    WHERE p.name IN ('Konsultant', 'Kadrowy')
)
ORDER BY e.date_employed DESC;

SELECT date_employed
FROM employees
ORDER BY date_employed;

    
-- Napisz zapytanie, zwracaj¹ce informacje o departamentach, w których œrednia wieku pracowników jest wiêksza ni¿ 35 lat. 
-- W wynikach podaj nazwê, bud¿et, imiê i nazwisko kierownika oraz œredni¹ wieku pracowników w tym departamencie. Wynik posortuj wzglêdem œredniej wieku malej¹co.

SELECT d.name, d.year_budget, man.name, man.surname,  AVG(FLOOR(MONTHS_BETWEEN(SYSDATE, e.birth_date)/12)) avg_age
FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    JOIN employees man ON man.employee_id = d.manager_id
GROUP BY d.department_id, d.name, d.year_budget, man.name, man.surname
HAVING AVG(FLOOR(MONTHS_BETWEEN(SYSDATE, e.birth_date)/12)) > 35
ORDER BY avg_age DESC;


-- Wykorzystuj¹c podzapytania napisz zapytanie, które zwróci dane managerów pracowników, o ile zarobki tych managerów s¹ wiêksze od œredniej zarobków w ogóle.

SELECT *
FROM employees man
WHERE man.employee_id IN (
    SELECT DISTINCT e.manager_id
    FROM employees e
    WHERE e.manager_id IS NOT NULL
)
AND man.salary > (
    SELECT AVG(e.salary)
    FROM employees e
);

SELECT AVG(e.salary)
    FROM employees e;


-- Wylistuj wszystkie zmiany ze stanowiska 'Programista' lub 'Konsultant' zachodz¹cych w latach 2006-2008 w³¹cznie. 
-- W wynikach zapytania zwróæ konkatencjê imienia i nazwiska  pracownika zmieniaj¹cego, nazwê starego stanowiska, nazwê nowego stanowiska oraz datê zmiany.

SELECT e.name || ' ' || e.surname name, p.name old,  NVL(
    (SELECT p2.name
    FROM positions_history h2
        JOIN positions p2 ON h2.position_id = p2.position_id
    WHERE h2.employee_id = e.employee_id
    AND h2.date_start >= h.date_end
    ORDER BY h2.date_start
    FETCH FIRST 1 ROW ONLY),
    (SELECT p3.name
    FROM employees e3
        JOIN positions p3 ON e3.position_id = p3.position_id
    WHERE e3.employee_id = e.employee_id)
) new, h.date_end
FROM positions_history h
    JOIN positions p ON p.position_id = h.position_id
    JOIN employees e ON e.employee_id = h.employee_id
WHERE p.name IN ('Programista', 'Konsultant')
AND date_end >= '06/01/01' AND date_end < '09/01/01';


-- Napisz zapytanie które zwróci regiony nieprzypisane do ¿adnego kraju. U¿yj z³¹czeñ.

SELECT r.region_id, r.name, r.shortname
FROM regions r
    LEFT JOIN reg_countries rg ON rg.region_id = r.region_id
    LEFT JOIN countries c ON rg.country_id = c.country_id
WHERE c.country_id IS NULL;