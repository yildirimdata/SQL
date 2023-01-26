--- SQL ASSIGNMENT 3
/*
Discount Effects

Generate a report including product IDs and discount effects on whether the increase in the 
discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. */

-- cte solution
WITH cte As
(SELECT  product_id, 
            discount,
            COUNT(order_id) AS orders,
            LAG(COUNT(order_id)) OVER (PARTITION BY product_id ORDER BY discount) as previous_orders,
            COALESCE((COUNT(order_id) - LAG(COUNT(order_id)) OVER (PARTITION BY product_id ORDER BY discount)),0) as change_in_orders
    FROM sale.order_item oi
    GROUP BY product_id, discount, list_price
    HAVING COUNT(product_id)>1)
SELECT cte.product_id, SUM(cte.change_in_orders) as total_diff,
    CASE 
    WHEN SUM(cte.change_in_orders) = 0 THEN 'neutral'
    WHEN SUM(cte.change_in_orders) > 0 THEN 'positive'
  WHEN SUM(cte.change_in_orders) < 0 THEN 'negative'
  END AS discount_effect
FROM cte
GROUP BY cte.product_id;


--- subquery solution
  
SELECT t.product_id, SUM(t.change_in_orders) as total_change,
 CASE 
        WHEN SUM(t.change_in_orders) < 0 THEN 'negative'
        WHEN SUM(t.change_in_orders) = 0 THEN 'neutral'
        WHEN SUM(t.change_in_orders) > 0 THEN 'positive'
        END AS DISCOUNT_EFFECT
FROM (
SELECT  product_id, 
            discount,
            COUNT(order_id) AS orders,
            LAG(COUNT(order_id)) OVER (PARTITION BY product_id ORDER BY discount) as previous_orders,
            COALESCE((COUNT(order_id) - LAG(COUNT(order_id)) OVER (PARTITION BY product_id ORDER BY discount)),0) as change_in_orders
    FROM sale.order_item oi
    GROUP BY product_id, discount, list_price
    HAVING COUNT(product_id)>1) t 
  GROUP BY t.product_id;



--- ikinci yontem veya having farklarını gorme

-- STEP 1: Preparing the table
-- without having

WITH cte AS(
  SELECT product_id, discount, COUNT(order_id) as total_orders
  FROM sale.order_item
  GROUP BY product_id, discount
  )
SELECT *,
        LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount) as previous_orders, 
        COALESCE(total_orders - (LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount)), 0) as change_order
  FROM cte;

-- with having
WITH cte AS(
  SELECT product_id, discount, COUNT(order_id) as total_orders
  FROM sale.order_item
  GROUP BY product_id, discount
  HAVING COUNT(product_id)>1)
SELECT *,
        LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount) as previous_orders, 
        COALESCE(total_orders - (LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount)), 0) as change_order
  FROM cte



-- STEP 3 and final result:

WITH cte AS(
  SELECT product_id, discount, COUNT(order_id) as total_orders
  FROM sale.order_item
  GROUP BY product_id, discount
  HAVING COUNT(product_id)>1),
cte2 
AS (SELECT *,
        LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount) as previous_orders, 
        COALESCE(total_orders - (LAG(total_orders) OVER(PARTITION BY product_id ORDER BY discount)), 0) as change_order
  FROM cte)
  SELECT cte2.product_id, SUM(cte2.change_order) as discount_effect,
        CASE 
        WHEN SUM(cte2.change_order) < 0 THEN 'negative'
        WHEN SUM(cte2.change_order) = 0 THEN 'neutral'
        WHEN SUM(cte2.change_order) > 0 THEN 'positive'
        END AS DISCOUNT_EFFECT
  FROM cte2
  GROUP BY cte2.product_id



