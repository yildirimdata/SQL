-- Script to create the Product table and load data into it.

DROP TABLE product;
CREATE TABLE product
( 
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);

INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);



select * from product;


-- FIRST_VALUE 
-- Write query to display the most expensive product under each category (corresponding to each record)

SELECT *,
        FIRST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC) AS most_exp_product
    FROM product;
-- corresponding to each category

SELECT DISTINCT product_category, FIRST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC)
FROM dbo.product


-- LAST_VALUE 
-- Write query to display the least expensive product under each category (corresponding to each record)

SELECT *,
        LAST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC) AS cheapest_product
    FROM dbo.product;

-- most expensive and least expensive together
SELECT *,
        FIRST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC) as most_exp_product,
        LAST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC
                                    range between unbounded preceding and unbounded following) 
                                    -- DEFAULT range between unbounded preceding and current row
                                    -- by changing it to the unbounded following, we assurer that if there are any cheaper
                                    -- products after the current row, they'll also be taken into account.
                                    AS cheapest_product
    FROM dbo.product;

-- just for the phone category --- with ROWS
SELECT *,
        FIRST_VALUE(product_name) OVER(PARTITION BY product_category 
                                    ORDER BY price DESC) as most_exp_product,
        LAST_VALUE(product_name) OVER(PARTITION BY product_category 
                                    ORDER BY price DESC
                                    rows between unbounded preceding and unbounded following) 
                                    AS cheapest_product
    FROM dbo.product
    WHERE product_category = 'Phone';


-- Alternate way to write SQL query using Window functions: to avoid repeating same over clause

-- this doesn't work on azure 
SELECT *,
FIRST_VALUE(product_name) OVER w as most_exp_product,
LAST_VALUE(product_name) OVER w as cheapest_product    
FROM product
WHERE product_category ='Phone'
WINDOW w AS (PARTITION BY product_category ORDER BY price DESC
            range between unbounded preceding and unbounded following);
            

            
-- NTH_VALUE 

-- it can return a value from any position that we specify
-- Write query to display the Second most expensive product under each category.

SELECT *,
        FIRST_VALUE(product_name) OVER(PARTITION BY product_category 
                                    ORDER BY price DESC) as most_exp_product,
        LAST_VALUE(product_name) OVER(PARTITION BY product_category 
                                    ORDER BY price DESC
                                    rows between unbounded preceding and unbounded following) 
                                    AS cheapest_product--,
        -- NTH_VALUE(product_name, 2) OVER(PARTITION BY product_category
        --                            ORDER BY price DESC) as second_most_exp_product
        -- There is no nth value in this SQL server 
    FROM dbo.product
    WHERE product_category = 'Phone';


-- NTILE
-- Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.


-- Solution with cte
WITH cte AS(
SELECT *, 
        NTILE(3) OVER(PARTITION BY product_category -- since the category is filtered with where, we don't actually need to
                                                  -- write PARTITION BY here again.
                ORDER BY price DESC) as price_category
    FROM dbo.product
    WHERE product_category = 'Phone'
)
SELECT cte.product_name, CASE 
            WHEN price_category = 1 THEN 'Expensive'
            WHEN price_category = 2 THEN 'Mid range'
            WHEN price_category = 3 THEN 'Cheap'
            END AS price_bucket
FROM cte

-- sql tries to set the groups in equal numbers. 
-- solution with subquery

SELECT x.product_name, 
CASE when x.buckets = 1 then 'Expensive Phones'
     when x.buckets = 2 then 'Mid Range Phones'
     when x.buckets = 3 then 'Cheaper Phones' END as Phone_Category
FROM (
    select *,
    ntile(3) over (order by price desc) as buckets
    from product
    where product_category = 'Phone') x;


-- CUME_DIST (cumulative distribution) ; 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */

-- Query to fetch all products which are constituting the first 30% 
-- of the data in products table based on price.

-- step 1: executing cume_dist function
SELECT *, CUME_DIST() OVER(ORDER BY price DESC) as cume_dist 
FROM dbo.product

-- step 2: converting it into percentage
SELECT *, CUME_DIST() OVER(ORDER BY price DESC) as cume_dist,
        CAST(CUME_DIST() OVER(ORDER BY price DESC) * 100 AS decimal (18,2)) as cume_dist_percentage 
        FROM dbo.product

-- step 3: getting the fist 30% and product names

WITH cte AS (
        SELECT *, CUME_DIST() OVER(ORDER BY price DESC) as cume_dist,
            CAST(CUME_DIST() OVER(ORDER BY price DESC) * 100 AS decimal (18,2)) as cume_dist_percentage 
            FROM dbo.product
)
SELECT cte.product_name, cume_dist_percentage FROM cte
WHERE cume_dist_percentage <30;

-- SOLUTION with SQuery

SELECT product_name, cume_dist_percetage
    FROM (
        SELECT *,
        CUME_DIST() OVER (ORDER BY price DESC) AS cume_distribution,
        CAST(CUME_DIST() OVER(ORDER BY price) * 100 AS decimal (18,2)) as cume_dist_percetage
        FROM product) x
WHERE x.cume_distribution <= 0.3;


-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */

-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to all products.

SELECT *, PERCENT_RANK() OVER(ORDER BY price) as percent_rank,
        CAST(PERCENT_RANK() OVER(ORDER BY price) *100 AS DECIMAL (18,2)) as percentage_rank
FROM dbo.product


WITH cte AS 
(
    SELECT *, PERCENT_RANK() OVER(ORDER BY price) as percent_rank,
            CAST(PERCENT_RANK() OVER(ORDER BY price) *100 AS DECIMAL (18,2)) as percentage_rank
            FROM dbo.product
) 
SELECT cte.product_name, percentage_rank
FROM cte 
WHERE cte.product_name = 'Galaxy Z Fold 3';


-- solution 2
SELECT product_name, per
FROM (
    SELECT *, 
        PERCENT_RANK() OVER(ORDER BY price) as percent_rank,
        CAST(PERCENT_RANK() OVER(ORDER BY price) *100 AS DECIMAL (18,2)) as per
    FROM product) x
WHERE x.product_name='Galaxy Z Fold 3';

