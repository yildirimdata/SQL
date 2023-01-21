
---SQL 8 : ADVANCED GROUPING OPERATIONS: HAVING-GROUPING SETS-PIVOT-ROLLUP-CUBE

/*
HAVING clause is used to filter on the new column that will create as a result of the aggregate operation.

Its intended use is very similar to WHERE. Both are used for filtering results. However, HAVING and WHERE differ from 
each other in terms of usage and reasons for use.

WHERE is taken into account at an earlier stage of a query execution, filtering the rows read from the tables. 
Using WHERE, the fields to be grouped over the filtered rows are determined and a new field is created with the 
aggregate operation. And then HAVING is used if you want to filter the newly created field within the same query. 

The GROUP BY clause groups rows into summary rows or groups. The HAVING clause filters groups on a specified condition. 
You have to use the HAVING clause with the GROUP BY. Otherwise, you will get an error. The HAVING clause is applied after 
the GROUP BY. Also, if you want to sort the output, you should use the ORDER BY clause after the HAVING clause. 

The syntax is:

SELECT column_1, aggregate_function(column_2)
FROM table_name
GROUP BY column_1
HAVING search_condition;
*/

-- QUESTION: Find the departments where the average salary of the instructors is more than $50,000. 
-- We cannot use the WHERE clause here. Because the WHERE clause is for non-aggregate data. we have to include the HAVING clause.

SELECT dept_name, AVG(salary)
        FROM dbo.department
        GROUP BY dept_name
        HAVING AVG(salary) > 50000;

-- IMPORTANT: HAVING and WHERE clauses can be in the same query.
-- HAVING is for aggregate data and WHERE is for non-aggregate data. The WHERE clause operates on the data before 
-- the aggregation and the HAVING clause operates on the data after the aggregation.

-- check if any product id is duplicated in product table

SELECT product_id, COUNT(product_id) AS num_of_products
        FROM product.product
        GROUP BY product_id  
        HAVING COUNT(product_id) > 1;
       
-- check if any product name is duplicated in product table

SELECT product_name, COUNT(product_name) AS num_of_products
        FROM product.product
        GROUP BY product_name  
        HAVING COUNT(product_name) > 1;

-- having select'ten once calistigi icin alias kullanamayız

-- Write a query that returns category ids with condititons max list price above 2000 or min list price below 500

SELECT category_id, 
        MAX(list_price) as max_price, 
        MIN(list_price) as min_price
        FROM product.product
        GROUP BY category_id
        HAVING MAX(list_price) > 2000 
                OR MIN(list_price) < 500

-- find the average product prices of the brands. display brand name and avg prices in desc

SELECT b.brand_name, 
        AVG(list_price) as avg_price
        FROM product.product p 
        JOIN product.brand b 
        ON p.brand_id = b.brand_id
        GROUP BY p.brand_id, b.brand_name
        ORDER BY AVG(list_price) DESC

-- display the brand names whose avg product prices are more than 1000

SELECT b.brand_name, 
        AVG(list_price) as avg_price
        FROM product.product p 
        JOIN product.brand b 
        ON p.brand_id = b.brand_id
        GROUP BY p.brand_id, b.brand_name
        HAVING AVG(list_price) > 1000
        ORDER BY AVG(list_price) DESC;

-- write a query that returns the list of each order id and that order's total net price

SELECT order_id,    
        SUM(quantity*list_price*(1-discount)) as net_price
        FROM sale.order_item oi 
        GROUP BY order_id

-- a cte practice
WITH cte AS
(
    SELECT order_id,    
        SUM(quantity*list_price*(1-discount)) as net_price
        FROM sale.order_item oi 
        GROUP BY order_id
)
SELECT order_id, net_price
FROM cte
-- how to see net_price > 5000 orders
HAVING SUM(quantity*list_price*(1-discount)) > 5000

-- write a query that returns yearly and  monthly order counts of the states for each order where a state has monthly order
-- more than 5

SELECT c.state, 
        YEAR(o.order_date) as years, 
        MONTH(o.order_date) as month,
        COUNT(o.order_id) as total_orders
        FROM sale.customer c 
        JOIN sale.orders o 
        ON c.customer_id = o.customer_id
        GROUP BY c.state, 
                YEAR(o.order_date), 
                MONTH(o.order_date)
        HAVING COUNT(o.order_id) > 5

-- Please write a query to return only the order ids that have an average amount of more than $2000. 
-- Your result set should include order_id. Sort the order_id in ascending order.

SELECT order_id 
    FROM sale.order_item
    GROUP BY order_id
    HAVING AVG(list_price * quantity * (1-discount)) > 2000
    ORDER BY order_id ASC;



/*
GROUPING SETS & PIVOT & ROLLUP & CUBE

These methods are mostly used in periodical reporting. They ensure that different breakdowns of the data are obtained 
as a result of a single query. Different grouping options are returned in a single query, saving time and resources.

In addition, it enables decision-makers to evaluate the reported analysis from different directions at a single glance.

GROUPING SETS operator refers to groups of columns grouped in aggregation operations. Syntax of the GROUPING SETS clause:

SELECT
    column1,
    column2,
    aggregate_function (column3)
FROM
    table_name
GROUP BY
    GROUPING SETS (
        (column1, column2),
        (column1),
        (column2),
        ()
);

PIVOT operator allows the rows in the pivot table to be converted into fields in reporting operations. 
The aggregation process is repeated for each column included in the grouping and a separate field is created.

Here is the syntax of the PIVOT clause:

SELECT [column_name], [pivot_value1], [pivot_value2], ...[pivot_value_n]
FROM 
table_name
PIVOT 
(
 aggregate_function(aggregate_column)
 FOR pivot_column
 IN ([pivot_value1], [pivot_value2], ... [pivot_value_n])
) AS pivot_table_name;

ROLLUP operator creates a group for each combination of column expressions. It makes grouping combinations 
by subtracting one at a time from the column names written in parentheses, in the order from right to left. 
Therefore, the order in which the columns are written is important.

Here is the syntax of the ROLLUP clause:

SELECT
    d1,
    d2,
    d3,
    aggregate_function(c4)
FROM
    table_name
GROUP BY
    ROLLUP (d1, d2, d3);

Groups for ROLLUP:
d1, d2, d3
d1, d2, NULL
d1, NULL, NULL
NULL, NULL, NULL

CUBE operator makes all possible grouping combinations for all fields specified in the select operator. The order 
in which the columns are written is not important. Here is the syntax of the CUBE clause:
SELECT
    d1,
    d2,
    d3,
    aggregate_function (c4)
FROM
    table_name
GROUP BY
    CUBE (d1, d2, d3);

Groups for CUBE:
d1, d2, d3
d1, d2, NULL
d1, d3, NULL
d2, d3, NULL
d1, NULL, NULL
d2, NULL, NULL
d3, NULL, NULL
NULL, NULL, NULL
*/

-- ************************************************************************************************
-- ************************************************************************************************
-- GROUPING SETS Example

SELECT
    seniority,
    graduation,
    AVG(Salary) as avg_salary
FROM
    dbo.department
GROUP BY
    GROUPING SETS (
        (seniority, graduation),
        (graduation),
        ()  -- koymazsak ana toplam record eksik kalir sadece
        );

-- EXAMPLE
SELECT * FROM sale.order_item;

-- bu listedeki 

-- STEP 1. calculate the total sales price of the brands
SELECT 
    SUM(oi.quantity * oi.list_price * (1-discount)) as total_sales
    FROM 
    sale.order_item;

--STEOP 2. calculate the total sale prices of the brands

SELECT b.brand_name,
    SUM(oi.quantity * oi.list_price * (1-discount)) as total_sales_amount
    FROM sale.order_item oi 
    JOIN product.product p 
    ON oi.product_id = p.product_id
    JOIN product.brand b 
    ON p.brand_id = b.brand_id
    GROUP BY b.brand_name;
-- STEP 3: calculate the total sale amount of each category

SELECT c.category_name,
    SUM(oi.quantity * oi.list_price * (1-discount)) as total_sales_amount
    FROM sale.order_item oi 
    JOIN product.product p 
    ON oi.product_id = p.product_id
    JOIN product.category c  
    ON p.category_id = c.category_id
    GROUP BY c.category_name;


-- calculate the total ales amount by brands and categories with model years

SELECT
	b.brand_name, c.category_name, p.model_year,
	SUM(oi.quantity * oi.list_price * (1 - oi.discount)) total_sales_amount
FROM
	SALE.order_item oi
	INNER JOIN
	product.product p ON oi.product_id=p.product_id
	INNER JOIN
	product.brand b ON p.brand_id=b.brand_id
	INNER JOIN
	product.category c ON p.category_id=c.category_id
GROUP BY
	b.brand_name, c.category_name, p.model_year
ORDER BY
	b.brand_name, c.category_name;

-- her brandin model yıllarına gore her bir kategorisini de goruyoruz, ama her bir brandınn kayegorisiz kendi basina total amountu yok
-- bunu grouping sets ile yaparız (model years olmadan yaparız)

SELECT
	b.brand_name, c.category_name, 
	SUM(oi.quantity * oi.list_price * (1 - oi.discount)) total_sales_amount
FROM
	SALE.order_item oi
	INNER JOIN
	product.product p ON oi.product_id=p.product_id
	INNER JOIN
	product.brand b ON p.brand_id=b.brand_id
	INNER JOIN
	product.category c ON p.category_id=c.category_id
GROUP BY
GROUPING SETS (
(b.brand_name, c.category_name),
(b.brand_name),
(c.category_name),
() -- en son bos bir parantez bırakırız
)   
ORDER BY
	1, 2; -- b.brand_name, c.category_name, 

-- model years da ekleyelim

SELECT
	b.brand_name, c.category_name, p.model_year,
	CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS decimal(18,2)) total_sales_amount
    -- veri kaybını engellemek icin yuvarlamada cast as decimal kullanmak en optimali
    -- 18 toplam digit sayısı, yuksek tutmak icin 18, 2 de nokta sonrasi kac karakter istedigimiz
FROM
	SALE.order_item oi
	INNER JOIN
	product.product p ON oi.product_id=p.product_id
	INNER JOIN
	product.brand b ON p.brand_id=b.brand_id
	INNER JOIN
	product.category c ON p.category_id=c.category_id
    GROUP BY
    GROUPING SETS (
    (b.brand_name, c.category_name, p.model_year),  -- hangi kombinasyonları gormek istersek onlara gore cagiracagiz
    (b.brand_name),
    (p.model_year),
    (c.category_name),
    () -- en son bos bir parantez bırakırız -- koymazsak tek toplamı getirmez, bir eksik getirir yani
    )   
    ORDER BY
        1, 2,3;


--- tablo nulls ile degil de isimle gelsin istiyorsak


SELECT COALESCE(brand_name, 'All brands') brand_name, 
        COALESCE(category_name,'All categories') category_name, 
        COALESCE(CAST(model_year AS VARCHAR), 'All years') model_year, 
        CAST(SUM(quantity*B.list_price*(1-discount)) AS decimal(18,2)) net_sales_price
FROM sale.order_item A, product.product B, product.category C, product.brand D
WHERE A.product_id = B.product_id --- join
AND B.category_id= C.category_id -- join
AND B.brand_id = D.brand_id
GROUP BY 
    GROUPING SETS(
        (brand_name, category_name, model_year),
        (brand_name, category_name),
        (brand_name, model_year),
        (category_name, model_year),
        (brand_name),
        (category_name),
        (model_year),
        () -- hic bir gruplama olmasaydi
    )
ORDER BY 1,2,3;


-- ************************************************************************************************
-- ************************************************************************************************
-- PIVOT Example
/*
Pivot, satır bazlı analiz sonucunu sütun bazına dönüştürülmesini sağlıyor.
GROUP BY gibi bir gruplama yapıyor. Dolayısıyla GROUP BY kullanmıyoruz, pivota özel bir syntax kullanıyoruz.
Bu syntax içerisinde aggregate işlemi yapıp ilgili sütunlardaki kategorilere göre bir pivot table oluşturuyor.
ve o sütunun satırlarını oluşturan her bir kategoriyi birer sütuna dönüştürüyor.
Yani satırlardaki value'lar sütunlarda sergileniyor.

Pivot tablosunda sütun ve value olarak gözükmesini istediğim sütunları (feature'ları) Pivot'un üstündeki SELECT satırına ekliyorum.
Bunlardan VALUE olacak olan sütununa Pivot ile başlayan kod bloğunda AGGRAGATE işlemi uyguluyorum.
Unutmayalım ki PIVOT TABLE , GROUP BY işleminin aynısını yapıyor. Aggregate işlemi de oradan geliyor.
*/

SELECT [seniority], [BSc], [MSc], [PhD]
FROM 
(
SELECT seniority, graduation, salary
FROM   dbo.department
) AS SourceTable
PIVOT 
(
 avg(salary)
 FOR graduation
 IN ([BSc], [MSc], [PhD])
) AS pivot_table;

-- The result is converted to pivot table format, making it easier to read. The average salaries of the instructors are 
-- presented in two different dimensions, by placing the seniority field on a vertical plane and the categories of the 
-- graduation field on a horizontal plane.

-- Question: Write a query that returns the count of orders of each day between '2020-01-19' and '2020-01-25'. 
-- Report the result using Pivot Table. Note: The column names should be day names (Sun, Mon, etc.).

SELECT * 
    FROM(
    SELECT order_id, DATENAME(weekday, order_date) as day_name
    FROM sale.orders
    WHERE order_date BETWEEN '2020-01-19' and '2020-01-25'
        ) AS source_table
    PIVOT (COUNT(order_id) FOR day_name 
        IN ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])) pvt

-- pivot kullanıyorsak group by kullanılmaz. her ikisinin calisma mantigi tamamen ayrı cunku.
-- yazdigimiz sorgu u-subquery icine alinip oyle kullanılabilir

-- write a query that returns total turnover from each brand by model year (in pivot table format)

--QUESTION: Write a query using summary table that returns the number of products for each category by model year. (in pivot table format)
--(kategorilere ve model y�l�na g�re toplam �r�n say�s�n� summary tablosu �zerinden hesaplay�n)

SELECT b.brand_name, p.model_year,
		COUNT(p.product_id)
FROM product.product p
INNER JOIN product.brand b
	ON p.brand_id=b.brand_id
GROUP BY b.brand_name, p.model_year
ORDER BY 1,2


--1. Select the columns from related table(s) as the base data for pivoting:

select model_year, product_id
from product.product

--2. Create a temporary result set using a derived table:

select * from (
	select model_year, product_id
	from product.product
) t


--3. Apply the PIVOT operator:

select * from (
	select model_year, product_id
	from product.product
) t
PIVOT (
	COUNT(product_id)
	FOR model_year IN(
		[2018],
		[2019],
		[2020],
		[2021])
) AS pvt;


--4. Add a dimension to the pivot table. (brand_name)

select * from (
	select model_year, product_id, b.brand_name
	from product.product p
	inner join product.brand b
		on p.brand_id=b.brand_id
) t
PIVOT (
	COUNT(product_id)
	FOR model_year IN(
		[2018],
		[2019],
		[2020],
		[2021])
) AS pvt;



--generating column values
--QUOTENAME function -- bu fonksiyonla column ismi olarak kullanmak istediklerimizi alabiliriz.

SELECT QUOTENAME(category_name) + ','
FROM product.category

[Televisions & Accessories],
[Camera],
[Dryer],
[Computer Accessories],
[Speakers],
[mp4 player],
[Home Theater],
[Car Electronics],
[Digital Camera Accessories],
[Hi-Fi Systems],
[Earbud],
[Game],
[Audio & Video Accessories],
[Bluetooth],
[gps],
[Receivers Amplifiers]

--QUESTION: Write a query that returns count of the orders day by day in a pivot table format that has been shipped later than two days.

SELECT * 
    FROM(
    SELECT order_id, DATENAME(weekday, order_date) as day_name
    FROM sale.orders
    WHERE DATEDIFF(DAY, order_date, shipped_date) > 2 
        ) AS source_table
    PIVOT (COUNT(order_id) FOR day_name 
        IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])) pivot_table

-- ************************************************************************************************
-- ************************************************************************************************
-- ROLLUP Example

SELECT * FROM dbo.department

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    dbo.department
GROUP BY
    ROLLUP (seniority, graduation);

-- there are three different grouping models using ROLLUP in this example. One of them is applied according to both 
-- seniority and graduation. The second one is applied according to only seniority. The last one is applied with no group.

-- ************************************************************************************************
-- ************************************************************************************************
-- CUBE Example

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    dbo.department
GROUP BY
    CUBE (seniority, graduation);

-- As you see above, there was applied four different grouping models using CUBE. One of them was applied according to 
-- both seniority and graduation. The second one was applied according to only seniority. The third one was applied 
-- according to only graduation.The last one was applied with no group. 

