-- E-Commerce Data and Customer Retention Analysis with SQL

USE ecommerce
GO

/*
An e-commerce organization demands some analysis of sales and shipping processes. Thus, the organization 
hopes to be able to predict more easily the opportunities and threats for the future.
Acording to this scenario, You are asked to make the following analyzes consistent with following 
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

-- First inferences from the data:
-- There are some order ids which are not compatible with order dates.
-- Take the duplicate rows into account.
-- don't forget to use distinct in the queries.

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
            COUNT(DISTINCT Ord_ID) as total_orders
        FROM dbo.e_commerce_data
        GROUP BY Cust_ID, Customer_Name
        ORDER BY total_orders DESC;

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
                COUNT(Cust_ID) --OVER() as January_customers
        FROM dbo.e_commerce_data
        WHERE MONTH(Order_Date) = 1 
                AND YEAR(Order_Date) = 2011
        GROUP BY Cust_ID, Customer_Name;

-- STEP 2: How many of these customers also order in the other months of 2011?

WITH cte as
        (
        SELECT DISTINCT Cust_ID
                FROM dbo.e_commerce_data
                WHERE MONTH(Order_Date) = 1 
                AND YEAR(Order_Date) = 2011
                )
        SELECT MONTH(d.Order_Date) as months_2011, 
                COUNT(DISTINCT cte.Cust_ID) as total_customers
                FROM cte, dbo.e_commerce_data d 
                WHERE cte.Cust_ID = d.Cust_ID 
                        AND YEAR(d.Order_Date) = 2011
                GROUP BY MONTH(d.Order_Date)
                ORDER BY MONTH(d.Order_Date);

-- solution with subquery
SELECT MONTH(Order_Date) as months_2011, 
                COUNT(DISTINCT Cust_ID) as total_customers
                FROM dbo.e_commerce_data 
                WHERE YEAR(Order_Date) = 2011
                        AND Cust_ID IN (            
                SELECT DISTINCT Cust_ID
                                FROM dbo.e_commerce_data
                                WHERE MONTH(Order_Date) = 1 
                                AND YEAR(Order_Date) = 2011
                        )
        GROUP BY MONTH(Order_Date);

-- solution with exist and corr subquery:

SELECT MONTH(Order_Date) ord_month,
	COUNT(DISTINCT Cust_ID) numofcust
        FROM e_commerce_data A
        WHERE YEAR(Order_Date)=2011
        AND EXISTS 
                (
                SELECT 1
			FROM e_commerce_data B
			WHERE YEAR(Order_Date)=2011
			AND MONTH(Order_Date)=1
			AND B.Cust_ID=A.Cust_ID)
        GROUP BY MONTH(Order_Date);

-- to check the result with a month example

WITH cte AS 
        (
        SELECT DISTINCT Cust_ID, 
                        Customer_Name, 
                        COUNT(Cust_ID) OVER() as January_customers
                FROM dbo.e_commerce_data
                WHERE MONTH(Order_Date) = 1 
                        AND YEAR(Order_Date) = 2011
                GROUP BY Cust_ID, Customer_Name
                )
        SELECT cte.Cust_ID, 
                cte.Customer_Name
        FROM cte, dbo.e_commerce_data d 
        WHERE cte.Cust_ID = d.Cust_ID 
                AND cte.Customer_Name = d.Customer_Name 
                AND MONTH(d.Order_Date) = 2 
                AND YEAR(d.Order_Date) = 2011
                -- both queries give the same result. The result is true


-- 4. Write a query to return for each user the time elapsed between the first purchasing and the 
-- third purchasing, in ascending order by Customer ID.


SELECT Cust_ID, 
        first_order, 
        Order_Date as third_order,
	DATEDIFF(DD, first_order, Order_Date) day_elapsed
FROM (
		SELECT DISTINCT Cust_ID, 
                        Ord_ID, 
                        Order_Date,
			MIN(Order_Date) OVER(PARTITION BY Cust_ID) first_order,
			DENSE_RANK() OVER(PARTITION BY Cust_ID ORDER BY Order_Date, Ord_ID) sales_order
		FROM e_commerce_data) subq
WHERE sales_order=3

-- an alternative solution with lead function

--- solution with LEAD()

SELECT Cust_ID,
	DATEDIFF(DD, MIN(Order_Date), MIN(next_two_order)) day_elapsed
FROM(
                SELECT Cust_ID, Ord_ID, Order_Date,
		LEAD(Order_Date, 2) OVER(PARTITION BY Cust_ID 
                                        ORDER BY Order_Date, Ord_ID) next_two_order 
	        FROM e_commerce_data
	        GROUP BY Cust_ID, Ord_ID, Order_Date
                )subq
        WHERE next_two_order IS NOT NULL
        GROUP BY Cust_ID
        GO

-- 5. Write a query that returns customers who purchased both product 11 and product 14, 
-- as well as the ratio of these products to the total number of products purchased by the customer.

-- STEP 1: creating a table which contains only the customers who purchased prod 11-14 and
-- number of total products they bought.


WITH t1 AS
(
	SELECT Cust_ID,
		SUM(CASE WHEN Prod_ID='Prod_11' THEN Order_Quantity ELSE 0 END) AS prod_11,
		SUM(CASE WHEN Prod_ID='Prod_14' THEN Order_Quantity ELSE 0 END) AS prod_14,
		SUM(Order_Quantity) total_quantity
	FROM e_commerce_data
	GROUP BY Cust_ID
	HAVING
		SUM(CASE WHEN Prod_ID='Prod_11' THEN Order_Quantity ELSE 0 END) > 0
		AND
		SUM(CASE WHEN Prod_ID='Prod_14' THEN Order_Quantity ELSE 0 END) > 0
)
SELECT *,
	CAST(1.0*prod_11 / total_quantity AS DEC(3,2)) p11_ratio,
	CAST(1.0*prod_14 / total_quantity AS DEC(3,2)) p14_ratio
FROM t1
GO

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

CREATE or ALTER VIEW cust_visit_logs AS
        SELECT Cust_ID, 
                Year(Order_Date) AS Year, 
                Month(Order_Date) AS Month
        FROM e_commerce_data;
        GO


-- to check it:
SELECT * 
        FROM cust_visit_logs 
        ORDER BY [Year], [Month]


-- 2. Create a “view” that keeps the number of monthly visits of the customers. (Show separately 
-- all months from the beginning business)

CREATE or ALTER VIEW monthly_visits AS
        SELECT Cust_ID, 
		YEAR(Order_Date) AS ord_year, 
		Month(Order_Date) AS ord_month,
		COUNT(DISTINCT Ord_ID) AS num_of_visits
                FROM e_commerce_data
        GROUP BY 
	Cust_ID, 
	Year(Order_Date), 
	Month(Order_Date)
        GO

-- to check it:
SELECT * 
        FROM monthly_visits
        ORDER BY ord_year, ord_month;

-- to show monthly distribution of the visits 
SELECT MONTH(Order_Date) Months, COUNT(Cust_ID) AS visit_count
FROM dbo.e_commerce_data
GROUP BY MONTH(Order_Date);


-- 3. For each visit of customers, create the month of next visit as a separate column.

SELECT *,
	LEAD(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month) next_month_visit
        FROM(
                SELECT *,
		DENSE_RANK() OVER(ORDER BY ord_year, ord_month) current_month
	        FROM monthly_visits
                ) subq
GO

-- 4. Calculate the monthly time gap between two consecutive visits by each customer.

CREATE VIEW monthly_time_gaps AS
SELECT *,
	LEAD(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month) next_month_visit,
	LEAD(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month)-current_month time_gap
        FROM(
                SELECT *,
		DENSE_RANK() OVER(ORDER BY ord_year, ord_month) current_month
	FROM monthly_visits
        ) subq

-- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you. For example:
-- o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
-- o Labeled as regular if the customer has made a purchase in every month. Etc.

SELECT Cust_ID, AVG(1.0*time_gap) avg_time_gap,
	CASE	
		WHEN AVG(1.0*time_gap) IS NULL THEN 'churn'
		WHEN AVG(1.0*time_gap) <=3 AND COUNT(*) >= 4 THEN 'regular'
		WHEN AVG(1.0*time_gap) <=3 AND COUNT(*) < 4 THEN 'need attention'
		ELSE 'irregular' 
	END cust_segment
        FROM monthly_time_gaps
        GROUP BY Cust_ID
        ORDER BY cust_segment


/*
Month-Wise Retention Rate

Find month-by-month customer retention rate since the start of the business.
Calculate the month-wise retention rate, how many of the customers in the previous month could be retained 
in the next month.
Proceed step by step by creating “views”. You can use the view you got at the end of the 
Customer Segmentation section as a source.

1. Find the number of customers retained month-wise. (You can use time gaps) 

2. Calculate the month-wise retention rate.

Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total 
                            Number of Customers in the Current Month
*/

-- a comon solution for both sub-tasks:

SELECT * FROM monthly_time_gaps
GO


WITH t1 AS
(
	SELECT current_month,
		COUNT(Cust_ID) total_cust,
		SUM(CASE WHEN time_gap=1 THEN 1 END) cnt_retained_cust
	FROM monthly_time_gaps
	GROUP BY current_month
)
SELECT current_month,
	LAG(retention_rate) OVER(ORDER BY current_month) ret_rate
FROM
	(SELECT current_month, CAST(1.0*cnt_retained_cust / total_cust AS DEC(3,2)) retention_rate
	 FROM t1) subq

-- Solution with while loops:     

-- 1. Find the number of customers retained month-wise. (You can use time gaps) 


-- step 1 for task 1: creating a table with sequential numbers for each month group in the database
CREATE or ALTER VIEW monthly_retained_customers AS  
SELECT cust_id, year(Order_Date) as year, month(Order_Date) as month,  
                DENSE_RANK() OVER (ORDER BY year(Order_Date), month(Order_Date)) as months
                 from dbo.e_commerce_data

SELECT * FROM monthly_retained_customers

-- step 2: checking the number of retained customers with a while loop for each consecutive month groups
DECLARE @counter INT, @max_months INT, @retained_customers INT 
SET @counter = 1 
SET @max_months = (SELECT MAX(months) FROM monthly_retained_customers) 

WHILE @counter <= @max_months
	BEGIN 
			SET @retained_customers = (SELECT COUNT(DISTINCT cust_id) FROM monthly_retained_customers
                        WHERE months = @counter +1 AND Cust_ID IN (
                                SELECT DISTINCT Cust_ID FROM monthly_retained_customers
                                WHERE months = @counter
                        ))
			PRINT 'There are ' + CAST(@retained_customers AS VARCHAR(10)) 
								+ ' retained customers in the ' 
								+ CAST(@counter +1 AS VARCHAR (2))
                                                                + '. month.'
			SET @counter +=1
	END         

-- checking the result manually: 

SELECT count(distinct cust_id) FROM monthly_retained_customers
WHERE months = 2 AND cust_id IN (
SELECT DISTINCT cust_id FROM monthly_retained_customers                 -- 10
WHERE months = 1) 

SELECT count(distinct cust_id) FROM monthly_retained_customers
WHERE months = 3 AND cust_id IN (
SELECT DISTINCT cust_id FROM monthly_retained_customers
WHERE months = 2)                                                       -- 12

SELECT count(distinct cust_id) FROM monthly_retained_customers
WHERE months = 4 AND cust_id IN (
SELECT DISTINCT cust_id FROM monthly_retained_customers
WHERE months = 3)                                                       -- 13



--2. Calculate the month-wise retention rate.
-- Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total 
--                             Number of Customers in the Current Month


DECLARE @counter INT, @max_months INT, @retained_customers INT, @total_customers_per_month INT  
SET @counter = 1 
SET @max_months = (SELECT MAX(months) FROM monthly_retained_customers) 

WHILE @counter < @max_months
	BEGIN 
			SET @retained_customers = (SELECT COUNT(DISTINCT cust_id) 
                                                FROM monthly_retained_customers
                                                WHERE months = @counter +1 
                                                        AND Cust_ID IN 
                                                                (
                                                                SELECT DISTINCT Cust_ID 
                                                                FROM monthly_retained_customers
                                                                WHERE months = @counter
                                                                ))
                        SET @total_customers_per_month = (SELECT COUNT (DISTINCT Cust_ID) 
                                                        FROM monthly_retained_customers
                                                        WHERE months = @counter + 1)

			PRINT 'Retention rate is ' 
                                + CAST(100 * @retained_customers / @total_customers_per_month AS VARCHAR(2))
                                + '% for the '
                                + CAST(@counter +1 AS VARCHAR (2))
                                + '. month.'

			SET @counter +=1
	END  


