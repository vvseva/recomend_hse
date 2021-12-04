# Из какого города клиент с наибольшим количеством трат
# (траты считать как quantityOrdered*priceEach)

USE classicmodels;

SELECT sum(spending) as total_spend,
       city
FROM
    (SELECT orderNumber, quantityOrdered*priceEach as spending
    FROM orderdetails) as t1
        JOIN
    (SELECT customerNumber FROM orders
        INNER JOIN orderdetails o on orders.orderNumber = o.orderNumber) as t2
    JOIN (
        SELECT city FROM customers inner join orders o2 on customers.customerNumber = o2.customerNumber
        ) as t3
GROUP BY customerNumber, city
ORDER BY -total_spend
LIMIT 10;


# 2. У какого работника больше всего клиентов,
# с которыми он работал? Выведите EmployeeNumber

SELECT COUNT(DISTINCT(customerNumber)) as num,
       salesRepEmployeeNumber
FROM customers
GROUP BY salesRepEmployeeNumber
ORDER BY -num;


# 3. В каком городе больше всего заказов?
SELECT count(orderNumber) as n,
       city
FROM
    (SELECT city, customerNumber FROM customers) as t1
    JOIN
    (SELECT orderNumber FROM orders
        INNER JOIN customers c on orders.customerNumber = c.customerNumber) as t2
GROUP BY city
order by -n
;


# Дайте каждому клиенту обозначение:
# если его сумма трат больше среднего, то "high spendings",
# меньше или равно среднему "low spendings".
# Кто первый клиент в списке в категории low spendings,
# отсортированном по количеству трат (ближайший к переходу в категорию "high spendings").
# Выведите CustomerNumber

SELECT
    total_spend,
    customerNumber,
    CASE WHEN total_spend > avg(total_spend) THEN 'high spendings'
        WHEN total_spend <= avg(total_spend) THEN 'low spendings' END as customer_tier
FROM (
SELECT sum(spending) as total_spend,
       customerNumber
FROM
    (SELECT orderNumber, quantityOrdered*priceEach as spending
     FROM orderdetails) as t1
        JOIN
    (SELECT customerNumber FROM orders
        INNER JOIN orderdetails o on orders.orderNumber = o.orderNumber) as t2
GROUP BY customerNumber) as t_agg
GROUP BY customerNumber
HAVING customer_tier = 'low spendings'
ORDER BY -total_spend
;

# Какой самый продаваемый (через quantityOrdered)
# продукт в категории (productLine) cars
# (вам нужно учесть разные варианты, содержащие в себе машины).
# Выведите productName
SELECT sum(quantityOrdered) as n,
       productName
FROM
(SELECT productCode,quantityOrdered  FROM orderdetails) as t1
JOIN
 (SELECT productLine, productName FROM products
     INNER JOIN orderdetails o on products.productCode = o.productCode) as t2
WHERE productLine LIKE '%Cars%'
GROUP BY productName
ORDER BY -n
;

# 6. Какой заказ доставлялся дольше всего?
# Выведите номер заказа

SELECT DATEDIFF(shippedDate, orderDate) as order_days,
       orderNumber
FROM orders
WHERE shippedDate is not null
order by -order_days
;


# Напишите запрос на основе таблички employees.
# Создайте колонку Full Name, в которой объедините First Name и Last Name;
# колонку login на основании email, откуда будет убрана часть после @;
# колонку Type с категориями A-J, K-R, S-Z в зависимости от того, с какой буквы начинается фамилия работника.
SELECT
       CONCAT(firstName, ' ',lastName) as fullname,
    SUBSTRING_INDEX( email, '@', 1 ) as login,
       CASE
           WHEN LEFT(lastName, 1) REGEXP  '^[A-J]' THEN 'A-J'
           WHEN LEFT(lastName, 1)  REGEXP  '^[K-R]' THEN 'K-R'
           WHEN LEFT(lastName, 1)  REGEXP  '^[S-Z]' THEN 'S-Z'
           END as Type
    FROM employees
;