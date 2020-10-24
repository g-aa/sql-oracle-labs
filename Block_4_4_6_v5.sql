WITH DATE_INTERVAL AS
(
SELECT  TO_DATE('01-JAN-2006','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') AS BEG_DATE,
        TO_DATE('01-JAN-2009','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') AS END_DATE
FROM DUAL
), -- заданный интервал времени
--REMDATES_2 AS 
--(
--    SELECT DISTINCT(TRUNC((TO_DATE('01-JAN-2006','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') + ROWNUM - 1), 'MONTH')) "DT"
--    FROM   (SELECT 1 FROM DUAL GROUP BY CUBE(1,1,1,1,1,1,1,1,1,1,1))
--    WHERE  TO_DATE('01-JAN-2006','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') + ROWNUM - 1 < 
--           TO_DATE('01-JAN-2009','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
--    ORDER BY 1  
--),-- дополнительные даты для последующего вывода тех месяцев где никого не наняли
REMDATES AS
(
    SELECT DISTINCT(TRUNC(TO_DATE('01-JAN-2006','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') + ROWNUM - 1,'MONTH')) AS "DT"
    FROM ALL_OBJECTS
    WHERE ROWNUM <= TO_DATE('01-JAN-2009', 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') - 
    TO_DATE('01-JAN-2006','DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH') + 1
),-- дополнительные даты для последующего вывода тех месяцев где никого не наняли / шустрый 
HIRE_DATE_BETWEEN AS
(
    SELECT  EMP.EMPLOYEE_ID,
            EMP.DEPARTMENT_ID,
            EMP.JOB_ID,
            TRUNC(EMP.HIRE_DATE, 'MONTH') AS DATE_M_TRUNC,
            TRUNC(EMP.HIRE_DATE, 'YEAR') AS DATE_Y_TRUNC
    FROM EMPLOYEES EMP
    WHERE EMP.HIRE_DATE 
    BETWEEN (SELECT BEG_DATE FROM DATE_INTERVAL) 
    AND (SELECT END_DATE FROM DATE_INTERVAL)
    ORDER BY EMP.HIRE_DATE
), -- выбор сотрудников в пределах заданного интервала
GRP_SELECT AS
(
    SELECT  HDB.DATE_Y_TRUNC,
            HDB.DATE_M_TRUNC, 
            HDB.DEPARTMENT_ID,
            HDB.JOB_ID,
            COUNT(*) AS EMPS,
            GROUPING(HDB.DATE_Y_TRUNC) AS GRP_DATE_Y,
            GROUPING(HDB.DATE_M_TRUNC) AS GRP_DATE_M,
            GROUPING(HDB.DEPARTMENT_ID) AS GRP_DEPT,
            GROUPING(HDB.JOB_ID) AS GRP_JOB       
    FROM HIRE_DATE_BETWEEN HDB
    GROUP BY ROLLUP(HDB.DATE_Y_TRUNC, 
                    HDB.DATE_M_TRUNC, 
                    (HDB.DEPARTMENT_ID, HDB.JOB_ID))
), -- результирующая группировка
GET_ONE_DEPT_TEMP AS 
(
    SELECT  TB.DATE_M_TRUNC,
            TB.DEPARTMENT_ID,
            TB.JOB_ID        
    FROM HIRE_DATE_BETWEEN TB
    GROUP BY TB.DATE_M_TRUNC, 
             TB.DEPARTMENT_ID, 
             TB.JOB_ID
), -- получение одного отдела в месяц temp
GET_ONE_DEPT AS
(
    SELECT  TB.DATE_M_TRUNC,
            TB.DEPARTMENT_ID,
            MIN(TB.JOB_ID) AS MIN_JOBS      
    FROM GET_ONE_DEPT_TEMP TB 
    GROUP BY TB.DATE_M_TRUNC, 
             TB.DEPARTMENT_ID
), -- получение одного отдела в месяц
GET_ONE_DATE_TEMP AS 
(
    SELECT  TB.DATE_M_TRUNC,
            MIN(TB.DEPARTMENT_ID) AS MIN_DEPT     
    FROM GET_ONE_DEPT TB 
    GROUP BY TB.DATE_M_TRUNC
), -- выбираем минимальные депортаменты по датам temp
GET_ONE_DATE AS 
(
    SELECT  TB_DEPT.DATE_M_TRUNC,
            TB_DEPT.DEPARTMENT_ID,
            TB_DEPT.MIN_JOBS
    FROM GET_ONE_DEPT TB_DEPT
    JOIN GET_ONE_DATE_TEMP TB_DATE
    ON (TB_DATE.DATE_M_TRUNC = TB_DEPT.DATE_M_TRUNC)
    AND (TB_DATE.MIN_DEPT = TB_DEPT.DEPARTMENT_ID)
), -- выбираем минимальные депортаменты по датам
RES_GRP_TAB AS
(
    SELECT  NVL(GRP.DATE_Y_TRUNC, TRUNC(RD.DT, 'YEAR')) AS GRP_DATE_Y_TRUNC,
            NVL(GRP.DATE_M_TRUNC, RD.DT) AS GRP_DATE_M_TRUNC,
            TB_DEPT.DATE_M_TRUNC AS DEPT_DATE_M_TRUNC,
            TB_DATE.DATE_M_TRUNC AS DATE_DATE_M_TRUNC,
            GRP.DEPARTMENT_ID AS GRP_DEPT_ID,
            TB_DEPT.DEPARTMENT_ID AS DEPT_DEPT_ID,
            TB_DATE.DEPARTMENT_ID AS DATE_DEPT_ID,
            GRP.JOB_ID AS GRP_JOBS,
            TB_DEPT.MIN_JOBS AS DEPT_MIN_JOBS,
            TB_DATE.MIN_JOBS AS DATE_MIN_JOBS,
            GRP.EMPS,
            GRP.GRP_DATE_Y,
            GRP.GRP_DATE_M,
            GRP.GRP_DEPT,
            GRP.GRP_JOB
    FROM GRP_SELECT GRP
    LEFT JOIN GET_ONE_DEPT TB_DEPT
    ON (GRP.DATE_M_TRUNC = TB_DEPT.DATE_M_TRUNC)
    AND (GRP.DEPARTMENT_ID = TB_DEPT.DEPARTMENT_ID)
    AND (GRP.JOB_ID = TB_DEPT.MIN_JOBS)
    LEFT JOIN GET_ONE_DATE TB_DATE
    ON (GRP.DATE_M_TRUNC = TB_DATE.DATE_M_TRUNC)
    AND (GRP.DEPARTMENT_ID = TB_DATE.DEPARTMENT_ID)
    AND (GRP.JOB_ID = TB_DATE.MIN_JOBS)
    FULL JOIN REMDATES RD
    ON (RD.DT = GRP.DATE_M_TRUNC)
    ORDER BY GRP_DATE_Y_TRUNC ASC, 
             GRP_DATE_M_TRUNC ASC, 
             GRP.DEPARTMENT_ID ASC, 
             GRP.JOB_ID ASC
) -- результурующая сгруппированная таблица для отчета 
SELECT  /* Месяц, Год */
        CASE    WHEN (TB.GRP_DATE_Y = 0 AND TB.GRP_DATE_M = 0 AND TB.GRP_DEPT = 1 AND TB.GRP_JOB = 1)
                THEN (  
                        TRIM(TO_CHAR(TB.GRP_DATE_M_TRUNC, 'Month'))
                        ||TO_CHAR(TB.GRP_DATE_M_TRUNC, ', YYYY')
                        ||': Итого'
                     )
                WHEN (TB.GRP_DATE_Y = 0 AND TB.GRP_DATE_M = 0 AND TB.GRP_DEPT = 0 AND TB.GRP_JOB = 0)
                THEN NVL(
                            TRIM(TO_CHAR(TB.DATE_DATE_M_TRUNC, 'Month'))
                            ||TO_CHAR(TB.DATE_DATE_M_TRUNC, ', YYYY'), ' '
                        )
                WHEN (TB.GRP_DATE_Y IS NULL)
                THEN (
			TRIM(TO_CHAR(TO_CHAR(TB.GRP_DATE_M_TRUNC, 'Month')))
			||TO_CHAR(TB.GRP_DATE_M_TRUNC, ', YYYY')
			||': Итого'
		     )
                ELSE (' ')
        END AS "Месяц, Год",
        /* Отдел */
        RPAD(CASE    WHEN (TB.GRP_DEPT_ID IS NULL AND TB.GRP_DATE_Y = 0 AND TB.GRP_DATE_M = 0 AND TB.GRP_DEPT = 0 AND TB.GRP_JOB = 0)
                THEN ('Нет департамента')
                ELSE NVL(TO_CHAR(TB.DEPT_DEPT_ID), ' ') 
        END, 16) AS "Отдел",
        /* Должность */
        CASE    WHEN (TB.GRP_DATE_Y = 1 AND TB.GRP_DATE_M = 1 AND TB.GRP_DEPT = 1 AND TB.GRP_JOB = 1)
                THEN ('ОБЩИЙ ИТОГ')
                WHEN (TB.GRP_DATE_Y = 0 AND TB.GRP_DATE_M = 1 AND TB.GRP_DEPT = 1 AND TB.GRP_JOB = 1)
                THEN ('ИТОГО В '|| TO_CHAR(TB.GRP_DATE_Y_TRUNC, 'YYYY') || ' году')                
                WHEN (TB.GRP_DATE_Y = 0 AND TB.GRP_DATE_M = 0 AND TB.GRP_DEPT = 1 AND TB.GRP_JOB = 1)
                     OR (TB.GRP_JOBS IS NULL)
                THEN (' ')
                ELSE TB.GRP_JOBS
        END AS "Должность",
        /* Количество сотрудников */
        NVL(TB.EMPS, 0) AS "Количество сотрудников"
FROM RES_GRP_TAB TB;