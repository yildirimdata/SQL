-- JOIN
/*
A JOIN clause is used to combine two or more tables into a single table. 
This process is carried out based on a related column between tables.

There are basically five types of JOINs: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN and CROSS JOIN. 
As a special case, a table can join to itself and this type is called SELF JOIN:

INNER JOIN: Returns the common records in both tables.
LEFT JOIN: Returns all records from the left table and matching records from the right table.
RIGHT JOIN: Returns all records from the right table and matching records from the left table.
FULL OUTER JOIN: Returns all records of both left and right tables.
(left, right and full outer join are together called as Outer Join in some sources)
CROSS JOIN: Returns the Cartesian product of records in joined tables.
SELF JOIN: A join of a table to itself.

INNER JOIN 

Inner Join is the most common type of JOINs. It creates a new result table based on the values in common 
columns from two or more tables. It returns a table that contains only joined rows that meet the join 
conditions. The intersection of the two tables represents the matching rows.

The INNER JOIN keyword selects all rows from both "employees" and "departments" tables as long as there is 
a match between the columns. If there are records in the "employees" table that do not have matches 
in "departments", these records are not shown in the output.

SELECT columns
  FROM table_A
  INNER JOIN table_B 
  ON table_A.column = table_B.column;

The operator in this statement is usually an equal sign (=), but any comparison operator can also be used.
Multiple join conditions can be written using AND or OR statements .  
In addition, three or more tables can be combined using the INNER JOIN clause. The syntax:

SELECT columns
  FROM table_A
  INNER JOIN table_B 
    ON join_conditions1 AND join_conditions2
  INNER JOIN table_C
    ON join_conditions3 OR join_conditions4
...
*/

-- make a list of products showing the product id, product name, category ID and category name

SELECT p.product_id, p.product_name, 
        c.category_id, c.category_name 
    FROM product.product p 
    INNER JOIN product.category c 
    ON p.category_id = c.category_id;
-- product.product 520 rows. product.category 16 rows. However there are 13 ctagory_names in the merged table
-- Join result is 520 rows. If we have a right join(below) it would be 523 rows. last three are null. That menas there are not
-- any products with the category id 2-3 and 12 in the product.product table

SELECT p.product_id, p.product_name, 
        c.category_id, c.category_name 
    FROM product.product p 
    RIGHT JOIN product.category c 
    ON p.category_id = c.category_id;

-- eger tüm fieldları almak istersek join edilen tabloların isimlerine * ekleriz. örn: SELECT table_1.*, table_2.*
SELECT p.product_id, p.product_name, 
        c.* -- c zaten 2 fields 
    FROM product.product p 
    INNER JOIN product.category c 
    ON p.category_id = c.category_id;

-- 2nd use of inner join

SELECT p.product_id, p.product_name, 
        c.category_id, c.category_name
    FROM product.product p, product.category c
    -- iki tabloyu da burada yazdık
    WHERE p.category_id = c.category_id;
    -- on yerine where ile filtreledik

-- list employees of stores with their store information. select first and last name and store name

SELECT sta.first_name, sta.last_name, 
        sto.store_name
    FROM sale.staff sta 
    JOIN sale.store sto 
    ON sta.store_id = sto.store_id;

SELECT sta.first_name, sta.last_name, 
        sto.store_name
    FROM sale.staff sta, sale.store sto 
    WHERE sta.store_id = sto.store_id;

-- How many employees are in each store?
SELECT sto.store_name, COUNT(sta.staff_id)  as total_employees
  FROM sale.staff sta 
    JOIN sale.store sto 
    ON sta.store_id = sto.store_id
    GROUP BY sto.store_name;

-- or
SELECT b.store_name, COUNT(b.store_name) as total_employees     
    FROM sale.staff a, sale.store b
    WHERE a.store_id = b.store_id
    GROUP BY b.store_name;

/*
LEFT JOIN

In this JOIN statement, all the records of the left table and the common records of the right table are 
returned in the query. If no matching rows are found in the right table during the JOIN operation, 
these values are assigned as NULL.  If no match is found for a particular row, NULL is returned.
LEFT JOIN and LEFT OUTER JOIN keywords are exactly the same. OUTER keyword is optional.
Syntax:

SELECT columns
  FROM table_A
  LEFT JOIN table_B ON join_conditions
*/
-- return the products that have never been ordered. select product id, product name and order ID

SELECT * FROM product.product;
-- 520 rows in total
SELECT * FROM sale.order_item;
-- 4722 rows in total

SELECT COUNT(DISTINCT product_id) FROM sale.order_item;
-- 307 products. 520-207: there are 213 products which have been not ordered.

-- inner join sadece eslesenleri gosterirç left ile eslesmeyenleri de gorürüz
SELECT *
FROM  product.product p 
LEFT JOIN sale.order_item o 
ON p.product_id = o.product_id;

SELECT p.product_id, p.product_name, o.order_id
FROM  product.product p 
LEFT JOIN sale.order_item o 
ON p.product_id = o.product_id
WHERE o.order_id IS NULL;  -- where is null ile getiririz.

-- report the total number of products sold by each employee
SELECT *
FROM sale.staff sta 
LEFT JOIN sale.orders o 
ON sta.staff_id = o.staff_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id;

SELECT sta.staff_id, SUM(oi.quantity)
FROM sale.staff sta 
LEFT JOIN sale.orders o 
ON sta.staff_id = o.staff_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id
GROUP BY sta.staff_id
ORDER BY sta.staff_id;

-- bar chart cizdirmek istersek nulları 0 yaparız once
SELECT sta.staff_id, ISNULL(SUM(oi.quantity), 0)
-- ya da coalesce(SUM(oi.quantity), 0)
FROM sale.staff sta 
LEFT JOIN sale.orders o 
ON sta.staff_id = o.staff_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id
GROUP BY sta.staff_id;

-- eger inner join kullansak satis yapmayanları goremezdik
SELECT sta.staff_id, ISNULL(SUM(oi.quantity), 0)
-- ya da coalesce(SUM(oi.quantity), 0)
FROM sale.staff sta 
JOIN sale.orders o 
ON sta.staff_id = o.staff_id
JOIN sale.order_item oi 
ON o.order_id = oi.order_id
GROUP BY sta.staff_id;

-- to see the order status of orders and the related store name and the city:
SELECT o.order_id, s.store_name, s.city, o.order_status
    FROM sale.orders o 
    LEFT JOIN sale.store s 
    ON o.store_id = s.store_id;


/*
In simple terms, RIGHT JOIN is the opposite of LEFT JOIN. In this join statement, all the records of the 
right table and the common records of the left table are returned in the query. If no matching rows are 
found in the left table during the JOIN operation, these values are assigned as NULL. Syntax:

SELECT columns
  FROM table_A
  RIGHT JOIN table_B ON join_conditions

RIGHTJOIN and RIGHT OUTER JOIN keywords are exactly the same. OUTER keyword is optional.
-- cok kullanılmaz. daha cok JOIN ve LEFT
*/

-- return products that have never been ordered. select product d, product name, order id
SELECT p.product_id, p.product_name, o.order_id
FROM  sale.order_item o
RIGHT JOIN product.product p  
ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- inner joinde hangi tabloyu once yazdigimiz sonucu degistimez, ama left ve right joinde order matters.


SELECT o.order_id, s.store_name, s.city, o.order_status
    FROM sale.orders o 
    RIGHT JOIN sale.store s 
    ON o.store_id = s.store_id;


/*
FULL OUTER JOIN

A FULL OUTER JOIN returns all rows from both tables. The output table will include rows with NULL data, 
so nothing is left out (Unmatched rows are filled with NULLs on either side). 
NULL values may be important to detect missing data in tables. A FULL OUTER JOIN is likely to generate 
large data sets based on the number of rows in the tables we want to join. Syntax:
SELECT columns
  FROM table_A
  FULL OUTER JOIN table_B ON join_conditions
*/

-- report the stock quantities of all products

SELECT * FROM product.stock ORDER BY store_id;
-- 1089 rows... 3 magaza var, 520 ürün vardi, yani 1560 olur hepsinde olsa , ama 1089 olduguna gore olmayanlar var
SELECT *
FROM product.product p 
FULL JOIN product.stock s 
ON p.product_id = s.product_id;

SELECT p.product_id, SUM(s.quantity)
FROM product.product p 
FULL JOIN product.stock s 
ON p.product_id = s.product_id
GROUP BY p.product_id;
-- 520 satır döndü
-- sadcee nulları gorelim
SELECT p.product_id, SUM(s.quantity) as total_quantity
FROM product.product p 
FULL JOIN product.stock s 
ON p.product_id = s.product_id
GROUP BY p.product_id;

/*
CROSS JOIN

In SQL, the CROSS JOIN is used to combine each row of the first table with each row of the second table. 
It is also known as the Cartesian join since it returns the Cartesian product of the sets of rows 
from the joined tables. Syntax: 
SELECT columns
  FROM table_A
  CROSS JOIN table_B

- iki tablo arası tum farklı kombinasyonları gormemizi saglar

There is also another implementation of CROSS JOIN in which we don't use CROSS JOIN clause. Syntax:

SELECT columns
  FROM table_A, table_B
*/

SELECT o.order_id, s.store_name, s.city, o.order_status
    FROM sale.orders o, sale.store s; 

SELECT o.order_id, s.store_name, s.city, o.order_status
    FROM sale.orders o
    CROSS JOIN sale.store s;

-- SORUYU HOCADAN AL

-- olmayanları görelim
SELECT * FROM product.stock ORDER BY quantity;

-- magaza bilgilerini unique alabilecegimiz bir table buluruz once. 520 unique product product tableda zaten.
SELECT  s.store_id, p.product_id
FROM product.product p 
CROSS JOIN sale.store s 
-- 1560 satır gelir 520x3
-- her product id'yi istemiyoruz, sub query ile filtreleme yaparız

SELECT  s.store_id, p.product_id
FROM product.product p 
CROSS JOIN sale.store s 
WHERE p.product_id NOT IN (SELECT product_id FROM product.stock);
-- 234 row döndü
-- o'ları ekleyelim

SELECT  s.store_id, p.product_id, 0 as quantity 
FROM product.product p 
CROSS JOIN sale.store s 
WHERE p.product_id NOT IN (SELECT product_id FROM product.stock);


/*
SELF JOIN

SELF JOIN is a join of a table to itself. Joining a table to itself means that each row of the table is 
combined with itself and the other rows of the table. A SELF JOIN can be defined as a combination of two 
copies of the same table. This is accomplished with the SQL command, the table is not actually copied a 
second time. We use INNER JOIN or LEFT JOIN for creating a self join.

We use self-join to create a result set that joins the rows with the other rows within the same table. 
Since we cannot refer to the same table more than one in a query, we need to use a table alias to assign the 
table a different name when we use self-join.

The self-join compares values of the same or different columns in the same table. Only one table is involved 
in the self-join. We often use self-join to query parents/child relationship stored in a table or to obtain 
running totals. Syntax:

SELECT columns
  FROM table A 
  JOIN table B   -- table = table. we dealwith it as two copies such as A and B
  WHERE join_conditions

- hangi columnlar uzerinden birlestirirsek ON iliskisini (condition) o ikisi üzerinden = ile kurarız.
-- hiyerarsik iliskileri gormek icin kullanılır daha cok.

There is no separate expression for SELF JOIN. The INNER JOIN statement is used to join the "employees" 
table with itself.
*/

-- wrtie a query that returns the staff names with their manager names

SELECT * FROM sale.staff;  -- staff_id, manager_id. amac manager_id yerine isim getirmek

SELECT a.staff_id, a.first_name + ' ' + a.last_name as employee, b.first_name +' ' + b.last_name as manager
FROM sale.staff a 
LEFT JOIN sale.staff b 
-- manageri olmayann employees var. bu nedenle inner join yerine left join kullanmalıyız. innerda manageri null olanlar gelmezdi
ON a.manager_id = b.staff_id;

/*
VIEWS

Views are useful tools for accessing multiple data types. Complex queries can be stored within views. 
In this way, we can invoke the view instead of recreating the queries every time we need them. 

Sometimes we want some of the information in a table to be hidden to certain users. View is a convenient way 
for this. This is also important from the security perspective as well. Using view, complex structures can be 
synthesized and presented in an easy format for the end-user.

If we are not sure whether a view already exists and want to run it in a stored procedure or function, 
the "CREATE VIEW IF NOT EXISTS view_name" syntax will prevent us from getting an error.

CREATE VIEW view_name AS
  SELECT columns
  FROM tables
  [WHERE conditions];

Views are read-only in SQL Server. So, we cannot use INSERT, DELETE, and  UPDATE statements to update data 
in the base tables through the view. WE can only use CREATE , DROP and  ALTER statements for views. 
To update a view, we should drop the view first, and then create it again. Syntax:

DROP VIEW view_name; 

Note that; when we execute the drop view command it removes the views. The underlying data stored in the base 
tables from which this view is derived remains unchanged. A view once dropped can be recreated with the same name.
*/

-- create a view of sale.store table which includes only the stores from Texas state.
CREATE VIEW store_Texas_view AS
    SELECT *
    FROM sale.store
    WHERE state = 'TX'; 

-- to see the table
SELECT *
FROM store_Texas_view;

-- to drop it:
DROP VIEW store_Texas_view;

-- when we want to retrieve it again, ERROR: Invalid object name 'store_Texas_view'.
SELECT *
FROM store_Texas_view;

-- müşterilerin siparis ettigi ürünleri gosteren bir view oluşturalım

SELECT c.customer_id, c.first_name+ ' ' + c.last_name as customer_name, 
        o.order_id, oi.product_id, oi.quantity
FROM sale.customer c 
LEFT JOIN sale.orders o 
ON c.customer_id = o.customer_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id;

-- bunu daha sonra da kullanacaksak, her seferinde yeniden yazmamak icin view olustururuz

CREATE OR ALTER VIEW VW_customer_product as
SELECT c.customer_id, c.first_name+ ' ' + c.last_name as customer_name, 
        o.order_id, oi.product_id, oi.quantity
FROM sale.customer c 
LEFT JOIN sale.orders o 
ON c.customer_id = o.customer_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id;

-- result: Started executing query at Line 391. Commands completed successfully.
Total execution time: 00:00:00.054
-- tables klasoru altinda views klasoru var, bu view orda gorunuyor su an

-- bunu tekrar cagirmak icin
SELECT * FROM VW_customer_product;

-- buna da filtre uygulayabliriz. örneğin salaryyi selectten silip view ousturma gibi. dikkatÇ bu bir table degil, bir query.
-- cagirdigimizda gelen bir query, table degil.

EXEC sp_helptext VW_customer_product

-- degistirmek icin
alter view vw_customer_product
AS
SELECT c.customer_id, c.first_name+ ' ' + c.last_name as customer_name, oi.quantity
FROM sale.customer c 
LEFT JOIN sale.orders o 
ON c.customer_id = o.customer_id
LEFT JOIN sale.order_item oi 
ON o.order_id = oi.order_id;

-- düsürmek icin

DROP VIEW VW_customer_product;
