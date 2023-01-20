-- SQL - ASSIGNMENT 2

/*
1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 
buy the product below or not.
1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)
To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.
*/

SELECT 
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
ORDER BY c.customer_id



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

SELECT * FROM dbo.Actions;


/*b.    Retrieve count of total Actions and Orders for each Advertisement Type,*/

WITH cte AS (
SELECT Adv_Type, COUNT(Action) as total_actions
FROM dbo.Actions
GROUP BY Adv_type
)
SELECT a.Adv_Type, cte.total_actions, COUNT(Action) as total_orders
FROM dbo.Actions a 
JOIN cte ON cte.Adv_type = a.Adv_type
WHERE Action = 'Order'
GROUP BY a.Adv_type, cte.total_actions

/*c.    Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting 
as float by multiplying by 1.0. */
SELECT Adv_type, 1.0 * SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END)/COUNT(Adv_type) as 'Conversion_rate'
FROM dbo.Actions
WHERE Adv_type = 'A'
GROUP BY Adv_type
UNION
SELECT Adv_type, 1.0*SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END)/COUNT(Adv_type) as 'Conversion_rate'
FROM dbo.Actions
WHERE Adv_type = 'B'
GROUP BY Adv_type;