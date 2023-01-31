
USE SampleRetail
GO 
----1. Select the least 3 products in stock according to stores.
WITH cte AS
	(
	SELECT store_id, 
			product_id, 
			SUM(quantity) as total_products,
			DENSE_RANK() OVER(PARTITION BY store_id, 
								product_id 
								ORDER BY SUM(quantity)) 
								as product_ranking
	FROM product.stock
	GROUP BY store_id, product_id
	)
	SELECT cte.store_id, 
			cte.product_id, 
			p.product_name, 
			cte.total_products
	FROM cte, product.product p 
	WHERE cte.product_id = p.product_id AND
			cte.product_ranking IN (1,2,3);


----2. Return the average number of sales orders in 2020 sales

SELECT DISTINCT o.order_id, AVG(oi.quantity) OVER(PARTITION BY o.order_id) as avg_sales
	FROM sale.orders o, sale.order_item oi 
	WHERE o.order_id= oi.order_id AND YEAR(o.order_date) = 2020

----3. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.\

WITH cte AS 
	(
		SELECT brand_id, 
				product_name, 
				list_price,
				DENSE_RANK() OVER(PARTITION BY brand_id ORDER BY list_price) as product_rankings
				FROM product.product
	)
	SELECT cte.brand_id, 
			cte.product_name, 
			cte.product_rankings
	FROM cte
	WHERE cte.product_rankings <= 3;


----4. Write a query that returns the highest daily turnover amount for each week on a yearly basis.

WITH cte AS 
	(
		SELECT DISTINCT YEAR(o.order_date) as year,
				DATEPART(WEEK, o.order_date) as week,
				SUM(oi.list_price*oi.quantity*(1-oi.discount)) 
					OVER(PARTITION BY o.order_date) as daily_turnover
				FROM sale.order_item oi, sale.orders o 
				WHERE oi.order_id = o.order_id
	)
	SELECT DISTINCT cte.year, 
			cte.week,
			MAX(daily_turnover) OVER(PARTITION BY cte.year, cte.week)
	FROM cte;  

-----with group by
SELECT 
	DISTINCT
	YEAR(a.order_date) order_year,
	DATEPART(ISOWW, a.order_date) order_week,
	FIRST_VALUE(SUM(b.quantity * b.list_price * (1-b.discount))) OVER(
			PARTITION BY YEAR(a.order_date), DATEPART(ISOWW, a.order_date)
			ORDER BY SUM(b.quantity * b.list_price * (1-b.discount)) DESC) highest_turnover
FROM
	sale.orders a
	LEFT JOIN
	sale.order_item b ON a.order_id=b.order_id
GROUP BY
	a.order_date


----5. Write a query that returns the cumulative distribution of the list price in product table by brand.

SELECT brand_id, list_price,
		CAST(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price) as decimal(18,2)) as cum_list_price
FROM product.product

----6. Write a query that returns the relative standing of the list price in the product table by brand.

SELECT
	brand_id, list_price,
	FORMAT(ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3), 'P') percent_rnk
FROM
	product.product;


----7. Divide customers into 5 groups based on the quantity of product they order.
WITH cte AS 
	(
			SELECT c.customer_id, 
					SUM(oi.quantity) total_products
			FROM sale.customer c
			LEFT JOIN sale.orders o
					ON c.customer_id = o.customer_id
			JOIN sale.order_item oi 
					ON o.order_id = oi.order_id
			GROUP BY c.customer_id
	)
	SELECT cte.customer_id, 
			cte.total_products, 
			NTILE(5) OVER(ORDER BY total_products DESC) as customer_groups
	FROM cte;


----8. List customers who have at least 2 consecutive orders which have not been shipped.


WITH t1 AS(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status
	FROM
		sale.orders
), t2 AS(
	SELECT *,
		LEAD(delivery_status) OVER(PARTITION BY customer_id ORDER BY order_id) next_delivery_status
	FROM
		t1
)
SELECT
	customer_id
FROM
	t2
WHERE
	delivery_status='not delivered' AND next_delivery_status='not delivered';


----2nd solution

SELECT customer_id
FROM(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status,
		LEAD(CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END) OVER(
			PARTITION BY customer_id ORDER BY order_date) next_delivery_status
	FROM
		sale.orders
) t
WHERE 
	delivery_status='not delivered' AND next_delivery_status='not delivered';
