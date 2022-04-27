SELECT
    e.name || ' ' || e.surname,
    old.employee_id,
    old.position_id AS old_position_id,
    p_old.name AS old_position,
    old.date_end AS change_date,
    new.position_id AS new_position_id,
    p_new.name AS new_position
FROM positions_history old
    LEFT JOIN positions_history new ON ((old.date_end = new.date_start)
                                    AND (old.employee_id = new.employee_id))
    INNER JOIN employees e ON (old.employee_id = e.employee_id)
    INNER JOIN positions p_old ON (old.position_id = p_old.position_id)
    LEFT JOIN positions p_new ON (new.position_id = p_new.position_id)
WHERE EXTRACT(YEAR FROM old.date_end) BETWEEN 2006 AND 2008
AND p_old.name IN ('Programista', 'Konsultant');


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

PURGE RECYCLEBIN;

SELECT COUNT(*) FROM RECYCLEBIN;

SELECT MAX(salary) FROM employees;

select a.city, count(d.department_id), coalesce(avg(d.year_budget), 0)
from departments d
right join addresses a on (a.address_id = d.address_id)
group by a.city, a.address_id;


select d.name, count(e.employee_id), floor(months_between(sysdate, e.birth_date)/12) age, avg(e.salary)
from employees e
join departments d on (e.department_id = d.department_id)
group by floor(months_between(sysdate, e.birth_date)/12), d.name, d.department_id;


-- Zwróæ listê pracowników, których mened¿erem jest pracownik maj¹cy pod sob¹ przynajmniej 2 podleg³e osoby. 
-- W wynikach zamieœæ imiê i nazwisko pracownika, imiê i nazwisko kierownika oraz liczbê pracownikow podleg³ych kierownikowi, atak¿e liczbê jemu podleg³ych pracowników.

SELECT e.name, e.surname, man.name, man.surname, man_count, (SELECT COUNT(*) FROM employees e2 WHERE e2.manager_id = e.employee_id)
FROM employees e
JOIN employees man ON e.manager_id = man.employee_id
WHERE (SELECT COUNT(*) FROM employees e2 WHERE e2.manager_id = man.employee_id) man_count >= 2;

SELECT e.employee_id, e.name, e.surname, g.grade, g.description
FROM employees e join emp_grades eg on (e.employee_id = eg.employee_id) join grades g on(eg.grade_id = g.grade_id)
where EXTRACT(YEAR from eg.inspection_date) > 2017;


-- Napisz zapytanie, które zwróci nazwê zak³adu, nazwê kraju oraz 
-- konktenacjê imienia i nazwiska pracowników zatrudnionych w zak³adach maj¹cych swoje siedziby w krajach, w których liczba ludnoœci jest wy¿sza ni¿ 40 (mln).

SELECT d.name, c.name, e.name || ' ' || e.surname employee_name
FROM countries c JOIN addresses a USING(country_id) JOIN departments d USING(address_id) JOIN employees e USING(department_id)
WHERE c.population > 40;



-- Napisz zapytanie zwracaj¹ce informacje o pracownikach, których kierownikiem jest Irene Janowski. W wynikach podaj: imiê i nazwisko  pracownika, jego nazwê zak³adu oraz imiê i nazwisko kierownika.
SELECT emp.name, emp.surname, d.name, man.name, man.surname
FROM employees emp JOIN employees man ON (emp.manager_id = man.employee_id) JOIN departments d ON (emp.department_id = d.department_id)
WHERE man.name LIKE 'Irene' AND man.surname LIKE 'Janowski';

--Napisz zapytanie zwracaj¹ce informacje o pracownikach, których kierownikiem jest Irene Janowski. W wynikach podaj: imiê i nazwisko  pracownika, jego nazwê zak³adu oraz imiê i nazwisko kierownika
select e.name, e.surname, d.department_id, m.name, m.surname
from employees e
join departments d on (d.department_id = e.department_id)
join employees m on (m.employee_id = e.manager_id)
where e.manager_id = (select e2.employee_id from employees e2 where e2.name like 'Irene' and e2.surname like 'Janowski');

-- Napisz zapytanie, które zwróci œredni roczny bud¿et departamentów dla grup tworzonych ze wzglêdu na managera departamentu i podgrup tworzonych ze wzglêdu na rok za³o¿enia departamentu.

-- Wykorzystuj¹c podzapytania napisz zapytanie zwracaj¹ce nazwê departamentu, w którym pracuje najmniej zarabiaj¹cy pracownik.
select d.name
from employees e
left join departments d on (e.department_id = d.department_id)
where e.salary = (select min(salary) from employees);

-- Wykorzystuj¹c podzapytania napisz zapytanie, które zwróci historiê zajmowanych stanowisk dla pracownika o najmniejszych zarobkach.
SELECT *
FROM employees e JOIN positions_history h USING(employee_id)
WHERE e.salary = (SELECT MIN(salary) FROM employees);

--Napisz zapytanie, które zwróci œredni roczny bud¿et departamentów dla grup tworzonych ze wzglêdu na managera departamentu i podgrup tworzonych ze wzglêdu na rok za³o¿enia departamentu.

select avg(d.year_budget), d.manager_id, extract(year from d.established)
from departments d
group by manager_id, extract(year from d.established);


--

SELECT d.name, man.name || ' ' || man.surname, (SELECT memp.name || ' ' || memp.surname FROM employees memp WHERE memp.salary = (SELECT MAX(salary) FROM employees emp WHERE emp.department_id = d.department_id) AND memp.department_id = d.department_id)
FROM departments d
JOIN employees man ON man.employee_id = d.manager_id
WHERE man.salary < (SELECT MAX(salary) FROM employees emp WHERE emp.department_id = d.department_id);

SELECT d.name, man.name || ' ' || man.surname, memp.name || ' ' || memp.surname
FROM departments d
LEFT JOIN employees man ON man.employee_id = d.manager_id 
LEFT JOIN employees memp ON memp.department_id = d.department_id AND memp.salary = (SELECT MAX(salary) FROM employees emp WHERE emp.department_id = d.department_id)
WHERE man.employee_id != memp.employee_id;
