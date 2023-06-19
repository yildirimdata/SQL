-- SQL - ASSIGNMENT 2

/*
1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 
buy the product below or not.
1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)
To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.
*/

SELECT DISTINCT
    c.customer_id, 
    c.first_name, 
    c.last_name,
    CASE
        WHEN (
            SELECT COUNT(DISTINCT product_id)
            FROM sale.order_item oi 
            JOIN sale.orders o ON oi.order_id = o.order_id
            WHERE product_id IN (
                SELECT p.product_id 
                FROM product.product p
                WHERE p.product_name IN ('Polk Audio - 50 W Woofer - Black', '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD')
            )
            AND o.customer_id = c.customer_id
        ) = 2 THEN 'YES'
        ELSE 'NO'
    END AS Other_product
FROM sale.orders o 
JOIN sale.customer c  
    ON o.customer_id = c.customer_id
JOIN sale.order_item oi 
    ON o.order_id = oi.order_id
JOIN product.product p 
    ON oi.product_id = p.product_id
WHERE p.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY c.customer_id;

-- or 
SELECT DISTINCT
    c.customer_id, 
    c.first_name, 
    c.last_name,
    CASE
        WHEN (
            SELECT COUNT(DISTINCT product_id)
            FROM sale.order_item oi, sale.orders o
            WHERE oi.order_id = o.order_id AND product_id IN (
                SELECT p.product_id 
                FROM product.product p
                WHERE p.product_name IN ('Polk Audio - 50 W Woofer - Black', '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD')
            )
            AND o.customer_id = c.customer_id
        ) = 2 THEN 'YES'
        ELSE 'NO'
    END AS Other_product
FROM sale.orders o, sale.customer c, sale.order_item oi,  product.product p
WHERE o.customer_id = c.customer_id AND o.order_id = oi.order_id AND oi.product_id = p.product_id
AND p.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY c.customer_id;

-- LEFT JOIN solution

SELECT DISTINCT A.*,
		CASE WHEN B.first_name IS NOT NULL THEN 'Yes' ELSE 'No' END IsOrder_SecondProduct
FROM
	(
	SELECT	 D.customer_id, D.first_name, D.last_name
	FROM	product.product A
			INNER JOIN
			sale.order_item B ON A.product_id = B.product_id
			INNER JOIN
			sale.orders C ON B.order_id = C.order_id
			INNER JOIN 
			sale.customer D ON C.customer_id = D.customer_id
	WHERE	
			A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	) A
	LEFT JOIN
	(
	SELECT	 D.customer_id, D.first_name, D.last_name
	FROM	product.product A
			INNER JOIN
			sale.order_item B ON A.product_id = B.product_id
			INNER JOIN
			sale.orders C ON B.order_id = C.order_id
			INNER JOIN 
			sale.customer D ON C.customer_id = D.customer_id
	WHERE	
			A.product_name = 'Polk Audio - 50 W Woofer - Black' 
	) B
	ON A.customer_id = B.customer_id
ORDER BY
	4 DESC

/* 2. 2. Conversion Rate
Below you see a table of the actions of customers visiting the website by clicking on two different types of 
advertisements given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type.
Actions:
a.    Create above table (Actions) and insert values,*/

CREATE TABLE Actions (
    VisitorID INT IDENTITY(1,1) PRIMARY KEY,
    Adv_type VARCHAR(255) NOT NULL,
    Action VARCHAR(255) NOT NULL
);

SELECT * FROM dbo.Actions;

INSERT dbo.Actions VALUES
 ('A', 'Left')
,('A', 'Order')
,('B', 'Left')
,('A', 'Order')
,('A', 'Review')
,('A', 'Left')
,('B', 'Left')
,('B', 'Order')
,('B', 'Review')
,('A', 'Review')



/*b.    Retrieve count of total Actions and Orders for each Advertisement Type,*/


WITH cte AS (
SELECT Adv_Type, COUNT(*) as total_actions
FROM dbo.Actions
GROUP BY Adv_type
)
SELECT a.Adv_type, cte.total_actions, COUNT(Action) as total_orders 
FROM dbo.Actions a 
JOIN cte ON cte.Adv_type = a.Adv_type
WHERE Action = 'Order'
GROUP BY a.Adv_type, cte.total_actions

select Adv_Type, count(*) total_action,
count(case when action = 'order' then 1 end) kaci_order
from dbo.Actions
group by Adv_Type

/*c.    Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting 
as float by multiplying by 1.0. */

SELECT Adv_type, CAST(1.0 * SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END)/
                COUNT(Adv_type) AS decimal(18,2)) as 'Conversion_rate'
FROM dbo.Actions
GROUP BY Adv_type;

-- ikisi birlikte

with t1 as 
(
select Adv_Type, count(*) total_action,
count(case when action = 'order' then 1 end) kaci_order
from dbo.Actions
group by Adv_Type
)
select adv_type, cast(1.0*kaci_order/total_action as decimal (3,2)) as conversion_rate
from t1