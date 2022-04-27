--Pakiety
--1
CREATE OR REPLACE PACKAGE emp_management
AS
FUNCTION dodatek (p_eid INTEGER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY emp_management
AS
FUNCTION dodatek (p_eid INTEGER)
RETURN NUMBER
AS
v_no_emp INTEGER;
v_bonus NUMBER(10, 2);
v_salary NUMBER(10, 2);
BEGIN
    SELECT count(employee_id) INTO v_no_emp
    FROM employees WHERE manager_id = p_eid;
    
    SELECT salary INTO v_salary
    FROM employees WHERE employee_id = p_eid;

    v_bonus := v_no_emp*0.1*v_salary;
    
    IF v_bonus > 0.5*v_salary THEN
        RETURN 0.5*v_salary;
    ELSE
        RETURN v_bonus;
    END IF;
END;
END;
/

SELECT employee_id, emp_management.dodatek(employee_id) FROM employees;

--Triggers (slajd 22)
--1
CREATE OR REPLACE TRIGGER tg_salarypodatek
AFTER UPDATE OF salary ON employees FOR EACH ROW
DECLARE
v_podatek NUMBER(20,2);
BEGIN

v_podatek := :new.salary*0.2;
dbms_output.put_line('Podatek: ' || :new.employee_id || ' ' || v_podatek);

END;
/

UPDATE employees SET salary  = 3000 WHERE employee_id = 102 OR employee_id = 101;

--2
CREATE OR REPLACE TRIGGER tg_updatesalary
AFTER INSERT OR DELETE OR UPDATE OF salary ON employees
DECLARE 
v_srednia NUMBER(20,2);
BEGIN
SELECT avg(salary) INTO v_srednia FROM employees;
dbms_output.put_line('Aktualne srednie zarobki: ' || v_srednia);
END;
/

UPDATE employees SET salary  = 3000 WHERE employee_id = 102 OR employee_id = 101;

--3
CREATE OR REPLACE TRIGGER tg_nomanager
BEFORE INSERT ON employees FOR EACH ROW
WHEN (new.manager_id IS NULL AND new.department_id IS NOT NULL)
DECLARE
v_manager INTEGER;
BEGIN
    SELECT manager_id INTO v_manager FROM departments WHERE department_id = :new.department_id;
    :new.manager_id := v_manager;
END;
/

INSERT INTO employees VALUES (301, 'Piotr', 'Kowalski', SYSDATE, NULL, NULL, NULL, NULL, 101, NULL, NULL);
COMMIT;

--4
CREATE OR REPLACE TRIGGER tg_nomanagerIF
BEFORE INSERT ON employees FOR EACH ROW
DECLARE
v_manager INTEGER;
BEGIN
IF (:new.manager_id IS NULL AND :new.department_id IS NOT NULL) THEN
    SELECT manager_id INTO v_manager FROM departments WHERE department_id = :new.department_id;
    :new.manager_id := v_manager;
END IF;
END;
/

INSERT INTO employees VALUES (302, 'Piotr', 'Kowalski', SYSDATE, NULL, NULL, NULL, NULL, 102, NULL, NULL);
COMMIT;

--5
CREATE OR REPLACE TRIGGER tg_oneprezes
BEFORE INSERT OR UPDATE of position_id ON employees
DECLARE
v_position_id INTEGER;
v_count INTEGER;
BEGIN
SELECT position_id INTO v_position_id FROM positions WHERE name Like 'Prezes';

SELECT count(employee_id) INTO v_count FROM employees WHERE position_id = v_position_id;

IF v_count >= 1 THEN RAISE_APPLICATION_ERROR(-20001, 'Wieciej niz jeden prezes'); END IF;
END;
/

UPDATE employees SET position_id = 118 WHERE employee_id = 101;
UPDATE employees SET position_id = 118 WHERE employee_id = 102;
UPDATE employees SET position_id = 118 WHERE employee_id = 103;

---------------------------
---Slajd 31 (Kursory)
--1
CREATE OR REPLACE PROCEDURE sredniezarobki
AS
CURSOR cr IS SELECT avg(salary), department_id FROM employees GROUP BY department_id;
CURSOR cr_emp IS SELECT * FROM employees;

v_salary NUMBER(20, 2); 
v_did INTEGER;
v_rec_employees employees%ROWTYPE;
BEGIN
OPEN cr_emp;
LOOP
OPEN cr;
FETCH cr_emp INTO v_rec_employees;
    LOOP
        FETCH cr INTO v_salary, v_did;
        IF v_rec_employees.salary > v_salary AND v_rec_employees.department_id = v_did THEN dbms_output.put_line(v_rec_employees.name ||  ' ' || v_rec_employees.surname
          || ' '  || v_rec_employees.salary || ' ' || v_salary); END IF;
        EXIT WHEN cr%NOTFOUND;
    END LOOP;
CLOSE cr;
EXIT WHEN cr_emp%NOTFOUND;
END LOOP;
CLOSE cr_emp;
END;
/

EXEC sredniezarobki;

--2
CREATE OR REPLACE PROCEDURE depr_max_budget (p_no_dept IN INTEGER)
AS
CURSOR cr IS SELECT * FROM departments ORDER BY year_budget DESC FETCH FIRST p_no_dept ROWS WITH TIES;
v_depts departments%ROWTYPE;
BEGIN
OPEN cr;
LOOP
FETCH cr INTO v_depts;
dbms_output.put_line(v_depts.name || ' ' || v_depts.year_budget);
EXIT WHEN cr%NOTFOUND;
END LOOP;
END;
/
EXEC depr_max_budget(4);

--3
CREATE OR REPLACE PROCEDURE raisesal
AS
v_count INTEGER;
BEGIN
FOR r_emp IN (SELECT * FROM employees)
LOOP
    SELECT count(position_id) INTO v_count FROM positions_history WHERE employee_id = r_emp.employee_id;
    IF v_count >= 1 THEN UPDATE employees SET salary = salary*1.02 WHERE employee_id = r_emp.employee_id; END IF;
END LOOP;
END;
/

EXEC raisesal;










