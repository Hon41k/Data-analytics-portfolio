CREATE TABLE users (
	date date,
	user_id VARCHAR(40),
	view_adverts INT
);

SELECT * FROM users;

# Задание 1

# 1. Напишите запрос SQL, выводящий одним числом количество уникальных пользователей в этой таблице в период с 2023-11-07 по 2023-11-15.

SELECT COUNT(DISTINCT user_id) AS unique_users
FROM users
WHERE date BETWEEN '2023-11-07' AND '2023-11-15';

# 2. Определите пользователя, который за весь период посмотрел наибольшее количество объявлений. 

SELECT
  user_id,
  SUM(view_adverts) AS total_views
FROM users
GROUP BY user_id
ORDER BY total_views DESC
LIMIT 1;

# 3. Определите день с наибольшим средним количеством просмотренных рекламных объявлений на пользователя, но учитывайте только дни с более чем 500 уникальными пользователями.

SELECT
  date
FROM users
GROUP BY date
HAVING COUNT(DISTINCT user_id) > 500
ORDER BY (SUM(view_adverts) / CAST(COUNT(DISTINCT user_id) AS DECIMAL(10,2))) DESC
LIMIT 1;

# 4. Напишите запрос возвращающий LT (продолжительность присутствия пользователя на сайте) по каждому пользователю. Отсортировать LT по убыванию.

SELECT
  user_id,
  MAX(date) - MIN(date) AS lt_days
FROM users
GROUP BY user_id
ORDER BY lt_days DESC;

# 5. Для каждого пользователя подсчитайте среднее количество просмотренной рекламы за день, а затем выясните, у кого самый высокий средний показатель среди тех, кто был активен как минимум в 5 разных дней.

SELECT
  user_id,
  AVG(view_adverts) AS avg_views_per_day,
  COUNT(DISTINCT date) AS active_days
FROM users
GROUP BY user_id
HAVING COUNT(DISTINCT date) >= 5
ORDER BY avg_views_per_day DESC
LIMIT 1;

# Задание 2

CREATE DATABASE mini_project;

CREATE TABLE T_TAB1 (
    ID INT UNIQUE,
    GOODS_TYPE VARCHAR(50),
    QUANTITY INT,
    AMOUNT INT,
    SELLER_NAME VARCHAR(50)
);

CREATE TABLE T_TAB2 (
    ID INT UNIQUE,
    NAME VARCHAR(50),
    SALARY INT,
    AGE INT
);

INSERT INTO T_TAB1 (ID, GOODS_TYPE, QUANTITY, AMOUNT, SELLER_NAME) VALUES
(1,  'MOBILE PHONE', 2, 400000, 'MIKE'),
(2,  'KEYBOARD',     1,  10000, 'MIKE'),
(3,  'MOBILE PHONE', 1,  50000, 'JANE'),
(4,  'MONITOR',      1, 110000, 'JOE'),
(5,  'MONITOR',      2,  80000, 'JANE'),
(6,  'MOBILE PHONE', 1, 130000, 'JOE'),
(7,  'MOBILE PHONE', 1,  60000, 'ANNA'),
(8,  'PRINTER',      1,  90000, 'ANNA'),
(9,  'KEYBOARD',     2,  10000, 'ANNA'),
(10, 'PRINTER',      1,  80000, 'MIKE');

INSERT INTO T_TAB2 (ID, NAME, SALARY, AGE) VALUES
(1, 'ANNA', 110000, 27),
(2, 'JANE',  80000, 25),
(3, 'MIKE', 120000, 25),
(4, 'JOE',   70000, 24),
(5, 'RITA', 120000, 29);

SELECT
  t1.ID,
  t1.GOODS_TYPE,
  t1.AMOUNT,
  t1.SELLER_NAME,
  t2.SALARY,
  t2.AGE
FROM T_TAB1 t1
JOIN T_TAB2 t2
  ON t1.SELLER_NAME = t2.NAME;

# 1. Напишите запрос, который вернёт список уникальных категорий товаров (GOODS_TYPE). Какое количество уникальных категорий товаров вернёт запрос?

  SELECT DISTINCT GOODS_TYPE
FROM T_TAB1;

SELECT COUNT(DISTINCT GOODS_TYPE) AS categories_cnt
FROM T_TAB1;

# 2. Напишите запрос, который вернет суммарное количество и суммарную стоимость проданных мобильных телефонов. Какое суммарное количество и суммарную стоимость вернул запрос?

SELECT
  SUM(QUANTITY) AS total_quantity,
  SUM(AMOUNT)   AS total_amount
FROM T_TAB1
WHERE GOODS_TYPE = 'MOBILE PHONE';

# 3. Напишите запрос, который вернёт список сотрудников с заработной платой > 100000. Какое кол-во сотрудников вернул запрос?

SELECT
  NAME,
  SALARY
FROM T_TAB2
WHERE SALARY > 100000;

# 4. Напишите запрос, который вернёт минимальный и максимальный возраст сотрудников, а также минимальную и максимальную заработную плату.

SELECT
  MIN(AGE)    AS min_age,
  MAX(AGE)    AS max_age,
  MIN(SALARY) AS min_salary,
  MAX(SALARY) AS max_salary
FROM T_TAB2;

# 5. Напишите запрос, который вернёт среднее количество проданных клавиатур и принтеров.

SELECT
  GOODS_TYPE,
  AVG(QUANTITY) AS avg_quantity
FROM T_TAB1
WHERE GOODS_TYPE IN ('KEYBOARD', 'PRINTER')
GROUP BY GOODS_TYPE;

# 6. Напишите запрос, который вернёт имя сотрудника и суммарную стоимость проданных им товаров.

SELECT
  t2.NAME AS employee_name,
  SUM(t1.AMOUNT) AS total_sales_amount
FROM T_TAB1 t1
JOIN T_TAB2 t2
  ON t1.SELLER_NAME = t2.NAME
GROUP BY t2.NAME;

# 7. Напишите запрос, который вернёт имя сотрудника, тип товара, кол-во товара, стоимость товара, заработную плату и возраст сотрудника MIKE.

SELECT
  t2.NAME        AS employee_name,
  t1.GOODS_TYPE  AS goods_type,
  t1.QUANTITY    AS quantity,
  t1.AMOUNT      AS amount,
  t2.SALARY      AS salary,
  t2.AGE         AS age
FROM T_TAB1 t1
JOIN T_TAB2 t2
  ON t1.SELLER_NAME = t2.NAME
WHERE t2.NAME = 'MIKE';

# 8. Напишите запрос, который вернёт имя и возраст сотрудника, который ничего не продал. Сколько таких сотрудников?

SELECT
  t2.NAME,
  t2.AGE
FROM T_TAB2 t2
LEFT JOIN T_TAB1 t1
  ON t2.NAME = t1.SELLER_NAME
WHERE t1.SELLER_NAME IS NULL;

# 1 сотрудник

# 9. Напишите запрос, который вернёт имя сотрудника и его заработную плату с возрастом меньше 26 лет? Какое количество строк вернул запрос?

SELECT
  NAME,
  SALARY
FROM T_TAB2
WHERE AGE < 26;

# строк 3

# 10. Сколько строк вернёт следующий запрос:

SELECT * FROM T_TAB1 t
JOIN T_TAB2 t2 ON t2.name = t.seller_name
WHERE t2.name = 'RITA';

# строк 0

# Задание 3

# 1. Выведите сколько пользователей добавили книгу 'Coraline', сколько пользователей прослушало больше 10%. 

SELECT COUNT(DISTINCT ac.user_id) AS users_added
FROM audio_cards ac
JOIN audiobooks ab ON ab.uuid = ac.audiobook_uuid
WHERE ab.title = 'Coraline';

# 2. По каждой операционной системе и названию книги выведите количество пользователей, сумму прослушивания в часах, не учитывая тестовые прослушивания.

SELECT
  l.os_name,
  ab.title,
  COUNT(DISTINCT l.user_id) AS users_cnt,
  ROUND(
    ( SUM( (l.position_to - l.position_from) / NULLIF(l.speed_multiplier, 0) ) / 3600.0 )::numeric
  , 2) AS listened_hours
FROM listenings l
JOIN audiobooks ab ON ab.uuid = l.audiobook_uuid
WHERE l.is_test = 0
GROUP BY l.os_name, ab.title
ORDER BY l.os_name, users_cnt DESC;

# 3. Найдите книгу, которую слушает больше всего людей.

SELECT
  ab.title,
  COUNT(DISTINCT l.user_id) AS listeners_cnt
FROM listenings l
JOIN audiobooks ab ON ab.uuid = l.audiobook_uuid
WHERE l.is_test = 0
GROUP BY ab.title
ORDER BY listeners_cnt DESC
LIMIT 1;

# 4. Найдите книгу, которую чаще всего дослушивают до конца.

WITH finished AS (
  SELECT
    l.user_id,
    l.audiobook_uuid
  FROM listenings l
  JOIN audiobooks ab ON ab.uuid = l.audiobook_uuid
  GROUP BY l.user_id, l.audiobook_uuid, ab.duration
  HAVING MAX(l.position_to) >= ab.duration
)
SELECT
  ab.title,
  COUNT(*) AS finished_users_cnt
FROM finished f
JOIN audiobooks ab ON ab.uuid = f.audiobook_uuid
GROUP BY ab.title
ORDER BY finished_users_cnt DESC
LIMIT 1;
