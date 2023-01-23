-- SQL 7 -- CASE Expression

/*
The CASE expression evaluates a list of conditions and returns a value when the first condition is met. 
The CASE expression is similar to the IF-THEN-ELSE statement in other programming languages. The  CASE expression 
is SQL's way of handling if/then logic. Every CASE expression must end with the END keyword.

ELSE part is optional. In case there is no ELSE part and no conditions are true, it returns NULL. 

There are two kinds of CASE expression: 
1.Simple CASE expression: The simple CASE expression compares an expression to a set of simple expressions to determine 
the result.
2. Searched CASE expression: The searched CASE expression evaluates a set of Boolean expressions to determine the result.

CASE can be used in any statement or clause. For example, we can use CASE in statements such as SELECT, UPDATE, 
DELETE and SET, and in clauses such as IN, WHERE, ORDER BY and HAVING.

Simple CASE Expression
The simple CASE expression compares an expression to a set of expressions to return the result. 
The simple CASE expression syntax:

CASE case_expression
  WHEN when_expression_1 THEN result_expression_1
  WHEN when_expression_1 THEN result_expression_1
  ...
  [ ELSE else_result_expression ]
END

The simple CASE expression compares the case_expression to the expressions in the WHEN clauses. Then it returns 
one of the multiple possible result expressions. If no case expression matches the when expression, the CASE expression 
returns the else_result_expression. If no ELSE part is included, the CASE expression returns NULL.

ELSE is optional. This is why it's displayed between the square brackets. The square bracket means "optional". That's 
to say we don't have to include the ELSE part in our CASE expressions. 

Example: We will classify the departments whether or not they are related to the Information Technologies (IT) field. 
If any department falls into this category, label it 'IT', otherwise 'others'.
*/

SELECT dept_name,
    CASE dept_name
        WHEN 'Computer Science' THEN 'IT'
        ELSE 'others'
    END AS category
FROM dbo.department;

-- We used the CASE expression in the SELECT statement and a new column named 'category' is created. We named it after 
-- the END keyword using the AS keyword. Column olusturmak icin kullanacaksak select icinde ve oncessinde virgul koyarak kullanılır


-- Generate a new column containinng what the mean of the values in the Order_Status column
-- 1 Pending, 2 Processing, 3 Rejected, 4 Completed

SELECT * FROM sale.orders

SELECT order_id, order_status, 
        CASE order_status
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Processing'
            WHEN 3 THEN 'Rejected'
            WHEN 4 THEN 'Completed'
        END AS orders_status_description
FROM sale.orders
   


-- searchun simpledan farki ise searchde artik kıyaslama yapabiliyoruzz comparison operatorlerle..
-- simpleda case yanınna expression yazılır, searchte ise casede yanında expression olmaz, altta whenler ile condition olur

/*
SEARCHED CASE Expression
The searched CASE expression evaluates a set of expressions to determine the result. In the simple CASE expression, 
it's only compared for equivalence whereas the searched CASE expression can include any type of comparison. 
In this type of CASE statement, we don't specify any expression right after the CASE keyword.

The searched CASE expression:
CASE
  WHEN condition_1 THEN result_1
  WHEN condition_2 THEN result_2
  WHEN condition_N THEN result_N
  [ ELSE result ]
END

Question: Classify the salaries of the employees into three categories: High, Middle, Low. The criteria:
- When salary < $55,000 THEN 'Low'
- When salary is between $55,000 and $80,000 THEN 'Middle'
- When salary > $80,000 THEN 'High'*/

-- I will solve this question first for the emploee_a and employee_b tables
WITH cte AS
(
   SELECT * FROM dbo.employees_A
   UNION
   SELECT * FROM dbo.employees_B 
) 
SELECT *,
CASE
WHEN cte.salary <= 55000 THEN 'low'
WHEN cte.salary > 55000 AND cte.salary < 80000 THEN 'Middle'
WHEN cte.salary > 80000 THEN 'High'
END as salary_group
FROM cte

-- the solution for the dbo.department table

SELECT name, salary,  -- we are using case expression within the select clause here
    CASE
        WHEN salary <= 55000 THEN 'Low'
        WHEN salary > 55000 AND salary < 80000 THEN 'Middle'
        WHEN salary >= 80000 THEN 'High'
    END AS category
FROM dbo.department;

-- An example of the CASE expression in WHERE statement: 
SELECT name, salary
FROM dbo.department
WHERE 
    CASE
        WHEN salary <= 55000 THEN 'Low'
        WHEN salary > 55000 AND salary < 80000 THEN 'Middle'
        WHEN salary >= 80000 THEN 'High'
    END = 'High';  -- sadece high olanları getir


-- Using CASE expression with aggregation functions most of the time saves you from long queries. Here is another 
-- example with CASE Expression: list the experienced employees whose graduation is Bachelor's Degree.

SELECT name,
       SUM (CASE WHEN seniority = 'Experienced' THEN 1 ELSE 0 END) AS Seniority,
       SUM (CASE WHEN graduation = 'BSc' THEN 1 ELSE 0 END) AS Graduation
FROM dbo.department
GROUP BY name
HAVING SUM (CASE WHEN seniority = 'Experienced' THEN 1 ELSE 0 END) > 0
	     AND
       SUM (CASE WHEN graduation = 'BSc' THEN 1 ELSE 0 END) > 0;

-- In this query, the columns that result from filtering using the SUM() function and CASE Expression normally may not be 
-- written in the SELECT statement. We wrote it here because we want you to see the result. 
-- We wanted to filter on the result of an aggregating operation. So, we did this in the HAVING statement.

-- Generate a new column containinng what the mean of the values in the Order_Status column
-- 1 Pending, 2 Processing, 3 Rejected, 4 Completed

SELECT * FROM sale.orders

SELECT order_id, order_status, 
        CASE 
            WHEN order_status=1 THEN 'Pending'
            WHEN order_status=2 THEN 'Processing'
            WHEN order_status=3 THEN 'Rejected'
            WHEN order_status=4 THEN 'Completed'
        END AS orders_status_description
FROM sale.orders

-- Create a new column that shows which email provider (Gmail, Hotmail, Yahoo, Other)

SELECT email, 
    CASE
    WHEN email LIKE '%@gmail.%' THEN 'Gmail'
    WHEN email LIKE '%@yahoo.%' THEN 'Yahoo'
    WHEN email LIKE '%@hotmail.%' THEN 'Hotmail'
    -- ELSE 'Other' else dersek eger varsa NULL degerleri de other yapar,i bunu istemeyiz
    WHEN email IS NOT NULL THEN 'Other'
    END AS email_provider
FROM sale.customer

--- QUESTION: Write a query that gives the first and last names of customers who have ordered products from 
-- the computer accessories, speakers, and mp4 player categories in the same order.


-- ilk once ilgili joinleri yapalım ve ihtiyacımız olan sutunları secelim
SELECT c.customer_id, c.first_name, c.last_name, o.order_id,p.product_name, cat.category_name
FROM sale.customer c 
JOIN sale.orders o ON c.customer_id = o.customer_id
JOIN sale.order_item oi ON o.order_id = oi.order_id
JOIN product.product p ON oi.product_id = p.product_id
JOIN product.category cat ON p.category_id = cat.category_id


-- CASE ile yeni bir sutun olusturup istedigimiz urunse 1 ise degilse 0 yazsa ve sonra 3ü aynı anda >0 diyerek filtreleyebiliriz

SELECT first_name, last_name
FROM (
SELECT c.customer_id, c.first_name, c.last_name, o.order_id,
    SUM(CASE  WHEN cat.category_name = 'speakers' THEN 1 ELSE 0 END) as speakers, 
    SUM(CASE  WHEN cat.category_name = 'computer accessories' THEN 1 ELSE 0 END) as comp, 
    SUM(CASE  WHEN cat.category_name = 'mp4 player' THEN 1 ELSE 0 END) as mp4
FROM sale.customer c 
JOIN sale.orders o ON c.customer_id = o.customer_id
JOIN sale.order_item oi ON o.order_id = oi.order_id
JOIN product.product p ON oi.product_id = p.product_id
JOIN product.category cat ON p.category_id = cat.category_id
GROUP BY c.customer_id, c.first_name, c.last_name, o.order_id
) as subq
WHERE speakers >0 AND comp >0 AND mp4>0;

-- bunu subq yerine cte ile yapalım


WITH cte AS
(
    SELECT c.customer_id, c.first_name, c.last_name, o.order_id,
    SUM(CASE  WHEN cat.category_name = 'speakers' THEN 1 ELSE 0 END) as speakers, 
    SUM(CASE  WHEN cat.category_name = 'computer accessories' THEN 1 ELSE 0 END) as comp, 
    SUM(CASE  WHEN cat.category_name = 'mp4 player' THEN 1 ELSE 0 END) as mp4
FROM sale.customer c 
JOIN sale.orders o ON c.customer_id = o.customer_id
JOIN sale.order_item oi ON o.order_id = oi.order_id
JOIN product.product p ON oi.product_id = p.product_id
JOIN product.category cat ON p.category_id = cat.category_id
GROUP BY c.customer_id, c.first_name, c.last_name, o.order_id
)
SELECT first_name, last_name
FROM cte
WHERE speakers >0 AND comp >0 AND mp4>0;

-- another solution 
WITH cte As
(SELECT oi.order_id 
FROM product.category c, product.product p, sale.order_item oi 
WHERE p.product_id = oi.product_id AND c.category_id = p.category_id 
AND c.category_name = 'computer accessories'
INTERSECT
SELECT oi.order_id
FROM product.category c, product.product p, sale.order_item oi 
WHERE p.product_id = oi.product_id AND c.category_id = p.category_id 
AND c.category_name = 'speakers' 
INTERSECT
SELECT oi.order_id
FROM product.category c, product.product p, sale.order_item oi 
WHERE p.product_id = oi.product_id AND c.category_id = p.category_id 
AND c.category_name = 'mp4 player')
SELECT C.first_name, c.last_name
FROM cte, sale.orders o, sale.customer c  
WHERE cte.order_id = o.order_id AND o.customer_id = c.customer_id


-- QUESTION
-- Write a query that returns the number of distributions of the orders in the previous
-- query result, according to the days of the week

SELECT * 
FROM (
    SELECT order_id, DATENAME(WEEKDAY, order_date) AS order_day
    FROM sale.orders
    WHERE DATEDIFF(DAY,order_date, shipped_date) > 2
) AS source_table
PIVOT 
(COUNT(order_id) FOR order_day IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], 
                                    [Saturday], [Sunday])) AS pivot_table



-- QUESTION
-- Classify staff according to the count of orders they receive as follows:
-- a) 'High-Performance Employee' if the number of orders is greater than 400
-- b) 'Normal-Performance Employee' if the number of orders is between 100 and 400
-- c) 'Low-Performance Employee' if the number of orders is between 1 and 100
-- d) 'No Order' if the number of orders is 0
-- Then, list the staff's first name, last name, employee class, and count of orders.  
-- (Count of orders and first names in ascending order)

SELECT s.first_name, s.last_name, 
        CASE 
            WHEN COUNT(o.order_id) > 400 THEN 'High-Performance Employee'
            WHEN COUNT(o.order_id)> 100 AND COUNT(o.order_id)< 400 THEN 'Normal-Performance Employee'
            WHEN COUNT(o.order_id)> 1 AND COUNT(o.order_id)<= 100 THEN 'Low-Performance Employee'
            WHEN COUNT(o.order_id)= 0 THEN 'No Order'
        END AS employee_class
    ,COUNT(o.order_id) as total_orders
FROM sale.staff s 
LEFT JOIN sale.orders o 
    ON s.staff_id = o.staff_id
GROUP BY s.first_name, s.last_name
ORDER BY total_orders, s.first_name

-- QUESTION
-- List counts of orders on the weekend and weekdays. Submit your answer in a single row with two columns. 
-- For example: 164 161. First value is for weekend.

SELECT 
SUM(CASE WHEN DATENAME(WEEKDAY, order_date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END) as weekend,
SUM(CASE WHEN DATENAME(WEEKDAY, order_date) NOT IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END) as weekday
FROM sale.orders


