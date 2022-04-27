--slajd 8
--1
BEGIN
NULL;
END;
/
--2
BEGIN
dbms_output.put_line('Napis');
END;
/
--3
BEGIN
INSERT INTO regions VALUES (201, 'Oceania', 'OC');
END;
/
SELECT * FROM regions;

BEGIN 
RAISE_APPLICATION_ERROR(-20000, 'Moja wiadomosc bledu');
END;
/
--slajd 13
--1
DECLARE
v_min_sal employees.salary%TYPE := 2000;
v_emp_id employees.employee_id%TYPE := 101;

v_emp_name employees.name%TYPE;
v_emp_surname employees.surname%TYPE;
v_emp_salary_act employees.salary%TYPE;

BEGIN

SELECT name, surname INTO v_emp_name, v_emp_surname
FROM employees WHERE employee_id = v_emp_id;

SELECT salary INTO v_emp_salary_act 
FROM employees WHERE employee_id = v_emp_id;

IF v_emp_salary_act > v_min_sal THEN
dbms_output.put_line('Imie: ' || v_emp_name || ' nazwisko: ' || v_emp_surname);
END IF;
END;
/

--slajd 20 (funkcje)
--1
CREATE FUNCTION podatek (p_eid INTEGER)
RETURN NUMBER
AS
    v_threshold NUMBER(10,0);
    v_tax1 NUMBER(2,2) := 0.15;
    v_tax2 NUMBER(2,2) := 0.25;
    v_salary employees.salary%TYPE;
BEGIN
    
    SELECT salary INTO v_salary
    FROM employees WHERE employee_id = p_eid;
    
    IF v_salary*v_tax1 < v_threshold THEN
        RETURN v_salary*v_tax1;
    ELSE
        RETURN v_salary*v_tax2;
    END IF;
END;
/

--2
--WIDOK

--3
CREATE FUNCTION dodatek (p_eid INTEGER)
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
/
SELECT m.employee_id, dodatek(m.employee_id)
FROM employees m
WHERE NOT EXISTS (SELECT e.employee_id
    FROM employees e
    WHERE e.manager_id = m.employee_id);

--4
CREATE FUNCTION total_bonus (p_eid INTEGER)
RETURN NUMBER
AS
BEGIN
    RETURN calculate_seniority_bonus(p_eid) + dodatek(p_eid);
END;
/
SELECT total_bonus(employee_id) FROM employees;

--slajd 26 (procedury)
--1
CREATE PROCEDURE update_pos (p_eid INTEGER, p_pid INTEGER)
AS
BEGIN
    UPDATE employees SET position_id = p_pid WHERE employee_id = p_eid;
END;
/

--3 (rozwiązanie jeśli pracownik jest managerem tylko 1 dept).
CREATE PROCEDURE change_manager (p_mid INTEGER)
AS
v_did INTEGER;
v_eid INTEGER;
BEGIN
    SELECT department_id INTO v_did
    FROM departments WHERE manager_id = p_mid;
    
    SELECT employee_id INTO v_eid
    FROM employees 
    WHERE employee_id = (SELECT employee_id FROM employees WHERE department_id = v_did ORDER BY birth_date ASC NULLS LAST FETCH FIRST ROW ONLY);

    UPDATE departments SET manager_id = v_eid WHERE manager_id = p_mid;
END;
/

BEGIN
 change_manager(102);   
END;

