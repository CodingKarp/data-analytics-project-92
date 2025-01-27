-- считает количество клиентов--
SELECT COUNT(*) AS customers_count
FROM customers;

--находит 10 лучших продавцов за весь период--
SELECT
    emp.first_name || ' ' || emp.last_name AS seller,
    COUNT(sa.sales_person_id) AS operations,
    FLOOR(SUM(p.price * sa.quantity)) AS income
FROM sales AS sa
INNER JOIN employees AS emp
    ON sa.sales_person_id = emp.employee_id
INNER JOIN products AS p
    ON sa.product_id = p.product_id
GROUP BY seller
ORDER BY FLOOR(SUM(p.price * sa.quantity)) DESC LIMIT 10;


--находит среднюю стоимость сделки--
WITH income AS (
    SELECT FLOOR(AVG(p.price * sa.quantity)) AS avg_income
    FROM sales AS sa
    INNER JOIN products AS p
        ON sa.product_id = p.product_id
)
--выводит всех продавцов, чья средняя стоимость сделки меньше средней общей--
SELECT
    emp.first_name || ' ' || emp.last_name AS seller,
    FLOOR(AVG(p.price * sa.quantity)) AS average_income
FROM sales AS sa
INNER JOIN employees AS emp
    ON sa.sales_person_id = emp.employee_id
INNER JOIN products AS p
    ON sa.product_id = p.product_id
CROSS JOIN income
GROUP BY seller, avg_income
HAVING FLOOR(AVG(p.price * sa.quantity)) < avg_income
ORDER BY average_income;

-- CTE для нахождения суммы продаж по дате--
WITH x AS (
    SELECT
        TO_CHAR(sa.sale_date, 'day') AS day_of_week,
        emp.first_name || ' ' || emp.last_name AS seller,
        SUM(FLOOR(p.price * sa.quantity)) AS income,
        EXTRACT(ISODOW FROM sa.sale_date) AS dow
    FROM sales AS sa
    INNER JOIN employees AS emp
        ON sa.sales_person_id = emp.employee_id
    INNER JOIN products AS p
        ON sa.product_id = p.product_id
    GROUP BY seller, day_of_week, dow
)
SELECT
    seller,
    day_of_week,
    income
FROM x
ORDER BY dow, seller;

--СTE создаёт возрастные категории, а тело основного запроса подсчитывает кол-во людей в каждой категории--
WITH age_cat AS (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)
SELECT
    age_category,
    COUNT(age_category)
FROM age_cat
GROUP BY age_category
ORDER BY age_category;

--Вычисляет количество клиентов и сумму дохода по месяцам-- 
WITH tab AS (
    SELECT
        s.customer_id AS total_customers,
        TO_CHAR(sale_date, 'YYYY-MM') AS selling_month,
        SUM(s.quantity * p.price) AS income
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM'), s.customer_id
    ORDER BY TO_CHAR(sale_date, 'YYYY-MM')
)
SELECT DISTINCT
    selling_month,
    COUNT(total_customers),
    FLOOR(SUM(income))
FROM tab
GROUP BY selling_month;

--Находит клиентов чья первая покупка включала акционный товар--
WITH tab AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date
        ) AS rw
    FROM sales
)
SELECT
    t.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM tab AS t
INNER JOIN customers AS c
    ON t.customer_id = c.customer_id
INNER JOIN employees AS e
    ON t.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON t.product_id = p.product_id
WHERE t.rw = 1 AND p.price = 0
GROUP BY t.sale_date, customer, seller, t.customer_id
ORDER BY t.customer_id;
