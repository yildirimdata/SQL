-- SQL 5 - SUBQUERY_CTEs

/*
A subquery is a SELECT statement that is nested within another statement. The subquery is also called 
the inner query or nested query. A subquery may be used in:
- SELECT clause
- FROM clause
- WHERE clause

There are some rules when using subquery:

- A subquery must be enclosed in parentheses.
- An ORDER BY clause is not allowed to use in a subquery.
- The BETWEEN operator can't be used with a subquery. But you can use BETWEEN within the subquery.
*/
-- Subquery in select clause
SELECT dept_name, 
       (SELECT MAX(salary) FROM dbo.department) as max_salary
FROM dbo.department;

-- bir agg function olmasına ragmen group by kullanmadan calistirabildik. 
-- en önemli kuralı tek bir deger döndürmesi gerekir. single subquery

-- Subquery in FROM clause:

SELECT *
FROM 
    (SELECT name, seniority, salary 
    FROM dbo.department
    WHERE seniority = 'Senior' AND salary > 80000) as sub_table;

    -- eger subquery from ile kullanılıyorsa her zaman as ile alias almalı (as sub_table bu ornekte)


-- write a query to see the stock numbers of the products more expensive than 1000

SELECT expensivee.product_id, COALESCE(s.quantity, 0)
FROM (SELECT product_id, list_price 
        FROM product.product
        WHERE list_price > 1000) as expensivee
    LEFT JOIN product.stock s 
    ON expensivee.product_id =  s.product_id
ORDER BY quantity;

-- Subquery in the WHERE clause example:
-- A subquery (inner query-nested query - main q is outer q) is usually embedded inside the WHERE clause. It's generally used with comparison 
-- operators such as >, <, =, IN, NOT IN within WHERE clause. 
-- The inner query is executed first before the outer query. The results of the inner query are passed to the outer query.

-- find the employees who get paid more than Jane in the departments table. The query should return name and salary.

SELECT name, salary 
    FROM dbo.department
    WHERE salary >
        -- a subquery to find the salary of Jane
        (SELECT salary FROM dbo.department
        WHERE name = 'Jane');

-- IMPORTANT: VIEW ve SUBQUERYler icinde ORDER BY kullanılamaz... BUna sadece top ile birlikte kullaırsak izin verir

SELECT order_id, order_date
FROM sale.orders
WHERE order_date IN (
    SELECT TOP 5 order_date
    FROM sale.orders
    ORDER BY order_date DESC
);

/*
There are three main types of subqueries:

1. Single-row subqueries
2. Multiple-row subqueries
3. Correlated subqueries

- Single-Row Subqueries

Single-row subqueries return one row with only one column and are used with single-row operators such as =, >, >=, <=, <>, !=. 
Scalar subquery which returns a single row with one column is an example of single-row subqueries (Jane's salary above). 
*/

-- Find the employees who get paid more than the average salary. Display the name and salary info of employees.

SELECT name, salary
    FROM dbo.department
    WHERE salary >
        -- sq for avg_salary
        (SELECT AVG(salary)
        FROM dbo.department)
    ORDER BY salary DESC;


    -- Write a query that shows all the employess in the store that Davis Thomas works:
    SELECT first_name + ' ' + last_name
        FROM sale.staff
        WHERE store_id = (SELECT store_id 
            FROM sale.staff
            WHERE first_name = 'Davis' AND last_name= 'Thomas')

-- Write a query that shows the employees for whom Charles Cussona is a first-degree manager?

SELECT *
FROM sale.staff
WHERE manager_id = (
    SELECT staff_id 
    FROM sale.staff
    WHERE first_name = 'Charles'
        AND last_name= 'Cussona'
)

-- list of products which are more expensive than the product named 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'
SELECT *
    FROM product.product
    WHERE list_price >
        (SELECT list_price
        FROM product.product
        WHERE product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)')

-- Multiple-Row Subqueries
-- Multiple-row subqueries return sets of rows and are used with multiple-row operators such as IN, NOT IN, ANY, ALL. 


-- ANY , ALL
-- list_price > ALL(6,8,9) tamamından büyük olanları getir
-- list_price>ANY(6,8,9) örneğinde 7 yi de getirir


-- Find the employees who work in the departments that have average salaries higher than 60000.

SELECT name, dept_name, salary 
    FROM dbo.department
    WHERE dept_name IN ( 
        SELECT dept_name
        FROM dbo.department
        GROUP BY dept_name
        HAVING AVG(salary) > 60000)



-- write a query which first name, last name and order date of customers who ordered on the same dates as Laurel Goldammer

SELECT c.first_name, c.last_name, o.order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON o.customer_id = c.customer_id
    WHERE o.order_date IN (
        SELECT o.order_date
        FROM sale.orders o 
        JOIN sale.customer c
        ON o.customer_id = c.customer_id
        WHERE c.first_name = 'Laurel' AND c.last_name = 'Goldammer')

-- join'i farkli sekilde yaparak yapalim:
SELECT a.first_name, a.last_name, b.order_date
FROM sale.customer a, sale.orders b
WHERE a.customer_id=b.customer_id
AND b.order_date IN(
		SELECT order_date
		FROM sale.customer c, sale.orders o
		WHERE c.customer_id=o.customer_id
			AND first_name='Laurel'
			AND last_name='Goldammer')

-- List the products that ordered in the last 10 orders in Buffalo

SELECT TOP 10 c.city, o.order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.city = 'Buffalo'
    ORDER BY o.order_date DESC;
    -- buraya kadar buffaloda order edilen son 10 ürünün tarihlerini bulduk. bir sonrak adım da product.producta baglanacagizz,
    -- ama onun icin ilk order.itema baglanacagiz. ama o tarihlerde baska sehirde de order vardir, dolayısıyla en iyisi unique
    -- degerleri sabitlemek icin order idlerini almak bunların

SELECT TOP 10 o.order_id
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.city = 'Buffalo'
    ORDER BY o.order_date DESC;

    -- simdi product.producta gidebiliriz

    SELECT DISTINCT p.product_name
        FROM product.product p, sale.order_item oi 
        WHERE p.product_id = oi.product_id
                AND oi.order_id IN  
                    (SELECT TOP 10 o.order_id
                    FROM sale.customer c 
                    JOIN sale.orders o 
                    ON c.customer_id = o.customer_id
                    WHERE c.city = 'Buffalo'
                    ORDER BY o.order_date DESC)


/*
Correlated Subqueries

If a subquery references columns in the outer query, or if a subquery uses values from the outer query, 
that subquery is called a correlated subquery. 

In a correlated subquery, each row in the subquery is executed once for every row of the outer query. 
So, it is also known as a repeating subquery.

💡Tips: The main difference between a SQL correlated subquery and a simple subquery is that a SQL correlated subquery 
references columns from the table of the outer query.*/

-- list employees who work in the departments that have average salaries higher than 80000.

SELECT id, name, graduation, seniority
FROM dbo.department AS A
WHERE dept_name IN 
            (
             SELECT dept_name
             FROM  dbo.department AS B
             WHERE A.id= B.id
             GROUP BY dept_name
             HAVING AVG(salary) > 80000
             )

---

SELECT product_id, product_name, category_id, list_price, (SELECT avg(list_price) from product.product)
-- bunların bir de avg priceını gorup karsilasitrmak istesek ancak ya group by a subquery
FROM product.product

-- ama bu tum Plar ortalaması, category bazında P ortalaması nasıl alacagız. pythondaki for loop isini burada corr subquery yapacak

SELECT product_id, product_name, p.category_id, 
        list_price, (SELECT avg(list_price) from product.product WHERE category_id = p.category_id)
FROM product.product p 

-- kendi kategorsinde list price yuksek olanlar gelmesin ortalmadan

SELECT product_id, product_name, p.category_id, 
        list_price--, (SELECT avg(list_price) from product.product WHERE category_id = p.category_id)
FROM product.product p 
WHERE list_price < (SELECT avg(list_price) from product.product WHERE category_id = p.category_id)

/* QUESTION: Find the employees in each department who earn more than the average salary in that department. */
-- this question is from another table in the master database
SELECT *
    FROM dbo.EMPLOYEE e1
    WHERE SALARY >
            (
            SELECT AVG(SALARY)
            FROM dbo.EMPLOYEE e2
            WHERE e1.DEPT_NAME = e2.DEPT_NAME
            );

-- Since it requires too much performance it's better to use alternative ways such as self join instead of coor sq
-- solution with self join
SELECT e1.emp_name, e1.dept_name, e1.salary
FROM employee e1
JOIN (
    SELECT dept_name, AVG(salary) AS avg_salary
    FROM employee
    GROUP BY dept_name
) e2
ON e1.dept_name = e2.dept_name AND e1.salary > e2.avg_salary;



/*
Exists and Not Exists Operators

EXISTS
The EXISTS operator is used to restrict the number of rows returned by the SELECT statement. If the subquery returns 
one or more row, the EXISTS operator returns true. Otherwise, the EXISTS operator returns false or NULL.
Even if the subquery returns a null row, the EXISTS operator treats it as a record and accepts the result as true.

The advantage of using the EXISTS and NOT EXISTS operators is that the inner subquery execution can be stopped as 
long as a matching record is found.

If the subquery requires to scan a large volume of records, stopping the subquery execution as soon as a single 
record is matched can greatly speed up the overall query response time. syntax:
SELECT column_name
FROM table_1
WHERE EXISTS (subquery);
*/
-- list employees who work in the departments that have average salaries higher than 80000.
SELECT id, name, graduation, seniority
FROM dbo.department AS A
WHERE EXISTS
            (
             SELECT 1
             FROM  dbo.department AS B
             WHERE A.id= B.id
             GROUP BY dept_name
             HAVING AVG(salary) > 80000
             );
-- In the inner query, it finds the departments that have average salaries higher than 8000.  If there are one or more 
-- departments that comply with this rule, employees who work in these departments are matched up with 
-- departments table (A) in the outer query. As a result, information about these employees is listed.

-- For the correlated subqueries using EXISTS or NOT EXISTS, no matter what returns from the subquery, 
-- the important thing is matched values, not the columns called in the select statement.

-- NOT EXISTS

-- Contrary to the above example, when we want to get employees who are not in the result of the inner query, 
-- we can use NOT EXISTS, which negates the logic of the EXISTS operator.

SELECT id, name, graduation, seniority 
FROM dbo.department AS A
WHERE NOT EXISTS 
            (
             SELECT 1
             FROM  dbo.department AS B
             WHERE A.id= B.id
             GROUP BY dept_name
             HAVING AVG(salary) > 80000
             );

-- Tips:
-- The NOT EXISTS operator returns true if the underlying subquery returns no record. However, if a single record is 
-- matched by the inner subquery, the NOT EXISTS operator will return false, and the subquery execution can be stopped.

--- Write a query that rerurns a list of states where 'Apple - Pre-Owned iPad3 - 32GB - White' product has not been ordered

-- ilk önce ürünü bulalaım. siparisleri order itemden eslestirelim. sonra sehir bilgileri customerda, oraya da sale.orders
-- üzerinden gidecegiz. 

SELECT *
FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c 
WHERE p.product_id = oi.product_id
    AND oi.order_id = o.order_id 
    AND o.customer_id = c.customer_id
    -- 4 tablo da birlesti, corr ve exists oncesi ihtiyacımız olan fieldlar ve istedigimiz ürünle ilgili son filtrelemeyi yapalım:

SELECT p.product_name, oi.order_id, c.state
FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c 
WHERE p.product_id = oi.product_id
    AND oi.order_id = o.order_id 
    AND o.customer_id = c.customer_id  
    AND p.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White'

    -- yukarısı siparis verilen stateler. sadece statelere bakip siparis verilmedigi stateleri bulalim corr subquery ile

SELECT distinct state 
FROM sale.customer x -- en altta state ile bagdastirmak icin x alias
    WHERE NOT EXISTS (
            SELECT p.product_name, oi.order_id, c.state
            FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c 
            WHERE p.product_id = oi.product_id
                 AND oi.order_id = o.order_id 
                AND o.customer_id = c.customer_id  
                AND p.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White'
                -- corr sq state uzerinden yapacagiz
                AND c.state = x.state)

-- ic selecte 1 de yazmak yeter

SELECT distinct state 
FROM sale.customer x -- en altta state ile bagdastirmak icin x alias
    WHERE NOT EXISTS (
            SELECT 1
            FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c 
            WHERE p.product_id = oi.product_id
                 AND oi.order_id = o.order_id 
                AND o.customer_id = c.customer_id  
                AND p.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White'
                -- corr sq state uzerinden yapacagiz
                AND c.state = x.state)
-- ya da WHERE state NOT IN () diyerek de yapabilirdik
SELECT DISTINCT state
FROM sale.customer x
WHERE state NOT IN (
    SELECT C.[state] -- bir sey dondurmesi yeterli 1 de yazilabilir
    FROM product.product P, sale.order_item OI, sale.orders O, sale.customer C
    WHERE p.product_id = OI.product_id
    AND OI.order_id = O.order_id -- join filtresi
    AND O.customer_id = C.customer_id -- join filtresi
    AND P.product_name LIKE 'Apple - Pre-Owned iPad 3 - 32GB - White')


-- QUESTION: Write a query that returns stock information of the products in Davi techno Retail store. 
-- The BFLO Store hasn't  got any stock of that products.

SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
EXCEPT
SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'The BFLO Store'
AND		a.quantity>0

--- NOT EXISTS solution

SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		NOT EXISTS (
						SELECT	1
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity>0
						AND		A.product_id = X.product_id
						)

--- NOT IN solution
SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		A.product_id NOT IN (
						SELECT	product_id
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity>0
						)




-- CTE solution
WITH CTE as
(
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'Davi techno Retail'
), CTE2 AS (
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'The BFLO Store'
)
SELECT *
FROM CTE cte
WHERE product_id NOT IN (SELECT product_id FROM CTE2 WHERE quantity > 0)

-- QUESTION: Write a query that returns the net amount of their first order for customers who placed their first order after 2019-10-01.

WITH T1 AS (
	SELECT	customer_id, MIN (order_id) min_orders
	FROM	sale.orders
	GROUP BY
			customer_id
)
SELECT	A.customer_id, A.order_id, SUM(quantity* list_price* (1-discount)) net_amount
FROM	sale.orders A 
		INNER JOIN
		sale.order_item B
		ON	A.order_id = B.order_id
		INNER JOIN
		T1 ON A.order_id = T1.min_orders
WHERE
		A.order_date > '2019-10-01'
GROUP BY
		A.customer_id, A.order_id


--- -- QUESTION: Write a query that returns the count of the orders day by day in a pivot table format that has been shipped two days later.

SELECT	order_id, DATENAME(WEEKDAY, order_date) weekofday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2


SELECT	 SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Monday' THEN 1 ELSE 0 END) Monday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Tuesday' THEN 1 ELSE 0 END) Tuesday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Wednesday' THEN 1 ELSE 0 END) Wednesday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Thursday' THEN 1 ELSE 0 END) Thursday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Friday' THEN 1 ELSE 0 END) Friday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Saturday' THEN 1 ELSE 0 END) Saturday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Sunday' THEN 1 ELSE 0 END) Sunday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2

/*
COMMON TABLE EXPRESSIONS (CTEs)

Common Table Expression (CTE) is a temporary result set that you can reference or use within another SELECT, INSERT, 
DELETE, or UPDATE statements. It is a query you can define within another SQL query. 
So, other queries can use CTE like a table. CTE provides us to write auxiliary statements for using in a larger query. 

CTE exists only for the duration of a single SQL statement. It is similar to views. 
In this manner, they are "statement scoped views" and not stored in the database schema. They are only valid in 
the query in which created. It's like a subquery. It generates a result that contains rows and columns of data.

There are two types of CTEs:

1.Ordinary
2. Recursive

CTEs are created by adding a WITH clause in front of SELECT, INSERT, DELETE or UPDATE statements. WITH clause is also known as CTEs.

-- All CTEs (ordinary and recursive) start with a WITH clause in front of a SELECT, INSERT, DELETE, or UPDATE statement. 
-- There may be one or more CTEs in a single WITH clause. Syntax of an ordinary common table expression:

WITH query_name [(column_name1, ...)] AS
    (SELECT ...) -- CTE Definition
SELECT * FROM query_name; -- SQL_Statement

1. First, WITH keyword is followed by the query_name which you can refer later in a query.
2. Next, specify a list of comma-separated columns after the query_name. The number of columns must be the same 
as the number of columns defined in the CTE_definition. This part is optional.
3. Then use the AS keyword after query_name or column list (if the column list is specified).
4. After AS keyword, define CTE with SELECT statement. We need to include parentheses in CTE definition. 
This will populate a result set. Finally, refer to the common table expression in a query (SQL_statement) 
using SELECT, INSERT, DELETE or UPDATE statements.*/


SELECT *
FROM product.brand, product.category  -- bu cross join yapar, altina where yazarak onu filtreleriz

-- List customers who are residents of the city of Austin and have an order prior to the last order date of a customer named Jerald Berray and 

-- jerald berrayin son siparis verdigi tarihi bulalım
    SELECT MAX(order_date) as last_order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.first_name = 'Jerald' AND c.last_name = 'Berray'
-- bunnu cte'ye alirken mutlaka bir isim vermemzi gerekyor. bu nednele as last order date
-- CTE

WITH t1 AS
( SELECT MAX(order_date) as last_order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.first_name = 'Jerald' AND c.last_name = 'Berray')

-- siparis tarihi karsilastirmasi icin ayrı bir tablo yapalım: tum musterilerin siparis tarihleri ve sehirleri
SELECT a.customer_id, a.first_name, a.last_name, a.city, b.order_date
-- bunu da where ile join yapalım
FROM sale.customer a, sale.orders b 
WHERE a.customer_id = b.customer_id

-- siparis tarihleri jeraldden once olanları ve austin de yasayanlar bulalım
WITH t1 AS
( SELECT MAX(order_date) as last_order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id
    WHERE c.first_name = 'Jerald' AND c.last_name = 'Berray')
SELECT a.customer_id, a.first_name, a.last_name, a.city, b.order_date
FROM sale.customer a, sale.orders b, t1 
WHERE a.customer_id = b.customer_id
AND b.order_date < t1.last_order_date
AND a.city = 'Austin'


-- list all customers their orders are on the same dates with Laurel Goldammer. display first and last name order date

WITH cte AS
(
    SELECT o.order_date
    FROM sale.customer c 
    JOIN sale.orders o 
    ON c.customer_id = o.customer_id 
    WHERE c.first_name = 'Laurel' AND c.last_name = 'Goldammer'
)
SELECT a.first_name, a.last_name, b.order_date
 FROM sale.customer a, sale.orders b, cte
WHERE a.customer_id = b.customer_id
    AND b.order_date = cte.order_date    

-- list the stores whose turnovers are under the average store turnovers in 2018

WITH trn_1 AS
(
 SELECT s.store_name, SUM(list_price*quantity*(1-discount)) as turnover
 FROM sale.order_item oi, sale.orders o, sale.store s 
 WHERE oi.order_id = o.order_id  
        AND o.store_id = s.store_id
    GROUP BY s.store_name
 -- store name sale.store tableda 
), 
trn_2 AS -- avg alabilmek icin 2. bir cte daha almamız gerekyor
    (SELECT avg(turnover) as avg_trn
    FROM trn_1)
SELECT *
FROM trn_1, trn_2
WHERE trn_1.turnover < trn_2.avg_trn

-- example:find the employees' salary which is higher than the average. 
-- (we previously used a subquery to solve this problem. This time we'll solve this problem using a CTE.)

WITH temp_table (avg_salary) AS 
    (
        SELECT AVG(salary)
        FROM dbo.department
    )
    SELECT name, salary 
    FROM dbo.department d 
    JOIN temp_table t 
    ON d.salary > t.avg_salary;

-- same question with subquery:
SELECT name, salary 
FROM dbo.department
WHERE salary > (SELECT AVG(salary) FROM dbo.department)  


-- ustteki select sorgusu bir cevap dondurur, orn avg.salary, sonra hemen altinda asil query'ye geceriz ve condition olarak bu 
-- donen ilk cevabı karsilastirma icin kullanrızı

-- RECURSIVE COMMON EXPRESSION TABLEs

-- A recursive common table expression (CTE) is a CTE that references itself. By doing so, the CTE repeatedly executes, 
-- returns subsets of data, until it returns the complete result set. 
-- A recursive CTE is useful in querying hierarchical data such as organization charts where 
-- one employee reports to a manager or multi-level bill of materials when a product consists of many components, 
-- and each component itself also consists of many other components. The following shows the syntax of a recursive CTE:

WITH expression_name (column_list)
AS
(
    -- Anchor member
    initial_query  
    UNION ALL
    -- Recursive member that references expression_name.
    recursive_query  
)
-- references expression name
SELECT *
FROM   expression_name

/* In general, a recursive CTE has three parts:

1. An initial query that returns the base result set of the CTE. The initial query is called an anchor member.
2. A recursive query that references the common table expression, therefore, it is called the recursive member. 
The recursive member is union-ed with the anchor member using the UNION ALL operator.
3. A termination condition specified in the recursive member that terminates the execution of the recursive member.

-- A recursive common table expression has the same basic syntax as an ordinary common table expression, 
but with the following additional features:
1. The SELECT statement must be a compound select where the right-most compound-operator is either UNION or UNION ALL.
2.The table named on the left-hand side of the AS keyword must appear exactly once in the FROM clause of 
the right-most SELECT statement of the compound select, and nowhere else.
3. The right-most SELECT of the compound select must not make use of aggregate or window functions.

WITH table_name (column_list)
AS
(
    -- Anchor member
    initial_query  
    UNION ALL
    -- Recursive member that references table_name.
    recursive_query  
)
-- references table_name
SELECT *
FROM table_name

The execution order of a recursive CTE is as follows:

1. First, execute the anchor member to form the base result set (R0), use this result for the next iteration.
2. Second, execute the recursive member with the input result set from the previous iteration (Ri-1) and 
return a sub-result set (Ri) until the termination condition is met.
3. Third, combine all result sets R0, R1, … Rn using UNION ALL operator to produce the final result set.*/

-- return the integers from 1 to 10

WITH cte
    AS (SELECT 1 AS n -- anchor member
        UNION ALL
        SELECT n + 1 -- recursive member
        FROM   cte
        WHERE  n < 10) -- terminator
SELECT n
FROM cte;

-- week days from monday to saturday
WITH cte_numbers(n, weekday) 
AS (
    SELECT 0, 
    DATENAME(DW, 0)
    UNION ALL
    SELECT n + 1, 
    DATENAME(DW, n + 1)
    FROM cte_numbers
    WHERE n < 6
)
SELECT weekday
FROM cte_numbers;

/*
CTE vs. Subquery

Common Table Expressions and Subqueries are mostly used for the same purpose. But the main advantage of the Common 
Table Expression (when not using it for recursive queries) is encapsulation, instead of having to declare the sub-query 
each time you wish to use it, you are able to define it once, but have multiple references to it.

Also CTEs are more common in practice, as they tend to be cleaner for someone (who didn't write the query) to 
follow the logic. In this context, we can say that CTEs are more readable. 

The performance of CTEs and subqueries should, in theory, be the same since both provide the same information to 
the query optimizer. One difference is that a CTE used more than once could be easily identified and calculated once.  
The results could then be stored and read multiple times.
*/

-- Let's compare two different queries with the same result, one with Common Table Expression and the other with Subquery:

-- CTE

WITH t1 AS 
(
SELECT *
FROM dbo.department
WHERE dept_name = 'Computer Science'
),
t2 as
(
SELECT *
FROM dbo.department
WHERE dept_name = 'Physics'
)
SELECT d.name, t1.graduation AS graduation_CS, t2.graduation AS graduation_PHY
FROM dbo.department as d
LEFT JOIN t1
ON d.id = t1.id
LEFT JOIN t2
ON d.id = t2.id
WHERE t1.graduation IS NOT NULL 
OR    t2.graduation IS NOT NULL
ORDER BY 2 DESC, 3 DESC;

-- SUBQUERY
SELECT d.name, t1.graduation AS graduation_CS, t2.graduation AS graduation_PHY
FROM dbo.department as d
LEFT JOIN 
(
SELECT *
FROM dbo.department
WHERE dept_name = 'Computer Science'
) AS t1
ON d.id = t1.id
LEFT JOIN
(
SELECT *
FROM dbo.department
WHERE dept_name = 'Physics'
) AS t2
ON d.id = t2.id
WHERE t1.graduation IS NOT NULL 
OR    t2.graduation IS NOT NULL
ORDER BY 2 DESC, 3 DESC

/*
In the CTE query, the compiler knows you’re querying the same data set since it has saved it (albeit temporarily) 
as temp_table. In the second query, even though the SQL is the exact same, the compiler does not realize they’re the 
same query until it runs them. Notice that we have to call the same query by the two distinct aliases: t1 and t2. 
Not only does this query take more compute and contain redundancy, it also forces us to call the same query two 
different names. This is misleading.

As an advice would be to only use subqueries in Adhoc queries when you need results quickly. If the query is going 
to be read by others, run every day, or reused, try to use a CTE for readability and performance.
*/

-- QUESTION: Write a query that returns the net amount of their first order for 
-- customers who placed their first order after 2019-10-01.