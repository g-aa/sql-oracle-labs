-- Block №1

-- LAB 5.6:
SELECT  	e.last_name AS "Employee",
        	e.employee_id AS "Emp#",
        	m.last_name AS "Manager",
        	m.employee_id AS "Mgr#"

FROM employees e
JOIN employees m
ON (e.manager_id = m.employee_id)
ORDER BY e.employee_id ASC;


-- LAB 5.7:
SELECT  	e.last_name AS "Employee",
        	TO_CHAR(e.employee_id) AS "Emp#",
        	NVL(m.last_name,' ') AS "Manager",
        	NVL(TO_CHAR(e.manager_id), ' ') AS "Mgr#"

FROM employees e
LEFT OUTER JOIN employees m
ON (e.manager_id = m.employee_id)
ORDER BY e.employee_id ASC;


-- LAB 5.8:
SELECT  	emp.department_id AS DEPARTMENT,
            emp.last_name AS EMPLOYEE,
        	NVL(clg.last_name, ' ') AS COLLEGUE
        	
FROM employees emp
LEFT OUTER JOIN employees clg
ON (emp.department_id = clg.department_id)
AND (emp.employee_id <> clg.employee_id)
ORDER BY emp.department_id, emp.employee_id ASC;


-- LAB 5.9:
DESCRIBE job_grades;

SELECT emp.last_name,
       emp.job_id,
       NVL(dep.department_name, ' '),
       emp.salary,
       gra.grade_level
        
FROM departments dep
RIGHT OUTER JOIN employees emp
ON (dep.department_id = emp.department_id)
JOIN job_grades gra
ON (emp.salary BETWEEN gra.lowest_sal AND gra.highest_sal)
ORDER BY emp.employee_id ASC;


-- LAB 5.10:
SELECT  	e1.last_name,
        	TO_CHAR(e1.hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE

FROM employees e1
CROSS JOIN employees e2
WHERE ( UPPER(e2.last_name) = 'DAVIES' AND e1.hire_date < e2.hire_date )
ORDER BY e1.hire_date ASC;


-- LAB 5.11:
SELECT  	emp.last_name AS "Employee",
        	TO_CHAR(emp.hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS "Emp Hired",
        	NVL(mng.last_name, ' ') AS "Manager",
        	NVL(TO_CHAR(mng.hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH'), ' ') AS "Mng Hired"

FROM employees emp
LEFT OUTER JOIN employees mng
ON (emp.manager_id = mng.employee_id)
WHERE emp.hire_date < mng.hire_date OR emp.manager_id IS NULL;


-- LAB 5.12:
SELECT  dep.department_id,
        dep.department_name,
        NVL(dep.location_id, 0) AS LOCATION_ID,
        NVL(COUNT(emp.department_id),0) AS "COUNT"

FROM departments dep
LEFT OUTER JOIN employees emp
ON (dep.department_id = emp.department_id)
GROUP BY    dep.department_id, dep.department_name, NVL(dep.location_id, 0)
ORDER BY    dep.department_id ASC;


-- LAB 5.13:
SELECT  	emp.job_id,
        	COUNT(dep.department_id) AS FREQUENCY
        
FROM employees emp
JOIN departments dep
ON (emp.department_id = dep.department_id)
AND (dep.department_name = 'Administration' OR dep.department_name = 'Executive')
GROUP BY emp.job_id, dep.department_id
ORDER BY FREQUENCY DESC;


-- LAB 5.14:
SELECT	emp.last_name,
        mng.last_name AS MANAGER,
        mng.salary,
        gr.grade_level AS GRA

FROM employees emp
JOIN employees mng
ON (emp.manager_id = mng.employee_id)
AND (mng.salary > 15000)
JOIN job_grades gr
ON (mng.salary BETWEEN gr.lowest_sal AND gr.highest_sal);


-- LAB 5.15:
SELECT  	emp.last_name,
        	NVL(dep.department_name, ' ') AS department_name, 
        	NVL(TO_CHAR(dep.location_id), ' ') AS location_id,
        	NVL(TO_CHAR(loc.city), ' ') AS city
        
FROM departments dep
JOIN locations loc
ON (dep.location_id = loc.location_id)
RIGHT OUTER JOIN employees emp
ON (dep.department_id = emp.department_id)
WHERE emp.commission_pct IS NOT NULL;


-- LAB 6.1:
SELECT  emp.last_name,
        TO_CHAR(emp.hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE
        
FROM employees emp
WHERE emp.department_id IN (SELECT  e.department_id
                            FROM    employees e
                           	WHERE   e.last_name = 'Zlotkey')
AND emp.last_name <> 'Zlotkey'
ORDER BY emp.last_name ASC;


-- LAB 6.2:
SELECT	employee_id,
        last_name,
        salary
        
FROM 	employees
WHERE 	salary > (SELECT ROUND(AVG(salary), 0)
                  FROM employees)
ORDER BY salary ASC;


-- LAB 6.3:
SELECT  NVL(TO_CHAR(emp.department_id), ' ') AS DEPT,
        emp.last_name,
        emp.salary
FROM    employees emp
JOIN (SELECT    NVL(TO_CHAR(e2.department_id), ' ') AS E2DEPT,
                ROUND(AVG(e2.salary), 0) AS E2DAVGS
      FROM      employees e2
      GROUP BY  NVL(TO_CHAR(e2.department_id), ' '))
ON (NVL(TO_CHAR(emp.department_id), ' ') = E2DEPT)
AND emp.salary >= E2DAVGS
ORDER BY NVL(TO_CHAR(emp.department_id), ' ') ASC;


-- LAB 6.4:
SELECT 	 employee_id, last_name
        
FROM employees
WHERE department_id IN (SELECT  department_id 
                        FROM employees 
                        WHERE last_name LIKE '%u%' 
                        HAVING COUNT(employee_id) > 1 
                        GROUP BY department_id);


-- LAB 6.5:
SELECT	last_name, department_id, job_id
FROM 	employees
WHERE 	department_id IN (SELECT department_id
						  FROM departments
                          WHERE location_id = 1700)
ORDER BY department_id ASC;


-- LAB 6.6:
SELECT  last_name, salary
FROM 	employees
WHERE 	manager_id = (	SELECT  employee_id
                    	FROM    employees
                    	WHERE   last_name = 'King'
                    	AND     manager_id IS NULL)
ORDER BY salary DESC;


-- LAB 6.7:
SELECT  department_id, last_name, job_id        
FROM 	employees
WHERE 	department_id = (SELECT department_id
                       	 FROM   departments
                       	 WHERE  department_name = 'Executive');


-- LAB 6.8:
SELECT  employee_id, last_name, salary
FROM    employees
WHERE   department_id IN (SELECT    department_id
                          FROM      employees
                          WHERE   last_name LIKE '%u%'
                          AND     salary > (SELECT ROUND(AVG(salary), 0)
                                            FROM employees)
                          HAVING COUNT (employee_id) > 1
                          GROUP BY department_id);


-- LAB 6.9:
SELECT  	department_id, MIN(salary)
FROM 		employees
GROUP BY 	department_id
HAVING department_id = (SELECT department_id
                        FROM employees
                        GROUP BY department_id
                        HAVING AVG(salary) = (SELECT  MAX(AVG(salary))
                                			  FROM employees
                                              GROUP BY department_id));


-- LAB 6.10:
WITH LOC_DEPT_MSAL AS
(
SELECT  e.department_id AS DEPT_ID,
        d.location_id AS LOC_ID,
        ROUND(SUM(e.salary), 0) AS SUM_SAL
FROM employees e
JOIN departments d
ON (e.department_id = d.department_id)
GROUP BY e.department_id, d.location_id
),
LOC_AVG_MSAL AS
(
SELECT  LOC_ID,
        ROUND(AVG(SUM_SAL),0) AS AVG_SUM
FROM LOC_DEPT_MSAL
GROUP BY LOC_ID
)


SELECT  d.department_id,
        d.department_name,
        d.location_id,
        l.city,
        SUM(e.salary) AS DEPT_SUM_SAL,
        las.AVG_SUM
        
FROM departments d
JOIN locations l
ON(d.location_id = l.location_id)
JOIN employees e
ON (d.department_id = e.department_id)
JOIN LOC_AVG_MSAL las
ON (l.location_id = las.LOC_ID)
GROUP BY d.department_id, d.department_name, d.location_id, l.city, las.AVG_SUM
HAVING SUM(e.salary) >= las.AVG_SUM 
ORDER BY d.department_id ASC;


-- LAB 6.11:
SELECT  department_id, department_name, manager_id, location_id
FROM 	departments
WHERE 	department_id <> ANY (SELECT  department_id
                              FROM    employees
                              WHERE   LOWER(job_id) = 'sa_rep'
                              GROUP BY    department_id);


-- LAB 6.12:


-- LAB 6.13:
WITH temp AS
(
SELECT DISTINCT salary AS SAL
FROM employees
ORDER BY salary DESC
),
temp1 AS
(
SELECT DISTINCT SAL AS SAL,
       rownum AS SAL_RANG
FROM temp
)

SELECT e.last_name, e.salary, t1.SAL_RANG
FROM employees e
JOIN temp1 t1
ON(e.salary = t1.SAL)
ORDER BY e.salary DESC;

-- LAB 7.1:
SELECT	e1.department_id
FROM 	employees e1
MINUS
SELECT	e2.department_id
FROM 	employees e2
WHERE 	job_id = 'ST_CLERK';


-- LAB 7.2:
SELECT  country_id AS CO, country_name
FROM    countries
WHERE   country_id NOT IN (SELECT DISTINCT loc.country_id
                           FROM locations loc
                           JOIN departments dep
                           ON(loc.location_id = dep.location_id));
						   

-- LAB 7.3:


-- LAB 7.4:
SELECT	e.employee_id, e.job_id
FROM 	employees e
INTERSECT
SELECT	j.employee_id, j.job_id
FROM 	job_history j;


-- LAB 7.5:
SELECT  department_id, 
        employee_id,
       	TO_CHAR(NULL) department_name        
FROM employees
UNION
SELECT  department_id,
        TO_NUMBER(NULL) employee_id,
        department_name
FROM departments
ORDER BY department_id ASC;    


-- LAB 8.1 & 8.2:
CREATE TABLE    my_employees (
NUM_ID      	NUMBER(4) CONSTRAINT my_emp_id_nn NOT NULL,
LAST_NAME   	VARCHAR2(25),
FIRST_NAME	VARCHAR2(25),
USER_ID     	VARCHAR2(8),
SALARY      	NUMBER(9,2));

DESCRIBE my_employees;


-- LAB 8.3:
INSERT INTO my_employees
VALUES (1,  'Patel',    'Ralph',    'rpatel',   895);


-- LAB 8.4:
INSERT INTO my_employees (	num_id, last_name, first_name, user_id, salary)
VALUES (2,  'Dancs',    'Betty',    'bdancs',   860);


-- LAB 8.6:
INSERT INTO my_employees 
VALUES (&num_id, '&&last_name', '&&first_name', SUBSTR(LOWER('&first_name'),1,1) || SUBSTR(LOWER('&last_name'),1,7), &salary);
UNDEFINE  (num_id, last_name, first_name, salary);


-- LAB 8.9:
COMMIT;


-- LAB 8.10:
UPDATE my_employees
SET last_name = 'Drexler'
WHERE ID = 3;


-- LAB 8.11:
UPDATE my_employees
SET salary = 1000
WHERE salary < 900;


-- LAB 8.13:
DELETE  FROM my_employees
WHERE   last_name = 'Dancs' 
AND     first_name = 'Betty';


-- LAB 8.15:
COMMIT;


-- LAB 8.16:
