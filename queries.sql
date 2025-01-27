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
