-- E-Commerce Data and Customer Retention Analysis with SQL

/*
An e-commerce organization demands some analysis of sales and shipping processes. Thus, the organization 
hopes to be able to predict more easily the opportunities and threats for the future.
Acording to this scenario, You are asked to make the following analyzes consistant with following 
the instructions given.
Introduction
- You have to create a database and import into the given csv file. 
- During the import process, you will need to adjust the date columns. 
You need to carefully observe the data types and how they should be.
- The data are not very clean and fully normalized. However, they don't prevent you from performing 
the given tasks.
- Manually verify the accuracy of your analysis.
*/

SELECT TOP (1000) [Ord_ID]
      ,[Cust_ID]
      ,[Prod_ID]
      ,[Ship_ID]
      ,[Order_Date]
      ,[Ship_Date]
      ,[Customer_Name]
      ,[Province]
      ,[Region]
      ,[Customer_Segment]
      ,[Sales]
      ,[Order_Quantity]
      ,[Order_Priority]
      ,[DaysTakenForShipping]
  FROM [ecommerce].[dbo].[e_commerce_data]


SELECT * FROM dbo.e_commerce_data; -- total 8103 rows


SELECT DISTINCT Ord_ID FROM dbo.e_commerce_data;  -- 5506
SELECT DISTINCT Cust_ID FROM dbo.e_commerce_data;  -- 1736
SELECT DISTINCT Prod_ID FROM dbo.e_commerce_data;  -- 17
SELECT DISTINCT Ship_ID FROM dbo.e_commerce_data;  -- 5505
SELECT DISTINCT Order_Date FROM dbo.e_commerce_data;  -- 1418
SELECT DISTINCT Ship_Date FROM dbo.e_commerce_data;  -- 1428
SELECT DISTINCT Customer_Name FROM dbo.e_commerce_data; -- 795
SELECT DISTINCT Province FROM dbo.e_commerce_data; -- 13
SELECT DISTINCT Region FROM dbo.e_commerce_data; -- 8
SELECT DISTINCT Customer_Segment FROM dbo.e_commerce_data;  -- 4
SELECT DISTINCT Sales FROM dbo.e_commerce_data;  -- 7823
SELECT DISTINCT Order_Quantity FROM dbo.e_commerce_data;  -- 50
SELECT DISTINCT Order_Priority FROM dbo.e_commerce_data;  -- 5
SELECT DISTINCT DaysTakenForShipping FROM dbo.e_commerce_data;  17

/*
Analyze the data by finding the answers to the questions below:

1. Find the top 3 customers who have the maximum count of orders.

2. Find the customer whose order took the maximum time to get shipping.

3. Count the total number of unique customers in January and how many of them came 
back every month over the entire year in 2011

4. Write a query to return for each user the time elapsed between the first purchasing and the 
third purchasing, in ascending order by Customer ID.

5. Write a query that returns customers who purchased both product 11 and product 14, 
as well as the ratio of these products to the total number of products purchased by the customer.
*/

-- 1. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 Cust_ID, 
            Customer_Name, 
            COUNT(Ord_ID) as total_orders
        FROM dbo.e_commerce_data
        GROUP BY Cust_ID, Customer_Name
        ORDER BY COUNT(Ord_ID) DESC;

-- 2. Find the customer whose order took the maximum time to get shipping.

SELECT TOP 1 Cust_ID, 
            Customer_Name, 
            DaysTakenForShipping
            FROM dbo.e_commerce_data
            ORDER BY DaysTakenForShipping DESC;

-- 3. Count the total number of unique customers in January and how many of them came 
-- back every month over the entire year in 2011

-- STEP 1: Who are the unique customers in January 2011 and their total number.

SELECT DISTINCT Cust_ID, Customer_Name, 
                COUNT(Cust_ID) OVER() as January_customers
        FROM dbo.e_commerce_data
        WHERE MONTH(Order_Date) = 1 
                AND YEAR(Order_Date) = 2011
        GROUP BY Cust_ID, Customer_Name;

-- STEP 2: How many of these customers also order in the other months of 2011?

WITH cte as
(SELECT DISTINCT Cust_ID
        FROM dbo.e_commerce_data
        WHERE MONTH(Order_Date) = 1 
                AND YEAR(Order_Date) = 2011)
SELECT MONTH(d.Order_Date) as months_2011, COUNT(DISTINCT cte.Cust_ID) as total_customers
        FROM cte, dbo.e_commerce_data d 
        WHERE cte.Cust_ID = d.Cust_ID AND YEAR(d.Order_Date) = 2011
        GROUP BY MONTH(d.Order_Date)
        ORDER BY MONTH(d.Order_Date);


-- to check it with a month example

WITH cte AS 
(
SELECT DISTINCT Cust_ID, Customer_Name, COUNT(Cust_ID) OVER() as January_customers
FROM dbo.e_commerce_data
WHERE MONTH(Order_Date) = 1 AND YEAR(Order_Date) = 2011
GROUP BY Cust_ID, Customer_Name
)
SELECT cte.Cust_ID, cte.Customer_Name
FROM cte, dbo.e_commerce_data d 
WHERE cte.Cust_ID = d.Cust_ID AND cte.Customer_Name = d.Customer_Name 
        AND MONTH(d.Order_Date) = 2 AND YEAR(d.Order_Date) = 2011
        -- both queries give the same result.


-- 4. Write a query to return for each user the time elapsed between the first purchasing and the 
-- third purchasing, in ascending order by Customer ID.

WITH cte AS(
        SELECT Cust_ID, Customer_Name, 
                COUNT(Ord_ID) as total_orders 
        FROM dbo.e_commerce_data
        GROUP BY Cust_ID, Customer_Name
        HAVING COUNT(Ord_ID) > 2), t2 AS (
SELECT cte.Cust_ID, cte.Customer_Name, d.Order_Date,
        LEAD(d.Order_Date, 2) OVER 
                (PARTITION BY cte.Cust_ID, cte.Customer_Name 
                ORDER BY cte.Cust_ID, d.Order_Date) as third_order,
        ROW_NUMBER() OVER(PARTITION BY cte.Cust_ID, cte.Customer_Name 
                    ORDER BY cte.Cust_ID, d.Order_Date) AS order_number
        FROM cte, dbo.e_commerce_data d
        WHERE cte.Cust_ID = d.Cust_ID) 
SELECT t2.Cust_ID, t2.Customer_Name, t2.Order_Date, t2.third_order, 
        DATEDIFF(DAY, Order_Date, third_order) as time_elapse
        FROM t2 
        WHERE t2.order_number = 1;


-- 5. Write a query that returns customers who purchased both product 11 and product 14, 
-- as well as the ratio of these products to the total number of products purchased by the customer.

-- STEP 1: creating a table which contains only the customers who purchased prod 11-14 and
-- number of total products they bought.

WITH cte as 
        (
        SELECT Cust_ID, Customer_Name
        FROM dbo.e_commerce_data
        WHERE Prod_ID = 'Prod_11'
        INTERSECT -- intersection of prod_11 and 14 buyers
        SELECT Cust_ID, Customer_Name
        FROM dbo.e_commerce_data
        WHERE Prod_ID = 'Prod_14'
        )
            SELECT cte.Cust_ID, cte.Customer_Name, d.Prod_ID,
                CASE 
                WHEN d.prod_ID IN ('Prod_11', 'Prod_14') THEN 1 ELSE 0 END as prod_11_14,
                COUNT(d.prod_ID) OVER(PARTITION BY cte.Cust_ID, cte.Customer_Name) as total_products
            FROM cte, dbo.e_commerce_data d 
            WHERE cte.Cust_ID = d.Cust_ID AND cte.Customer_Name = d.Customer_Name
            ORDER BY cte.Cust_ID;

-- STEP 2: filtering the table and calculating the ratio

WITH cte as 
    (
    SELECT Cust_ID, Customer_Name
        FROM dbo.e_commerce_data
        WHERE Prod_ID = 'Prod_11'
    INTERSECT 
    SELECT Cust_ID, Customer_Name
        FROM dbo.e_commerce_data
        WHERE Prod_ID = 'Prod_14'
    ), t2 as (
        SELECT DISTINCT cte.Cust_ID, cte.Customer_Name,
            SUM(CASE WHEN d.prod_ID IN ('Prod_11', 'Prod_14') THEN 1 ELSE 0 END) 
            OVER (PARTITION BY cte.Cust_ID, cte.Customer_Name) as prod_11_14,
            COUNT(d.prod_ID) OVER(PARTITION BY cte.Cust_ID, cte.Customer_Name) as total_products
        FROM cte, dbo.e_commerce_data d 
        WHERE cte.Cust_ID = d.Cust_ID AND cte.Customer_Name = d.Customer_Name
                )
    SELECT t2.Cust_ID, t2.Customer_Name, t2.prod_11_14, t2.total_products,
            100 * t2.prod_11_14/t2.total_products as ratio_11_14
            FROM t2
            ORDER BY t2.Cust_ID;


/*
Customer Segmentation
Categorize customers based on their frequency of visits. The following steps will guide you. 
If you want, you can track your own way.

1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, 
three field is kept: Cust_id, Year, Month)
2. Create a “view” that keeps the number of monthly visits by users. (Show separately 
all months from the beginning business)
3. For each visit of customers, create the next month of the visit as a separate column.
4. Calculate the monthly time gap between two consecutive visits by each customer.
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
For example:
o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
o Labeled as regular if the customer has made a purchase every month. Etc.
*/

-- 1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, 
-- three field is kept: Cust_id, Year, Month)

CREATE or ALTER VIEW vw_customer_visits 
AS 
        SELECT Cust_ID,
            YEAR(Order_Date) AS Year,
            MONTH(Order_Date) AS Month,
            Order_Date as timestamp
        FROM dbo.e_commerce_data
        GROUP BY Cust_ID, YEAR(Order_Date),  MONTH(Order_Date), Order_Date;

-- to check it:
SELECT * FROM vw_customer_visits


-- 2. Create a “view” that keeps the number of monthly visits by users. (Show separately 
-- all months from the beginning business)

CREATE or ALTER VIEW monthly_visits AS
        SELECT 
                YEAR(order_date) as Year, 
                MONTH(order_date) as Month, 
                COUNT(*) as monthly_visits
        FROM dbo.e_commerce_data
        GROUP BY YEAR(order_date), MONTH(order_date);

-- to check it:
SELECT * FROM monthly_visits
ORDER BY Year, Month;


-- 3. For each visit of customers, create the month of next visit as a separate column.

SELECT Cust_ID, Customer_Name,
		Ord_ID,
        Order_Date,
			MONTH(LEAD(Order_Date) OVER (PARTITION BY Cust_ID, Customer_Name ORDER BY Cust_ID, Order_Date)) as next_order_month
				FROM dbo.e_commerce_data;


-- 4. Calculate the monthly time gap between two consecutive visits by each customer.

SELECT Cust_ID, Customer_Name,
		Ord_ID,
        Order_Date,
			LEAD(Order_Date) OVER (PARTITION BY Cust_ID, Customer_Name ORDER BY Cust_ID, Order_Date) as next_order,
            DATEDIFF(MONTH,Order_Date, 
                    LEAD(Order_Date) OVER (PARTITION BY Cust_ID, Customer_Name ORDER BY Cust_ID, Order_Date)) 
                    as time_gap_between_orders
				FROM dbo.e_commerce_data;

-- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you. For example:
-- o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
-- o Labeled as regular if the customer has made a purchase every month. Etc.

WITH cte AS(
    SELECT Cust_ID, Customer_Name,
	    	Ord_ID,
            Order_Date,
			LEAD(Order_Date) OVER (PARTITION BY Cust_ID, Customer_Name ORDER BY Cust_ID, Order_Date) as next_order,
            DATEDIFF(MONTH,Order_Date, LEAD(Order_Date) 
                    OVER (PARTITION BY Cust_ID, Customer_Name ORDER BY Cust_ID, Order_Date)) 
                    as time_gap_between_orders
				FROM dbo.e_commerce_data)
SELECT Cust_ID, 
        Customer_Name, 
        AVG(time_gap_between_orders) as avg_time_gap,
        CASE
        WHEN AVG(time_gap_between_orders) IS NULL THEN 'Churn'
        WHEN AVG(time_gap_between_orders) <= 24 THEN 'Regular'  -- if a customer orders at least once in 24 months: "regular"
        WHEN AVG(time_gap_between_orders) > 24 THEN 'Potential Churn' -- if there is a huge time gap between orders, the company
                                                                    -- should give more attention to this type of customers
                                                                    -- as churn candidates.
        END AS churn_status
FROM cte 
GROUP BY Cust_ID, Customer_Name
ORDER BY AVG(time_gap_between_orders)


/*
Month-Wise Retention Rate
Find month-by-month customer retention rate since the start of the business.
There are many different variations in the calculation of Retention Rate. But we will try to 
calculate the month-wise retention rate in this project.
So, we will be interested in how many of the customers in the previous month could be retained 
in the next month.
Proceed step by step by creating “views”. You can use the view you got at the end of the 
Customer Segmentation section as a source.

1. Find the number of customers retained month-wise. (You can use time gaps) 

2. Calculate the month-wise retention rate.

Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total 
                            Number of Customers in the Current Month
*/