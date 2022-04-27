-- Napisz zapytanie, kt�re zwr�ci �rednie zarobki pracownik�w pogrupowane ze wzgl�du na pierwsz� liter� imienia pracownik�w. Wyklucz te grupy, dla kt�rych �rednie zarobki s� puste.

SELECT  SUBSTR(e.name, 1, 1), AVG(salary)
FROM employees e
GROUP BY SUBSTR(e.name, 1, 1)
HAVING AVG(salary) IS NOT NULL;

-- Napisz zapytanie zwracaj�ce list� pracownik�w (poka� ich imi�, nazwisko oraz nazw� departamentu, w kt�rym pracuj�), kt�rzy zostali zatrudnieni wcze�niej ni� wszyscy pracownicy pracuj�cy na stanowiskach 'Konsultant' lub 'Kadrowy'. Wynik posortuj malej�co wzgl�dem dat.

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

    
-- Napisz zapytanie, zwracaj�ce informacje o departamentach, w kt�rych �rednia wieku pracownik�w jest wi�ksza ni� 35 lat. 
-- W wynikach podaj nazw�, bud�et, imi� i nazwisko kierownika oraz �redni� wieku pracownik�w w tym departamencie. Wynik posortuj wzgl�dem �redniej wieku malej�co.

SELECT d.name, d.year_budget, man.name, man.surname,  AVG(FLOOR(MONTHS_BETWEEN(SYSDATE, e.birth_date)/12)) avg_age
FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    JOIN employees man ON man.employee_id = d.manager_id
GROUP BY d.department_id, d.name, d.year_budget, man.name, man.surname
HAVING AVG(FLOOR(MONTHS_BETWEEN(SYSDATE, e.birth_date)/12)) > 35
ORDER BY avg_age DESC;


-- Wykorzystuj�c podzapytania napisz zapytanie, kt�re zwr�ci dane manager�w pracownik�w, o ile zarobki tych manager�w s� wi�ksze od �redniej zarobk�w w og�le.

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


-- Wylistuj wszystkie zmiany ze stanowiska 'Programista' lub 'Konsultant' zachodz�cych w latach 2006-2008 w��cznie. 
-- W wynikach zapytania zwr�� konkatencj� imienia i nazwiska  pracownika zmieniaj�cego, nazw� starego stanowiska, nazw� nowego stanowiska oraz dat� zmiany.

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


-- Napisz zapytanie kt�re zwr�ci regiony nieprzypisane do �adnego kraju. U�yj z��cze�.

SELECT r.region_id, r.name, r.shortname
FROM regions r
    LEFT JOIN reg_countries rg ON rg.region_id = r.region_id
    LEFT JOIN countries c ON rg.country_id = c.country_id
WHERE c.country_id IS NULL;