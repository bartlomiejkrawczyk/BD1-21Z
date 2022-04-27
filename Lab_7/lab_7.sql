CREATE VIEW emp_pos_names
AS 
    SELECT e.name as name, surname, salary, p.name as position
    FROM employees e JOIN positions p USING (position_id);

SELECT  position, COUNT(*) 
    FROM emp_pos_names
WHERE salary > 2100 
GROUP BY position
HAVING COUNT (*) >= 2
ORDER BY 2 DESC;

--------------------------------------------------------------------------------
CREATE VIEW emp_view AS 
    SELECT employee_id, name, surname, birth_date
    FROM employees;

INSERT INTO emp_view VALUES (301, 'Piotr', 'Kowalski', SYSDATE);
UPDATE emp_view SET name = 'PIOTR' WHERE name LIKE 'Piotr';

SELECT * FROM emp_view;

ROLLBACK;

--------------------------------------------------------------------------------

CREATE VIEW emp_view_names AS   
	SELECT employee_id, name, surname, birth_date FROM employees
	WHERE name like 'P%' OR name like 'R%' OR name like 'M%'
	WITH CHECK OPTION;
    
SELECT * FROM emp_view_names;


--------------------------------------------------------------------------------
-- 1. Zdefiniuj widok, który bêdzie zwracaæ imiê, nazwisko, zarobki, nazwê
-- stanowiska, nazwê departamentu oraz imiê i nazwisko managera dla
-- wszystkich pracowników w tabeli employees.

CREATE OR REPLACE VIEW employee_info AS
    SELECT e.name, e.surname, e.salary, p.name position, d.name department, man.name man_name, man.surname man_surname
    FROM employees e
        JOIN positions p ON e.position_id = p.position_id
        JOIN departments d ON e.department_id = d.department_id
        LEFT JOIN employees man ON man.employee_id = e.manager_id;

SELECT * FROM employee_info;
        
-- 2. Zdefiniuj widok typu WITH CHECK OPTION przechowuj¹cy id stanowisk
-- (position_id) oraz nazwê, minimalne zarobki wszystkich stanowisk
-- rozpoczynaj¹cych siê od litery ‘P’, ‘K’ lub ‘M’. Nastêpnie spróbuj zwiêkszyæ
-- minimalne zarobki dla stanowiska ‘Rekruter’ o 1000 i przeanalizuj komunikat
-- b³êdu.

CREATE OR REPLACE VIEW min_salaries_pkm AS
    SELECT p.position_id position_id, p.name name, MIN(e.salary) min_salary
    FROM positions p
        LEFT JOIN employees e ON e.position_id = p.position_id
    WHERE p.name LIKE 'P%' OR p.name LIKE 'K%' OR p.name LIKE 'M%'
    GROUP BY p.position_id, p.name
    WITH CHECK OPTION;
    

SELECT * FROM min_salaries_pkm;

UPDATE min_salaries_pkm
SET
    min_salary = min_salary + 1000
WHERE
    name = 'Rekruter';
    
-- 3. Wykonaj polecenia DROP VIEW, aby usun¹æ jeden z wczeœniej utworzonych
-- widoków.

DROP VIEW min_salaries_pkm;

--------------------------------------------------------------------------------

CREATE MATERIALIZED VIEW emp_pos_dept_mview AS
    SELECT e.name name, e.surname, e.salary, p.name position, d.name department
    FROM employees e JOIN positions p USING(position_id)
    JOIN departments d USING (department_id);

SELECT * FROM emp_pos_dept_mview;

--------------------------------------------------------------------------------

-- 1. Zdefiniuj widok, zmaterializowany, który bêdzie przechowywa³ imiê i nazwisko 
-- kierowników i liczbê jego podw³adnych.

CREATE MATERIALIZED VIEW man_employee_count AS
    SELECT man.name man_name, man.surname man_surname, COUNT(*)
    FROM employees e
        JOIN employees man ON man.employee_id = e.manager_id
    GROUP BY man.employee_id, man.name, man.surname;
    
SELECT * FROM man_employee_count;


-- 2. Zdefiniuj widok zmaterializowany przechowuj¹cy informacje o sumie
-- bud¿etów (estimated_budget) projektów prowadzonych przez dany
-- departament.

CREATE MATERIALIZED VIEW department_budget AS
    SELECT d.department_id, d.name, SUM(p.estimated_budget) sum_project
    FROM projects p
        JOIN departments d ON d.department_id = p.owner
    GROUP BY d.department_id, d.name;
    
SELECT * FROM department_budget;
    
-- 3. Do widoku stworzonego w powyzszym poleceniu dodaj kolumnê z informacj¹
-- o procentowym udziale sumy budzetow projektow w rocznym budzecie
-- danego departamentu. Zaokr¹glij procentowy udzial do 2 miejsc po
-- przecinku. Posortuj malej¹co wzglêdem tego procentowego udzia³u.

DROP MATERIALIZED VIEW department_budget;

CREATE MATERIALIZED VIEW department_budget AS
    SELECT d.department_id, d.name, SUM(p.estimated_budget) sum_project, ROUND(100 * SUM(p.estimated_budget) / d.year_budget, 2) project_percentage
    FROM projects p
        JOIN departments d ON d.department_id = p.owner
    GROUP BY d.department_id, d.name, d.year_budget
    ORDER BY project_percentage DESC;
    
SELECT * FROM department_budget;

-- 4. Wykonaj polecenia DROP MATERIALIZED VIEW, aby usun¹æ jeden z
-- wczeœniej utworzonych widoków.

DROP MATERIALIZED VIEW man_employee_count;

--------------------------------------------------------------------------------

CREATE SEQUENCE int_seq1 START WITH 100 MAXVALUE 1000;

SELECT int_seq1.NEXTVAL FROM DUAL;
SELECT int_seq1.CURRVAL FROM DUAL;

--------------------------------------------------------------------------------
-- 1. Zdefiniuj sekwencjê, która: 
-- (i) bêdzie posiada³a minimaln¹ wartoœæ 10; 
-- (ii) rozpocznie generowanie wartoœci od 12; 
-- (iii) bêdzie posiada³a maksymaln¹ wartoœæ 17; 
-- (iv) bêdzie cykliczna. Nastêpnie wygeneruj kilkanaœcie wartoœci za pomoc¹ tej sekwencji i obserwuj rezultaty.

CREATE SEQUENCE int_seq2 
    START WITH 12 
    MINVALUE 10 
    MAXVALUE 17 
    CYCLE 
    CACHE 5;

SELECT int_seq2.NEXTVAL FROM DUAL;

DROP SEQUENCE int_seq2;

-- 2. Zdefiniuj sekwencjê, która bêdzie generowa³a malej¹co liczby parzyste 
-- z przedzia³u 100 ÷ 0.

CREATE SEQUENCE int_seq3
    INCREMENT BY -2
    MINVALUE 0
    MAXVALUE 100
    CYCLE;

SELECT int_seq3.NEXTVAL FROM DUAL;

-- 3. Nadaj synonim dla dowolnej z dwóch poprzednio zdefiniowanych sekwencji 
-- i pobierz z niej wartoœæ za pomoc¹ synonimu.

CREATE SYNONYM int_seq4 FOR int_seq3;

SELECT int_seq3.NEXTVAL FROM DUAL;
SELECT int_seq4.NEXTVAL FROM DUAL;
--------------------------------------------------------------------------------

-- 1. Utwórz widok zawieraj¹cy z³¹czenia kilku tabel (np. employees, positions, departments, addresses) i spróbuj go wykorzystaæ do wprowadzenia nowych danych do tych tabel. Jaki komunikat b³êdu zaobserwowa³eœ? 
-- Wyszukaj w dokumentacji mo¿liwe rozwi¹zanie tego problemu.

CREATE OR REPLACE VIEW emp_detail AS
    SELECT e.name, e.surname, e.birth_date, d.name AS department, p.name AS position, a.city
    FROM employees e
    JOIN positions p ON e.position_id = p.position_id
    JOIN departments d ON e.department_id = d.department_id
    JOIN addresses a ON d.address_id = a.address_id;
    
INSERT INTO emp_detail VALUES ('test', 'test', '01/01/01', 'a', 'b', 'c');
-- 01776. 00000 -  "cannot modify more than one base table through a join view"

-- 2. Zdefiniuj widok ³¹cz¹cy tabele countries, regions i addresses. Nastêpnie wykorzystuj¹c z³¹czenie pomiêdzy tym widokiem, a tabel¹ departments wyœwietl kraje oraz regiony po³o¿enia wszystkich departamentów.

CREATE OR REPLACE VIEW rca AS
    SELECT r.region_id, c.country_id, a.address_id, r.name region, c.name country, a.city
    FROM regions r
    JOIN reg_countries rg ON rg. region_id = r.region_id
    JOIN countries c ON c.country_id = rg.country_id
    JOIN addresses a ON a.country_id = c.country_id;
    
SELECT *
FROM departments d
JOIN rca r ON r.address_id = d.address_id;

-- 3. Wyszukaj informacje w Internecie lub w dokumentacji bazy Oracle, w jaki sposób mo¿liwe jest automatyczne wykorzystanie sekwencji do generowania wartoœci klucza g³ównego przy dodawaniu danych do tabeli.

-- Np. poprzer trigger before insert when id = null
CREATE SEQUENCE employee_id_seq
    MINVALUE 1000
    NOCYCLE;
    
CREATE OR REPLACE TRIGGER employee_id_trg BEFORE
    INSERT ON employees
    FOR EACH ROW
    WHEN ( new.employee_id IS NULL )
BEGIN
    :new.employee_id := employee_id_seq.NEXTVAL;
END;


ROLLBACK;