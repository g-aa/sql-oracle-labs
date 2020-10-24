select to_date(1, 'J'), to_date(5373484, 'J') from dual;
SELECT TO_DATE('31.12.9999', 'DD.MM.sYYYY', 'NLS_DATE_LANGUAGE = RUSSIAN') AS dd
FROM DUAL;



DEFINE date_form = 'DD.MM.sYYYY';
DEFINE date_lang = 'NLS_DATE_LANGUAGE = RUSSIAN';
DEFINE last_bc_day = TO_DATE('31.12.-1', '&date_form', '&date_lang');

WITH date_interval AS (
SELECT  TO_DATE('31.12.-1', '&date_form', '&date_lang') AS beg_date,
        TO_DATE('01.01.1', '&date_form', '&date_lang') AS end_date
FROM SYS.DUAL
), -- заданный интервал времени

days_interval AS (
SELECT CASE WHEN (beg_date > &last_bc_day AND end_date > &last_bc_day) OR (beg_date <= &last_bc_day AND end_date <= &last_bc_day)
            THEN (end_date - beg_date) + 1
            ELSE (end_date - beg_date - 364)
       END AS days_cnt
FROM date_interval
),  -- число дней в интервале времени

days_interval_new AS (
SELECT * 
FROM SYS.DUAL 
GROUP BY CUBE(1,1,1,1,1,1,1,1,1,1)
), -- генерация таблицы в 1024 строки

sub_res AS (
SELECT  (SELECT beg_date FROM date_interval) + ROWNUM - 1 AS my_date,
        (SELECT end_date FROM date_interval) + ROWNUM - (SELECT days_cnt FROM days_interval) AS date_ad,
        (SELECT beg_date FROM date_interval) + ROWNUM - 1 AS date_bc   
FROM days_interval_new
WHERE  ROWNUM <= (SELECT days_cnt FROM days_interval)
AND ROWNUM <= 1000
), -- массив дат в заданном интервале

out_res AS (
SELECT  CASE    WHEN tb.my_date > &last_bc_day
                THEN tb.date_ad
                WHEN tb.my_date <= &last_bc_day
                THEN tb.date_bc
        END AS dates,
        
        CASE    WHEN tb.my_date > &last_bc_day
                THEN TO_CHAR(tb.date_ad, '&date_form', '&date_lang')
                WHEN tb.my_date <= &last_bc_day
                THEN TO_CHAR((tb.date_bc - 5), 'Day','&date_lang')
        END AS days_of_week
                
FROM sub_res tb
WHERE tb.dates != '00.00.00'
), -- результирующий подзапрос




temp_1 AS 
(
SELECT  CASE    WHEN tb.my_date > TO_DATE('31.12.-1','DD.MM.sYYYY')
                THEN tb.date_1
                WHEN tb.my_date <= TO_DATE('31.12.-1','DD.MM.sYYYY')
                THEN tb.date_2
        END AS DS,
        
        CASE    WHEN tb.my_date > TO_DATE('31.12.-1','DD.MM.sYYYY')
                THEN tb.date_of_w_1
                WHEN tb.my_date <= TO_DATE('31.12.-1','DD.MM.sYYYY')
                THEN TO_CHAR((tb.date_of_w_2 - 5), 'Day','NLS_DATE_LANGUAGE = RUSSIAN')
        END AS DSN
                
FROM sub_res tb
)



-- SELECT *
-- FROM days_interval_new


SELECT  dates AS "дата",
        days_of_week AS "день недели"
FROM 	out_res;



UNDEFINE date_form;
UNDEFINE date_lang;
UNDEFINE last_bc_day;