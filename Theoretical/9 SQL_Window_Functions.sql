-- SQL 9 : WINDOW FUNCTIONS
/*
Window functions are also known as analytic functions. Its definiton in the official documents: 

A window function is an SQL function where the input values are taken from a "window" of one or more rows in 
the results set of a SELECT statement.
Window functions are distinguished from other SQL functions by the presence of an OVER clause. If a function 
has an OVER clause, then it is a window function. If it lacks an OVER clause, then it is an ordinary aggregate or
 scalar function. Window functions might also have a FILTER clause in between the function and the OVER clause.

A window function performs a calculation across a set of table rows that are somehow related to the current row. This 
is comparable to the type of calculation that can be done with an aggregate function. But unlike regular aggregate 
functions, use of a window function does not cause rows to become grouped into a single output row — the rows 
retain their separate identities. Behind the scenes, the window function is able to access more than just the current 
row of the query result.

To sum up, window functions operate on a set of rows and return a single value for each row from the underlying query. 
This explains "...the rows retain their separate identities." phrase in the definition above. The term "window" describes 
the set of rows on which the function operates. Here is the syntax of the window function:*/

window_function (expression) OVER (
[ PARTITION BY expr_list ]
[ ORDER BY order_list ] [ frame_clause ])

/*
When we use a window function, we simply define the window using the OVER() clause. The OVER() clause separates 
the window functions from other functions in SQL. 
The OVER() clause can take the following clauses to extend its functionality:
- PARTITION BY clause: Defines window partitions to form groups of rows
- ORDER BY clause: Orders rows within a partition
- ROW or RANGE clause: Defines the scope of the function

We can group window functions into three categories:
- Aggregate Window Functions (ANalytic aggregate functions)
- Ranking Window Functions (Analytic navigation functions)
- Value Window Functions (Analytic numbering functions)

*************************************************************************************************
*************************************************************************************************
AGGREGATE Window Functions

An aggregate window function is similar to a normal aggregate function. But the main difference between them 
is the aggregate window function doesn't change the number of rows returned. General syntax:*/
window function (column_name)
OVER ( [ PARTITION BY expr_list ] [ ORDER BY orders_list frame-clause ] )

/*
Window functions syntax breakdown

- window_function: This is an ordinary aggregate function which may be AVG(), COUNT(), MAX(), MIN(), SUM()
- column_name: The column that the function operates on
- OVER:  Specifies the window clauses for the aggregation functions. The OVER clause distinguishes window 
aggregation functions from ordinary aggregation functions.
- PARTITION BY expr_list : Optional. Defines the window for the window function.
- ORDER BY order_list : Optional. Sorts the rows within each partition.
- frame_clause: If ORDER BY clause is used, frame_clause is required. The frame clause refines the set of rows 
in a function's window, including or excluding sets of rows within the ordered result.*/

SELECT graduation, COUNT (id) OVER() as cnt_employee
FROM dbo.department;

--  the whole table records were returned for the graduation column. Besides, the count of employees in the whole table 
-- was written for per row. The new column created with a window function was added into the result without any changes 
-- in the main table. Also, there are many duplicate rows. 

-- 💡Tips:
-- If you use DISTINCT keyword like the query below, you would be get rid of duplicate rows.

SELECT DISTINCT graduation, COUNT (id) OVER() as cnt_employee
FROM dbo.department;

-- We didn't use any partitioning, ordering, or frame condition so far. The parentheses near the OVER keyword were empty 
-- and we got the results above.  If we use PARTITION BY with DISTINCT keyword like below:

SELECT DISTINCT graduation, COUNT (id) OVER(PARTITION BY graduation) as cnt_employee
FROM dbo.department; 

-- an example from the store table
SELECT DISTINCT store_id, COUNt(*) OVER(PARTITION BY store_id) as store_IDs 
FROM sale.orders 

-- how many distinct cities from the customers are
SELECT DISTINCT city 
FROM sale.customer

SELECT DISTINCT city, COUNT(city) OVER(PARTITION BY city) as total_customers
FROM sale.customer

-- PARTITION BY specifies partitions on which a window function operates. The window function is applied to 
-- each partition separately and computation restarts for each partition. If we don't include PARTITION BY, 
-- the window function operates on the whole column.

-- What if we use only ORDER BY in the parentheses? 

SELECT hire_date, COUNT (id) OVER(ORDER BY hire_date) cnt_employee
FROM dbo.department;

-- If we don't specify the ordering rule as ASC or DESC, ORDER BY accept ASC by default. So, in this example, hire_date 
-- column was ordered by ascending. 

-- when we don't include the ORDER BY we get total number; when we include ORDER BY then we get running total/cumulative 
-- total. We don't have to use ORDER BY with aggregate window functions. But that's important to know what 
-- happened when you use ORDER BY with aggregate functions.

-- total amount for each order over $500 :
WITH cte(order_id, total_amount) As
(SELECT DISTINCT order_id, SUM(list_price*quantity*(1-discount)) OVER(PARTITION BY order_id) as total_amount
FROM sale.order_item)
SELECT order_id, total_amount
FROM cte 
WHERE total_amount > 500;


-- Write a query that shows the total stock amount of each product in the stock table.(Use both of Group by and WF)

-- solution with Group BY
SELECT product_id, SUM(quantity)
FROM product.stock
GROUP BY product_id
ORDER BY product_id;

-- solution with window function
SELECT DISTINCT product_id, 
			SUM(quantity) OVER(PARTITION BY product_id) as total_stock_amount
FROM product.stock  

SELECT *,  -- bunu groupby'da yapamıyorduk -- bu tablodan gruplar icin yuzde hsabı da yapılır
			SUM(quantity) OVER(PARTITION BY product_id) as total_stock_amount
FROM product.stock 

-- Write a query that returns average product prices of brands.(Use both of Group by and WF)

-- GB solution
SELECT brand_id, AVG(list_price)
FROM product.product
GROUP BY brand_id;

-- WF Solution
SELECT DISTINCT brand_id, AVG(list_price) OVER(PARTITION BY brand_id) as avg_price
FROM product.product


SELECT *, AVG(list_price) OVER(PARTITION BY brand_id) as avg_price
FROM product.product

-- QUESTION
-- What is the cheapest product price for each category?

-- tüm tabloya ek sutun olarak ekleyelim
SELECT *, MIN(list_price) OVER(PARTITION BY category_id) as cheapest_product
FROM product.product
-- normal sadece brand ile gosterelim
SELECT DISTINCT category_id, MIN(list_price) OVER(PARTITION BY category_id) as cheapest_product
FROM product.product

-- QUESTION
-- How many different product in the product table?

SELECT COUNT(product_id) OVER() as total_products  -- tüm toplam sayıyı istedigimizden partitiona gerek yok
FROM product.product  -- bu 520 tane 520 verir, distinct ile birini istedigimiz belirtiriz

SELECT DISTINCT product_id, COUNT(product_id) OVER() as total_products  -- tüm toplam sayıyı istedigimizden partitiona gerek yok
FROM product.product

-- QUESTION
-- How many different product in the order_item table?
SELECT DISTINCT product_id, -- DISTINCt yazmazsak 4722 satir 77 dondurur
		COUNT(product_id) OVER(PARTITION BY product_id) as total_products  
FROM sale.order_item
-- ama bu sonuc yanlıs. bu sadece o product_idnin kac defa gectigini gosteriyor. bu cevap WF ile bulunamaz
-- bu her ürünün kacar tane oldugunu gosterir.
-----following queries don't return the correct result.

select count(product_id) over()
from sale.order_item


select count(product_id) over(partition by product_id) num_of_products
from sale.order_item


select distinct count(product_id) over(partition by product_id) num_of_products
from sale.order_item


select distinct product_id, 
	count(product_id) over(partition by product_id) num_of_products
from sale.order_item

-----true result

select count(distinct product_id)
from sale.order_item

-----or
select distinct count(product_id) over() num_of_products
from(
	select distinct product_id
	from sale.order_item
) t

-- WF ile soyle yapardik : subquery

  -- fromun icinde subqueriye isim verilir unutma

-- QUESTION
-- Write a query that returns how many products are in each order?
SELECT DISTINCT order_id, 
		SUM(quantity) OVER(PARTITION BY order_id) as total_quantity
FROM sale.order_item
-- ayni islem group by ile
SELECT order_id, sum(quantity)
		FROM sale.order_item
		GROUP BY order_id
		ORDER BY order_id 

-- birden fazla wf kullanabilirz. mesela sumun yanına quantitynin bir de sayısını ve ort fiyat ekleyelim
SELECT DISTINCT order_id, 
		SUM(quantity) OVER(PARTITION BY order_id) as total_quantity,
		COUNT(quantity) OVER(PARTITION BY order_id) as number_of_products,
		CAST(AVG(list_price) OVER(PARTITION BY order_id) as decimal (18,2)) as avg_order_price
FROM sale.order_item

-- 2 GRUBA GORE PARTITION -- istedigimiz sayıda gruplama yapabiliriz
-- QUESTION
-- Write a query that returns the number of products in each category of brands.

SELECT DISTINCT category_id, brand_id, 
		COUNT(product_id) OVER (PARTITION BY category_id, brand_id) as total_products
FROM product.product

--- -- Write a query using the window function that returns the cumulative total turnovers of the 
-- Burkes Outlet by order date between "2019-04-01" and "2019-04-30".
-- Columns that should be listed are: 'order_date' in ascending order and 'Cumulative_Total_Price'.

WITH cte AS (
SELECT o.order_date, SUM(oi.list_price*oi.quantity* (1-oi.discount)) as total_turnover
FROM sale.order_item oi, sale.orders o, sale.store s
WHERE s.store_id = o.store_id AND o.order_id=oi.order_id
			AND s.store_name = 'Burkes Outlet'
			AND o.order_date BETWEEN '2019-04-01' AND '2019-04-30'
GROUP BY o.order_date)
SELECT cte.order_date, SUM(cte.total_turnover) OVER (order by cte.order_date ) as cumulative_sum
FROM cte

-- Write a query using the window function that returns staffs' first name, last name, and their total net 
-- amount of orders in descending order.

SELECT DISTINCT s.first_name, 
				s.last_name, 
				SUM(oi.list_price*oi.quantity*(1-oi.discount)) 
				OVER(PARTITION BY s.first_name, s.last_name) as total_sales
		FROM sale.staff s, sale.order_item oi, sale.orders o 
		WHERE s.staff_id = o.staff_id 
			AND o.order_id = oi.order_id
		ORDER BY total_sales DESC;

-- solution with group by

SELECT s.first_name, s.last_name, SUM(oi.list_price*oi.quantity*(1-oi.discount)) as total_sales
		FROM sale.staff s, sale.order_item oi, sale.orders o 
		WHERE s.staff_id = o.staff_id 
			AND o.order_id = oi.order_id
		GROUP BY s.first_name, s.last_name
		ORDER BY total_sales DESC;

-- List the employee's first order dates by month in 2020. Expected columns are: first name, last name, month 
-- and the first order date. (last name and month in ascending order)

-- WF solution 
SELECT DISTINCT s.first_name, s.last_name, 
		MONTH(o.order_date) as months, 
		MIN(order_date) OVER(PARTITION BY s.first_name, s.last_name, MONTH(o.order_date)) as first_order_date
	FROM sale.staff s, sale.orders o 
	WHERE s.staff_id = o.staff_id AND YEAR(o.order_date) = 2020
	ORDER BY last_name, months;

-- GroupBy solution
SELECT s.first_name, s.last_name, 
		MONTH(o.order_date) as months, 
		MIN(order_date) as first_order_date
	FROM sale.staff s, sale.orders o 
	WHERE s.staff_id = o.staff_id AND YEAR(o.order_date) = 2020
	GROUP BY s.first_name, s.last_name, MONTH(o.order_date)
	ORDER BY last_name, months;



-- *************************************************************************************************
-- *************************************************************************************************


/*
WINDOW FRAMES

By default, a window is set for each row to encompass all the rows from the first to the current row in the partition.
However, this is the default and can be adjusted using the window frame clause. 
A window function query using the window frame clause would look as follows:

SELECT {columns},
{window_func} OVER (PARTITION BY {partition_key} ORDER BY {order_key} {rangeorrows} 
BETWEEN {frame_start} AND {frame_end})
FROM {table1};

Here,
- {columns} are the columns to retrieve from tables for the query,  
- {window_func} is the window function you want to use,  
- {partition_key} is the column or columns you want to partition on,  
- {order_key} is the column or columns you want to order by,  
- {rangeorrows} is either the RANGE keyword or the  ROWS keyword,  
- {frame_start} is a keyword indicating where to start the window frame,  
- {frame_end} is a keyword indicating where to end the window frame


Commonly Used Framing Syntax

			Frame																		Meaning
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW :	Start at row 1 of the partition and include rows up to the current row.
ROWS UNBOUNDED PRECEDING 						 :	Start at row 1 of the partition and include rows up to the current row.
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING :	Start at the current row and include rows up to the end of the partition.
ROWS BETWEEN N PRECEDING AND CURRENT ROW		 :	Start at a specified number of rows before the current row and 
													include rows up to the current row.
ROWS BETWEEN CURRENT ROW AND N FOLLOWING		 :  Start at the current row and include rows up to a specified number 
													of rows following the current row.
ROWS BETWEEN N PRECEDING AND N FOLLOWING		 :  Start at a specified number of rows before the current row and 
													include a specified number of rows following the current row. 
													The current row is also included!
*/

-- order by kullanmazsak window frame kullanılamaz. order by ile birlikte optionaldir.

-- QUESTION
-- her markanın kac tane ürünü var
SELECT brand_id, model_year,
		COUNT(product_id) OVER() as total_products,
		COUNT(product_id) OVER(PARTITION BY brand_id) as total_products_per_brand,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year) total_products_per_brand_per_year
		--- 1 branddan 2018de 13 varmis, 2019da 8 varmis, bunu 13 ve 8 degil, 13-21 diye kümülatif yapar. 42. sıraya bak
		FROM product.product

-- simdi burda window frame kullanalım

SELECT brand_id, model_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year) total_products_per_brand_per_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year RANGE BETWEEN UNBOUNDED 
		PRECEDING AND current ROW) total_products_per_brand_per_year -- RANGE BETWEEN UNBOUNDED 
		-- PRECEDING AND current ROW default degerdir. bu endenle yukarıyla aynı geldi.
		FROM product.product
-- aralık belirtirken ya range ya row kullanılır
SELECT brand_id, model_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year) total_products_per_brand_per_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year RANGE BETWEEN UNBOUNDED 
		PRECEDING AND current ROW) total_products_per_brand_per_year, -- default
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year ROWS BETWEEN UNBOUNDED 
		PRECEDING AND current ROW) total_products_per_brand_per_year
		FROM product.product


--- 1 preceding ile yapalım
SELECT brand_id, model_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year) total_products_per_brand_per_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year 
							RANGE BETWEEN UNBOUNDED PRECEDING AND current ROW) total_products_per_brand_per_year, -- default
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year 
								ROWS BETWEEN UNBOUNDED PRECEDING AND current ROW) total_products_per_brand_per_year,
		COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year 
								ROWS  BETWEEN 1 PRECEDING AND CURRENT ROW) total_products_per_brand_per_year
		FROM product.product




select brand_id, model_year,
	count(product_id) over(partition by brand_id order by model_year),
	count(product_id) over(partition by brand_id order by model_year range between unbounded preceding and current row) [range], --default
	count(product_id) over(partition by brand_id order by model_year rows between unbounded preceding and current row) [row],
	count(product_id) over(partition by brand_id order by model_year rows between 1 preceding and current row) [row_1_preceding],
	count(product_id) over(partition by brand_id order by model_year rows between unbounded preceding and unbounded following) [row_un],
	count(product_id) over(partition by brand_id order by model_year range between unbounded preceding and unbounded following) [range_un]
from product.product


select brand_id, model_year,
	count(product_id) over(partition by brand_id order by model_year rows between current row and unbounded following) [row_un],
	count(product_id) over(partition by brand_id order by model_year range between current row and unbounded following) [range_un]
from product.product

-- Örn: 7 günlük ortalama, 7 günlük hareketli ortalama gibi analizlerde kullanılabilir.
-- Üç günün max cirosu, 7 günün min sipariş sayısı vb vb

-- *************************************************************************************************
-- *************************************************************************************************

/* Ranking Window Functions

Ranking window functions return a ranking value for each row in a partition. Some of the Ranking Window Functions are:

- CUME_DIST	 :   Compute the cumulative distribution of a value in an ordered set of values.
- DENSE_RANK :	Compute the rank for a row in an ordered set of rows with no gaps in rank values.
- NTILE	     :   Divide a result set into a number of buckets as evenly as possible and assign a bucket number to each row.
- PERCENT_RANK :	Calculate the percent rank of each row in an ordered set of rows.
- RANK	     : Assign a rank to each row within the partition of the result set.
- ROW_NUMBER :	Assign a sequential integer starting from one to each row within the current partition.*/

-- Let's rank the employees based on their hire date.

SELECT name,
	   RANK() OVER(ORDER BY hire_date DESC) AS rank_duration
FROM dbo.department;

-- RANK() function assigns the same rank number if the hire_date value is same.  
-- Note: RANK() function assigns the row numbers of the values in the list created by the ordering rule. For 
-- the same values assigns their smallest row number.

-- rank employees according to their graduation and in line with their salary from highest to lowest.
SELECT name, salary, graduation,
	   RANK() OVER(PARTITION BY graduation ORDER BY salary DESC) AS rank_duration
FROM dbo.department;

-- rank aynı kategorinin tamamına aynı noyu verir. örneğin aynı puanı alan ogrenciler aynı sırada olur, aynı fiyatli 
-- ürünler aynı sırada yer alır vb vb
SELECT order_id, RANK() OVER(order by order_id) as rank_no
FROM sale.order_item

-- dense rankin farki ise kacta birakirsa ordn baslar. 2sini karsilastir

SELECT order_id, 
		RANK() OVER(order by order_id) as rank_no,
		DENSE_RANK() OVER(order by order_id) as dense_rank_no
FROM sale.order_item

--  let's apply the same scenario by using the DENSE_RANK function. 

SELECT name,
	   DENSE_RANK() OVER(ORDER BY hire_date DESC) AS rank_duration
FROM dbo.department;

-- Note: DENSE_RANK() returns the sequence numbers of the values in the list created by the ordering rule. For 
-- the same values assigns their smallest sequential integer.

-- rank employees according to their graduation and in line with their salary from highest to lowest.
SELECT name, salary, graduation,
	   DENSE_RANK() OVER(PARTITION BY graduation ORDER BY salary DESC) AS dense_rank_duration,
	   RANK() OVER(PARTITION BY graduation ORDER BY salary DESC) AS rank_duration
FROM dbo.department;

SELECT name, hire_date, seniority,
	   DENSE_RANK() OVER(PARTITION BY seniority ORDER BY hire_date DESC) AS rank_duration,
	   RANK() OVER(PARTITION BY seniority ORDER BY hire_date DESC) AS rank_duration
FROM dbo.department;



/*
ROW_NUMBER(): 

ROW_NUMBER() assigns a sequential integer to each row.  The row number starts with 1 for the first row. 

If used with PARTITION BY, ROW_NUMBER() assigns a sequential integer to each row within the partition. 
The row number starts with 1 for the first row in each partition.*/

-- Let's give a sequence number to the employees in each seniority category according to their hire dates. 

SELECT name, seniority, hire_date,
	   ROW_NUMBER() OVER(PARTITION BY seniority ORDER BY hire_date DESC) AS row_number,
	   RANK() OVER(PARTITION BY seniority ORDER BY hire_date DESC) AS rank_number,
	   DENSE_RANK() OVER(PARTITION BY seniority ORDER BY hire_date DESC) AS dense_rank_number
FROM dbo.department;

-- ama sunun ciktisi farkli, partition olmadigi icin tum listeyi tek sira yapar
SELECT name, seniority, hire_date,
	   ROW_NUMBER() OVER (ORDER BY hire_date DESC) AS row_number
FROM dbo.department;

-- partition by sifirlamanın nerede yapilacagi, eger yoksa row_no devam eder.
-- örneğin order by'da list_price yazarsak en düşükten siralar ve ilk 10, 20 vs istedigimizi aliriz

-- Note: We must use ORDER BY with ranking window functions.

-- window functions sadece select veya order by icinde kullanılır. ornegin where vs icinde kullanılmaz

-- QUESTION
-- Assign an ordinal number to the product prices for each category in ascending order

SELECT category_id, list_price,  
		ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price DESC) as row_number
  -- order by kullanmazsak error
FROM product.product;

-- en bastan en sona kesintisiz numaralandırma

SELECT category_id, list_price,  ROW_NUMBER() OVER(ORDER BY list_price DESC) as row_number
  -- order by kullanmazsak error
FROM product.product;

-- QUESTION
-- Lets try previous query again using RANK() and DENSE_RANK() functions and discuss differences among all of them..

SELECT category_id, list_price,  
		ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price DESC) as row_number,
		RANK() OVER(PARTITION BY category_id ORDER BY list_price DESC) as rank_number,
		-- 4. kategoride 3 ürüne row_number 1-2-3 verdi rank ise 1-1-1 verdi. oraya ve sonrasina gecise dikkkat 
		DENSE_RANK() OVER(PARTITION BY category_id ORDER BY list_price DESC) as dense_rank_number
		-- 5. kategoride rank 3 adet 1denn sonra 4ten devam etmisti, dense_rank ise 1-1-1 sonrası kategori 5e 2 ile basladi
FROM product.product;

-- nerelerde kullanırız. her kategorinin fiyatı en yüksek (most expensive - highest) 3er ürününü bulmak icin, 
-- ya da her markada en düsük fiyatli (cheapest)3 ürün,
-- en erken tarihli (earliest - latest) 3 siparis vb vb... neyi siralarsak orada kullanırız

-- *************************************************************************************************
-- *************************************************************************************************
/*
VALUE WINDOW Functions
(Analytic navigation functions)

value window functions allow us to include values from other rows. Value Window Functions access a previous row 
without having to do a self-join. Some also call these functions as 'offset functions'. The following table illustrates 
value window functions and their descriptions. 

Function	Description:

- FIRST_VALUE   : Get the value of the first row in a specified window frame.
- LAG	        : Provide access to a row at a given physical offset that comes before the current row.
- LAST_VALUE	: Get the value of the last row in a specified window frame.
- LEAD          : Provide access to a row at a given physical offset that follows the current row.

 LAG() and LEAD() functions are useful to compare rows to preceding or following rows. LAG returns 
 data from previous rows and LEAD returns data from the following rows. SYntax:

 LAG(column_name [,offset] [,default])
 LEAD(column_name [,offset] [,default])

OFFSET: Optional. It specifies the number of rows back from the current row from which to obtain a value. 
        If not given, the default is 1. In that case, it returns the value of the previous value. 
        If there is no previous row (the current row is the first), then returns NULL. 
        Offset value must be a non-negative integer.

DEFAULT: The value to return when the offset is beyond the scope of the partition. If a default value is not 
        specified, NULL is returned.*/

		-- ORDER BY kullanımı zorunlu

SELECT id, name,
		LAG(name) OVER(ORDER BY id) AS previous_name
FROM dbo.department;

SELECT id, name,
		LEAD(name) OVER(ORDER BY id) AS next_name
FROM dbo.department;

-- If you want to access two rows back from the current row, you need to specify the offset argument 2. The following 
-- query displays the values two rows back from the current row.

SELECT id, name,
		LAG(name, 2) OVER(ORDER BY id) AS previous_name
FROM dbo.department;


-- QUESTION:
-- Write a query that returns the order date of the one previous sale of each staff (use the LAG function)

SELECT a.order_id,
				   b.staff_id, 
				   b.first_name,
				   b.last_name,
				   a.order_date,
			
			LAG(a.order_date) OVER (PARTITION BY b.staff_id ORDER BY a.order_id) as 'Previous Order Date'
			-- lag default 1 order date yanında, degistirebilirz, 2 dersek 2 oncekini alir
				FROM sale.orders a ,sale.staff b
				WHERE a.staff_id=b.staff_id



-- QUESTION
-- Write a query that returns the order date of the next sale (consecutive) of each staff (use the LEAD function)

SELECT a.order_id,
				   b.staff_id, 
				   b.first_name,
				   b.last_name,
				   a.order_date,
			LEAD(a.order_date) OVER (PARTITION BY b.staff_id ORDER BY a.order_id) as 'Previous Order Date'
			-- lead default 1. bir hafta sonrayi gormek istersek 7
				FROM sale.orders a ,sale.staff b
				WHERE a.staff_id=b.staff_id


select a.order_id, b.staff_id, b.first_name, b.last_name, a.order_date,
	lead(a.order_date, 3) over(partition by b.staff_id order by a.order_id) -- lead 3 ornegin
from sale.orders a, sale.staff b
where a.staff_id=b.staff_id

--- IMPORTANT QUESTION
-- Write a query that returns the difference of order count between the current month and the previous month for each year.

-- bu soruyu yaparkan ilk olarak tabloyu bulur ve yıl ve aya gore ayırırız.
SELECT order_id, YEAR(order_date) years, MONTH(order_date) months
FROM sale.orders

-- her yılın her ayının siparislerini saydıralım ve gruplayalım
SELECT DISTINCT YEAR(order_date) years, MONTH(order_date) months,	
		COUNT(order_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) total_orders
FROM sale.orders

-- en sondaki totalorders sutunu yanına lag ile bir onceki ayı getirelim
WITH cte AS 
(SELECT DISTINCT YEAR(order_date) years, MONTH(order_date) months,	
		COUNT(order_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) total_orders
FROM sale.orders)
SELECT years, months, total_orders,
		LAG(total_orders) OVER(PARTITION BY years ORDER BY years, months) previous_month
FROM cte

-- simdi aradaki farki bir column yapalim
WITH cte AS 
(SELECT DISTINCT YEAR(order_date) years, MONTH(order_date) months,	
		COUNT(order_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) total_orders
FROM sale.orders)
SELECT years, months, total_orders,
		LAG(total_orders) OVER(PARTITION BY years ORDER BY years, months) previous_month,
		total_orders - LAG(total_orders) OVER(PARTITION BY years ORDER BY years, months) as difference
FROM cte


-- examples with FIRST_VALUE() AND LAST_VALUE()

SELECT id, name,
		FIRST_VALUE(name) OVER(ORDER BY id) AS first_name
FROM dbo.department;

-- order by sıralar first_value functionn da ilk sıradakini getirir yeni bir column yapar. last_value da en sondakini alir

-- for each row, FIRST_VALUE() function returns the first value from the whole name column sorted by id. 
--  Because the default window frame covered all of the rows for each row.

SELECT id, name,
		LAST_VALUE(name) OVER(ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_name
FROM dbo.department;

-- for each row, LAST_VALUE() function returns the last value from the whole name column sorted by id.
-- We can change the window frame. Because the default window frame didn't cover all of the rows for each row.

-- firstvalue ile ilgili bir ornek

SELECT * FROM sale.staff;
-- diyelimki first namee gore sıralayıp first value olarak da first namei sececegiz

SELECT *, FIRST_VALUE(first_name) OVER(ORDER BY first_name)
FROM sale.staff;

SELECT *, FIRST_VALUE(first_name) OVER(ORDER BY last_name)
FROM sale.staff;


-- QUESTION
-- Write a query that returns first order date by month.

SELECT order_date, YEAR(order_date) years, MONTH(order_date) months,
	FIRST_VALUE(order_date) OVER(PARTITION BY YEAR(order_date),MONTH(order_date))  -- bu hata verir, order by yok
FROM sale.orders 

SELECT DISTINCT YEAR(order_date) years, MONTH(order_date) months,
	FIRST_VALUE( order_date) OVER(PARTITION BY YEAR(order_date),MONTH(order_date) ORDER BY order_date) 
FROM sale.orders 

SELECT DISTINCT YEAR(order_date) years, MONTH(order_date) months,
	FIRST_VALUE( order_date) OVER(PARTITION BY YEAR(order_date),MONTH(order_date) ORDER BY order_date) 
FROM sale.orders 
ORDER BY years DESC


-- QUESTION
-- Write a query that returns customers and their most valuable order with total amount of it.

with cte as
(
		select a.customer_id, b.order_id,
			SUM(quantity * list_price * (1-discount)) net_price
		from sale.orders a
			inner join sale.order_item b
			on a.order_id=b.order_id
		group by a.customer_id, b.order_id
		--order by a.customer_id, b.order_id
)
select distinct customer_id,
	first_value(order_id) over(partition by customer_id order by net_price desc), -- her customer grubu list pricea gore desc
							-- sıralandıktan sonra en üstte kalan order_id / alttaki de bunun price'ı.
	first_value(net_price) over(partition by customer_id order by net_price desc)
from cte


-- QUESTION
-- Write a query that returns first order date by month. (Use Last_Value)

select distinct YEAR(order_date) years, MONTH(order_date) months,
	last_value(order_date) over(partition by YEAR(order_date), MONTH(order_date) 
			order by order_date rows between unbounded preceding and unbounded following) last_date,
			-- bunu first_value ile de desc order sonrası getirebiliriz.
	first_value(order_date) over(partition by YEAR(order_date), MONTH(order_date) 
			order by order_date DESC) last_date
from sale.orders



-- QUESTION
-- Write a query that returns both of the followings:
		-- The average product price (tüm ürünler icin tek bir ortalama P)
		-- The average product price by orders.

SELECT DISTINCT order_id, 
		CAST(AVG(list_price) OVER()  AS decimal(18,2))as avg_price,  -- tüm ürünler icin istiyor, partition bya gerek yok
		CAST(AVG(list_price) OVER(PARTITION BY order_id) AS decimal(18,2)) as avg_order_price 
FROM sale.order_item;

-- QUESTION 
-- Which orders' average product price is lower than the overall average price?

-- agg functionlar where icinde kullanılamaz..
WITH cte AS
(
SELECT DISTINCT order_id, 
		CAST(AVG(list_price) OVER()  AS decimal(18,2))as avg_price,  
		CAST(AVG(list_price) OVER(PARTITION BY order_id) AS decimal(18,2)) as avg_order_price 
FROM sale.order_item	
)
SELECT *
FROM cte 
WHERE avg_order_price < avg_price
ORDER BY avg_order_price DESC; 

-- ya da SQuery ile
SELECT *
FROM (
	SELECT DISTINCT order_id, 
		CAST(AVG(list_price) OVER()  AS decimal(18,2))as avg_price, 
		CAST(AVG(list_price) OVER(PARTITION BY order_id) AS decimal(18,2)) as avg_order_price 
FROM sale.order_item
) t 
WHERE avg_order_price < avg_price
ORDER BY avg_order_price DESC; 


-- QUESTION
-- Calculate the stores' weekly cumulative count of orders for 2018


SELECT DISTINCT o.store_id, s.store_name, 
	DATEPART(WEEK, o.order_date) as week_of_year,
	COUNT(o.order_id) OVER(PARTITION BY o.store_id, DATEPART(WEEK, o.order_date)) as total_orders,
	COUNT(o.order_id) OVER(PARTITION BY o.store_id ORDER BY DATEPART(WEEK, o.order_date)) AS cum_total_orders  -- default
					-- range between unbounded precedinng and current row oldugu icin yazmaya gerek kalmadi
FROM sale.orders o
LEFT JOIN sale.store s   -- normal join de olur, 3 store da var cunku burda da, ama bu tablo ana calisma tablomuz olsun
						-- diye leftle devam edelim
ON o.store_id = s.store_id
WHERE YEAR(order_date) = 2018
ORDER BY o.store_id, s.store_name


-- QUESTION 
-- Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.

-- ilk önce tabloyu hazırlayalım
SELECT a.order_id, a.order_date, b.quantity,
	SUM(b.quantity) OVER(PARTITION BY a.order_date) as sum_quantity
FROM sale.orders a 
LEFT JOIN sale.order_item b 
ON a.order_id = b.order_id
WHERE a.order_date 
		BETWEEN '2018-03-12' AND '2018-04-12'

-- yukarıyı gorduk, distinct atmadan once ihtiyacımız olmayanları cikarizi

SELECT DISTINCT a.order_date, 
	SUM(b.quantity) OVER(PARTITION BY a.order_date) as sum_quantity
FROM sale.orders a 
LEFT JOIN sale.order_item b 
ON a.order_id = b.order_id
WHERE a.order_date 
		BETWEEN '2018-03-12' AND '2018-04-12'

-- moving avg icin window frame uygulamamız gerekir: current row ve 6 preceding
-- sum üzerinden avg alamayacagimiz icin cte veya squery

WITH cte AS(
SELECT DISTINCT a.order_date, 
	SUM(b.quantity) OVER(PARTITION BY a.order_date) as sum_quantity
FROM sale.orders a 
LEFT JOIN sale.order_item b 
ON a.order_id = b.order_id
WHERE a.order_date 
		BETWEEN '2018-03-12' AND '2018-04-12'
)
SELECT *, 
	AVG(sum_quantity) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) sales_moving_average_7
	-- rakamları kullanacagimiz zaman range degil row kullanılır
FROM cte 

--- SQuery olmadan da yapabilirdik: WF groupby ile kullanılabilir

SELECT DISTINCT a.order_date, 
	SUM(b.quantity) as sum_quantity,
	AVG(SUM(b.quantity)) OVER(ORDER BY a.order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) sales_moving_average_7
FROM sale.orders a 
LEFT JOIN sale.order_item b 
ON a.order_id = b.order_id
WHERE a.order_date 
		BETWEEN '2018-03-12' AND '2018-04-12'
GROUP BY a.order_date


-- QUESTION
-- Write a query that returns the highest daily turnover amount for each week on a yearly basis.

-- ilk tablomuzu hazırlayalım
SELECT a.order_id, a.order_date, b.quantity, b.list_price, b.discount,
		SUM(b.quantity*b.list_price*(1-b.discount)) 
				OVER(PARTITION BY a.order_date) as daily_turnover
		FROM sale.orders a 
		LEFT JOIN sale.order_item b 
		ON a.order_id = b.order_id
-- hafta bazında ayıralım
SELECT a.order_id, a.order_date, 
		DATEPART(WEEK, a.order_date) week_of_year,
		SUM(b.quantity*b.list_price*(1-b.discount)) 
				OVER(PARTITION BY a.order_date) as daily_turnover
		FROM sale.orders a 
		LEFT JOIN sale.order_item b 
		ON a.order_id = b.order_id

-- yıl bazında her haftanın farklı gunlerınde farklı cirolar var, en yukseklerini alalım
SELECT DISTINCT DATEPART(YEAR,a.order_date) order_year, 
		DATEPART(WEEK, a.order_date) order_week,
		SUM(b.quantity*b.list_price*(1-b.discount)) 
				OVER(PARTITION BY a.order_date) as daily_turnover
		FROM sale.orders a 
		LEFT JOIN sale.order_item b 
		ON a.order_id = b.order_id

-- cok farklı cozum yolları var en yüksek ciro icin: 1. maxi deneyelim
WITH cte AS 
(
SELECT DISTINCT DATEPART(YEAR,a.order_date) order_year, 
		DATEPART(WEEK, a.order_date) order_week,
		SUM(b.quantity*b.list_price*(1-b.discount)) 
				OVER(PARTITION BY a.order_date) as daily_turnover
		FROM sale.orders a 
		LEFT JOIN sale.order_item b 
		ON a.order_id = b.order_id
)
SELECT DISTINCT order_year, order_week, 
			MAX(daily_turnover) OVER(PARTITION BY order_year, order_week) highest_turnover
FROM cte;

-- 2. first_value ile cozumu
WITH cte AS 
(
SELECT DISTINCT DATEPART(YEAR,a.order_date) order_year, 
		DATEPART(WEEK, a.order_date) order_week,
		SUM(b.quantity*b.list_price*(1-b.discount)) 
				OVER(PARTITION BY a.order_date) as daily_turnover
		FROM sale.orders a 
		LEFT JOIN sale.order_item b 
		ON a.order_id = b.order_id
)
SELECT DISTINCT order_year, order_week, 
			FIRST_VALUE(daily_turnover) OVER(PARTITION BY order_year, order_week 
										ORDER BY daily_turnover DESC) AS highest_turnover
FROM cte;

-- Bu sorunun group by cozumu

SELECT 
	DISTINCT
	YEAR(a.order_date) order_year,
	DATEPART(WEEK, a.order_date) order_week,
	FIRST_VALUE(SUM(b.quantity * b.list_price * (1-b.discount))) OVER(
			PARTITION BY YEAR(a.order_date), DATEPART(WEEK, a.order_date)
			ORDER BY SUM(b.quantity * b.list_price * (1-b.discount)) DESC) highest_turnover
FROM
	sale.orders a
	LEFT JOIN
	sale.order_item b ON a.order_id=b.order_id
GROUP BY
	a.order_date;


-- QUESTION
-- List customers who have at least 2 consecutive orders which are not shipped.

-- kolaylastirmasi adina case ile teslim edilen edilmeyenleri yeni fieldde gosterelim
SELECT order_id, customer_id, order_date, shipped_date,
		CASE 
		WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END AS delivery_status
FROM sale.orders 
ORDER BY customer_id, order_date;

-- müşteri bazında delivery_statusun yanına bir oncekini lag ile yazdıralim.
-- 2 not delivered yanyana geldiyse cevabi bulmus oluruz
-- daha duzenli gorunsun diye cte alalım
WITH t1 AS(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status
	FROM sale.orders
), t2 AS(
	SELECT
		*,
		LEAD(delivery_status) OVER(PARTITION BY customer_id ORDER BY order_id) next_delivery_status
	FROM t1
)
SELECT	customer_id
FROM t2
WHERE delivery_status='not delivered' AND next_delivery_status='not delivered';

-- 2nd solution: cte kullanmadan lead icinde expressionlar nasil kullanılır

SELECT customer_id
FROM(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status,
		LEAD(CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END) OVER(
			PARTITION BY customer_id ORDER BY order_date) next_delivery_status
	FROM sale.orders
) t
WHERE 
	delivery_status='not delivered' AND next_delivery_status='not delivered';

-- CUME_DIST example
-- write a query that returns the cumulative distribution of the list price in product table by brand

SELECT brand_id, list_price,
ROUND(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS cume_dist
FROM product.product;

-- PERCENT_RANK

SELECT brand_id, list_price,
ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS percent_dist
FROM product.product;

/*
If there are 100 scores and the PERCENT_RANK is 90, that means that the score is higher than 90 scores. 
If the CUME_DIST is 90, that means that the score is the 90th one in the list
*/

-- NTILE
-- kac grup istersek tum satirlari o kadar bolup gruplar

-- Divide customer into 5 groups based on the quantity of product they order



-- *************************************************************************************************
-- *************************************************************************************************


---- PRACTICE

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
                                    -- by changing it to the unbounded following, we assure that if there are any cheaper
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
