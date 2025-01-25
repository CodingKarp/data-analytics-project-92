-- считает количество клиентов--
select COUNT(*) as customers_count
from customers;

--находит 10 лучших продавцов за весь период--
select
    emp.first_name || ' ' || emp.last_name as seller,
    COUNT(sa.sales_person_id) as operations,
    FLOOR(SUM(p.price * sa.quantity)) as income
from sales as sa
inner join employees as emp
    on sa.sales_person_id = emp.employee_id
inner join products as p
    on sa.product_id = p.product_id
group by seller
order by FLOOR(SUM(p.price * sa.quantity)) desc limit 10;



