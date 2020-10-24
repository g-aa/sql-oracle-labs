-- Block №1


-- lab 5.1:
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';

-- lab 5.2:
SELECT	TZ_OFFSET('US/Pacific-New') AS "US/Pacific-New",
        TZ_OFFSET('Singapore') AS "Singapore", 
		TZ_OFFSET('Egypt') AS "Egypt"   
FROM SYS.DUAL;

ALTER SESSION SET TIME_ZONE = 'US/Pacific-New';

SELECT	CURRENT_DATE, CURRENT_TIMESTAMP, LOCALTIMESTAMP
FROM SYS.DUAL;

ALTER SESSION SET TIME_ZONE = 'Singapore';

-- lab 5.3:
SELECT	DBTIMEZONE, SESSIONTIMEZONE        
FROM SYS.DUAL;

-- lab 5.4:
SELECT	emp.DEPARTMENT_ID, emp.HIRE_DATE
FROM EMPLOYEES emp
WHERE emp.DEPARTMENT_ID = 80;

-- lab 5.5:
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- lab 5.6:
SELECT  	e.LAST_NAME, EXTRACT(MONTH FROM e.HIRE_DATE) AS "MONTH",
       		e.HIRE_DATE       
FROM EMPLOYEES e
WHERE TO_CHAR(e.HIRE_DATE, 'MON') = 'ЯНВ';


-- lab 6.1:
WITH tmp AS (
SELECT DEPARTMENT_ID, SALARY
FROM EMPLOYEES e1
WHERE COMMISSION_PCT IS NOT NULL
)

SELECT	e.LAST_NAME, e.DEPARTMENT_ID, e.SALARY        
FROM EMPLOYEES e
WHERE (e.DEPARTMENT_ID, e.SALARY) IN (SELECT * FROM tmp)
ORDER BY e.salary ASC;

-- lab 6.2:
WITH tmp AS (
SELECT	e.SALARY, NVL(e.COMMISSION_PCT, 0)
FROM EMPLOYEES e
JOIN DEPARTMENTS d
ON (e.DEPARTMENT_ID = d.DEPARTMENT_ID)
WHERE d.LOCATION_ID = 1700
)

SELECT emp.LAST_NAME, dep.DEPARTMENT_NAME, emp.SALARY
FROM EMPLOYEES emp
JOIN DEPARTMENTS dep
ON (emp.DEPARTMENT_ID = dep.DEPARTMENT_ID)
WHERE (emp.SALARY, NVL(emp.COMMISSION_PCT, 0)) IN (SELECT * FROM tmp)
ORDER BY emp.salary ASC;

-- lab 6.3:
WITH tmp AS (
SELECT SALARY, NVL(COMMISSION_PCT, 0)
FROM EMPLOYEES 
WHERE LAST_NAME = 'Kochhar'
)

SELECT	LAST_NAME,
TO_CHAR(HIRE_DATE, 'DD-MON-RR', 'NLS_DATE_LANGUAGE = ENGLISH') AS "HIRE_DATE", SALARY        
FROM EMPLOYEES
WHERE (SALARY, NVL(COMMISSION_PCT, 0)) IN (SELECT * FROM tmp)  
AND LAST_NAME != 'Kochhar';

-- lab 6.4:
WITH tmp AS (
SELECT SALARY
FROM EMPLOYEES
WHERE JOB_ID = 'SA_MAN'
)

SELECT emp.LAST_NAME, emp.JOB_ID, emp.SALARY
FROM EMPLOYEES emp
WHERE emp.SALARY > ALL (SELECT * FROM tmp)
ORDER BY emp.SALARY DESC;

-- lab 6.5:
SELECT 	emp1.LAST_NAME AS "ENAME", 
		emp1.SALARY, 
		emp1.DEPARTMENT_ID AS "DEPTNO", 
		LPAD(REPLACE(TO_CHAR(ROUND(AVG(avgS.SALARY),4)), ',', '.'), 10) AS DEPT_AVG
FROM EMPLOYEES emp1
JOIN EMPLOYEES avgS
ON (emp1.DEPARTMENT_ID = avgS.DEPARTMENT_ID)
WHERE emp1.SALARY > (SELECT	AVG(emp2.SALARY)
                    FROM 	EMPLOYEES emp2
                    WHERE emp2.DEPARTMENT_ID = emp1.DEPARTMENT_ID)
GROUP BY emp1.LAST_NAME, emp1.SALARY, emp1.DEPARTMENT_ID
ORDER BY AVG(avgS.SALARY) ASC;



-- lab 6.6:
SELECT emp.LAST_NAME
FROM EMPLOYEES emp
WHERE NOT EXISTS (SELECT 'X' FROM EMPLOYEES e2 WHERE emp.EMPLOYEE_ID = e2.MANAGER_ID);

-- lab 6.7:
SELECT emp.LAST_NAME
FROM EMPLOYEES emp
WHERE emp.EMPLOYEE_ID NOT IN (SELECT e2.MANAGER_ID FROM EMPLOYEES e2 WHERE e2.MANAGER_ID = emp.EMPLOYEE_ID);

-- lab 6.8:
SELECT	emp.last_name
FROM    employees emp
WHERE   emp.salary < (SELECT AVG(salary)
                      FROM employees 
                      WHERE department_id = emp.department_id
                      GROUP BY department_id)
ORDER BY emp.last_name ASC;

-- lab 6.9:
SELECT	emp1.LAST_NAME
FROM 	EMPLOYEES emp1
WHERE 	EXISTS (SELECT 'X'
                FROM EMPLOYEES emp2
              	WHERE	(emp1.DEPARTMENT_ID = emp2.DEPARTMENT_ID)
              	AND	(emp1.HIRE_DATE < emp2.HIRE_DATE)
              	AND	(emp1.SALARY < emp2.SALARY))
ORDER BY emp1.LAST_NAME ASC;

-- lab 6.10:
SELECT	e.employee_id,
        e.last_name,
        (SELECT	d.department_name
        FROM 	departments d
        WHERE	d.department_id = e.department_id) AS department
FROM employees e
ORDER BY department;

-- lab 6.11:
WITH summary AS (
SELECT dep.department_name, SUM(emp.SALARY) AS dept_total
FROM DEPARTMENTS dep
JOIN EMPLOYEES emp
ON (dep.DEPARTMENT_ID = emp.DEPARTMENT_ID)
GROUP BY dep.department_name
)

SELECT department_name, dept_total
FROM summary
WHERE dept_total > (SELECT SUM(dept_total)/8 FROM summary)
ORDER BY dept_total DESC;

-- lab 6.12:
DEFINE no_dep_id =  'no dept';
WITH preparation AS (
SELECT  e.last_name, 
        NVL(TO_CHAR(e.department_id), '&no_dep_id') AS department_id, 
        e.salary
FROM employees e
ORDER BY e.department_id ASC, e.salary DESC, e.last_name ASC
), -- сортиповка исходных данных
emps_rid AS (
SELECT p.last_name, p.department_id, p.salary, ROWNUM AS rid
FROM preparation p
), -- присвоение rid каждому emp 
max_sel_depts AS (
SELECT emp.*
FROM emps_rid emp
WHERE emp.salary = (SELECT MAX(salary)
                    FROM emps_rid
                    WHERE department_id = emp.department_id)
), -- поиск максимальных зарплат по отделам
first_n_emps_depts AS (
SELECT  tb.last_name,
        tb.department_id,
        tb.salary,
        tb.rid
FROM emps_rid tb
WHERE tb.rid - (SELECT rid
                FROM max_sel_depts 
                WHERE department_id = tb.department_id) < 3
), -- первые n людей из департаментов 
sub_res AS (
SELECT  fn_tb.last_name,
        NVL(md_tb.department_id, ' ') AS department_id,
        fn_tb.department_id AS tmp_dept_id,
        fn_tb.salary,
        fn_tb.rid AS tmp_rid     
FROM first_n_emps_depts fn_tb
LEFT OUTER JOIN max_sel_depts md_tb
ON (fn_tb.rid = md_tb.rid)
ORDER BY fn_tb.rid ASC
) -- результирующий join

SELECT tb1.last_name, tb1.department_id, tb1.salary
FROM sub_res tb1
WHERE tb1.tmp_dept_id = '&&dep_id'
UNION ALL
SELECT tb2.last_name, tb2.department_id, tb2.salary
FROM sub_res tb2
WHERE NOT EXISTS (SELECT 'X' FROM sub_res WHERE tmp_dept_id = '&dep_id');

UNDEFINE no_dep_id;
UNDEFINE dep_id;


 -- вывод всех:
WITH preparation AS (
SELECT emp.last_name, emp.department_id, emp.salary
FROM employees emp
ORDER BY emp.department_id ASC, emp.salary DESC, emp.last_name ASC
), -- сортиповка исходных данных

emps_rid AS (
SELECT p.last_name, p.department_id, p.salary, ROWNUM AS rid
FROM preparation p
), -- присвоение rid каждому emp 

max_sel_depts AS (
SELECT *
FROM emps_rid emp
WHERE emp.salary = (SELECT MAX(salary)
                    FROM emps_rid
                    WHERE NVL(TO_CHAR(department_id), ' ') = NVL(TO_CHAR(emp.department_id), ' '))
), -- поиск максимальных зарплат по отделам

first_n_emps_depts AS (
SELECT  tb.last_name,
        tb.department_id,
        tb.salary,
        tb.rid
FROM emps_rid tb
WHERE tb.rid - (SELECT rid
                FROM max_sel_depts 
                WHERE NVL(TO_CHAR(department_id), ' ') = NVL(TO_CHAR(tb.department_id), ' ')) < 3 
) -- первые n людей из департаментов 

SELECT  fn_tb.last_name,
        CASE    WHEN fn_tb.department_id IS NULL
                THEN NVL(TO_CHAR(md_tb.department_id), 'нет департамента')
                ELSE NVL(TO_CHAR(md_tb.department_id), ' ')
        END AS DEPARTMENT_ID,
        -- fn_tb.department_id,
        fn_tb.salary 
FROM first_n_emps_depts fn_tb
LEFT OUTER JOIN max_sel_depts md_tb
ON (fn_tb.rid = md_tb.rid)
ORDER BY fn_tb.department_id ASC, fn_tb.salary DESC, fn_tb.last_name ASC;



-- lab 7.1:
SELECT emp.LAST_NAME, emp.SALARY, emp.DEPARTMENT_ID
FROM EMPLOYEES emp
START WITH emp.LAST_NAME = 'Mourgos'
CONNECT BY PRIOR	emp.EMPLOYEE_ID = emp.MANAGER_ID;

-- lab 7.2:
WITH tmp AS (
SELECT EMPLOYEE_ID 
FROM EMPLOYEES 
WHERE LAST_NAME = 'Lorentz'
)

SELECT LAST_NAME
FROM EMPLOYEES
WHERE LEVEL > 1
START WITH EMPLOYEE_ID IN (SELECT * FROM tmp)
CONNECT BY  EMPLOYEE_ID = PRIOR MANAGER_ID;

-- lab 7.3:
SELECT	LPAD(LAST_NAME, LENGTH(LAST_NAME)+2*(LEVEL - 1), '_') AS NAME,
        NVL(TO_CHAR(MANAGER_ID), ' ') AS MGR,
        NVL(TO_CHAR(DEPARTMENT_ID), ' ') AS DEPTNO
FROM 	EMPLOYEES 
START WITH 	LAST_NAME = 'Kochhar'
CONNECT BY PRIOR EMPLOYEE_ID = MANAGER_ID;

-- lab 7.4:
SELECT	LPAD(last_name, LENGTH(last_name) + 2*(LEVEL - 1), ' ') AS last_name, 
        employee_id, 
        manager_id
FROM	employees
WHERE   (job_id != 'ST_MAN')
START WITH 	manager_id IS NULL
CONNECT BY PRIOR (employee_id = manager_id) 
AND last_name != 'De Haan';

-- lab 7.5:
DEFINE date_form = 'DD.MM.sYYYY';
DEFINE date_lang = 'NLS_DATE_LANGUAGE = RUSSIAN';
DEFINE last_bc_day = TO_DATE('31.12.-0001', '&date_form');

DEFINE my_date = TO_DATE('28.12.-0001', '&date_form');

SELECT  TO_CHAR(&my_date + (LEVEL - 1), '&date_form', '&date_lang') AS "DATE" , 
        CASE    WHEN (&my_date >= &last_bc_day - 7 AND &my_date <= &last_bc_day)
                THEN TO_CHAR(&my_date + (LEVEL - 1) -5, 'DAY','&date_lang')
                WHEN &my_date < &last_bc_day - 7
                THEN TO_CHAR(&my_date + (LEVEL - 1) + 2, 'DAY','&date_lang')
                ELSE TO_CHAR(&my_date + (LEVEL - 1), 'DAY', '&date_lang')
                
        END AS "DAY OF WEEK"
FROM SYS.DUAL
CONNECT BY LEVEL <= EXTRACT(DAY FROM LAST_DAY(&my_date)) - EXTRACT(DAY FROM &my_date) + 1;

UNDEFINE date_form;
UNDEFINE date_lang;
UNDEFINE last_bc_day;
UNDEFINE my_date;

-- lab 7.6:
DEFINE in_str = '8t0(6fg)8p98h)phpi(ojhdf(fsfs)afsa';

WITH step1 AS (
SELECT LEVEL lvl, SUBSTR('&in_str', LEVEL, 1) AS ch, 
DECODE(SUBSTR('&in_str', LEVEL, 1), '(', 1, 0) AS pleft,
DECODE(SUBSTR('&in_str', LEVEL, 1), ')', 1, 0) AS pright
FROM SYS.DUAL
CONNECT BY LEVEL <= LENGTH('&in_str')
), -- транспонирование строки в столбик, маркировка скобок
step2 AS (
SELECT tb.lvl, tb.pleft, tb.pright, 
(SELECT SUM(pleft) FROM step1 WHERE lvl <= tb.lvl) AS suml, 
(SELECT SUM(pright) FROM step1 WHERE lvl <= tb.lvl) AS sumr
FROM step1 tb
) -- подсчет скобок

SELECT DISTINCT
CASE -- возврат строки или сообщ. об ошибке 
    CASE -- проверка скобок
         -- есть ли правые скобки:
		WHEN EXISTS(SELECT 1 FROM step2 WHERE sumr > suml) 
		THEN 0
         -- равна ли 0 разность числа скобок разного виида:
        WHEN (SELECT suml - sumr FROM step2 WHERE lvl = (SELECT MAX(lvl) FROM step2)) != 0  
		THEN 0 
		ELSE 1 
	END
	--
	WHEN 0 
	THEN 'Incorrect input argument' 
	ELSE '&in_str' 
END AS result_str
FROM step2;

UNDEFINE in_str;

-- lab 7.7:
DEFINE reg_name = 'Europe';

WITH funct AS (
SELECT * 
FROM (SELECT r1.region_name AS r_name, 
             c1.country_name AS c_name 
      FROM regions r1
      JOIN countries c1
      ON (r1.region_id = c1.region_id) AND r1.region_name = '&reg_name'
      UNION ALL
      SELECT c2.country_name, 
             l2.city 
      FROM countries c2
	  JOIN locations l2
	  ON (c2.country_id = l2.country_id)
      UNION ALL
      SELECT l3.city, 
             d3.department_name 
      FROM locations l3
	  JOIN departments d3 
      ON (l3.location_id = d3.location_id))
ORDER BY r_name, c_name
)

SELECT 1 AS "Уровень", '&reg_name' AS "Единица" 
FROM SYS.DUAL
UNION ALL
SELECT 	LEVEL + 1, (LPAD(' ', LEVEL*3,' ') || c_name)
FROM funct f1
START WITH f1.r_name = '&reg_name'
CONNECT BY PRIOR f1.c_name = f1.r_name;

UNDEFINE reg_name;

-- lab 7.8:
DEFINE in_str = ' , 1, ,abc,cde,ef,gh,mn, ,3, ,test,ss,df,fw,ewe,wwe,1,9,2';

WITH tmp AS (
SELECT ','||'&in_str'||',' AS sh FROM SYS.DUAL
), -- для внутренних нужд )))

pars_str AS (
SELECT  LEVEL lvl, SUBSTR((SELECT sh FROM tmp), LEVEL, 1) AS ch, 
        DECODE(SUBSTR((SELECT sh FROM tmp), LEVEL, 1), ',', 1, 0) AS flag	
FROM SYS.DUAL
CONNECT BY LEVEL <= LENGTH((SELECT sh FROM tmp)) 
), -- парсинг строки в столбец посимвольно

comm_id AS (
SELECT ROWNUM AS r, lvl
FROM pars_str
WHERE flag = 1
), -- поиск индексов зяпятых

substr_tb AS (
SELECT SUBSTR((SELECT sh FROM tmp), (SELECT lvl FROM comm_id WHERE r = tb.r) + 1, (SELECT lvl FROM comm_id WHERE r = tb.r + 1) - (SELECT lvl FROM comm_id WHERE r = tb.r) - 1) AS str
FROM comm_id tb
ORDER BY str ASC
), -- таблица с подстроками

sub_res AS (
SELECT ROWNUM AS r, str  
FROM substr_tb
WHERE str is not null
), -- подрезультат с r_id

out_res AS (
SELECT SUBSTR(SYS_CONNECT_BY_PATH(str, ','),2) AS res
FROM sub_res
WHERE r = (SELECT COUNT(*) FROM sub_res)
START WITH r = 1
CONNECT BY PRIOR r = r - 1
)

SELECT 'In str:' AS title, '&in_str' AS result  
FROM SYS.DUAL
UNION ALL
SELECT 'Out str:', tb.res  
FROM out_res tb;

UNDEFINE in_str;

-- lab 7.9:
WITH tmp AS (
SELECT  SYS_CONNECT_BY_PATH (last_name, '->') AS mng_line,
        SYS_CONNECT_BY_PATH (TO_CHAR(employee_id), '->') AS mng_id
FROM employees
WHERE manager_id IS NOT NULL
START WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id
) -- построение ветвей mng -> emp

SELECT	SUBSTR(tb.mng_line, 3) AS "Список сотрудников",
        	(SELECT SUM(salary)
         	FROM employees 
         	WHERE INSTR(tb.mng_id, '->' || TO_CHAR(employee_id)) > 0) AS "Сумма зарплат" 
FROM tmp tb
ORDER BY 2 DESC;


-- lab 8.1:
SELECT REGEXP_REPLACE(loc.STREET_ADDRESS,' ', '') AS STREET_ADDRESS
FROM LOCATIONS loc;
  
-- lab 8.2:
SELECT REGEXP_REPLACE(loc.STREET_ADDRESS, 'St$', 'Street') AS STREET_ADDRESS
FROM LOCATIONS loc
WHERE REGEXP_LIKE (loc.STREET_ADDRESS, 'St');

-- lab 8.3:
define in_path = 'D:/_Apps_/..  1   ...MatLab 111/98..dp_tr___ans   1__/diff_protection/f12131f t_f12123123un.m.d.12d.5675t';
SELECT  '&path' AS FULL_NAME, REGEXP_REPLACE('&in_path', '.*[\\/]|\.[^.]*$', '') AS FILE_NAME
FROM SYS.DUAL;
undefine in_path;


DEFINE in_str = 'D:/_Apps_/..  1   ...MatLab 111/98..dp_tr___ans   1__/diff_protection/f12131f t_f12123123un.m.d.12d.5675t';

DEFINE p_disk = '^([A-Z]:(\\|/)){1}';
DEFINE p_server = '^((\\|/){2}\w+|\d+(\\|/){1}){1}';
DEFINE p_folder = '(((\w+|\d+)|((\w+|\d+|\.*)\s*\.*(\w+|\d+)))+(\\|/){1})+';
DEFINE p_file = '.*[\\/]|\.*$';

WITH tmp AS (
SELECT REPLACE('&in_str', REGEXP_REPLACE('&in_str', '&p_file', ''), '') AS folder_name
FROM SYS.DUAL
)

SELECT  '&in_str' AS full_name,
        CASE    WHEN REGEXP_SUBSTR((select * from tmp), '&p_disk'||'&p_folder') = (select * from tmp)
                THEN REGEXP_REPLACE('&in_str', '&p_file', '')
                WHEN REGEXP_SUBSTR((select * from tmp), '&p_server'||'&p_folder') = (select * from tmp)
                THEN REGEXP_REPLACE('&in_str', '&p_file', '')
                ELSE 'Err !!!'
        END AS file_name
FROM SYS.DUAL;

DEFINE in_str; DEFINE p_disk; DEFINE p_server; DEFINE p_folder; DEFINE p_file;

-- lab 8.4:
DEFINE in_str = '......a   a a\\\a   A a a    аааааааа ааааа _АааАа    ааааа Кулон лон Слон......слОн---СЛон Книга  ////   книга            s';

WITH tmp AS(
SELECT REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE('&in_str', '[,.!?;:_//\-]|(^|$)', ' '),'\s{2,}', ' '), ' +', '  ') AS str
FROM SYS.DUAL
) -- подготовка строки
SELECT  CASE LEVEL WHEN 1 THEN '&in_str' ELSE ' ' END AS "Исходная строка",
        REGEXP_REPLACE((REGEXP_REPLACE((REGEXP_SUBSTR(str, '( \w+ )\1{1,}', 1, LEVEL, 'i')), '  ', ' ')), '^ ', '') AS "Повторяющиеся слова"
FROM tmp
CONNECT BY LEVEL <= regexp_count(LOWER(str), '( \w+ )\1{1,}', 1);

UNDEFINE in_str;


DEFINE in_str = 'ку-ку ку-ку ку-ку rr r rrr rrr rrr rr-rr rr-rr кк. rr r м м rr rr rr r r r у точь-в-точь точь-в-точь точь-в-точь кое-как кое-как  точь-в-точь у у кк. rr rr_ rr_ r r rr rrr rr rrr rrr rrrr rrr rr rr';

WITH tmp AS(
SELECT REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE('&in_str', '-', 'тире'), '[,.!?;:_//\]|(^|$)', ' '),'\s{2,}', ' '), ' +', '  ') AS str
FROM SYS.DUAL
), -- подготовка строки
tmp2 AS(
SELECT  CASE LEVEL WHEN 1 THEN '&in_str' WHEN 2 THEN (SELECT * FROM tmp) ELSE ' ' END AS input_str,
        REGEXP_REPLACE((REGEXP_REPLACE((REGEXP_SUBSTR(str, '( \w+ )\1{1,}', 1, LEVEL, 'i')), '  ', ' ')), '^ ', '') AS res_str
FROM tmp
CONNECT BY LEVEL <= regexp_count(LOWER(str), '( \w+ )\1{1,}', 1)
) -- костыли )))

SELECT input_str, REPLACE(res_str, 'тире', '-') FROM tmp2;

UNDEFINE in_str;

-- lab 8.6:
DEFINE in_str = '1@com';
SELECT '&in_str' AS "STRING_EML" 
FROM SYS.DUAL
WHERE REGEXP_LIKE ('&in_str', '^\w+((\.?\w*\-?)*\w+)*@(\w+\.?\w*\-?\w+)+$' );
UNDEFINE in_str;

-- lab 8.7:
WITH INSTR AS (
SELECT '2.0*2+3.1Результатом 5.0+ вычисления 2 выражения 2.5*3-6*5 будет число -22.5, а результатом вычисления выражения (3+5)-9*4 – число -28' AS STR 
FROM SYS.DUAL
),
STEP1 AS (
SELECT regexp_substr (STR, '(\d+\.\d+(\+)+)|(\d+(\+)+)', 1, LEVEL) AS STR1
FROM INSTR
CONNECT BY LEVEL <= regexp_count(STR, '(\d+\.\d+(\+)+)|(\d+(\+)+)')
),
STEP2 AS (
SELECT regexp_substr (STR, '(\d+\.\d+)|(\d+)', 1, LEVEL) AS STR2
FROM INSTR
CONNECT BY LEVEL <= regexp_count(STR, '(\d+\.\d+)|(\d+)')
),
STEP3 AS (
SELECT regexp_replace (STR1, '\+', '') AS STR3
FROM STEP1
),
STEP4 AS (
SELECT to_number(STR2, '999.99') AS RES1
FROM STEP2
MINUS
SELECT to_number(STR3, '999.99')
FROM STEP3
)

SELECT	(SELECT STR FROM INSTR) AS "Текст", SYS_CONNECT_BY_PATH (REPLACE(RES1, ',', '.'), ' ') AS "Результат"
FROM    (SELECT RES1, ROWNUM RNM FROM STEP4)
WHERE RNM = (SELECT MAX(ROWNUM) FROM STEP4)
START WITH RNM = 1
CONNECT BY PRIOR RNM = RNM - 1;



WITH STRTAB AS (SELECT '2.0*2+3.1Результатом 5.0+ вычисления 2 выражения 2.5*3-6*5 будет число -22.5, а результатом вычисления выражения (3+5)-9*4 – число -28' STR FROM SYS.DUAL),
NTAB1 AS(
SELECT LEVEL LVL, REGEXP_SUBSTR(STR, '\d+\.*\d*', 1, LEVEL) NUMM1
FROM STRTAB
CONNECT BY LEVEL <= REGEXP_COUNT(STR,'\d+\.*\d*')
),
NTAB2 AS(
SELECT LEVEL LVL2, REPLACE(REGEXP_SUBSTR(STR, '\d+\.*\d*\+', 1, LEVEL), '+', '') NUMM2
FROM STRTAB
CONNECT BY LEVEL <= REGEXP_COUNT(STR,'\d+\.*\d*\+')
),
NTAB3 AS(
SELECT TO_NUMBER(REPLACE(NUMM1, '.', ',')) NUMM3
FROM NTAB1
MINUS
SELECT TO_NUMBER(REPLACE(NUMM2, '.', ','))
FROM NTAB2
ORDER BY 1
),
NTAB4 AS(
SELECT NUMM3, ROWNUM RN
FROM NTAB3
)
SELECT (SELECT STR FROM STRTAB) "Текст",
SYS_CONNECT_BY_PATH(NUMM3, ' ') "Результат"
FROM NTAB4
WHERE level = (SELECT MAX(RN) FROM NTAB4)
START WITH RN =1
CONNECT BY PRIOR RN=RN-1;

-- lab 8.8:
DEFINE p_str = '((((\s{1}|^)[1-9]{1}\d{0,2}){1}( \d{3})*)|(([1-9]{1}\d{0,2}){1}(,\d{3})*)|0|([1-9]{1}\d*))\.\d*[1-9]';

WITH tmp AS (
SELECT '222222 222 222 222.222 Пусть имеем 212 45 567.456 789 или 212,13,245.4568 или варик ктороый не работал 434,00000044444444444455555.0000375034735083 343 или такой 000555 5489q596346.57607040000000 7 5485 и так епта 222,222 000,456.38473465034' AS str_1 
FROM SYS.DUAL
)

SELECT  CASE LEVEL WHEN 1 THEN (SELECT str_1 FROM tmp) ELSE ' ' END AS "Текст и цифры",
        REGEXP_SUBSTR(str_1, '&p_str', 1, LEVEL) AS "Результат"
FROM tmp
CONNECT BY LEVEL <= REGEXP_COUNT(str_1, '&p_str');

UNDEFINE p_str;


DEFINE p_str = '((((\s{1}|^)[1-9]{1}\d{0,2}){1}( \d{3})*)|(((\s{1}|,|^)[1-9]{1}\d{0,2}){1}(,\d{3})*)|0|([1-9]{1}\d*))\.\d*[1-9]';

WITH tmp AS (
SELECT '222222 222 222 222.4545 222222,222,222,222.4545 222222222222222222.4545' AS str_1 
FROM SYS.DUAL),
tmp2 AS(
SELECT  CASE LEVEL WHEN 1 THEN (SELECT str_1 FROM tmp) ELSE ' ' END AS input_str,
        REGEXP_REPLACE(REGEXP_SUBSTR(str_1, '&p_str', 1, LEVEL),'^,|^ ','') AS result_str
FROM tmp
CONNECT BY LEVEL <= REGEXP_COUNT(str_1, '&p_str')
)

SELECT input_str AS "Текст и цифры", result_str AS "Результат"
FROM tmp2;
UNDEFINE p_str;

-- lab 8.9:
DEFINE in_str = 'A[[B[C[()]][D]E[F[J]]H][K]L]M';

SELECT  '&in_str' AS "RESULT"
FROM    SYS.DUAL
UNION ALL 
SELECT  REGEXP_REPLACE('&in_str', '\[([^][]*)\]', '(\1)')
FROM    SYS.DUAL;

UNDEFINE in_str;





DEFINE in_str = '0123abcdefghi45678';
DEFINE pattern_str = '((0123(((abc)(de)f)ghi)45(678)))';

-- DEFINE in_str = '1234567890';
-- DEFINE pattern_str = '(123)(4(56)(78))';

SELECT  LEVEL - 1 AS "значение SubExpr",
        REGEXP_INSTR('&in_str', '&pattern_str', 1, 1, 0, 'i', LEVEL - 1) AS "точка вхождения",
        REGEXP_SUBSTR('&in_str', '&pattern_str', 1, 1,'i', LEVEL - 1) AS " результирующая подстрока" 
FROM SYS.DUAL
CONNECT BY LEVEL <= 10;

UNDEFINE in_str;
UNDEFINE pattern_str;




DEFINE in_str = '0123abcdefghi45678';
DEFINE pattern_str = '((0123(((abc)(de)f)ghi)45(678)))';

-- DEFINE in_str = '1234567890';
-- DEFINE pattern_str = '(123)(4(56)(78))';

SELECT  CASE LEVEL WHEN 1 THEN '&in_str' ELSE ' ' END AS "Строка", 
        LEVEL - 1 AS "значение SubExpr",       
        REGEXP_SUBSTR(REGEXP_REPLACE('&pattern_str', '[(,)]', ''), '&pattern_str', 1, 1, 'i', LEVEL - 1) AS "шаблон поиска",
        REGEXP_INSTR('&in_str', '&pattern_str', 1, 1, 0, 'i', LEVEL - 1) AS "точка вхождения",
        REGEXP_SUBSTR('&in_str', '&pattern_str', 1, 1, 'i', LEVEL - 1) AS "результирующая подстрока" 
FROM dual 
CONNECT BY LEVEL <= 10;

UNDEFINE in_str;
UNDEFINE pattern_str;
