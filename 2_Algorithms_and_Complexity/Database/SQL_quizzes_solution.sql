-- QUIZZES SOLUTION --

-- 1/ Retrieve the first name and last name of customers whose points are greater than 1000.
SELECT first_name, last_name
FROM customers
WHERE points > 1000;

-- 2/ Retrieve the product name and unit price of products with a quantity in stock between 50 and 100.
SELECT name, unit_price
FROM products
WHERE quantity_in_stock BETWEEN 50 AND 100;

-- 3/ Retrieve the order ID and order date of orders placed between ‘2018-01-01' and ‘2018-12-31’.
SELECT order_id, order_date
FROM orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-12-31';

-- 4/ Retrieve the first name and last name of customers whose phone number is null.
SELECT first_name, last_name
FROM customers
WHERE phone IS NULL;

-- 5/ Retrieve the customer ID and points of customers whose first name starts with ‘I’.
SELECT customer_id, points
FROM customers
WHERE first_name LIKE 'I%';

-- 6/ Retrieve the order ID and order date of the latest 5 orders, ordered by order date in descending order.
SELECT order_id, order_date
FROM orders
ORDER BY order_date DESC
LIMIT 5;


-- 7/ Retrieve the product name and unit price of the top 3 most expensive products.
SELECT name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 3;

-- 8/ Retrieve the first name and last name of customers whose birth year is a leap year.
SELECT first_name, last_name
FROM customers
WHERE YEAR(birth_date) % 4 = 0 AND (YEAR(birth_date) % 100 != 0 OR YEAR(birth_date) % 400 = 0);

-- 9/ Retrieve the customer ID and the count of orders placed by each customer, ordered by the count in descending order.
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC;

-- 10/ Retrieve the product name and quantity in stock of products whose quantity is a multiple of 10.
SELECT name, quantity_in_stock
FROM products
WHERE quantity_in_stock % 10 = 0;

-- 11/ Retrieve the product name and unit price of products that have a name starting with a vowel (AIUEO).
SELECT name, unit_price
FROM products
WHERE name REGEXP '^[aeiouAEIOU]';

-- 12/ Retrieve the customer ID and the total points for customers whose points are above the average points.
SELECT customer_id, SUM(points) AS total_points
FROM customers
GROUP BY customer_id
HAVING SUM(points) > (SELECT AVG(points) FROM customers);

-- 13/ Retrieve the order ID and order date of the 5th to 10th orders, ordered by order date.
SELECT order_id, order_date
FROM orders
ORDER BY order_date
LIMIT 4, 6;

-- 14/ Retrieve the customer ID and the total points for customers born in the same month, ordered by total points in descending order.
SELECT customer_id, SUM(points) OVER(PARTITION BY MONTH(birth_date)) AS total_points
FROM customers
ORDER BY total_points DESC;

-- 15/ Retrieve the product name and unit price of products whose unit price is a whole number.
SELECT name, unit_price
FROM products
WHERE unit_price = FLOOR(unit_price);

-- 16/ Retrieve the customer ID and the count of orders placed by each customer, where the count is greater than 3.
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING order_count > 3;

-- 17/ Retrieve the product name and unit price of products whose unit price is greater than the average unit price.
SELECT name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);

-- 18/ Retrieve the order ID and order date of the oldest order for each customer.
SELECT o.order_id, o.order_date
FROM orders o
WHERE o.order_date = (
    SELECT MIN(order_date)
    FROM orders
    WHERE customer_id = o.customer_id
);

-- 19/ Retrieve the order ID and order date of orders placed in the last 7 days.
SELECT order_id, order_date
FROM orders
WHERE order_date >= CURDATE() - INTERVAL 7 DAY;

-- 20/ Retrieve the customer ID and points of customers whose first name contains the letter 'a' and last name contains the letter 'b’.
SELECT customer_id, points
FROM customers
WHERE first_name LIKE '%a%' AND last_name LIKE '%b%';

-- 21/ Retrieve the customer ID and the count of orders placed by each customer, ordered by the count in ascending order.
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count;

-- 22/ Retrieve the product name and quantity in stock of products whose quantity is a power of 2.
SELECT name, quantity_in_stock
FROM products
WHERE LOG2(quantity_in_stock) = FLOOR(LOG2(quantity_in_stock));

-- 23/ Retrieve the order ID and order date of orders that were placed on weekends (Saturday or Sunday).
SELECT order_id, order_date
FROM orders
WHERE DAYOFWEEK(order_date) IN (1, 7);


