-- JOIN-VIEW PRACTICE

-- QUESTION 1
-- Write a query that returns the order date of the product named 
-- "Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black".

SELECT o.order_date
    FROM sale.orders o  
    JOIN sale.order_item oi  
    ON o.order_id = oi.order_id
    JOIN product.product p 
    ON p.product_id = oi.product_id
    WHERE product_name = 'Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black';

-- what have we done exactly above. We've used 3 tables to get the final result.
-- 1. find the product_id of the related product from the product.product table
    SELECT product_id
    FROM product.product
    WHERE product_name = 'Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black';
    -- output 260

-- 2. by using this product_id, find the order_id of this product from sale.order_item table
    SELECT order_id
    FROM sale.order_item
    WHERE product_id = 260;
    -- output: 1435,1449,1498,1589

-- 3. find the order_date from the sale.orders table by using order_id as a condition
    SELECT order_date
    FROM sale.orders
    WHERE order_id IN (1435,1449,1498,1589);


-- QUESTION 2
-- Write a query that returns orders of the products branded "Seagate". It should be listed Product names and order IDs 
-- of all the products ordered or not ordered. (order_id in ascending order)

SELECT product_name, brand_id
    FROM product.product
    WHERE product_name LIKE '%seagate%'; 

SELECT p.product_name, oi.order_id 
    FROM product.product p 
    FULL OUTER JOIN sale.order_item oi 
    ON p.product_id = oi.product_id
    WHERE p.product_name LIKE '%seagate%'
    ORDER BY oi.order_id;  

-- we can also solve this question with a left join
SELECT p.product_name, oi.order_id
    FROM product.product p 
    LEFT JOIN sale.order_item oi 
    ON p.product_id = oi.product_id
    WHERE p.product_name LIKE '%Seagate%'
    ORDER BY oi.order_id;

-- QUESTION 3
-- How many employees are in each store?
SELECT sto.store_name, COUNT(sta.staff_id) as total_employees
  FROM sale.staff sta 
    JOIN sale.store sto 
    ON sta.store_id = sto.store_id
    GROUP BY sto.store_name;

