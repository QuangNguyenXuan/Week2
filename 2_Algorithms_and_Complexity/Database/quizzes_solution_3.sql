-- 1/  Using the sql_hr database, how would you retrieve a list of all employees 
-- who earn a higher salary than their manager using a subquery?
USE sql_hr;
SELECT e1.*
FROM employees e1
WHERE e1.salary > (
    SELECT e2.salary
    FROM employees e2
    WHERE e1.reports_to = e2.employee_id
);


-- 2/ Using the sql_hr database, create a temporary table that includes 
-- the first name, last name, and office address for each employee.
DROP TABLE IF EXISTS temp_employee_office;
CREATE TEMPORARY TABLE temp_employee_office AS
SELECT e.first_name, e.last_name, o.address AS office_address
FROM employees e
JOIN offices o ON e.office_id = o.office_id;

SELECT * 
FROM temp_employee_office;
-- 3/ In the sql_invoicing database, can you write a stored procedure 
-- that inserts a new payment record, then updates the corresponding invoice 
-- with the payment total?
DROP PROCEDURE IF EXISTS update_payment_invoice;
DELIMITER //
CREATE PROCEDURE update_payment_invoice(
    IN new_payment_id INT, 
    IN new_client_id INT, 
    IN new_invoice_id INT,
    IN new_date DATE,
    IN new_amount DECIMAL,
    IN new_payment_method INT
)
BEGIN
    INSERT INTO payments (payment_id, client_id, invoice_id, date, amount, payment_method)
    VALUES (new_payment_id, new_client_id, new_invoice_id, new_date, new_amount, new_payment_method);
    
    UPDATE invoices 
    SET payment_total = payment_total + new_amount
    WHERE invoice_id = new_invoice_id;
END //
DELIMITER ;


-- 4/ Using the sql_invoicing database, can you create a stored procedure 
-- that finds the client who has made the most payments in the last year?
DROP PROCEDURE IF EXISTS top_paying_client_last_year;
DELIMITER //
CREATE PROCEDURE top_paying_client_last_year()
BEGIN
    SELECT client_id, COUNT(payment_id) as payment_count
    FROM payments
    WHERE date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
    GROUP BY client_id
    ORDER BY payment_count DESC
    LIMIT 1;
END //
DELIMITER ;

-- 5/ In the sql_store database, how would you list the orders that have 
-- a total amount greater than the average order amount using a subquery?
USE sql_store;
SELECT o.order_id
FROM orders o
WHERE (
    SELECT SUM(oi.quantity * oi.unit_price) 
    FROM order_items oi 
    WHERE oi.order_id = o.order_id
) > (
    SELECT AVG(order_amount)
    FROM (
        SELECT oi.order_id, SUM(oi.quantity * oi.unit_price) as order_amount
        FROM order_items oi
        GROUP BY oi.order_id
    ) as average_order
);


-- 6/ In the sql_store database, how would you identify the product 
-- that appears most frequently in orders using a Common Table Expression?
USE sql_store;
WITH product_frequency AS (
    SELECT product_id, COUNT(*) as count
    FROM order_items
    GROUP BY product_id
)
SELECT product_id, count
FROM product_frequency
ORDER BY count DESC
LIMIT 1;

-- 7/ Using the sql_store database, create a temporary table that includes 
-- the customer_id, total quantity of products ordered, and total amount spent by each customer.
USE sql_store;
CREATE TEMPORARY TABLE temp_customer_totals AS
SELECT 
    o.customer_id, 
    SUM(oi.quantity) AS total_quantity, 
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM 
    orders o 
    JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.customer_id;

SELECT * 
FROM temp_customer_totals;


-- 8/ Using the sql_hr database, how would you find the employee who earns 
-- the least in each office using a Common Table Expression?
USE sql_hr;
WITH min_salary_office AS (
    SELECT office_id, MIN(salary) as min_salary
    FROM employees
    GROUP BY office_id
)
SELECT e.first_name, e.last_name, e.office_id, e.salary
FROM employees e
JOIN min_salary_office mso ON e.office_id = mso.office_id AND e.salary = mso.min_salary;


-- 9/ In the sql_invoicing database, can you write a stored procedure to calculate 
-- the total unpaid amount for each client?
USE sql_invoicing;
DROP PROCEDURE IF EXISTS calculate_unpaid_amount;
DELIMITER //
CREATE PROCEDURE calculate_unpaid_amount()
BEGIN
    SELECT 
        c.client_id, 
        c.name, 
        SUM(i.invoice_total) - IFNULL(SUM(p.amount), 0) AS unpaid_amount
    FROM 
        clients c
        LEFT JOIN invoices i ON c.client_id = i.client_id
        LEFT JOIN payments p ON i.invoice_id = p.invoice_id
    GROUP BY 
        c.client_id, c.name;
END //
DELIMITER ;


-- 10/ Using the sql_invoicing database, how would you list the top 5 clients 
-- who have the most unpaid invoices using a subquery?
USE sql_invoicing;
SELECT 
    c.client_id, 
    c.name, 
    unpaid_amounts.unpaid_amount
FROM 
    clients c
    JOIN (
        SELECT 
            client_id, 
            SUM(invoice_total) - IFNULL(SUM(payment_total), 0) AS unpaid_amount
        FROM 
            invoices
        GROUP BY 
            client_id
    ) AS unpaid_amounts ON c.client_id = unpaid_amounts.client_id
ORDER BY 
    unpaid_amounts.unpaid_amount DESC
LIMIT 5;


-- 11/ Using the sql_store database, how would you determine the total revenue 
-- made from each product using a subquery?
USE sql_store;
SELECT 
    p.product_id, 
    p.name, 
    SUM(order_item_totals.total_amount) AS total_revenue
FROM 
    products p
    JOIN (
        SELECT 
            product_id, 
            quantity * unit_price AS total_amount
        FROM 
            order_items
    ) AS order_item_totals ON p.product_id = order_item_totals.product_id
GROUP BY 
    p.product_id, p.name;


-- 12/ In the sql_hr database, create a stored procedure that promotes 
-- an employee to a manager position, updating their salary and reports_to fields accordingly.
USE sql_hr;
DROP PROCEDURE IF EXISTS promote_to_manager;
DELIMITER //
CREATE PROCEDURE promote_to_manager(
    IN emp_id INT, 
    IN new_salary DECIMAL(10, 2), 
    IN new_reports_to INT
)
BEGIN
    UPDATE employees
    SET salary = new_salary, 
        reports_to = new_reports_to
    WHERE employee_id = emp_id;
END //
DELIMITER ;


-- 13/ In the sql_invoicing database, can you write a stored procedure 
-- that applies a discount to all invoices over a certain amount?
USE sql_invoicing;
DROP PROCEDURE IF EXISTS apply_discount;
DELIMITER //
CREATE PROCEDURE apply_discount(
    IN min_invoice_total DECIMAL(10, 2), 
    IN discount_rate DECIMAL(5, 2)
)
BEGIN
    UPDATE invoices
    SET invoice_total = invoice_total * (1 - discount_rate)
    WHERE invoice_total > min_invoice_total;
END //
DELIMITER ;


-- 14/ In the sql_store database, how would you find the order that 
-- has the highest total amount using a Common Table Expression?
USE sql_store;
WITH order_totals AS (
    SELECT 
        order_id, 
        SUM(quantity * unit_price) AS total_amount
    FROM 
        order_items
    GROUP BY 
        order_id
)
SELECT 
    order_id, 
    total_amount
FROM 
    order_totals
ORDER BY 
    total_amount DESC
LIMIT 1;


-- 15/ Using the sql_store database, create a temporary table that 
-- includes the product_id, total quantity sold, and total revenue from each product.
USE sql_store;
CREATE TEMPORARY TABLE product_sales AS
SELECT 
    product_id, 
    SUM(quantity) AS total_quantity_sold, 
    SUM(quantity * unit_price) AS total_revenue
FROM 
    order_items
GROUP BY 
    product_id;
    
SELECT * FROM product_sales;


-- 16/ Using the sql_hr database, can you write a stored procedure that 
-- calculates the total salary expense for each office?
USE sql_hr;
DROP PROCEDURE IF EXISTS calculate_office_salaries;
DELIMITER //
CREATE PROCEDURE calculate_office_salaries()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE o_id INT;
  DECLARE total_salary DECIMAL(10, 2);
  DECLARE office_cursor CURSOR FOR SELECT office_id FROM offices;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  CREATE TEMPORARY TABLE office_salaries (
    office_id INT,
    total_salary DECIMAL(10, 2)
  );

  OPEN office_cursor;

  read_loop: LOOP
    FETCH office_cursor INTO o_id;

    IF done THEN
      LEAVE read_loop;
    END IF;

    SELECT SUM(salary) INTO total_salary
    FROM employees
    WHERE office_id = o_id;

    INSERT INTO office_salaries VALUES (o_id, total_salary);
  END LOOP;

  CLOSE office_cursor;
END //
DELIMITER ;


-- 17/ In the sql_hr database, create a temporary table that lists 
-- each manager and the total salary of all employees who report to them.
USE sql_hr;
CREATE TEMPORARY TABLE manager_salaries AS
SELECT 
    manager.employee_id AS manager_id, 
    manager.first_name AS manager_first_name, 
    manager.last_name AS manager_last_name, 
    SUM(employee.salary) AS total_salary
FROM 
    employees AS manager
JOIN 
    employees AS employee ON manager.employee_id = employee.reports_to
GROUP BY 
    manager.employee_id;

SELECT * FROM manager_salaries;


-- 18/ Identify the products which have never been ordered using subquery.
USE sql_store;
SELECT 
    product_id, 
    name
FROM 
    products
WHERE 
    product_id NOT IN (
        SELECT product_id 
        FROM order_items
    );


-- 19/ List the customers who have never placed an order using subquery.
USE sql_store;
SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    customers
WHERE 
    customer_id NOT IN (
        SELECT customer_id 
        FROM orders
    );


-- 20/ In sql_hr, list all employees who earn more than the 
-- average salary of their office using a subquery.
USE sql_hr;
SELECT 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    e.salary
FROM 
    employees e
WHERE 
    e.salary > (
        SELECT 
            AVG(e2.salary)
        FROM 
            employees e2
        WHERE 
            e2.office_id = e.office_id
    );


-- 21/ In sql_store, list the customers who have ordered every product at least once. 
USE sql_store;
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id
HAVING 
    COUNT(DISTINCT oi.product_id) = (SELECT COUNT(*) FROM products);


-- 22/ In sql_hr, write a stored procedure to raise the salary of an 
-- employee by a given percentage.
USE sql_hr;
DROP PROCEDURE IF EXISTS RaiseSalary;
DELIMITER //
CREATE PROCEDURE RaiseSalary(IN employee_id_param INT, IN percentage_increase DECIMAL(5,2))
BEGIN
    UPDATE employees
    SET salary = salary + salary * (percentage_increase / 100)
    WHERE employee_id = employee_id_param;
END //
DELIMITER ;


-- 23/ In sql_store, find the customer who has ordered the most distinct products.
USE sql_store;
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(DISTINCT oi.product_id) AS distinct_products_ordered
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name
ORDER BY 
    distinct_products_ordered DESC
LIMIT 1;


-- 24/ In sql_hr, list all offices that have more than the average number of employees.
USE sql_hr;
SELECT 
    o.office_id, 
    o.address, 
    o.city, 
    o.state, 
    COUNT(e.employee_id) AS employee_count
FROM 
    offices o
JOIN 
    employees e ON o.office_id = e.office_id
GROUP BY 
    o.office_id, 
    o.address, 
    o.city, 
    o.state
HAVING 
    employee_count > (
        SELECT AVG(employee_count) 
        FROM (
            SELECT 
                office_id, 
                COUNT(employee_id) AS employee_count
            FROM 
                employees
            GROUP BY 
                office_id
        ) AS average_office
    );


-- 25/ In sql_store, find the shipper that has shipped the most orders.
USE sql_store;
SELECT 
    s.shipper_id, 
    s.name AS shipper_name, 
    COUNT(o.order_id) AS order_count
FROM 
    shippers s
JOIN 
    orders o ON s.shipper_id = o.shipper_id
GROUP BY 
    s.shipper_id, 
    s.name
ORDER BY 
    order_count DESC
LIMIT 1;




