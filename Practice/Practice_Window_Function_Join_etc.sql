

--1.  By using view get the average number of products sold by staffs and years using the AVG() aggregate function.
SELECT s.staff_id, YEAR(o.order_date) as years, 1.0 * AVG(oi.quantity) as avg_sales
FROM sale.orders o, sale.order_item oi, sale.staff s 
WHERE o.staff_id = s.staff_id AND o.order_id = oi.order_id
GROUP BY s.staff_id, YEAR(o.order_date)
ORDER BY s.staff_id;

SELECT DISTINCT s.staff_id, YEAR(o.order_date), AVG(oi.quantity) 
            OVER(PARTITION BY s.staff_id, YEAR(o.order_date)) as avg_sales
FROM sale.orders o, sale.order_item oi, sale.staff s 
WHERE o.staff_id = s.staff_id AND o.order_id = oi.order_id
ORDER BY s.staff_id

--2. Select the annual amount of product produced according to brands (use window functions).

SELECT p.brand_id, i.product_id, YEAR(order_date) years, SUM(i.quantity) as total_product  
FROM sale.order_item i
JOIN sale.orders o ON i.order_id = o.order_id
JOIN product.product p ON p.product_id= i.product_id
GROUP BY p.brand_id, i.product_id, YEAR(order_date)

SELECT DISTINCT p.brand_id, i.product_id, YEAR(order_date) years,SUM(i.quantity) 
    OVER(PARTITION BY p.brand_id, i.product_id, YEAR(order_date)) as total_product
    FROM sale.order_item i
    JOIN sale.orders o 
        ON i.order_id = o.order_id
    JOIN product.product p 
        ON p.product_id= i.product_id

--3. List all the cities in California which has more than 5 customer, by showing the cities which have more customers first.---

SELECT  city, COUNT(customer_id) as total_customers
FROM sale.customer
WHERE [state] = 'CA'
GROUP BY city 
HAVING COUNT(customer_id)>5
ORDER BY total_customers DESC;

WITH cte AS (
SELECT  DISTINCT city, COUNT(customer_id) OVER(PARTITION BY city) as total_customers
FROM sale.customer
WHERE [state] = 'CA'
  )
  SELECT * FROM cte
  WHERE total_customers >5


--4.Find the customers who placed at least two orders per year.
-- year, customer_id, order_id

SELECT customer_id, YEAR(order_date), COUNT(order_id)
FROM sale.orders
GROUP BY customer_id, YEAR(order_date)
HAVING COUNT(order_id) >=2
ORDER BY customer_id

WITH cte AS(
SELECT DISTINCT customer_id, YEAR(order_date) years, COUNT(order_id) OVER(PARTITION BY customer_id, YEAR(order_date)) as annual_order
FROM sale.orders)
SELECT * from cte 
WHERE annual_order>=2

/*5. Find the total amount of each order which are placed in 2018. Then categorize them according to limits stated below.
(You can use case statements here)

    If the total amount of order    
        less then 500 then "very low"
        between 500 - 1000 then "low"
        between 1000 - 5000 then "medium"
        between 5000 - 10000 then "high"
        more then 10000 then "very high" 
*/



--6. By using Exists Statement find all customers who have placed more than two orders

--7. Show all the products and their list price, that were sold with more than two units in a sales order

/*
  8. Show the total count of orders per product for all times. 
  (Every product will be shown in one line and the total order count will be shown besides it) 
*/

--9. Find the products whose list prices are more than the average list price of products of all brands:

