CREATE TABLE customer_info (
    Id_client INT,
    Total_amount INT,
    Gender VARCHAR(5) NULL,
    Age INT NULL,
    Count_city INT,
    Response_communcation INT,
    Communication_3month INT,
    Tenure INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_info.xlsx.csv'
INTO TABLE customer_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Id_client, Total_amount, @Gender, @Age, Count_city, Response_communcation, Communication_3month, Tenure)
SET
    Gender = NULLIF(@Gender, ''),
    Age = NULLIF(@Age, '');

select count(age) from customer_info;
select * from customer_info;

select * from transactions_info;

describe transactions_info;

SET SQL_SAFE_UPDATES = 0;

UPDATE transactions_info
SET date_new = STR_TO_DATE(date_new, '%d/%m/%Y');

SELECT date_new
FROM transactions_info
LIMIT 10;

# список клиентов с непрерывной историей за год (с 01.06.2015 по 01.06.2016)
WITH filtered AS (
    SELECT
        ID_client,
        Id_check,
        date_new,
        Sum_payment
    FROM transactions_info
    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'
),
continuous_clients AS (
    SELECT
        ID_client
    FROM filtered
    GROUP BY ID_client
    HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12
)
SELECT
    f.ID_client,
    ROUND(SUM(f.Sum_payment) / COUNT(DISTINCT f.Id_check), 2) AS avg_check,
    ROUND(SUM(f.Sum_payment) / 12, 2) AS avg_monthly_purchase,
    COUNT(DISTINCT f.Id_check) AS total_operations
FROM filtered f
JOIN continuous_clients cc
    ON f.ID_client = cc.ID_client
GROUP BY f.ID_client
ORDER BY f.ID_client;

# средняя сумма чека в месяц;
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month_,
    ROUND(SUM(Sum_payment) / COUNT(DISTINCT Id_check), 2) AS avg_check_month
FROM transactions_info
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month_;

# среднее количество операций в месяц;
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month_,
    ROUND(SUM(Sum_payment) / COUNT(DISTINCT Id_check), 2) AS avg_check_month
FROM transactions_info
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month_;

# среднее количество клиентов, которые совершали операции;
# по месяцам
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month_,
    COUNT(DISTINCT ID_client) AS clients_cnt
FROM transactions_info
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month_;

# среднее количество в общем
SELECT
    ROUND(AVG(clients_cnt), 2) AS avg_clients_per_month
FROM (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS month_,
        COUNT(DISTINCT ID_client) AS clients_cnt
    FROM transactions_info
    GROUP BY DATE_FORMAT(date_new, '%Y-%m')
) t;

# долю от общего количества операций за год и долю в месяц от общей суммы операций;
WITH monthly AS (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS month_,
        COUNT(DISTINCT Id_check) AS operations_cnt,
        SUM(Sum_payment) AS month_sum
    FROM transactions_info
    GROUP BY DATE_FORMAT(date_new, '%Y-%m')
),
totals AS (
    SELECT
        COUNT(DISTINCT Id_check) AS total_operations_year,
        SUM(Sum_payment) AS total_sum_year
    FROM transactions_info
)
SELECT
    m.month_,
    m.operations_cnt,
    CONCAT(ROUND(m.operations_cnt / t.total_operations_year * 100, 2), '%') AS operations_share_year_pct,
    m.month_sum,
    CONCAT(ROUND(m.month_sum / t.total_sum_year * 100, 2), '%') AS sum_share_year_pct
FROM monthly m
CROSS JOIN totals t
ORDER BY m.month_;
# вывести % соотношение M/F/NA в каждом месяце с их долей затрат;
WITH base AS (
    SELECT
        DATE_FORMAT(t.date_new, '%Y-%m') AS month_,
        COALESCE(c.Gender, 'NA') AS Gender,
        t.ID_client,
        t.Sum_payment
    FROM transactions_info t
    LEFT JOIN customer_info c
        ON t.ID_client = c.Id_client
),
gender_stats AS (
    SELECT
        month_,
        Gender,
        COUNT(DISTINCT ID_client) AS clients_cnt,
        SUM(Sum_payment) AS gender_sum
    FROM base
    GROUP BY month_, Gender
),
month_totals AS (
    SELECT
        month_,
        COUNT(DISTINCT ID_client) AS total_clients,
        SUM(Sum_payment) AS total_sum
    FROM base
    GROUP BY month_
)
SELECT
    g.month_,
    g.Gender,
    g.clients_cnt,
    ROUND(g.clients_cnt / m.total_clients * 100, 2) AS gender_pct,
    ROUND(g.gender_sum, 2) AS gender_sum,
    ROUND(g.gender_sum / m.total_sum * 100, 2) AS spend_share_pct
FROM gender_stats g
JOIN month_totals m
    ON g.month_ = m.month_
ORDER BY g.month_, g.Gender;

# задание 3

# Сумма операций и количество операций за весь период
SELECT
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+'
    END AS age_group,
    ROUND(SUM(t.Sum_payment), 2) AS total_sum,
    COUNT(DISTINCT t.Id_check) AS operations_cnt
FROM transactions_info t
LEFT JOIN customer_info c
    ON t.ID_client = c.Id_client
GROUP BY age_group
ORDER BY age_group;

# Средние показатели и % доля поквартально
WITH base AS (
    SELECT
        CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter_,
        CASE
            WHEN c.Age IS NULL THEN 'NA'
            WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS age_group,
        t.ID_client,
        t.Id_check,
        t.Sum_payment
    FROM transactions_info t
    LEFT JOIN customer_info c
        ON t.ID_client = c.Id_client
),
grp AS (
    SELECT
        quarter_,
        age_group,
        SUM(Sum_payment) AS quarter_sum,
        COUNT(DISTINCT Id_check) AS operations_cnt,
        COUNT(DISTINCT ID_client) AS clients_cnt,
        ROUND(SUM(Sum_payment) / COUNT(DISTINCT Id_check), 2) AS avg_check,
        ROUND(COUNT(DISTINCT Id_check) / COUNT(DISTINCT ID_client), 2) AS avg_operations_per_client
    FROM base
    GROUP BY quarter_, age_group
),
quarter_totals AS (
    SELECT
        quarter_,
        SUM(quarter_sum) AS total_sum_quarter,
        SUM(operations_cnt) AS total_operations_quarter
    FROM grp
    GROUP BY quarter_
)
SELECT
    g.quarter_,
    g.age_group,
    g.avg_check,
    g.avg_operations_per_client,
    CONCAT(ROUND(g.quarter_sum / q.total_sum_quarter * 100, 2), '%') AS sum_share_pct,
    CONCAT(ROUND(g.operations_cnt / q.total_operations_quarter * 100, 2), '%') AS operations_share_pct
FROM grp g
JOIN quarter_totals q
    ON g.quarter_ = q.quarter_
ORDER BY g.quarter_, g.age_group;
