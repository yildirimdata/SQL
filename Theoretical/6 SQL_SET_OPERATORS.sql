-- SQL 6 : SET Operators

/*
Set operations allow the results of multiple queries to be combined into a single result set. Set operators 
include UNION, INTERSECT, and EXCEPT:

1. UNION set operator returns the combined results of the two SELECT statements. Essentially, It removes 
duplicates from the results i.e. only one row will be listed for each duplicated result. 

2. To counter this behavior, we can use the UNION ALL set operator which retains the duplicates in the final result.

3. INTERSECT lists only records that are common to both the SELECT queries; 
4. EXCEPT set operator removes the second query's results from the output if they are also found in the first query's results. 
INTERSECT and EXCEPT set operations produce unduplicated results.

- Join'nden farkı satirlari altalta eklemeleri . join ise columnları yanyana ekliyor

Important:

- Both SELECT statements must contain the same number of columns.
- In the SELECT statements, the corresponding columns must have the same data type.
- Positional ordering must be used to sort the result set. The individual result set ordering is not allowed with Set operators. 
ORDER BY can appear once at the end of the query.
- UNION and INTERSECT operators are commutative, i.e. the order of queries is not important; it doesn't change the final result.
- Performance-wise :  UNION ALL shows better performance as compared to UNION because resources are not wasted in filtering 
duplicates and sorting the result set.
- Set operators can be the part of subqueries.

-- Let's create a "departments" table to work on:
*/

CREATE TABLE employees_A
(
emp_id BIGINT,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary BIGINT,
job_title VARCHAR (30),
gender VARCHAR(10),
);

INSERT employees_A VALUES
 (17679,  'Robert'    , 'Gilmore'       ,   110000 ,  'Operations Director', 'Male')
,(26650,  'Elvis'    , 'Ritter'        ,   86000 ,  'Sales Manager', 'Male')
,(30840,  'David'   , 'Barrow'        ,   85000 ,  'Data Scientist', 'Male')
,(49714,  'Hugo'    , 'Forester'    ,   55000 ,  'IT Support Specialist', 'Male')
,(51821,  'Linda'    , 'Foster'     ,   95000 ,  'Data Scientist', 'Female')
,(67323,  'Lisa'    , 'Wiener'      ,   75000 ,  'Business Analyst', 'Female')

-- a second table
CREATE TABLE employees_B
(
emp_id BIGINT,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary BIGINT,
job_title VARCHAR (30),
gender VARCHAR(10),
);
-- insert the values
INSERT employees_B VALUES
 (49714,  'Hugo'    , 'Forester'       ,   55000 ,  'IT Support Specialist', 'Male')
,(67323,  'Lisa'    , 'Wiener'        ,   75000 ,  'Business Analyst', 'Female')
,(70950,  'Rodney'   , 'Weaver'        ,   87000 ,  'Project Manager', 'Male')
,(71329,  'Gayle'    , 'Meyer'    ,   77000 ,  'HR Manager', 'Female')
,(76589,  'Jason'    , 'Christian'     ,   99000 ,  'Project Manager', 'Male')
,(97927,  'Billie'    , 'Lanning'      ,   67000 ,  'Web Developer', 'Female')

SELECT * FROM dbo.employees_A;
SELECT * FROM dbo.employees_B;

-- I'll create same table with different column names to check some further details (I'll change the name of emp_id and 
-- order of gender column and the name of job_title)

-- CREATE TABLE employees_C
(
id BIGINT,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary BIGINT,
gender VARCHAR(10),
title_job VARCHAR (30),

);
-- insert the values
-- INSERT employees_C VALUES
 (49714,  'Hugo'    , 'Forester'       ,   55000 ,  'Male', 'IT Support Specialist')
,(67323,  'Lisa'    , 'Wiener'        ,   75000 ,  'Female', 'Business Analyst')
,(70950,  'Rodney'   , 'Weaver'        ,   87000 ,  'Male', 'Project Manager')
,(71329,  'Gayle'    , 'Meyer'    ,   77000 ,   'Female', 'HR Manager')
,(76589,  'Jason'    , 'Christian'     ,   99000 ,  'Male', 'Project Manager')
,(97927,  'Billie'    , 'Lanning'      ,   67000 ,  'Female', 'Web Developer')

-- SELECT * FROM employees_C;
/*
UNION OPERATOR
In some cases, we may need to combine data from two or more tables into a result set. Union clause is used to perform this 
operation. The tables that we need to combine can be tables with similar data in the same database, or in DIFFERENT databases.

It returns the combined results of the two SELECT statements. Essentially, It removes 
duplicates from the results i.e. only one row will be listed for each duplicated result.

We will use the UNION operator to combine rows from two or more queries into a single result set. 
The basic syntax for the UNION operator is:
SELECT column1, column2, ...
  FROM table_A
UNION
SELECT column1, column2, ...
  FROM table_B
*/

-- write a query to combine the emp_id, first and last name and job title of the employees from the employees A and B tables.

SELECT emp_id, first_name, last_name, job_title
    FROM employees_A  -- normally it has 6 rows
UNION
SELECT emp_id, first_name, last_name, job_title
    FROM employees_B; -- it has 6 rows too. but the result set is 10. 2 duplicated records are excluded.

-- What if we try to combine A and C tables through UNION
SELECT emp_id, first_name, last_name, gender, job_title
    FROM employees_A  -- normally it has 6 rows
UNION
SELECT id, first_name, last_name, title_job, gender 
    FROM employees_C; 
-- farklı 2 tablo gibi gorup 12 getirdi.
-- Sutun isimlerini soldaki ilk tablodan aldı. dolayısıyla c'nin id'si yok ama a'nın emp_id'si, a'nın job_title'ı var
-- Gender sutunlarının pozisyonunu degistirdim. A'ya gore yapti ve B tablosunda o hizada bulunan job_title iceriklerini
-- gender icine aldı. Job titleda da b'nin genderları aldı. sutun sırasi duzgun olarak tekrar yapalım

SELECT emp_id, first_name, last_name, gender, job_title
    FROM employees_A  -- normally it has 6 rows
UNION
SELECT id, first_name, last_name, gender, title_job 
    FROM employees_C; -- simdi 10 getirdi. dolayısıyla column order matters ama column name onemli degil.. Bir de aynı sayıda 
                        -- column olması onemli

-- once bir view recap'i
-- diyelim asagidakini sık kullanacaksak view ile kalıcı hale getirmek mantikli
create view sales_info_2 as
        select c.customer_id, c.first_name, c.last_name, c.city, o.order_id, oi.list_price,
            p.product_name
        from sale.customer c
        inner join sale.orders o on c.customer_id=o.customer_id
        inner join sale.order_item oi on o.order_id=oi.order_id
        inner join product.product p on oi.product_id=p.product_id

--------
-- eger saklayacaksak full ile hepsini saklamak daha mantikli
alter view sales_info_2 as
    select c.customer_id, c.first_name, c.last_name, c.city, o.order_id, oi.list_price,
        p.product_name
    from sale.customer c
    full join sale.orders o on c.customer_id=o.customer_id
    full join sale.order_item oi on o.order_id=oi.order_id
    full join product.product p on oi.product_id=p.product_id

select * from sales_info_2

-- List the products sold in the cities of Charlotte and Aurora

SELECT p.product_name
FROM sale.customer c
JOIN sale.orders o ON c.customer_id=o.customer_id
JOIN sale.order_item oi ON o.order_id=oi.order_id
JOIN product.product p ON oi.product_id=p.product_id
WHERE c.city = 'Charlotte'
UNION ALL  -- 306 satıırın tamamını getirir
SELECT p.product_name -- aurora icin
FROM sale.customer c
JOIN sale.orders o ON c.customer_id=o.customer_id
JOIN sale.order_item oi ON o.order_id=oi.order_id
JOIN product.product p ON oi.product_id=p.product_id
WHERE c.city = 'Aurora'

-- UNION ise;
SELECT p.product_name
FROM sale.customer c
JOIN sale.orders o ON c.customer_id=o.customer_id
JOIN sale.order_item oi ON o.order_id=oi.order_id
JOIN product.product p ON oi.product_id=p.product_id
WHERE c.city = 'Charlotte'
UNION  -- 132 satır getirdi... distinct urunleri getirdi bu. toplam kac urun satildi veya toplam satis miktari vs icin
        -- union all daha mantikli
SELECT p.product_name -- aurora icin
FROM sale.customer c
JOIN sale.orders o ON c.customer_id=o.customer_id
JOIN sale.order_item oi ON o.order_id=oi.order_id
JOIN product.product p ON oi.product_id=p.product_id
WHERE c.city = 'Aurora'

--- joini diger turlu yaparak ve where'de In ile cozelim
SELECT DISTINCT p.product_name
	FROM sale.customer c, sale.orders o, sale.order_item oi, product.product p
	WHERE c.customer_id=o.customer_id
		AND o.order_id=oi.order_id
		AND oi.product_id=p.product_id
		AND c.city IN ('Aurora', 'Charlotte') 

-- Write a query that returns all customers whose first or last name is Thomas

SELECT first_name 
    FROM sale.customer
    WHERE first_name = 'Thomas'
UNION ALL
SELECT last_name 
    FROM sale.customer
    WHERE last_name = 'Thomas'
/*
UNION ALL Operator

The UNION ALL clause is used to print all the records including duplicate records when combining the two tables.

The basic syntax for the UNION ALL operator is:
SELECT column1, column2, ...
  FROM table_A
UNION ALL
SELECT column1, column2, ...
  FROM table_B
*/


-- let's combine Employees A and B tables with union all. We'll also use a new field called "Type" to indicate 
-- which table the employees belong to.

SELECT 'employees_A' AS Type, emp_id, first_name, last_name, job_title 
    FROM employees_A
UNION ALL
SELECT 'employees_B' AS Type, emp_id, first_name, last_name, job_title
    FROM employees_B;  
-- all 12 records are included. However, the employee records of emp_id 49714 and emp_id 67323 are duplicate records.

-- 2 farklı dbaseden de union yapabiliriz

SELECT city FROM sale.customer
UNION
SELECT city FROM [BikeStores].sales.customers  -- sadece ikinci de dbase ismini de yazarız

/*
INTERSECT OPERATOR

INTERSECT operator compares the result sets of two queries and returns distinct rows that are output by both queries.
The basic syntax for the INTERSECT  operator is:
SELECT column1, column2, ...
  FROM table_A
INTERSECT
SELECT column1, column2, ...
  FROM table_B
*/
-- Let's find Using the employees who are common in both tables by using the INTERSECT operator

SELECT emp_id, first_name, last_name, job_title
    FROM employees_A  
INTERSECT
SELECT emp_id, first_name, last_name, job_title
    FROM employees_B
    ORDER BY emp_id;  -- only the duplicated records: 2 rows
 
-- write a query that returns all brands with products for both 2018 and 2020 model year

SELECT brand_id FROM product.product
WHERE model_year = 2018  -- 120 records
INTERSECT  -- toplam 28 markanın
SELECT brand_id FROM product.product
WHERE model_year = 2020 -- 177 records

-- bunların isimlerini getirelim: farkli tabloya gidecegiz subq ile

SELECT brand_name FROM product.brand
WHERE brand_id IN (SELECT brand_id FROM product.product
WHERE model_year = 2018  -- 120 records
INTERSECT  -- toplam 28 markanın
SELECT brand_id FROM product.product
WHERE model_year = 2020) -- 177 records

-- solution with cte
WITH t1 AS
(
    SELECT brand_id FROM product.product
    WHERE model_year = 2018  -- 120 records
    INTERSECT  -- toplam 28 markanın
    SELECT brand_id FROM product.product
    WHERE model_year = 2020
)
SELECT b.brand_name FROM product.brand b 
JOIN t1 on b.brand_id = t1.brand_id;


-- Write a query that returns the first and the last names of customers who placed
-- order in all of 2018,2019 and 2020

SELECT first_name, last_name
    FROM sale.customer
    WHERE customer_id IN (
            SELECT customer_id FROM sale.orders o 
            WHERE DATEPART(YEAR, order_date) =  2018 -- ya da YEAR(order_date)
        INTERSECT
        SELECT customer_id FROM sale.orders
        WHERE DATEPART(YEAR, order_date) =  2019
        INTERSECT
        SELECT customer_id FROM sale.orders
        WHERE DATEPART(YEAR, order_date) =  2020)


-- 



/*
EXCEPT Operator

EXCEPT operator compares the result sets of the two queries and returns the rows of the PREVIOUS query 
that differ from the next query. The basic syntax for the EXCEPT operator is:

SELECT column1, column2, ...
  FROM table_A
EXCEPT
SELECT column1, column2, ...
  FROM table_B
*/

-- Using EXCEPT operator, find employees who are just in Employees A table.

SELECT emp_id, first_name, last_name, job_title
    FROM employees_A  
EXCEPT
SELECT emp_id, first_name, last_name, job_title
    FROM employees_B; -- 4 unique and 2 duplicated

-- Write a query that returns brand name and brand id of the brands which have 2018 model products but not 2019 model products

SELECT brand_id, brand_name
    FROM product.brand
    WHERE brand_id IN (
            SELECT brand_id
            FROM product.product
            WHERE model_year = 2018 
            EXCEPT
            SELECT brand_id
            FROM product.product
            WHERE model_year = 2019 ) 

-- write a wuery that contains id and names of products ordered only in 2019 (Result not include products ordered in other years)
SELECT product_id, product_name 
    FROM product.product
    WHERE product_id IN ( 
        SELECT oi.product_id
        FROM sale.orders o 
        JOIN sale.order_item oi 
                ON o.order_id = oi.order_id
        WHERE YEAR(order_date) = 2019
        EXCEPT
        SELECT oi.product_id
        FROM sale.orders o 
        JOIN sale.order_item oi ON o.order_id = oi.order_id
        WHERE YEAR(order_date) != 2019)

SELECT product_id, product_name 
    FROM product.product
    WHERE product_id IN ( 
        SELECT oi.product_id
        FROM sale.orders o 
        JOIN sale.order_item oi 
                ON o.order_id = oi.order_id
        WHERE YEAR(order_date) = 2019)


-- QUESTION:
-- List in ascending order the stores where both "Samsung Galaxy Tab S3 Keyboard Cover" and 
-- "Apple - Pre-Owned iPad 3 - 64GB - Black" are stocked.

SELECT store.store_name  
    FROM product.stock stock
JOIN sale.store store 
    ON stock.store_id = store.store_id
WHERE stock.product_id IN (
                    SELECT product_id FROM product.product 
                    WHERE product_name IN (
                        'Samsung Galaxy Tab S3 Keyboard Cover', 'Apple - Pre-Owned iPad 3 - 64GB - Black'
                        )
                    UNION
                    SELECT product_id FROM product.stock
                    WHERE product_id IN (
                    SELECT product_id FROM product.product 
                    WHERE product_name IN ('Samsung Galaxy Tab S3 Keyboard Cover', 'Apple - Pre-Owned iPad 3 - 64GB - Black')
                    )
                        )
GROUP BY store.store_name
HAVING COUNT(store.store_name)>1
ORDER BY store.store_name;

-- another solution without union
SELECT e.store_name 
FROM sale.store e 
INNER JOIN product.stock k ON k.store_id = e.store_id
INNER JOIN product.product p ON p.product_id = k.product_id
WHERE p.product_name IN ('Apple - Pre-Owned iPad 3 - 64GB - Black', 'Samsung Galaxy Tab S3 Keyboard Cover')
GROUP BY e.store_name
HAVING COUNT(DISTINCT p.product_name) = 2
ORDER BY e.store_name;

-- QUESTION
-- Detect the store that does not have a product named "Samsung Galaxy Tab S3 Keyboard Cover" in its stock.

-- solution 1: except:
SELECT e.store_name 
    FROM sale.store e 
EXCEPT
SELECT e.store_name 
    FROM sale.store e 
    JOIN product.stock k 
            ON k.store_id = e.store_id
    JOIN product.product p 
            ON p.product_id = k.product_id
    WHERE p.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'

-- solution 2: not in
SELECT e.store_name 
FROM sale.store e 
WHERE e.store_id NOT IN (
    SELECT k.store_id
    FROM product.stock k 
    JOIN product.product p ON p.product_id = k.product_id
    WHERE p.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
);

-- solution 3 : left join
SELECT e.store_name
    FROM sale.store e
    LEFT JOIN product.stock k 
            ON k.store_id = e.store_id
    LEFT JOIN product.product p 
            ON p.product_id = k.product_id
            AND p.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
GROUP BY e.store_name
HAVING COUNT(p.product_name) = 0;
