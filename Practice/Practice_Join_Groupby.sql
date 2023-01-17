
---- 1. List all the cities in the Texas and the numbers of customers in each city.----
SELECT city, COUNT('customer_id') as total_customers 
    FROM sale.customer 
    
    GROUP BY city;

---- 2. List all the cities in the California which has more than 5 customer, by showing the cities which have more customers first.---
SELECT city, COUNT('customer_id') as total_customers 
    FROM sale.customer
    WHERE state= 'CA' 
    GROUP BY city 
    ORDER BY total_customers DESC;


---- 3. List the top 10 most expensive products----
SELECT TOP 10 product_name, list_price 
    FROM product.product 
    ORDER BY list_price DESC;

---- 4. List store_id, product name and list price and the quantity of the products which are located in the store id 2 and the quantity is greater than 25----
SELECT s.store_id, p.product_name, s.quantity, p.list_price 
    FROM product.stock s 
    JOIN product.product p 
    ON s.product_id = p.product_id
    WHERE s.store_id = 2 AND s.quantity > 25;


---- 5. Find the sales order of the customers who lives in Boulder order by order date----

SELECT c.customer_id, 
        c.first_name + ' '+c.last_name as customer_name, 
        o.order_id,
        o.order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.city = 'Boulder'
    ORDER BY o.order_date;

---- 6. Get the sales by staffs and years using the AVG() aggregate function.

SELECT s.staff_id, 
        AVG(oi.list_price * oi.quantity * (1-oi.discount)) as total_sales
    FROM sale.staff s 
    JOIN sale.orders o 
    ON s.staff_id = o.staff_id
    JOIN sale.order_item oi 
    ON o.order_id = oi.order_id
    GROUP BY s.staff_id, 
            DATEPART(YEAR, o.order_date);

---- 7. What is the sales quantity of product according to the brands and sort them highest-lowest----

SELECT p.brand_id, 
        SUM(o.quantity) as total_quantity 
    FROM product.product p 
    JOIN sale.order_item o
    ON p.product_id = o.product_id
    GROUP BY p.brand_id
    ORDER BY total_quantity DESC;

---- 8. What are the categories that each brand has?----

SELECT DISTINCT b.brand_id, p.category_id
    FROM product.brand b 
    JOIN product.product p 
    ON b.brand_id = p.brand_id
    ORDER BY b.brand_id

SELECT DISTINCT category_id FROM product.category
SELECT DISTINCT category_id FROM product.product
SELECT DISTINCT brand_id FROM product.brand
SELECT DISTINCT brand_id FROM product.product

---- 9. Select the avg prices according to brands and categories----

SELECT DISTINCT b.brand_id, p.category_id, AVG(p.list_price) as avg_price
    FROM product.brand b 
    JOIN product.product p 
    ON b.brand_id = p.brand_id
    GROUP BY b.brand_id, p.category_id
    ORDER BY b.brand_id

---- 10. Select the annual amount of product produced according to brands----

-- query to control if there are difefrent brand_ids in two tables
SELECT DISTINCT brand_id FROM product.brand
SELECT DISTINCT brand_id FROM product.product


SELECT p.brand_id, b.brand_name, 
        p.model_year, COUNT(*) as total_product
    FROM product.product p 
    JOIN product.brand b 
    ON p.brand_id = b.brand_id
    GROUP BY p.brand_id, b.brand_name, p.model_year
    ORDER BY p.brand_id;

---- 11. Select the store which has the most sales quantity in 2016.----
SELECT DISTINCT store_id FROM sale.store --3
SELECT DISTINCT store_id FROM sale.orders --3

SELECT TOP 1 o.store_id, s.store_name, 
        SUM(oi.list_price * oi.quantity * (1-oi.discount)) as total_sales
    FROM sale.orders o 
    JOIN sale.order_item oi 
    ON o.order_id = oi.order_id
    JOIN sale.store s 
    ON o.store_id = s.store_id
    GROUP BY o.store_id, s.store_name
    ORDER BY total_sales DESC;

---- 12 Select the store which has the most sales amount in 2018.----

SELECT TOP 1 o.store_id, s.store_name, 
        SUM(oi.list_price * oi.quantity * (1-oi.discount)) as total_sales
    FROM sale.orders o 
    JOIN sale.order_item oi 
    ON o.order_id = oi.order_id
    JOIN sale.store s 
    ON o.store_id = s.store_id
    WHERE DATEPART(YEAR, o.order_date) = 2018
    GROUP BY o.store_id, s.store_name
    ORDER BY total_sales DESC;


---- 13. Select the personnel which has the most sales amount in 2019.----
SELECT DISTINCT staff_id FROM sale.staff  -- 10
SELECT DISTINCT staff_id FROM sale.orders

SELECT TOP 1 s.staff_id, s.first_name + ' ' + s.last_name,
        SUM(oi.list_price * oi.quantity * (1-oi.discount)) as total_sales
FROM sale.staff s 
LEFT JOIN sale.orders o 
ON  s.staff_id = o.staff_id
JOIN sale.order_item oi 
ON o.order_id = oi.order_id
WHERE DATEPART(YEAR, o.order_date) = 2019
GROUP BY s.staff_id, s.first_name + ' ' + s.last_name
ORDER BY total_sales DESC;
