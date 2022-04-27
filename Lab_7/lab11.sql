--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT * FROM DUAL;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

--------------------------------------------------------------------------------
select * from employees;
select * from dual;
select sysdate from dual;
select * from employees where employee_id > 130;
select * from employees where surname = 'Himuro';
select * from employees where salary between 1000 and 5000;
select department_id, count(*) from employees group by department_id;
select department_id, count(*) from employees where manager_id is not null group by department_id;
select department_id, count(*) from employees where manager_id is not null group by department_id having count (*) > 2;

--------------------------------------------------------------------------------

-- Sprawdzenie jakie s¹ indeksy na tabeli

SELECT * FROM ALL_INDEXES where owner ='HR' and table_name = 'EMPLOYEES';
SELECT * FROM USER_INDEXES where table_name = 'EMPLOYEES';

--------------------------------------------------------------------------------

-- 1. Za³ó¿ indeks na kolumnie surname w tabeli employees. 
SELECT * FROM employees WHERE surname = 'aaa';

CREATE INDEX idx_emp_surname
ON employees (surname);

-- 2. Przeanalizuj plan zapytania z warunkiem równoœciowym na tej kolumnie. Przeanalizuj zapytanie z warunkiem równoœciowym na kluczu g³ównym tabeli employees. Porównaj uzyskane plany.

SELECT * FROM employees 
WHERE surname = 'aaa'; -- RANGE SCAN

SELECT * FROM employees
WHERE employee_id = 101; -- UNIQUE SCAN

SELECT * FROM employees
WHERE name = 'Piotr'; -- FULL

SELECT * FROM employees
WHERE employee_id BETWEEN 105 AND 110; -- RANGE SCAN

SELECT * FROM employees
WHERE employee_id > 105; -- FULL SCAN

SELECT * FROM employees
WHERE employee_id > 150; -- RANGE SCAN

-- 3. Zaindeksuj kolumnê tabeli zawieraj¹c¹ NULL-e i sprawdŸ plan wykonania przy zapytaniu z warunkiem „kolumna IS NULL” oraz „kolumna IS NOT NULL”.

CREATE INDEX idx_emp_salary
ON employees (salary);

SELECT * 
FROM employees 
WHERE salary IS NULL; -- FULL

SELECT * 
FROM employees 
WHERE salary IS NOT NULL; -- FULL

CREATE INDEX idx_projects_date_end
ON projects (date_end);

SELECT * 
FROM projects 
WHERE date_end IS NULL; -- FULL

SELECT * 
FROM projects 
WHERE date_end IS NOT NULL; -- FULL

-- 4. Utwórz indeks B-tree na dwóch kolumnach (np. w tabeli positions na min_salary i max_salary) i sprawdŸ plan wykonania dla wszystkich kombinacji wystêpowania kolumn indeksuj¹cych w klauzuli WHERE. Kiedy wykorzystany jest indeks?

CREATE INDEX idx_positions_treshold
ON positions (min_salary, max_salary);

SELECT * 
FROM positions 
WHERE min_salary = 1000 AND max_salary = 4000; -- FULL

SELECT * 
FROM positions 
WHERE min_salary = 1000; -- FULL

SELECT * 
FROM positions 
WHERE max_salary = 4000; -- FULL

SELECT * 
FROM positions 
WHERE min_salary < 2000 AND max_salary > 4000; -- FULL

-- Nie dzia³a mi ten indeks :(

-- 5. SprawdŸ plany wykonania zapytañ z fraz¹ ORDER BY dotycz¹c¹ kolumn zaindeksowanych null/not null.

SELECT * FROM employees ORDER BY salary NULLS LAST;

SELECT * FROM projects ORDER BY date_end NULLS LAST;


-- 6. SprawdŸ plany wykonania zapytañ z/bez fraz(¹/y) ORDER BY dotycz¹c¹ kolumn zaindeksowanych indeksami unikalnymi i nieunikalnymi, przy czym lista selekcji ma byæ ograniczona wy³¹cznie do tych kolumn.


-- 7. Jakie czynniki maj¹ wp³yw na to czy indeks zostanie wykorzystany?


--------------------------------------------------------------------------------

-- 1. Wykonaj zapytanie na tabeli employees z warunkiem
--      surname = ’Himuro’
-- oraz z warunkiem
--      UPPER(surname) = ’HIMURO’.
-- Kiedy jest wykorzystany indeks?

SELECT * FROM employees
WHERE surname = 'Himuro'; -- RANGE SCAN

SELECT * FROM employees
WHERE UPPER(surname) = 'HIMURO'; -- FULL

-- 2. Stwórz indeks funkcyjny na tabeli employees na kolumnie surname poddanej dzia³aniu funkcji upper.

CREATE INDEX idx_emp_upper_surname
ON employees (UPPER(surname));

-- 3. Wykonaj zapytanie z warunkiem upper(surname) = ‘HIMURO’. Czy jest wykorzystany indeks?

SELECT * FROM employees
WHERE UPPER(surname) = 'HIMURO'; -- RANGE SCAN

-- Tak, indeks jest wykorzystany

--------------------------------------------------------------------------------

-- 1. Jak zmieni siê plan wykonania, jeœli w poprzednim przyk³adzie w definicji z³¹czenia zastosujemy frazê USING?


-- 2. Dodaj indeks B-tree na kolumnie klucza obcego z poprzedniego przyk³adu i sprawdŸ plan wykonania.
-- Jakiego rodzaju musi byæ to indeks (unikalny, nieunikalny)?
-- Czy wydajnoœæ z³¹czenia uleg³a poprawie?

-- 3. Za pomoc¹ wskazówek zmieñ typ z³¹czenia tabel.

-- 4. Zmieñ warunek z³¹czenia na nierównoœciowy, zweryfikuj jak zmieni³ siê plan wykonania.

--------------------------------------------------------------------------------

-- 1. Wykonaj æwiczenia z przebiegu laboratorium

-- DONE

-- 2. Co to jest klastrowanie tabel?


-- 3. Do schematu bazy danych dodaj klaster tabel EMPLOYEES_CL oraz DEPARTMENTS_CL o strukturze odpowiadaj¹cej tabelom EMPLOYEES oraz DEPARTMENTS.


-- 4. Przekopiuj dane z tabel EMPLOYEES oraz DEPARTMENTS do odpowiednich tabel w klastrze.


-- 5. SprawdŸ plany wykonania zapytañ do pojedynczych tabel klastra z warunkami do ró¿nych kolumn.


-- 6. SprawdŸ plan wykonania operacji z³¹czenia sklastrowanych tabel.


-- 7. Stwórz indeks bitmapowy na kolumnie status_id w tabeli pracownicy. Wykonaj zapytania na tej tabeli i sprawdŸ, czy indeks jest wykorzystywany.

