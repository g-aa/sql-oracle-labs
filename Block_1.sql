
-- Block №1

-- LAB 1.1:
SELECT  employee_id, last_name, salary*12 AS "ANNUAL SALARY"
FROM employees;

-- "sal" -> salary;
-- "," -> после last_name
-- "x" -> *;
-- ANNUAL SALARY - > "ANNUAL SALARY" or ANNUAL_SALARY


-- LAB 1.2:
DESCRIBE departments;

SELECT  department_id, department_name, manager_id, location_id
FROM departments;


-- LAB 1.3:
DESCRIBE employees;

SELECT  employee_id, last_name, job_id, TO_CHAR(hire_date, 'DD-MON-RR','NLS_DATE_LANGUAGE = ENGLISH') AS "StartDate"
FROM employees;


-- LAB 1.5:
SELECT  DISTINCT job_id
FROM employees;


-- LAB 1.6:
SELECT  employee_id AS "Emp #", last_name AS "Employee", job_id AS "Job", TO_CHAR(hire_date, 'DD-MON-RR','NLS_DATE_LANGUAGE = ENGLISH') AS "Hire Date"
FROM employees;


-- LAB 1.7:
SELECT  last_name || ', ' || job_id AS "Employee and Title"
FROM employees;


-- LAB 1.8:
SELECT  employee_id || ',' ||
        first_name || ',' ||
        last_name || ',' ||
        email || ',' ||
        phone_number || ',' ||
        hire_date || ',' ||
        job_id || ',' ||
        salary || ',' ||
        commission_pct || ',' ||
        manager_id || ',' ||
        department_id AS THE_OUTPUT

FROM employees;


-- LAB 2.1:
SELECT  last_name, salary
FROM employees
WHERE salary > 12000;


-- LAB 2.2:
SELECT  last_name, department_id
FROM employees
WHERE employee_id = 176;


-- LAB 2.3:
SELECT  last_name, salary
FROM employees
WHERE salary NOT BETWEEN 5000 AND 12000;


-- LAB 2.4:
SELECT  last_name, job_id, TO_CHAR(hire_date, 'DD-MON-RR','NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE
FROM employees
WHERE hire_date BETWEEN TO_DATE('20-ФЕВ-2008','DD-MON-YYYY') AND TO_DATE('01-МАЙ-2008','DD-MON-YYYY')
ORDER BY hire_date ASC;


-- LAB 2.5:
SELECT  last_name, department_id
FROM employees
WHERE department_id IN (20, 50)
ORDER BY last_name ASC;


-- LAB 2.6:
SELECT  last_name AS "Employee", salary AS "Monthly Salary"
FROM employees
WHERE department_id IN (20, 50) 
AND salary BETWEEN 5000 AND 12000;


-- LAB 2.7:
SELECT  last_name, TO_CHAR(hire_date,'DD-MON-RR','NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE
FROM employees
WHERE TO_CHAR(hire_date,'YYYY') = '2004';


-- LAB 2.8:
SELECT  last_name, job_id
FROM employees
WHERE manager_id IS NULL;


-- LAB 2.9:
SELECT  last_name, salary, TO_CHAR(commission_pct, 'fm9.999') AS COMMISSION_PCT
FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY salary, commission_pct DESC;


-- LAB 2.10:
SELECT  last_name, salary
FROM employees
WHERE salary > '&min_salary_limit';


-- LAB 2.11:
SELECT  employee_id, last_name, salary, department_id
FROM employees
WHERE manager_id = '&Please_enter_manager_id';


-- LAB 2.12:
SELECT  last_name
FROM employees
WHERE last_name LIKE '__a%';


-- LAB 2.13:
SELECT  last_name
FROM employees
WHERE   LOWER(last_name) LIKE '%a%' AND LOWER(last_name) LIKE '%e%';


-- LAB 2.14:
SELECT  last_name, job_id, salary
FROM employees
WHERE	job_id IN ('SA_REP', 'ST_CLERK')
AND 	salary NOT IN (2500, 3500, 7000);


-- LAB 2.15:
SELECT  last_name AS "Employee", salary AS "Monthly Salary", TO_CHAR(commission_pct,'fm99.99') AS COMMISSION_PCT
FROM employees
WHERE commission_pct = TO_NUMBER('20', '999')/100;


-- LAB 3.1.1:
SELECT  TO_CHAR(sysdate, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS "Date",
        TO_CHAR(CURRENT_DATE, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS "Date"
FROM SYS.DUAL;


-- LAB 3.1.2:
SELECT  employee_id, last_name, salary,
        ROUND(salary*(1 + TO_NUMBER('15.5','99.99')/100),0) AS "New Salary"
FROM 	employees;


-- LAB 3.1.4:
SELECT  employee_id, last_name, salary,
        ROUND(salary*(1 + TO_NUMBER('15.5','99.99')/100),0) AS "New Salary",
        ROUND(salary*(1 + TO_NUMBER('15.5','99.99')/100) - salary,0) AS "Increase"
FROM 	employees;


-- LAB 3.1.5:
SELECT  INITCAP(last_name) AS "Orig Name",
      	SUBSTR(last_name,1,1) || LOWER(TRIM(SUBSTR(last_name,1,1) FROM last_name)) AS "Name",
        LENGTH(last_name) AS "Length"
        
FROM    employees
WHERE   SUBSTR(INITCAP(last_name), INSTR(last_name, '_') + 1,1) IN ('J','A', 'M')
ORDER BY 	last_name ASC;


-- LAB 3.1.6:
SELECT  INITCAP(last_name) AS "Orig Name",
      	SUBSTR(last_name,1,1) || LOWER(TRIM(SUBSTR(last_name,1,1) FROM last_name)) AS "Name",
		LENGTH(last_name) AS "Length"

FROM 	employees
WHERE 	SUBSTR(INITCAP(last_name), INSTR(last_name, ' ') + 1,1) = SUBSTR(UPPER('&Please_enter_the_simbol'),1,1)
ORDER BY	last_name ASC;


--LAB 3.1.7:
SELECT  last_name, ROUND(MONTHS_BETWEEN(SYSDATE, hire_date),0) AS MONTH_WORKED
FROM 	employees
ORDER BY MONTH_WORKED ASC;


-- LAB 3.2.1:
SELECT  last_name || ' earns ' ||
        TO_CHAR(salary,'fm$99,999.00') || ' monthly but wants ' ||
        TO_CHAR((salary*3),'fm$99,999.00') AS "Dream Salaries"

FROM 	employees
ORDER BY salary DESC;


-- LAB 3.2.2:
SELECT  emp.last_name,
        -- LENGTH(emp.salary),
        LPAD('$',(15 - LENGTH(emp.salary)),'$') ||
        TO_CHAR(emp.salary, 'fm99999') AS SALARY

FROM employees emp
ORDER BY emp.salary DESC;


-- LAB 3.2.3:
SELECT  last_name,
        TO_CHAR(hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE,
        TO_CHAR(NEXT_DAY(ADD_MONTHS(hire_date, 6), 'Понедельник'), '"Monday, the" fmDdspth "of" Month, RRRR', 'NLS_DATE_LANGUAGE = ENGLISH') AS REVIEW

FROM employees;


-- LAB 3.2.4:
-- (a)
SELECT  last_name,
        TO_CHAR(hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE,
        TO_CHAR(hire_date, 'DAY','NLS_DATE_LANGUAGE = ENGLISH') AS "DAY"
        
FROM employees
ORDER BY TO_CHAR(TO_DATE(HIRE_DATE, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH'),'D')  ASC;

-- (b)
SELECT  emp.last_name,
        TO_CHAR(emp.hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS HIRE_DATE,
        TO_CHAR(emp.hire_date, 'DAY','NLS_DATE_LANGUAGE = ENGLISH') AS "DAY"
        
FROM employees emp
ORDER BY TO_CHAR(emp.hire_date,'D')  ASC;

-- (c)
SELECT  last_name,
        TO_CHAR(hire_date, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS " HIRE_DATE ",
        TO_CHAR(hire_date, 'DAY','NLS_DATE_LANGUAGE = ENGLISH') AS "DAY"
        
FROM employees
ORDER BY TO_CHAR(hire_date,'D')  ASC;
        

--LAB 3.2.5 (b):
SELECT  last_name,
        NVL2(commission_pct, TO_CHAR(commission_pct, 'fm99.99'), 'No Commission') 
        AS COMM

FROM employees
ORDER BY COMM ASC;


-- LAB 3.2.6:
WITH 
MyDATE AS (
SELECT  TO_DATE('31.12.-1','DD.MM.sYYYY') AS BegDate,
        TO_DATE('01.01.1','DD.MM.sYYYY') AS EndDate

FROM    SYS.DUAL
),                    
GetMonths AS ( 
SELECT  MONTHS_BETWEEN(EndDate, BegDate) AS MinY,
        BegDate,
        EndDate
        
FROM    MyDATE
),

GetYears AS (
SELECT  (TRUNC(MinY) - TRUNC(MOD(MinY, 12)))/12 AS Ys,
        MinY,
        BegDate,
        EndDate
        
FROM    GetMonths
),
GetDays AS ( 
SELECT  EndDate - ADD_MONTHS(BegDate, TRUNC(MinY)) AS Ds,
        Ys,
        TRUNC(MOD(MinY, 12)) AS Ms,
        BegDate,
        EndDate
        
FROM    GetYears
)

SELECT  CASE 
        WHEN (BegDate > TO_DATE('31.12.-1','DD.MM.sYYYY') AND EndDate > TO_DATE('31.12.-1','DD.MM.sYYYY')) 
                OR (BegDate <= TO_DATE('31.12.-1','DD.MM.sYYYY') AND EndDate <= TO_DATE('31.12.-1','DD.MM.sYYYY'))
            THEN Ys || ' лет ' || Ms || ' мес. ' || Ds || ' дней'
        ELSE
            Ys-1 || ' лет ' || Ms || ' мес. ' || Ds || ' дней'
        END AS "Result" 

FROM    GetDays;


--LAB 3.2.7:
SELECT  dept.DEPARTMENT_NAME AS DEPT_NAME,
        --INSTR(dept.DEPARTMENT_NAME, ' '),
       
        CASE 
        WHEN SUBSTR(dept.DEPARTMENT_NAME, 1,INSTR(dept.DEPARTMENT_NAME, ' ')) IS NULL THEN dept.DEPARTMENT_NAME 
        WHEN SUBSTR(dept.DEPARTMENT_NAME, 1,INSTR(dept.DEPARTMENT_NAME, ' ', 1, 2)) IS NULL THEN SUBSTR(dept.DEPARTMENT_NAME, INSTR(dept.DEPARTMENT_NAME, ' ') + 1) 
        ELSE SUBSTR(dept.DEPARTMENT_NAME, INSTR(dept.DEPARTMENT_NAME, ' ') + 1, INSTR(dept.DEPARTMENT_NAME, ' ',1,2) - INSTR(dept.DEPARTMENT_NAME, ' '))        
        END AS "Result"
        
FROM    DEPARTMENTS dept;


-- LAB 3.2.8:
SELECT  RPAD(last_name,LENGTH(last_name) + TRUNC(salary/1000),'*') 
        AS "EMPLOYEES AND THEIR SALARIES"

FROM employees
ORDER BY salary DESC;


-- LAB 3.2.9:
SELECT  job_id,
        DECODE(LOWER(job_id),   'ad_pres', 'A',
                                'st_man', 'B',
                                'it_prog', 'C',
                                'sa_rep', 'D',
                                'st_clerk', 'E',
                                '0') AS "G"
FROM employees;


-- LAB 3.2.10:
SELECT  job_id,
        CASE LOWER(job_id)  WHEN 'ad_pres'  THEN 'A'
                            WHEN 'st_man'   THEN 'B'
                            WHEN 'it_prog'  THEN 'C'
                            WHEN 'sa_rep'   THEN 'D'
                            WHEN 'st_clerk' THEN 'E'
                            ELSE '0'
        END "G"
FROM employees;


-- LAB 3.2.11:
WITH MyStr AS (
SELECT 	'22' AS str 
FROM 	SYS.DUAL
)

SELECT	0 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '0', '')), 0)) +
        1 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '1', '')), 0)) +
		2 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '2', '')), 0)) +
		3 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '3', '')), 0)) +
		4 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '4', '')), 0)) +
		5 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '5', '')), 0)) +
		6 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '6', '')), 0)) +
		7 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '7', '')), 0)) +
		8 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '8', '')), 0)) +
		9 * (LENGTH(str) - NVL(LENGTH(REPLACE(str, '9', '')), 0)) AS "RESULT"
FROM MyStr; 


-- LAB 4.1:
SELECT  MAX(salary) AS "Maximum",
        MIN(salary) AS "Minimum",
        SUM(salary) AS "Sum",
        ROUND(AVG(salary), 0) AS "Average"

FROM employees;


-- LAB 4.2:
SELECT  job_id,
        MAX(salary) AS "Maximum",
        MIN(salary) AS "Minimum",
        SUM(salary) AS "Sum",
        ROUND(AVG(salary), 0) AS "Average"

FROM employees
GROUP BY job_id
ORDER BY job_id ASC;


-- LAB 4.3:
SELECT  job_id,
        COUNT(job_id) AS CNT

FROM employees
GROUP BY job_id
ORDER BY job_id ASC;


-- LAB 4.4:
SELECT  COUNT(DISTINCT manager_id) AS "Number of Managers"

FROM employees;


-- LAB 4.5:
SELECT  MAX(salary) - MIN(salary) AS DIFFERENCE

FROM employees;


-- LAB 4.6:
SELECT  manager_id,
        --count( manager_id) AS NUM,
        MIN(salary) AS MIN_SALARY

FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY MIN_SALARY DESC;


-- LAB 4.7:
SELECT  COUNT(employee_id) AS TOTAL,
        COUNT(DECODE(TO_CHAR(hire_date, 'YYYY'),'2005',1)) AS "2005",
        COUNT(DECODE(TO_CHAR(hire_date, 'YYYY'),'2006',1)) AS "2006",
        COUNT(DECODE(TO_CHAR(hire_date, 'YYYY'),'2007',1)) AS "2007",
        COUNT(DECODE(TO_CHAR(hire_date, 'YYYY'),'2008',1)) AS "2008"
        
FROM employees;



-- LAB 4.8:
SELECT  job_id AS "Job",
        
        CASE department_id WHEN 20 THEN TO_CHAR(SUM(salary)) ELSE ' ' END AS "Dept20",
        CASE department_id WHEN 50 THEN TO_CHAR(SUM(salary)) ELSE ' ' END AS "Dept50",        
        CASE department_id WHEN 80 THEN TO_CHAR(SUM(salary)) ELSE ' ' END AS "Dept80",
        CASE department_id WHEN 90 THEN TO_CHAR(SUM(salary)) ELSE ' ' END AS "Dept90",
        SUM(salary) AS "Total"
        
FROM employees
GROUP BY job_id, department_id
HAVING department_id IN (20, 50, 80, 90);